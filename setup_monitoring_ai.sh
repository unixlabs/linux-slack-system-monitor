
#!/bin/bash

# -------------------- CONFIG --------------------
INSTALL_DIR="/opt/system-monitor"
SYSTEMD_DIR="/etc/systemd/system"
CONFIG_FILE="$INSTALL_DIR/monitor_config.env"

read -p "Enter your Slack Webhook URL: " SLACK_WEBHOOK_URL
read -p "Enter Slack user/tag to mention (e.g. @Tony): " SLACK_TAG

# ------------------ NETWORK IFACE ----------------
DEFAULT_IFACE=$(ip route | grep default | awk '{print $5}')
if [[ -z "$DEFAULT_IFACE" ]]; then
    echo "❌ Could not detect network interface. Exiting."
    exit 1
fi
echo "✅ Using network interface: $DEFAULT_IFACE"

# ------------------ CREATE FILES ------------------
mkdir -p "$INSTALL_DIR"

# Secure config
cat > "$CONFIG_FILE" <<EOF
SLACK_WEBHOOK_URL="$SLACK_WEBHOOK_URL"
SLACK_TAG="$SLACK_TAG"
NET_IFACE="$DEFAULT_IFACE"
HOSTNAME="$(hostname)"
EOF
chmod 600 "$CONFIG_FILE"

# ------------ RAM Monitor + Optimizer ------------
cat > "$INSTALL_DIR/ram_monitor.sh" <<'EOF'
#!/bin/bash
source /opt/system-monitor/monitor_config.env
while true; do
    usage=$(free | awk '/Mem:/ { printf("%.0f", $3/$2 * 100) }')
    if [ "$usage" -ge 90 ]; then
        sync; echo 3 > /proc/sys/vm/drop_caches
        curl -s -X POST -H 'Content-type: application/json'         --data "{"text":"🔹 [${HOSTNAME}] High RAM usage detected: ${usage}% — Auto-cleared system cache. ${SLACK_TAG}"}"         "$SLACK_WEBHOOK_URL"
    fi
    sleep 60
done
EOF

# ------------ CPU Monitor + Optimizer ------------
cat > "$INSTALL_DIR/cpu_monitor.sh" <<'EOF'
#!/bin/bash
source /opt/system-monitor/monitor_config.env
while true; do
    usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    usage_int=${usage%.*}
    if [ "$usage_int" -ge 90 ]; then
        pid=$(ps -eo pid,pcpu,comm,user --sort=-pcpu | awk '$4 != "root" && NR==2 {print $1}')
        proc=$(ps -p $pid -o comm=)
        if [ -n "$pid" ]; then
            kill -9 $pid
            curl -s -X POST -H 'Content-type: application/json'             --data "{"text":"🔹 [${HOSTNAME}] High CPU usage: ${usage_int}% — Killed process '$proc' (PID $pid). ${SLACK_TAG}"}"             "$SLACK_WEBHOOK_URL"
        fi
    fi
    sleep 60
done
EOF

# ------------ Network Monitor ------------
cat > "$INSTALL_DIR/net_monitor.sh" <<'EOF'
#!/bin/bash
source /opt/system-monitor/monitor_config.env
IFACE="$NET_IFACE"
while true; do
    rx1=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
    tx1=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
    sleep 60
    rx2=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
    tx2=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
    rx_rate=$(( (rx2 - rx1) / 1024 / 1024 ))
    tx_rate=$(( (tx2 - tx1) / 1024 / 1024 ))
    total=$((rx_rate + tx_rate))
    if [ "$total" -ge 100 ]; then
        curl -s -X POST -H 'Content-type: application/json'         --data "{"text":"🔹 [${HOSTNAME}] High Network Usage: ${total}MB/min on $IFACE ${SLACK_TAG}"}"         "$SLACK_WEBHOOK_URL"
    fi
done
EOF

# ------------ Login Alert ------------
cat > "$INSTALL_DIR/login_alert.sh" <<'EOF'
#!/bin/bash
source /opt/system-monitor/monitor_config.env
journalctl -f -u ssh.service | while read line; do
    if echo "$line" | grep -q "Accepted"; then
        user=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if ($i=="for") print $(i+1)}')
        if [ "$user" != "root" ]; then
            curl -s -X POST -H 'Content-type: application/json'             --data "{"text":"🔹 [${HOSTNAME}] Login detected for user *$user* ${SLACK_TAG}"}"             "$SLACK_WEBHOOK_URL"
        fi
    fi
done
EOF

chmod +x "$INSTALL_DIR"/*.sh

# ----------- SYSTEMD SERVICE GENERATOR -----------
create_service() {
    name=$1
    desc=$2
    script="$INSTALL_DIR/${name}.sh"

    cat > "$SYSTEMD_DIR/${name}.service" <<EOF
[Unit]
Description=$desc
After=network.target

[Service]
ExecStart=$script
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now "${name}.service"
}

create_service ram_monitor "RAM Usage Monitor with Auto-Optimizer"
create_service cpu_monitor "CPU Usage Monitor with Auto-Optimizer"
create_service net_monitor "Network Traffic Monitor"
create_service login_alert "Login Alert Monitor"

# ------------------- DONE -------------------
echo "✅ AI-powered monitoring installed and running!"
systemctl status ram_monitor.service cpu_monitor.service net_monitor.service login_alert.service --no-pager

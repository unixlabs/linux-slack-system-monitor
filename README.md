
# 🛡️ Linux Slack System Monitor

A lightweight system monitoring tool for Linux that alerts you via **Slack** on:

- 🔥 High RAM, CPU, or Network usage
- 🧑‍💻 New user login events (non-root)
- 🧩 Built with Bash, runs as systemd services
- ⚡ One-click install script (`setup_monitoring.sh`)

---

## 🚀 Features

| Feature               | Description                                        |
|------------------------|----------------------------------------------------|
| ✅ RAM Monitoring       | Alerts if RAM usage exceeds 90%                   |
| ✅ CPU Monitoring       | Alerts if CPU usage exceeds 90%                   |
| ✅ Network Monitoring   | Alerts if network traffic exceeds 100MB/min       |
| ✅ Login Alerts         | Detects and alerts on new login sessions          |
| ✅ Slack Integration    | Sends real-time alerts to any Slack channel       |
| ✅ Mentions             | Tags a user (e.g. `@adil`) in each alert          |
| ✅ systemd Services     | Automatically runs on boot and restarts on fail   |
| ✅ Secure Configs       | Webhook and tags stored in permission-protected files |

---

## 📥 Installation

### ✅ Step 1: Download & Run the Installer

Clone the repo or download the ZIP:

```bash
wget https://raw.githubusercontent.com/unixlabs/linux-slack-system-monitor/refs/heads/main/setup_monitoring.sh
chmod +x setup_monitoring.sh
sudo ./setup_monitoring.sh
```

You will be prompted to enter:

- 🔗 **Slack Webhook URL**
- 💬 **Slack mention tag** (e.g. `@adil`)

---

## 🧠 Slack Setup Guide (Step-by-Step)

### ✅ Step 1: Create a Slack App

1. Go to https://api.slack.com/apps  
2. Click **"Create New App"**  
3. Select **From Scratch**  
4. Name it (e.g., `SystemMonitorBot`)  
5. Choose your Slack workspace  
6. Click **Create App**

---

### ✅ Step 2: Enable Incoming Webhooks

1. In the left menu, click **"Incoming Webhooks"**  
2. Switch **Activate Incoming Webhooks** to **ON**  
3. Scroll down → click **"Add New Webhook to Workspace"**  
4. Choose a channel like `#sys-alerts` or `#devops`  
5. Click **Allow**  
6. Slack will now show you a Webhook URL, like:

```
https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
```

📋 Copy this URL — paste it when prompted by the installer.

---

### ✅ Step 3: Invite Your App to the Channel

Make sure the bot is in your channel:

```bash
/invite @SystemMonitorBot
```

---

### ✅ Step 4: Enable Mentions

To get notified via `@mention`, enter:

- Your Slack display name (e.g., `@adil`)  
- Or use `<!here>` or `<!channel>` to alert everyone  

---

## 🔍 File Structure

```bash
/opt/system-monitor/
├── monitor_system.sh        # Monitors RAM, CPU, Network
├── login_alert.sh           # Detects user logins
├── slack_webhook.conf       # Stores your Slack webhook
├── slack_mention.conf       # Stores your Slack mention tag
```

---

## 🧪 Testing

### ✅ Test RAM/CPU/Network Monitor

```bash
sudo /opt/system-monitor/monitor_system.sh
```

You should receive a Slack alert if usage exceeds thresholds.

### ✅ Test Login Alert

SSH into the machine as a non-root user from another terminal:

```bash
ssh someuser@your-server
```

Slack should notify you that `someuser` logged in.

---

## 🧰 Manage Services

### Monitor System Service

```bash
# Start/stop/status
sudo systemctl start monitor-system.service
sudo systemctl stop monitor-system.service
sudo systemctl status monitor-system.service
```

### Login Alert Service

```bash
sudo systemctl start login-alert.service
sudo systemctl stop login-alert.service
sudo systemctl status login-alert.service
```

### Enable Autostart on Boot

```bash
sudo systemctl enable monitor-system.service
sudo systemctl enable login-alert.service
```

---

## 📄 Logs

- System monitor logs: `/var/log/monitor_system.log`
- Login alerts log: `/var/log/login_alert.log`

Or view live logs:

```bash
journalctl -u monitor-system.service -f
journalctl -u login-alert.service -f
```

---

## 🧼 Uninstallation

To remove everything:

```bash
# Stop and disable services
sudo systemctl stop monitor-system.service login-alert.service
sudo systemctl disable monitor-system.service login-alert.service

# Remove service files
sudo rm /etc/systemd/system/monitor-system.service
sudo rm /etc/systemd/system/login-alert.service
sudo systemctl daemon-reload

# Remove app files
sudo rm -rf /opt/system-monitor
sudo rm -f /var/log/monitor_system.log /var/log/login_alert.log
```

---

## 💬 FAQ

### 🔹 Can I use this on Ubuntu?
Yes! The script auto-detects `/var/log/auth.log` (Ubuntu) and `/var/log/secure` (CentOS).

### 🔹 Will this work if I reboot?
Yes — both services are systemd-enabled and auto-start on boot.

### 🔹 Can I change the thresholds?
Yes. Edit `/opt/system-monitor/monitor_system.sh` and adjust:

```bash
RAM_THRESHOLD=90
CPU_THRESHOLD=90
NET_THRESHOLD_MB=100
```

---

## 📝 License

MIT License — free to use, modify, and distribute.

---

## ✨ Credits

Built by "@unixlabs Adil Hussain" for sysadmins, SREs, and devs who need fast, no-dependency alerts from their servers.

Need advanced monitoring? Ask about Prometheus + Grafana + Slack AlertManager integrations! conteact at Fiverr @openlinux

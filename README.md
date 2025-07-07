
# Linux Slack System Monitor

A lightweight system monitoring tool for Linux that alerts you via Slack on:

- High RAM, CPU, or Network usage
- New user login events (non-root)
- Built with Bash, runs as systemd services
- One-click install script (`setup_monitoring.sh`)

---

## Features

| Feature               | Description                                        |
|------------------------|----------------------------------------------------|
| RAM Monitoring         | Alerts if RAM usage exceeds 90%                   |
| CPU Monitoring         | Alerts if CPU usage exceeds 90%                   |
| Network Monitoring     | Alerts if network traffic exceeds 100MB/min       |
| Login Alerts           | Detects and alerts on new login sessions          |
| Slack Integration      | Sends real-time alerts to any Slack channel       |
| Mentions               | Tags a user (e.g. `@adil`) in each alert          |
| systemd Services       | Automatically runs on boot and restarts on fail   |
| Secure Configs         | Webhook and tags stored in permission-protected files |

---

## Installation

### Step 1: Download & Run the Installer

Clone the repo or download the script:

```bash
wget https://raw.githubusercontent.com/unixlabs/linux-slack-system-monitor/main/setup_monitoring.sh
chmod +x setup_monitoring.sh
sudo ./setup_monitoring.sh
```

You will be prompted to enter:

- Slack Webhook URL
- Slack mention tag (e.g. `@adil`)

The script will automatically:

- Detect your default network interface (e.g. `eth0`, `ens18`)
- Install monitoring scripts to `/opt/system-monitor/`
- Set up and start systemd services

---

## Slack Setup Guide

🔹 **Step 1: Create a Slack App**
1. Go to https://api.slack.com/apps  
2. Click "Create New App"  
3. Select "From Scratch"  
4. Name it (e.g., `SystemMonitorBot`)  
5. Choose your Slack workspace  
6. Click "Create App"

🔹 **Step 2: Enable Incoming Webhooks**
1. In the left menu, click "Incoming Webhooks"  
2. Turn ON "Activate Incoming Webhooks"  
3. Scroll down and click "Add New Webhook to Workspace"  
4. Choose a channel (e.g. `#sys-alerts`) and click Allow  
5. Copy the generated Webhook URL

🔹 **Step 3: Invite Your App to the Channel**
```bash
/invite @SystemMonitorBot
```

🔹 **Step 4: Enable Mentions**
Use a Slack tag (e.g. `@adil`, `<!here>`, or `<!channel>`) when prompted during setup.

---

## File Structure

```bash
/opt/system-monitor/
├── ram_monitor.sh
├── cpu_monitor.sh
├── net_monitor.sh
├── login_alert.sh
├── monitor_config.env
/etc/systemd/system/
├── ram_monitor.service
├── cpu_monitor.service
├── net_monitor.service
├── login_alert.service
```

---

## Testing

🔹 **Test Slack Alert**

```bash
source /opt/system-monitor/monitor_config.env
curl -X POST -H 'Content-type: application/json' --data "{"text":"Test Slack Alert from System Monitor ${SLACK_TAG}"}" "$SLACK_WEBHOOK_URL"
```

🔹 **Test Login Alert**

```bash
ssh user@your-server
```

You should see a Slack alert for that login.

---

## Manage Services

```bash
sudo systemctl start ram_monitor.service
sudo systemctl status ram_monitor.service
sudo systemctl enable ram_monitor.service
```

Check live logs:

```bash
journalctl -u ram_monitor.service -f
```

---

## Uninstallation

```bash
sudo systemctl stop ram_monitor.service cpu_monitor.service net_monitor.service login_alert.service
sudo systemctl disable ram_monitor.service cpu_monitor.service net_monitor.service login_alert.service
sudo rm /etc/systemd/system/{ram,cpu,net,login}_monitor.service
sudo systemctl daemon-reload
sudo rm -rf /opt/system-monitor
```

---

## FAQ

🔹 **Can I use this on Ubuntu?**  
Yes, it works on most Linux distros.

🔹 **Will this work after reboot?**  
Yes. systemd services auto-start on boot.

🔹 **Can I change the thresholds?**  
Yes. Edit the monitoring scripts in `/opt/system-monitor/` and adjust the values.

---

## License

MIT License — free to use, modify, and distribute.

---

## Credits

Built and maintained by [@unixlabs Adil Hussain](https://github.com/unixlabs) — for sysadmins, DevOps engineers, and SREs who need **fast, reliable, and no-dependency Slack alerts** from their Linux servers.

Need advanced infrastructure monitoring?
🔹 Prometheus
🔹 Grafana dashboards
🔹 Slack AlertManager integration
🔹 Kubernetes observability
🔹 Production-grade alerting systems

➡️ Contact on **Fiverr**: [@openlinux](https://www.fiverr.com/openlinux)


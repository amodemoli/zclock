## The Zima Clock Fixer

zima clock fixer maded by _demolition_ in zima development <br>
this skript maded for update automatic time/date. this script coded for linux. only linux!<br>
if your system cannot update automatic time/date you need to this script <br>
this script connects to [google.com](https://google.com) & cloud flare & amazon for get lastles time/date. you can edit websites/limits/timeout's in `linux.sh`.

[»] **Install For Linux**:

### 1) Download `conf_service.sh` and `linux.sh` file from repositoreie.

### 2) Make Scripts Executable

Ensure both the core synchronizer and the service installer have execution permissions:

```bash
sudo +x linux.sh conf_service.sh
```

### 3) Run the Automated installer

Execute the configuration script with root privileges to install the binaries and register the systemd service:

```bash
sudo ./conf_service.sh
```

## Post_installation & Management

### Setting Your Timezone

To ensure the synchronized universal time maps correctly to your local region, set your timezone using timedatectl. For example, to set it to Tehran time:

```bash
sudo timedatectl set-timezone Asia/Tehran
```

### Managing the Service

The daemon runs under systemd as zima_clock.service (or the specific service name registered by your installer). Use the following standard systemctl commands to manage it:

- ### Check Service Status:

```bash
sudo systemctl status zima_clock.service
```

- ### Restart the Synchronizer:

```bash
sudo systemctl restart zima_clock.service
```

- ### Stop the Service:

```bash
sudo systemctl stop zima_clock.service
```

- ### View Live Logs:

```bash
journalctl -u zima_clock.service -f
```

## License

This project is open-source and distributed under the terms of the MIT License. See the `LICENSE` file for more details.

> Discord: @ir.de <br>
> Website: [demolition.ir](http://demolition.ir) <br>
> Telegram: [@amodemoli](https://t.me/amodemoli) <br>
> Bale(Irainian Messager): @demolition <br>

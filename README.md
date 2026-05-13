## The Zima Clock Fixer
zima clock fixer maded by _demolition_ in zima development <br>
this skript maded for update automatic time/date. this script coded for linux. only linux!<br>
if your system cannot update automatic time/date you need to this script <br>
this script connects to [google.com](https://google.com) & cloud flare & amazon for get lastles time/date.  you can edit websites/limits/timeout's in ``linux.sh``. 

[»] **Install For Linux**:
1) Download ``linux.sh`` and ``linux.service`` file from repositoreie.
2) run this command on terminal and paste ``linux.sh`` contents.
```bash
sudo nano /usr/local/bin/zima_clock.sh
```
3) push Ctrl + X key -> type Y. and prees ENTER (for save zima_clock.sh new content)
4) run this command on terminal:
```bash
sudo chmod +x /usr/local/bin/zima_clock.sh
```
5) and run this command for add .service file:
```bash
sudo nano /etc/systemd/system/zima_clock.service
```
6) paste ``linux.service`` file contents
7) push Ctrl + X key -> type Y. and prees ENTER (for save zima_clock.service new content)
8) now, you need run this command:
```bash
sudo systemctl enable zima_clock.service
```
if enable not worked use:
```bash
sudo systemctl status zima_clock.service
```
9) now you can see service stats with this command:
```bash
sudo systemctl status zima_clock.service
```
10) run this command on terminal (and enter your timezone
```bash
sudo timedatectl set-timezone Asia/Tehran
```
11) done. now you can restart your system and connect to wifi or... (wait for update automatic your clock)

> Discord: @ir.de <br>
> Website: [demolition.ir](http://demolition.ir) <br>
> Telegram: [@amodemoli](https://t.me/amodemoli) <br>
> Bale(Irainian Messager): @demolition <br>

# DockerGC
DockerGC is a container that runs [Grasscutter](https://github.com/Melledy/Grasscutter) (*some anime game* server reimplementation) with just a single command.<br>
[![dockeri.co](https://dockeri.co/image/siakbary/dockergc)](https://hub.docker.com/r/siakbary/dockergc)
## How to create a server:
- Install [Docker](https://docs.docker.com/engine/install/) + [MongoDB](https://www.mongodb.com/try/download/community)
- Open Terminal and Enter:
```sh
# Network (just once)
docker network create gc
# Datebase (just once) (db:27017 change ip and port and delete this if you already have a database)
docker run --rm -it --network gc --name db -d mongo &
# Game server (just once download resources with -f 'yes' after that you can set -f 'no')
docker run --rm -it --network gc -v resources:/home/Grasscutter/resources -p 22102:22102/udp -p 443:443/tcp siakbary/dockergc:ubuntu-dev-5.7 -d 'mongodb://db:27017' -b 'localhost' -f 'yes'
```
or (if you have compose)
```sh
"docker compose up" or "docker-compose up"
```
- Then type "account create yourusername" if there is a new response open the game.
- Yay

## How to connect: (PC)
- Before starting, open game first and then logout if you have logged in before and then exit again.
- Install Fiddler then Open Fiddler then click Tools -> Options -> HTTPS -> Check "Capture Https" and "Decrypt Https" then click "Actions" then click "Trues Root" then click yes if a popup appears.
- In Fiddler in "FiddlerScript" tab, copy script from [directed.cs](directed.cs) then click save.
- Login with your username then password with random then login.

 ## How to connect: (Android Root) + (Fiddler PC for proxy)
- Open Fiddler then click Tools -> Options -> HTTPS -> Check "Capture Https" and "Decrypt Https".
- After you follow it, Go to Tools -> Options -> Connection -> Check "Allow remote computer to connect" and make sure the windows firewall is off and don't forget to change the port other than 8888 (change it like 8887) - [more info](https://www.telerik.com/blogs/how-to-capture-android-traffic-with-fiddler)
- In Fiddler in "FiddlerScript" tab, copy script from [directed.cs](directed.cs) then click save.
- On Phone (Android 7+), Install Magisk+MagiskTrustUserCerts - [more info](https://platinmods.com/threads/intercepting-https-traffic-from-apps-on-android-7-and-above-root.131373/)
- Change proxy on wifi settings with your server ip
- Login with your username then password with random then login.

## How to connect: (Android No-Root) (Termux)
- do backup first (apk & data game) because patching apk cannot be updated with game that is installed now.
- Install patched apk that accepts user ca certs, unfortunately you will have to uninstall regular and [install apk patched](https://file.yuuki.me/0:/Leak/uc-patched.apk) (If file is miss/not trusted you can do it yourself with [apk-mitm](https://github.com/shroudedcode/apk-mitm))
- Install Termux
- use these commands
```sh
apt update && apt full-upgrade
pkg install python wget rustc-dev nano
python3 -m ensurepip --upgrade
python3 -m pip install --user pipx
python3 -m pipx ensurepath
export CARGO_BUILD_TARGET=aarch64-linux-android
pipx install mitmproxy
```
- Now download proxy config: 
```sh
wget https://github.com/akbaryahya/Grasscutter/raw/Patch/proxy_config.py
wget https://github.com/akbaryahya/Grasscutter/raw/Patch/proxy.py
```
- Now run mitmproxy: 
```sh
mitmdump -s proxy.py -k --ssl-insecure --set block_global=false
```
- Then go to wifi settings and set proxy to 127.0.0.1 and 8080. Note that proxies are ignored if you are using a VPN.
- Open http://mitm.it/ in your browser, download certificate. Then go to settings and install it.
- Play Game


## Bro, I don't want to make a server, so can I just join to your server?
Yes, Simple way is to just change localhost in file in pastebin to address server you want to connect to.<br>
For server list please join:<br>
[![DockerGC](https://discordapp.com/api/guilds/964119462188040202/widget.png?style=banner2)](https://discord.gg/tRYMG7Nm2D)

## How to build this?
### Required
- [Java 17 JDK](https://adoptium.net/temurin/releases) 
- [Docker](https://docs.docker.com/engine/install/)
- [Gradle](https://gradle.org/install/)
- [MongoDB](https://www.mongodb.com/try/download/community)

Clone this with
```sh
git clone --recurse-submodules https://github.com/akbaryahya/DockerGC
cd DockerGC
cd gc
sh run.sh # local for jar only
sh run.sh local start # run localhost server for testing without docker
sh run.sh local clean_work # clean folder work directory
sh run.sh alpine start # run localhost server for testing with docker alpine
sh run.sh ubuntu start # run localhost server for testing with docker ubuntu
sh run.sh alpine build # Docker with alpine
sh run.sh ubuntu build # Docker with ubuntu
```
## HELP
| Func | Info |
| ------ | ------ |
| d | is ip address for your database server , note: use computer ip if you want to run on your own pc, no "localhost" because it is ip in container |
| b | ip public server |
| v | ip private server |
| m | Chat Welcome message |
| e | Email Welcome when registering for first time |
| f | re-download resources if you type "yes" this is useful if you already have a resources folder but there is latest update |
| l | Server Language and includes commands [more info](https://github.com/Grasscutters/Grasscutter/tree/development/src/main/resources/languages) |
| j | -Xms500M -Xmx8G [more info](https://www.baeldung.com/ops/docker-jvm-heap-size) |

## Port
| Port | Info |
| ------ | ------ |
| 80 | Web Server for HTTP. (Not required) |
| 443 | Web Server for HTTPS. (required) |
| 22102 | Game Communication (udp) (required) |

Power by [Grasscutter](https://github.com/Melledy/Grasscutter) ❤️
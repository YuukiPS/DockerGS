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
docker run --rm -it --network gc -v resources:/home/Grasscutter/resources -p 22102:22102/udp -p 443:443/tcp siakbary/dockergc:ubuntu-dev-6.3 -d 'mongodb://db:27017' -b 'localhost' -f 'yes'
```
or (if you have compose)
```sh
"docker compose up" or "docker-compose up"
```
- Then type "account create yourusername" if there is a new response open the game.
- Yay

## Bro, I don't want to make a server, so can I just join to your server?
Yes, Simple way is to just change localhost in file in [Grasscutter Proxy](https://gitlab.com/yukiz/grasscutter-proxy) to address server you want to connect to.<br>
For server list please join:<br>
[![DockerGC](https://discordapp.com/api/guilds/964119462188040202/widget.png?style=banner2)](https://discord.gg/tRYMG7Nm2D)

## How to build this?
### Required
- [Java 17 JDK](https://adoptium.net/temurin/releases) 
- [Docker](https://docs.docker.com/engine/install/)
- [Gradle](https://gradle.org/install/)
- [MongoDB](https://www.mongodb.com/try/download/community)
- [Lombok](https://stackoverflow.com/questions/67899014/vs-code-did-not-recognize-lombok)

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
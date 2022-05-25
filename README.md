# DockerGC
DockerGC is a container that runs [Grasscutter](https://github.com/Melledy/Grasscutter) (*some anime game* server reimplementation) with just a single command.<br>
[![dockeri.co](https://dockeri.co/image/siakbary/dockergc)](https://hub.docker.com/r/siakbary/dockergc)
## How to create a server:
[Since I don't want to write the same post, please visit this](https://game.yuuki.me/posts/how-to-make-server)

## How to connect to server
[Since I don't want to write the same post, please visit this](https://game.yuuki.me/posts/how-connect)

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
# (0 is Patch-DEV and 1 is Patch-Early) (2.0.0.100 is your ip computer, make sure you have mongodb installed)
sh run.sh # default build localhost
sh run.sh local  start 0 # run localhost server for without docker
sh run.sh alpine start 0 2.0.0.100 # run localhost server for with docker alpine 
sh run.sh ubuntu start 0 2.0.0.100 # run localhost server for with docker ubuntu
sh run.sh local  build 0 # Build local aja jar only
sh run.sh alpine build 0 # Build Docker Image Alpine
sh run.sh ubuntu build 0 # Build Docker Image Ubuntu
sh run.sh local sync 1 Grasscutters dev-world-scripts # Sync Grasscutters Branch dev-world-scripts to Patch-Early
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
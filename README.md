# DockerGC
DockerGC is a container that run [Grasscutter](https://github.com/Melledy/Grasscutter) (**some anime game** server reimplementation) with just a single command.<br>
[![dockeri.co](https://dockeri.co/image/siakbary/dockergc)](https://hub.docker.com/r/siakbary/dockergc)
## How to create a server:
[Since I don't want to write same post, please visit this](https://game.yuuki.me/posts/how-to-make-server)
## How to connect to server
[Since I don't want to write same post, please visit this](https://game.yuuki.me/posts/how-connect)

## How to build this? 
### Source code (Patch Version) is closed now because many are remove "source link" from their server, so at this time you can only do push from docker image or download jar file.
### Remember [Grasscutter](https://github.com/Melledy/Grasscutter) source code is still open, you can do your own custom server with your own hard work.
## Required
- [Java 17 JDK](https://adoptium.net/temurin/releases) 
- [Docker](https://docs.docker.com/engine/install/)
- [Gradle](https://gradle.org/install/)
- [MongoDB](https://www.mongodb.com/try/download/community)
- [Lombok](https://stackoverflow.com/questions/67899014/vs-code-did-not-recognize-lombok)

Clone this with
```sh
git clone https://github.com/akbaryahya/DockerGC
cd DockerGC
cd gc
# 0=Patch-2.6, 1=Patch-2.6-Early, 2=Patch-2.7, 3=Patch-2.7-Early, 4=Patch-2.8
# 2.0.0.100 is your ip computer, make sure you have mongodb installed
sh run.sh # default build localhost
sh run.sh local res 2 # Get Resources File Based Version Server
sh run.sh local start 2 # run localhost server for without docker
sh run.sh alpine start 2 2.0.0.100 # run localhost server for with docker alpine
sh run.sh ubuntu start 2 2.0.0.100 # run localhost server for with docker ubuntu
sh run.sh local build 2 # Build local aja jar only
sh run.sh alpine build 2 # Build Docker Image Alpine
sh run.sh ubuntu build 2 # Build Docker Image Ubuntu
# (private, please ask for access if you really want to do something)
sh run.sh local sync 2 # Sync Grasscutters 2.7 to Patch-2.7
sh run.sh local sync 3 Grasscutters dev-world-scripts # Sync dev-world-scripts to Patch-2.7-Early
sh run.sh local sync 3 akbaryahya Patch-2.7 GCPrivate # Sync Patch-2.7 to Patch-2.7-Early
sh run.sh data core # Clone Patch Version
```
### Note:
* If you have a problem with **not foundsh**: Change **CRLF** to **LF**

## HELP
| Func | Info |
| ------ | ------ |
| d | IP Address for your database server, note: use computer ip if you want to run on your own pc/server, no "localhost" because it is IP in Container |
| b | IP/Domain Public Web Server |
| g | IP Public Game Server |
| p | Port Public Game Server |
| m | Chat Welcome Message |
| s | Name Server |
| r | Server Owner Name |
| r | Server Region Name |
| e | Email welcome when registering for first time |
| u | Player limit online (-1 for unlimited) |
| f | Re-download resources if you type "yes" this is useful if you already have a resources folder but there is latest update |
| l | Server Language and includes commands [more info](https://github.com/Grasscutters/Grasscutter/tree/development/src/main/resources/languages) |
| j | -Xms500M -Xmx8G [more info](https://www.baeldung.com/ops/docker-jvm-heap-size) |

## Port
| Port | Info |
| ------ | ------ |
| 80 | Web Server for HTTP. (Not required) |
| 443 | Web Server for HTTPS. (required) |
| 22102 | Game Communication (udp) (required) |

Power by [Grasscutter](https://github.com/Melledy/Grasscutter) ❤️
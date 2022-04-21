# DockerGC
Running Grasscutter (*some anime game* server reimplementation) with Docker

## How to create a server:
- Install Docker+MongoDB
- Open Terminal and Enter:
```sh
docker run --rm -it -v resources:/Grasscutter/resources -p 22102:22102/udp -p 443:443/tcp siakbary/dockergc:dev-1.5 -d '2.0.0.100:27017' -b 'localhost' -f 'yes'
```
- done 🙂

## How to connect:
- Before starting, open game first and then logout if you have logged in before and then exit again.
- Install Fiddler then open Fiddler then click tools -> options -> HTTPS print "Capture HTTPS" and "Decrypt Https" then click the "Actions" section then click Trues Root then click yes if a popup appears.
- In Fiddler in "FiddlerScript" tab, copy script from https://pastebin.com/raw/rfhpS7U5 then click save.
- Type again "docker run --rm -it -p 22102:22102/udp -p 443:443/tcp -p 80:80/tcp siakbary/dockergc:1.0 -d '2.0.0.100:27017' -b 'localhost'".
- Then type "account create yuuki" if there is a new response open the game.
- Login with user yuuki then password random/whatever then login already🙂

## Bro, I don't want to make a server, so can I just join to your server?
Yes, Simple way is to just change localhost in file in pastebin to address server you want to connect to.

## SERVER TESTING MODE
```sh
Server IP:
game.yuuki.me

* In order to access the command, please contact me *
```
This server is located in Germany so Asian players will get high ping, you can login with "user1-10" for example "user1", for user11-50 it will be created again when we get a more stable version or at least have a password feature so you now you can login without a password on the account, the account data will be reset when the datebase is reset/error and sometimes the server is automatically disconnected due to an error/bug/update.

## HELP
| Func | Info |
| ------ | ------ |
| d | is ip address for your database server , note: use computer ip if you want to run on your own pc, no "localhost" because it is ip in container |
| b | ip public server |
| v | ip private server |
| m | Welcome message for users |
| f | re-download resources if you type "yes" this is useful if you already have a resources folder but there is the latest update |

## Port
| Port | Info |
| ------ | ------ |
| 80 | web server for http, useless so far |
| 443 | web server for https game only works on https so make sure you have ssl or proxy stuff |
| 22102 | game communication with udp line |

This Version Docker uses sources from Grasscutter:
https://github.com/Melledy/Grasscutter
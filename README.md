# DockerGC
Running Grasscutter (Genshin Impact Emulator) with Docker

## How to create a server:
- Install Docker+MongoDB
- Open Terminal and enter "docker pull siakbary/dockergc" (1,5GB download)
- done 🙂

If you want a version without docker but it's complicated:
https://github.com/Melledy/Grasscutter

## How to connect:
- Before starting, open the game first and then logout if you have logged in before and then exit again or you don't need to.
- Install Fiddler then open Fiddler then click tools -> options -> HTTPS print "Capture HTTPS" and "Decrypt Https" then click the "Actions" section then click Trues Root then click yes if a popup appears.
- In Fiddler in "FiddlerScript" tab, copy script from https://pastebin.com/raw/rfhpS7U5 then click save.
- Type again "docker run --rm -it -p 22102:22102/udp -p 443:443/tcp -p 80:80/tcp siakbary/dockergc:1.0 -d '2.0.0.100:27017' -b 'localhost'".
- Then type "account create yuuki" if there is a new response open the game.
- Login with user yuuki then password random/whatever then login already🙂

## Bro, I don't want to make a server, so can I just join to your server?
Yes, Simple way is to just change localhost in file in pastebin to the address of the server you want to connect to.
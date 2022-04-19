# DockerGC
Running Grasscutter with Docker

docker run --rm -it -p 22102:22102/udp -p 443:443/tcp -p 80:80/tcp siakbary/dockergc:1.0 -d '2.0.0.100:27017' -b 'localhost'
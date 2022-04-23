FROM openjdk:18-jdk-alpine as build 

# Work work work!
WORKDIR /work

# Base Install
RUN apk add --no-cache git

# Building Grasscutter Source
RUN echo update dev-1.9 && java -version && \
    git clone -b development https://github.com/Grasscutters/Grasscutter.git && cd Grasscutter && \
    # bug PlayerBirthday need fix later
    git reset --hard bdfd92e7a3799e9560b2927ec5b2c00fbb81cace &&\
    # Need utf-8
    export GRADLE_OPTS="-Dfile.encoding=utf-8"  && \
    # Run it :)
    chmod +x gradlew && ./gradlew jar && \
    # We delete it because it is only needed during building process.
    rm -R -f /root/* Grasscutter-Protos LICENSE README.md build build.gradle gradle gradlew gradlew.bat lib proxy.py proxy_config.py run.cmd settings.gradle src

FROM openjdk:18-jdk-alpine

# Install json utilities for config.json
RUN apk add --no-cache npm && npm install --unsafe-perm -g json

# Sweet Home Alabama :)
WORKDIR /home

# EXPOSE Web (https) and Game Server
EXPOSE 443 22102

# Copy files
COPY --from=build /work/Grasscutter ./Grasscutter
COPY missing ./missing

# Rock
COPY entrypoint.sh .
ENTRYPOINT ["sh", "entrypoint.sh"]
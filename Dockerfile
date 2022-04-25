FROM openjdk:18-jdk-alpine as build

# Work work work!
WORKDIR /work

# Base Install
RUN apk add --no-cache git

# Building Grasscutter Source
RUN echo update dev-entity-2.4.1 && \
    git clone -b dev-entity https://github.com/Grasscutters/Grasscutter.git && cd Grasscutter && \
    # Need utf-8
    export GRADLE_OPTS="-Dfile.encoding=utf-8"  && \
    # Run it :)
    chmod +x gradlew && ./gradlew jar && \
    # We delete it because it is only needed during building process.
    rm -R -f start_config.cmd start.cmd Grasscutter-Protos LICENSE README.md build build.gradle gradle gradlew gradlew.bat lib run.cmd settings.gradle src

FROM openjdk:18-jdk-alpine
RUN  \
     # Install json utilities for config.json
     apk add --no-cache npm && npm install --unsafe-perm -g json

# Sweet Home Alabama :)
WORKDIR /home

# EXPOSE Web (https) and Game Server
EXPOSE 443 22102

# Copy files
COPY --from=build /work/Grasscutter ./Grasscutter

# Rock
COPY entrypoint.sh .
ENTRYPOINT ["sh", "entrypoint.sh"]
FROM lwieske/java-8:jdk-8u202-slim

# Sweet Home Alabama :)
WORKDIR /home

# Base Install
RUN apk add --no-cache git npm &&\
    # for config.json stuff
    npm install --unsafe-perm -g json

# Building Grasscutter Source (with bypass cache https://stackoverflow.com/a/36996107)
ADD https://api.github.com/repos/Grasscutters/Grasscutter/commits /tmp/bustcache
RUN git clone -b development https://github.com/Grasscutters/Grasscutter.git &&\
    cd Grasscutter && \
    # Need utf-8
    export GRADLE_OPTS="-Dfile.encoding=utf-8"  &&\
    # Run it :)
    chmod +x gradlew && ./gradlew jar &&\
    # We delete it because it is only needed during building process.
    rm -R -f Grasscutter-Protos LICENSE README.md build build.gradle gradle gradlew gradlew.bat lib proxy.py proxy_config.py run.cmd settings.gradle src

# FOR WEB HTTPS MODE
EXPOSE 443
# FOR GAME SERVER
EXPOSE 22102

# Missing file
COPY missing/ missing/

# Rock
COPY entrypoint.sh .
ENTRYPOINT ["sh", "entrypoint.sh"]
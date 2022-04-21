FROM lwieske/java-8:jdk-8u202-slim

# Base Install
RUN apk add git \
    #PR: https://stackoverflow.com/questions/43292243/how-to-modify-a-keys-value-in-a-json-file-from-command-line
    #FOR https://github.com/Melledy/Grasscutter/blob/59d01209f931440ad09697f995a5d456c7840084/src/main/java/emu/grasscutter/server/dispatch/DispatchServer.java#L107
    #LOG: The connection to '172.17.0.2' failed. <br />Error: TimedOut (0x274c). AKA CODE ERROR 4206
    npm && npm install -g json

# Missing file
COPY bug/ bug/

# Building Grasscutter Source (with bypass cache https://stackoverflow.com/a/36996107)
ADD https://api.github.com/repos/Grasscutters/Grasscutter/commits /tmp/bustcache
RUN git clone -b development --recurse-submodules https://github.com/Grasscutters/Grasscutter.git /Grasscutter
RUN cd Grasscutter && \
    # Bug id so back to stable version
    git reset --hard 9c136859eb9ed842e43905868d81414e8848928f &&\
    #LANG=en_US.UTF-8 &&\
    cp -rf /bug/ResourceLoader.java src/main/java/emu/grasscutter/data/ResourceLoader.java &&\
    chmod +x gradlew && ./gradlew jar &&\
    # We delete it because it is only needed during building process
    rm -R -f LICENSE README.md build build.gradle gradle gradlew gradlew.bat proxy.py proxy_config.py run.cmd settings.gradle src Grasscutter-Protos lib && ls

# FOR WEB STUFF WITH HTTP MODE
EXPOSE 80 
# FOR WB STUFF WITH HTTPS MODE
EXPOSE 443
# FOR GAME SERVER?
EXPOSE 22102
# FOR GAME LOG
EXPOSE 8888

# Sweet Home Alabama :)
WORKDIR /Grasscutter

# Missing file
COPY missing/ missing/

# Rock
COPY entrypoint.sh .
ENTRYPOINT ["sh", "entrypoint.sh"]
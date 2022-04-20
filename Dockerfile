FROM lwieske/java-8:jdk-8u202-slim

# Base Install
RUN apk add git

#PR: https://stackoverflow.com/questions/43292243/how-to-modify-a-keys-value-in-a-json-file-from-command-line
#FOR https://github.com/Melledy/Grasscutter/blob/59d01209f931440ad09697f995a5d456c7840084/src/main/java/emu/grasscutter/server/dispatch/DispatchServer.java#L107
#LOG: The connection to '172.17.0.2' failed. <br />Error: TimedOut (0x274c). AKA CODE ERROR 4206
RUN apk add npm && npm install -g json

WORKDIR /Install

# Building Data Source
RUN git clone https://github.com/Dimbreath/GenshinData &&\
    git clone https://github.com/radioegor146/gi-bin-output

# Building Grasscutter Source (with bypass cache https://stackoverflow.com/a/36996107)
ADD https://api.github.com/repos/Grasscutters/Grasscutter/commits /tmp/bustcache
RUN git clone -b development --recurse-submodules https://github.com/Grasscutters/Grasscutter.git /Grasscutter

# Missing file
COPY missing/ missing/

# Bug fix (fast mode)
#COPY bug/ bug/
#RUN cp bug/ResourceLoader.java      /Grasscutter/src/main/java/emu/grasscutter/data/
#RUN cp bug/DispatchServer.java      /Grasscutter/src/main/java/emu/grasscutter/server/dispatch/

# Sweet Home Alabama :)
WORKDIR /Grasscutter

# Buat yuk
RUN chmod +x gradlew && ./gradlew jar

# Generated Resources
RUN mkdir resources && mkdir resources/BinOutput &&\    
    # gi-bin-output for Fix skill animasi etc (Outdated 2.2>2.5)
    cp -r /Install/gi-bin-output/2.2/Data/_BinOutput/*     resources/BinOutput &&\    
    cp -r /Install/gi-bin-output/2.5.52/Data/_BinOutput/*  resources/BinOutput &&\
    # GenshinData (latest 2.6^)
    cp -r /Install/GenshinData/*                           resources &&\
    # missing file
    cp -r /Install/missing/*                               resources/ExcelBinOutput &&\
    # just remove it
    rm -R -f src/* &&\
    rm -R -f build/* &&\
    rm -R -f /Install/* &&\
    rm -R -f .gradle/* &&\
    rm -R -f gradle/* &&\
    # dev need fix this 
    cp resources/TextMap/TextMapEN.json resources

# GM Handbook Generated stuff
RUN java -jar grasscutter.jar -handbook

# FOR WEB STUFF WITH HTTP MODE
EXPOSE 80 
# FOR WB STUFF WITH HTTPS MODE
EXPOSE 443
# FOR GAME SERVER?
EXPOSE 22102
# FOR GAME LOG
EXPOSE 8888

# yay
COPY entrypoint.sh .
ENTRYPOINT ["sh", "entrypoint.sh"]
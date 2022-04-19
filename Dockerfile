FROM lwieske/java-8:jdk-8u202-slim

# Base Install
RUN apk add git

WORKDIR /Install

# Building Data Source
RUN git clone https://github.com/Dimbreath/GenshinData &&\
    git clone https://github.com/radioegor146/gi-bin-output

# Building Grasscutter Source
RUN git clone https://github.com/Melledy/Grasscutter /Grasscutter

# Missing file
COPY missing/ missing/

# Sweet Home Alabama :)
WORKDIR /Grasscutter

# Buat yuk
RUN chmod +x gradlew && ./gradlew jar

# Generated Resources
RUN mkdir resources &&\
    cp -r /Install/GenshinData/*    resources &&\
    cp -r /Install/gi-bin-output/*  resources &&\
    cp -r /Install/missing/*        resources/ExcelBinOutput &&\
    rm -R /Install/* &&\
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

RUN ls resources/BinOutput/Talent/EquipTalents

# yay
COPY entrypoint.sh .
ENTRYPOINT ["sh", "entrypoint.sh"]
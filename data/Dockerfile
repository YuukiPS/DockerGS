FROM alpine:3.15.4
COPY g_gc.sh .
RUN \
    apk add --no-cache git wget &&\
    sh g_gc.sh &&\
    apk del git wget
FROM ubuntu:latest

ENV HOME /server/Engine/Binaries/ThirdParty/SteamCMD/Linux


COPY entrypoint /usr/bin/entrypoint

# I have to have a run layer here anyway so chmod does not cost anything
# in terms of image size

RUN apt-get update && apt-get install -y lib32gcc1 curl netcat && \
    chmod a+x /usr/bin/entrypoint && \
    rm -rf /var/lib/apt/lists/*

# EXPOSE 27015 7777 7778 27020
VOLUME /server /cluster

USER ark

ENTRYPOINT ["entrypoint"]

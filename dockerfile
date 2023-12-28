# FROM --platform=$TARGETPLATFORM debian:buster-slim AS src
FROM ubuntu:latest AS src

ARG TARGETARCH
ENV TARGETARCH=$TARGETARCH
ENV DEBIAN_FRONTEND="noninteractive" \
  PLEX_PATH=/usr/lib/plexmediaserver \
  PLEX_USER_NAME=plex \
  PLEX_CONFIG_DIR=/config \
  PLEX_DATA_DIR=/data \
  PLEX_TRANSCODE_DIR=/transcode
ARG TARGETPLATFORM
ENV TARGETPLATFORM=$TARGETPLATFORM
RUN echo ${TARGETARCH} > ./ARCH.txt
RUN apt-get clean

COPY ./VERSION .
COPY scripts/plex-url.sh .
RUN mkdir /transcode
RUN chmod 777 -R /transcode

FROM drjp81/powershell as build
ARG $TARGETARCH
ENV TARGETARCH=$TARGETARCH
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
COPY --from=src ./ARCH.txt ./ARCH.txt
RUN cat ./ARCH.txt
RUN mkdir /dload
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]
RUN write-host ($env:TARGETARCH);
RUN $uri = "https://plex.tv/api/downloads/5.json" ; \
$res = Invoke-RestMethod -Uri $uri ; \
$OS = "Linux" ; \
$env:TARGETARCH = (get-content ./ARCH.txt) ; \
switch ($env:TARGETARCH) {"amd64" {$build = "linux-x86_64"  } "arm" {$build = "linux-armv7neon"  } "arm64" {$build = "linux-aarch64"  }} ; \
$releases  = $res.computer.($OS).releases | ? {$_.distro -eq "debian"} |  ? {$_.build -eq $build } ; \
set-content -path /dload/fil.txt -value ($releases.url) ; write-host ($releases.url) 
RUN invoke-WebRequest (get-content /dload/fil.txt -RAW) -OutFile /dload/plex.deb -erroraction stop; gci /dload ;

FROM src
SHELL [ "/bin/sh","-c" ]
COPY --from=build /dload/fil.txt /dload/fil.txt
COPY --from=build /dload/plex.deb /dload/plex.deb
# Download / install Plex
RUN cat /dload/fil.txt \
&& dpkg -i /dload/plex.deb \
&& rm -f /dload/plex.deb

# Add user
RUN useradd -U -d $PLEX_CONFIG_DIR -s /bin/false $PLEX_USER_NAME \
 && usermod -G users $PLEX_USER_NAME

COPY scripts/entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

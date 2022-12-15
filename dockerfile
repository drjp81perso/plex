FROM --platform=$TARGETPLATFORM debian:buster-slim AS src

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
RUN apt-get update
RUN apt-get install -y --no-install-recommends wget ca-certificates

COPY ./VERSION .
COPY scripts/plex-url.sh .

FROM --platform=$BUILDPLATFORM drjp81/powershell as build
ARG $TARGETARCH
ENV TARGETARCH=$TARGETARCH
COPY --from=src ./ARCH.txt ./ARCH.txt
RUN cat ./ARCH.txt
SHELL ["pwsh","-command"]
RUN write-host ($env:TARGETARCH);
RUN $uri = "https://plex.tv/api/downloads/5.json" ; \
$res = Invoke-RestMethod -Uri $uri ; \
$OS = "Linux" ; \
$env:TARGETARCH = (get-content ./ARCH.txt) ; \
switch ($env:TARGETARCH) {"amd64" {$build = "linux-x86_64"  } "arm" {$build = "linux-armv7neon"  } "arm64" {$build = "linux-aarch64"  }} ; \
$releases  = $res.computer.($OS).releases | ? {$_.distro -eq "debian"} |  ? {$_.build -eq $build } ; \
$dloadurl = $releases.url ; \
invoke-WebRequest -uri $dloadurl -OutFile /tmp/plex.deb  ;

FROM src
SHELL [ "/bin/sh","-c" ]
COPY --from=build /tmp/plex.deb /tmp/plex.deb
# Download / install Plex
RUN dpkg -i /tmp/plex.deb \
 && rm -f /tmp/plex.deb

# Add user
RUN useradd -U -d $PLEX_CONFIG_DIR -s /bin/false $PLEX_USER_NAME \
 && usermod -G users $PLEX_USER_NAME

COPY scripts/entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

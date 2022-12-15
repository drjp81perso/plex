Docker images: https://hub.docker.com/repository/docker/drjp81/plex/general

# Plex Server multi platform

A simple way to run a plex media server in Docker on the ARM and AMD64 .

**NOTE: The Pi 1 is NOT supported.**

## Usage


I highly recommend you use a docker-compose file to manage your server:

```yaml
version: '2'
services:
  plex:
    container_name: plex
    image: drjp81/plex:latest
    restart: unless-stopped
    hostname: plex1 #adjust accordingly
    user: "${UID}:${GID}" #optional
    environment:
      - TZ=America/Toronto #adjust accordingly
      - VERSION=docker
      - PLEX_CLAIM=[your-plex-claim-here]
    network_mode: host
    volumes:
    - /storage/usb2/config:/config
    - /storage/usb2/transcode:/transcode
    - "/etc/timezone:/etc/timezone:ro"
    - "/etc/localtime:/etc/localtime:ro"
```

You can use a ```docker-compose log```  to see the state of the container after startup

## NFS Shares

If you have permission issues using NFS shares as the mounted volumes, set the `UID` and `GID` environment variables to the user/group id of the owner of those directories.

### To find the uid/gid:

```
# show user/group owner of a directory
ls -n ~/media/plex/config

# outputs something like this:
# drwxr-xr-x 20 1001  1001  4096 Apr  9 19:00 config
#               ^ uid ^ gid
```

## Updating

Plex cannot be updated via the web ui. Run the following to download and run a new version:

```sh
docker-compose pull && docker-compose down && docker-compose up -d 
```

## Transcoding

The Pi isn't powerful enough for transcoding but if you have media that will direct play on your client it works great! If you have a more powerful ARM platform with H264 and/or H265 hardware encoding, you should be okay.

Be sure to set the "Transcoder temporary directory" setting to `/transcode` in the Plex -> Transcoder settings UI. Or disable transcoding if necessary.

## Development

To build the images yourself clone this repository and run the following:

```PowerShell
pwsh -file ./get-version.ps1 
```
I use PowerShell but it's not strictly necessary. It's just a way for the scripts to see if there's a newer version of plex in the source repo and either build or skip if there was no change. I suppose all of this could be shell script too, but I'm more familiar with PowerShell, so do as you see fit.

Lastly refer to the [license](./LICENSE)
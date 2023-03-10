$versionfile = (Join-Path -Path $PSScriptRoot -ChildPath "VERSION") 
if ($env:Dockerjobs -eq "True") {
    Set-Location $PSScriptRoot
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker buildx create --name cibuilder --driver docker-container --use
    docker buildx ls
    docker buildx inspect --bootstrap
    docker buildx build --platform=linux/amd64, linux/arm64/v8, linux/arm/v7 -f dockerfile -t drjp81/plex:latest --progress plain --push .
    if ($LASTEXITCODE -ne 0) {
        Remove-Item -LiteralPath $versionfile
    }

}
else {
    Write-Output "Nothing to do"
}

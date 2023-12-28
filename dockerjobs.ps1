$versionfile = (Join-Path -Path $PSScriptRoot -ChildPath "VERSION") 
if ($env:Dockerjobs -eq "True") {
    Set-Location $PSScriptRoot
    #docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker buildx ./rm mybuilder
    docker buildx create --use --name mybuilder #--driver-opt network=host --buildkitd-flags '--allow-insecure-entitlement network.host'
    docker buildx ls
    docker buildx inspect --bootstrap
    docker buildx build --platform=linux/amd64,linux/arm64/v8  -f dockerfile -t drjp81/plex:latest --progress plain --push .
    if ($LASTEXITCODE -ne 0) {
        Remove-Item -LiteralPath $versionfile
    }

}
else {
    Write-Output "Nothing to do"
}
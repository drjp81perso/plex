$versionfile= (Join-Path -Path $PSScriptRoot -ChildPath "VERSION") 
[string]$oldver = (get-content $versionfile -erroraction ignore)

$uri = "https://plex.tv/downloads/details/5?build=linux-x86_64&channel=8&distro=debian"
[xml]$res = (Invoke-WebRequest -Uri $uri -ContentType "text/xml").content
#$res
$res.MediaContainer.Release.version -match "[0-9]\..+\..+\-"
[string]$vstring = $Matches[0]
$finalver = $vstring.Replace("-","")
if ($finalver -ne $oldver)
{
    write-host ("Old version was : " + $oldver + " and new version is: " + $finalver +". Will continue to process...")
    $env:Dockerjobs="True"

}
else
{
    write-host ("Old version was : " + $oldver + " and new version is: " + $finalver +". They are the same. Quitting.")
    $env:Dockerjobs="False"

}

if ($env:Dockerjobs -eq "True")
{

    $uri = "https://plex.tv/downloads/details/5?build=linux-x86_64&channel=8&distro=debian"
    [xml]$res = (Invoke-WebRequest -Uri $uri -ContentType "text/xml").content
    #$res
    $res.MediaContainer.Release.version -match "[0-9]\..+\..+\-"
    [string]$vstring = $Matches[0]
    $finalver = $vstring.Replace("-","")
    Write-Host $finalver
    Set-Content -path (Join-Path -Path $PSScriptRoot -ChildPath "VERSION") -Value $finalver -NoNewline -Force
    
}
cd $PSScriptRoot
./dockerjobs.ps1

# This script is used to produce a NuGet package contaiting the windows sdk

[CmdletBinding(PositionalBinding=$false)]
param (
    [string]$root = "c:\",
    [string]$packageName = "RoslynTools.WindowsSdk",
    [string]$packageVersion = "0.0.1-alpha",
    [parameter(ValueFromRemainingArguments=$true)] $extraArgs)
Set-StrictMode -version 2.0
$ErrorActionPreference="Stop"

function Print-Usage() {
    Write-Host "build-windows-sdk.ps1"
    Write-Host "`t-root path        Root to look for the sdk (c:\)"
    Write-Host "\t-packageName      Name of the nuget package (RoslynTools.WindowsSdk)"
    Write-Host "\t-packageVersion   Version of the nuget package"
}

function Compose-WindowsSdk() {
    Write-Host "Composing windows sdk"
    $copyList = @(
	    "v8.1A\bin\NETFX 4.5.1 Tools"
    )

    Create-Directory $outDir
    Remove-Item -re "$outDir\*" 

    $sdkDir = Join-Path $root "Program Files (x86)\Microsoft SDKs\Windows"
    if (-not (Test-Path $sdkDir)) {
        throw "Windows Sdk directory missing: $sdkDir"
    }

    foreach ($item in $copyList) {
        $dest = Join-Path $outDir $item
        $source = Join-Path $sdkDir $item
        Create-Directory $dest | Out-Null
        Copy-Item -re "$source\*" $dest
    }
}

function Create-Package() {
    $nuget = Ensure-NuGet
    Write-Host "Packing $packageName"
    & $nuget pack windowssdk.nuspec -ExcludeEmptyDirectories -OutputDirectory $binariesDir -Properties name=$packageName`;version=$packageVersion`;filePath=$outDir
}

Push-Location $PSScriptRoot
try {
    . .\build-utils.ps1

    $outDir = Join-Path $binariesDir "Sdk"

    if ($extraArgs -ne $null) {
        Write-Host "Did not recognize extra arguments: $extraArgs"
        Print-Usage
        exit 1
    }

    Compose-WindowsSdk
    Create-Package

    exit 0
}
catch {
    Write-Host $_
    Write-Host $_.Exception
    exit 1
}
finally {
    Pop-Location
}

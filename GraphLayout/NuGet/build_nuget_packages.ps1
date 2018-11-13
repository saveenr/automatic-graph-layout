param([string]$ver="1.1.3") 

.\AcquireNuGetExe.ps1

$tokens = $ver.Split(".")


if ($ver.Length -eq $null)
{
    Write-Error "Version cant't be null"
    exit
}

if ($ver.Length -lt 5)
{
    Write-Error "Version must have at least 5 total chars"
    exit
}

if ($tokens.Count -ne 3)
{
    Write-Error "version must have three components"
    exit
}


$specs = ("Microsoft.Msagl.nuspec",
    "Microsoft.Msagl.Drawing.nuspec",
    "Microsoft.Msagl.GraphViewerGDI.nuspec",
    "Microsoft.Msagl.WpfGraphControl.nuspec")


Push-Location $PSScriptRoot 

foreach ($spec in $specs)
{
    Write-Host "----------"

    $spec_fname = Join-Path $PSScriptRoot $spec

    $xml = [xml](Get-Content $spec_fname)

    # Update the package version
    Write-Host $xml.package.metadata.version
    $xml.package.metadata.version = $ver
    Write-Host $xml.package.metadata.version

    # Updating the package versions of Msagl depedencies

    foreach ($dep in $xml.package.metadata.dependencies.dependency)
    {
        if ($dep.id.Contains("Microsoft.Msagl"))
        {
            Write-Host $dep.id $dep.version
            $dep.version = $ver
            Write-Host $dep.id $dep.version
        }
    } 

    $xml.Save( $spec_fname )
}

foreach ($spec in $specs)
{
    Write-Host "----------"
    Write-Host "NUSPEC:" $spec_fname
    #Invoke-Expression "nuget pack $spec"
}
Pop-Location
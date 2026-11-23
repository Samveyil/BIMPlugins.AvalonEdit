# Builds the BIMPlugins.AvalonEdit package from a release of AvalonEdit:
#   ./build.ps1            -> artifacts/BIMPlugins.AvalonEdit.<version>.nupkg
# The release's sources are cloned into .work/ (not kept in this repository), renamed by tools/rename.py,
# built for .NET Framework 4.6.2 (Revit 2019-2024) and .NET 8 (Revit 2025+), and packed by BIMPlugins.AvalonEdit.nuspec.
param(
    [string]$Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'

# The AvalonEdit release the package is built from.
$AvalonEditVersion = '6.3.1'

# The package version: the release's, with a fourth number for BIMPlugins' own changes to the same release (6.3.1.1).
# The tag that publishes it is v<PackageVersion>.
$PackageVersion = '6.3.1'

$root = $PSScriptRoot
$work = Join-Path $root '.work'
$sources = Join-Path $work 'AvalonEdit'
$artifacts = Join-Path $root 'artifacts'

function Invoke-Checked([scriptblock]$command) {
    & $command
    if ($LASTEXITCODE -ne 0) { throw "Failed with exit code ${LASTEXITCODE}: $command" }
}

if (Test-Path $sources) { Remove-Item $sources -Recurse -Force }
New-Item -ItemType Directory -Force $work, $artifacts | Out-Null

Invoke-Checked { git clone --quiet --depth 1 --branch "v$AvalonEditVersion" -c advice.detachedHead=false `
    https://github.com/icsharpcode/AvalonEdit.git $sources }
Invoke-Checked { python (Join-Path $root 'tools/rename.py') $sources (Join-Path $root 'key/BIMPlugins.AvalonEdit.snk') }

# The assembly version is the package's in four parts (6.3.1.0), so the loaded copy shows the package it came from.
$parts = @($PackageVersion.Split('.'))
while ($parts.Count -lt 4) { $parts += '0' }
$assemblyVersion = $parts -join '.'

$project = Join-Path $sources 'ICSharpCode.AvalonEdit/ICSharpCode.AvalonEdit.csproj'
foreach ($framework in 'net462', 'net8.0-windows') {
    Invoke-Checked { dotnet build $project -c $Configuration -f $framework -nologo -v q `
        "-p:Version=$PackageVersion" "-p:AssemblyVersion=$assemblyVersion" "-p:FileVersion=$assemblyVersion" }
}

$output = Join-Path $sources "ICSharpCode.AvalonEdit/bin/$Configuration"

# The commit of this repository the package is built from, shown on nuget.org.
$commit = (git -C $root rev-parse HEAD).Trim()

Invoke-Checked { dotnet pack (Join-Path $root 'pack/Pack.csproj') -nologo -v q -o $artifacts `
    "-p:PackageVersion=$PackageVersion" "-p:BuildOutput=$output" "-p:RepositoryCommit=$commit" }

Write-Host "Packed BIMPlugins.AvalonEdit $PackageVersion to $artifacts"

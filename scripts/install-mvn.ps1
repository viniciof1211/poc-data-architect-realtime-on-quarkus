<#
.SYNOPSIS
 Installs Apache Maven on Windows via Chocolatey or manual download fallback.
#>
Param()

# Check for Chocolatey
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Using Chocolatey to install Maven..."
    choco install maven -y
} else {
    Write-Host "Chocolatey not found. Downloading Maven binary..."
    $mavenVersion = "3.8.8"
    $url = "https://downloads.apache.org/maven/maven-3/$mavenVersion/binaries/apache-maven-$mavenVersion-bin.zip"
    $zipPath = "$env:TEMP\apache-maven-$mavenVersion-bin.zip"
    Invoke-WebRequest -Uri $url -OutFile $zipPath
    $installDir = "$env:ProgramFiles\Apache\Maven"
    Expand-Archive $zipPath -DestinationPath $installDir -Force
    # Add to PATH
    [Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$installDir\apache-maven-$mavenVersion\bin", [EnvironmentVariableTarget]::Machine)
    Write-Host "Maven extracted to $installDir"
}

# Verify installation
Write-Host "`n===== Maven Installation Complete =====`n"
$mvn = Get-Command mvn -ErrorAction SilentlyContinue
if ($mvn) {
    & mvn --version
} else {
    Write-Host "Error: 'mvn' not found in PATH. Please restart your shell or add MAVEN_HOME\bin to PATH."
}

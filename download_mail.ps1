$dest = ".\FreshFruitStore-main\web\WEB-INF\lib\jakarta.activation-api-2.1.2.jar"
$url = "https://repo1.maven.org/maven2/jakarta/activation/jakarta.activation-api/2.1.2/jakarta.activation-api-2.1.2.jar"
Write-Output "Downloading jakarta.activation-api..."
Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
if (Test-Path $dest) {
    Write-Output "Downloaded activation: $((Get-Item $dest).Length) bytes"
}

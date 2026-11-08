$srcFiles = Get-ChildItem -Path ".\FreshFruitStore-main\src\java" -Filter "*.java" -Recurse | Select-Object -ExpandProperty FullName
Write-Output "Found $($srcFiles.Count) Java files to compile."

$cp = "C:\Program Files\Apache Software Foundation\Tomcat 10.1\lib\servlet-api.jar;.\FreshFruitStore-main\web\WEB-INF\lib\*"
$outDir = ".\FreshFruitStore-main\build\web\WEB-INF\classes"

if (!(Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

& javac -encoding UTF-8 -cp $cp -d $outDir $srcFiles
if ($LASTEXITCODE -eq 0) {
    Write-Output "COMPILATION SUCCESS"
    # Copy properties and resource files from src to classes
    Get-ChildItem -Path ".\FreshFruitStore-main\src\java" -Filter "*.properties" -Recurse | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $outDir -Force
    }
    # Copy web assets to build directory
    Copy-Item -Path ".\FreshFruitStore-main\web\*" -Destination ".\FreshFruitStore-main\build\web\" -Recurse -Force
    Write-Output "WEB ASSETS SYNCED"

    # Reload Tomcat
    $tomcatXml = "C:\Program Files\Apache Software Foundation\Tomcat 10.1\conf\Catalina\localhost\FreshFruitStore.xml"
    if (Test-Path $tomcatXml) {
        (Get-Item $tomcatXml).LastWriteTime = Get-Date
        Write-Output "TOMCAT CONTEXT TOUCHED"
    }
} else {
    Write-Output "COMPILATION FAILED with code $LASTEXITCODE"
}

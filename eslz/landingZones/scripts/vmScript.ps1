# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Apps & Fonts
choco install pwsh -y
choco install bicep -y
choco install azure-cli -y

mkdir C:\downloads -force
$filepath = "C:\downloads"
$stgacctname = "stccstest1111usvassvc"
$containername = "certs"
$blobname = "rootCA.crt"
az cloud set --name AzureUSGovernment
az login --identity
az storage blob download --auth-mode login --container-name $containername --name $blobname --account-name $stgacctname --file "$filepath\$blobname"
certutil -addstore -enterprise -f -v root “$filepath\$blobname”
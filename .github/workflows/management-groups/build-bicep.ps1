mkdir build
$env:path += "C:\Program Files\Bicep CLI"    
bicep build entlz\management-groups\bicep\main.bicep --outdir build
Copy-Item entlz\management-groups\main.parameters.*.json build
Copy-Item entlz\management-groups\deploy-arm.ps1 build
Copy-Item entlz\management-groups\test-arm.ps1 build
<#
SUMMARY: This PowerShell script helps with the authoring of the policy definiton module by outputting information required for the variables within the module.
DESCRIPTION: This PowerShell script outputs the Name & Path to a Bicep strucutred .txt file named '_policyDefinitionsBicepInput.txt' and '_policySetDefinitionsBicepInput.txt' respectively. It also creates a parameters file for each of the policy set definitions. It also outputs the number of policies definition and set definition files to the console for easier reviewing as part of the PR process.
AUTHOR/S: jtracey93
VERSION: 1.5.3
#>

# Policy Definitions

Write-Information "====> Creating/Emptying '_policyDefinitionsBicepInput.txt'" -InformationAction Continue
Set-Content -Path "./eslz/managementServices/policy/_policyDefinitionsBicepInput.txt" -Value $null -Encoding "utf8"

Write-Information "====> Looping Through Policy Definitions:" -InformationAction Continue
Get-ChildItem -Recurse -Path "./eslz/managementServices/policy/policyDefinitions" -Filter "*.json" | ForEach-Object {
    $policyDef = Get-Content $_.FullName | ConvertFrom-Json -Depth 100

    $policyDefinitionName = $policyDef.name
    $fileName = $_.Name

    Write-Information "==> Adding '$policyDefinitionName' to '$PWD/_policyDefinitionsBicepInput.txt'" -InformationAction Continue
    Add-Content -Path "./eslz/managementServices/policy/_policyDefinitionsBicepInput.txt" -Encoding "utf8" -Value "{`r`n`tname: '$policyDefinitionName'`r`n`tlibDefinition: json(loadTextContent('policyDefinitions/$fileName'))`r`n}"
}

$policyDefCount = Get-ChildItem -Recurse -Path "./eslz/managementServices/policy/policyDefinitions" -Filter "*.json" | Measure-Object
$policyDefCountString = $policyDefCount.Count
Write-Information "====> Policy Definitions Total: $policyDefCountString" -InformationAction Continue

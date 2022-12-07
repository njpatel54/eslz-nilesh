Write-Information "====> Creating/Emptying '_policyDefinitionsBicepInput.txt'" -InformationAction Continue
Set-Content -Path "./eslz/test/_policyDefinitionsBicepInput.txt" -Value $null -Encoding "utf8"

Write-Information "====> Looping Through Policy Definitions:" -InformationAction Continue
Get-ChildItem -Recurse -Path "./eslz/test/policyDefinitions" -Filter "*.json" | ForEach-Object {
    $policyDef = Get-Content $_.FullName | ConvertFrom-Json -Depth 100

    $policyDefinitionName = $policyDef.name
    $fileName = $_.Name

    Write-Information "==> Adding '$policyDefinitionName' to '$PWD/_policyDefinitionsBicepInput.txt'" -InformationAction Continue
    Add-Content -Path "./eslz/test/_policyDefinitionsBicepInput.txt" -Encoding "utf8" -Value "{`r`n`tname: '$policyDefinitionName'`r`n`tdefinition: json(loadTextContent('./policyDefinitions/$fileName'))`r`n}"
}

$policyDefCount = Get-ChildItem -Recurse -Path "./eslz/test/policyDefinitions" -Filter "*.json" | Measure-Object
$policyDefCountString = $policyDefCount.Count
Write-Information "====> Policy Definitions Total: $policyDefCountString" -InformationAction Continue


# Policy Set Definitions

Write-Information "====> Creating/Emptying '_policySetDefinitionsBicepInput.txt'" -InformationAction Continue
Set-Content -Path "./eslz/test/_policySetDefinitionsBicepInput.txt" -Value $null -Encoding "utf8"

Write-Information "====> Looping Through Policy Set/Initiative Definition:" -InformationAction Continue

Get-ChildItem -Recurse -Path "./eslz/test/policySetDefinitions" -Filter "*.json" -Exclude "*.parameters.json" | ForEach-Object {
    $policyDef = Get-Content $_.FullName | ConvertFrom-Json -Depth 100

    # Load child Policy Set/Initiative Definitions
    $policyDefinitions = $policyDef.properties.policyDefinitions | Sort-Object -Property policyDefinitionReferenceId

    $policyDefinitionName = $policyDef.name
    $fileName = $_.Name

    # Construct file name for Policy Set/Initiative Definitions parameters files
    $parametersFileName = $fileName.Substring(0, $fileName.Length - 5) + ".parameters.json"

    # Create Policy Set/Initiative Definitions parameter file
    Write-Information "==> Creating/Emptying '$parametersFileName'" -InformationAction Continue
    Set-Content -Path "./eslz/test/policySetDefinitions/$parametersFileName" -Value $null -Encoding "utf8"

    # Loop through all Policy Set/Initiative Definitions Child Definitions and create parameters file for each of them
    [System.Collections.Hashtable]$definitionParametersOutputJSONObject = [ordered]@{}
    $policyDefinitions | Sort-Object | ForEach-Object {
        $definitionReferenceId = $_.policyDefinitionReferenceId
        $definitionParameters = $_.parameters

        $definitionParameters | Sort-Object | ForEach-Object {
            [System.Collections.Hashtable]$definitionParametersOutputArray = [ordered]@{}
            $definitionParametersOutputArray.Add("parameters", $_)
        }

        $definitionParametersOutputJSONObject.Add("$definitionReferenceId", $definitionParametersOutputArray)
    }
    Write-Information "==> Adding parameters to '$parametersFileName'" -InformationAction Continue
    Add-Content -Path "./eslz/test/policySetDefinitions/$parametersFileName" -Value ($definitionParametersOutputJSONObject | ConvertTo-Json -Depth 10) -Encoding "utf8"

    # Sort parameters file alphabetically to remove false git diffs
    Write-Information "==> Sorting parameters file '$parametersFileName' alphabetically" -InformationAction Continue
    $definitionParametersOutputJSONObjectSorted = New-Object PSCustomObject
    Get-Content -Raw -Path "./eslz/test/policySetDefinitions/$parametersFileName" | ConvertFrom-Json -pv fromPipe -Depth 10 |
    Get-Member -Type NoteProperty | Sort-Object Name | ForEach-Object {
        Add-Member -InputObject $definitionParametersOutputJSONObjectSorted -Type NoteProperty -Name $_.Name -Value $fromPipe.$($_.Name)
    }
    Set-Content -Path "./eslz/test/policySetDefinitions/$parametersFileName" -Value ($definitionParametersOutputJSONObjectSorted | ConvertTo-Json -Depth 10) -Encoding "utf8"

    # Check if variable exists before trying to clear it
    if ($policySetDefinitionsOutputForBicep) {
        Clear-Variable -Name policySetDefinitionsOutputForBicep -ErrorAction Continue
    }

    # Create HashTable variable
    [System.Collections.Hashtable]$policySetDefinitionsOutputForBicep = [ordered]@{}

    # Loop through child Policy Set/Initiative Definitions if HashTable not == 0
    if (($policyDefinitions.Count) -ne 0) {
        $policyDefinitions | Sort-Object | ForEach-Object {
            $policySetDefinitionsOutputForBicep.Add($_.policyDefinitionReferenceId, $_.policyDefinitionId)
        }
    }

    # Start output file creation of Policy Set/Initiative Definitions for Bicep
    Write-Information "==> Adding '$policyDefinitionName' to '$PWD/_policySetDefinitionsBicepInput.txt'" -InformationAction Continue
    Add-Content -Path "./eslz/test/_policySetDefinitionsBicepInput.txt" -Encoding "utf8" -Value "{`r`n`tname: '$policyDefinitionName'`r`n`tsetDefinition: json(loadTextContent('policy/policySetDefinitions/$fileName'))`r`n`tsetChildDefinitions: ["

    # Loop through child Policy Set/Initiative Definitions for Bicep output if HashTable not == 0
    if (($policySetDefinitionsOutputForBicep.Count) -ne 0) {
        $policySetDefinitionsOutputForBicep.Keys | Sort-Object | ForEach-Object {
            $definitionReferenceId = $_
            $definitionId = $($policySetDefinitionsOutputForBicep[$_])
            # Add nested array of objects to each Policy Set/Initiative Definition in the Bicep variable
            Add-Content -Path "./eslz/test/_policySetDefinitionsBicepInput.txt" -Encoding "utf8" -Value "`t`t{`r`n`t`t`tdefinitionReferenceId: '$definitionReferenceId'`r`n`t`t`tdefinitionId: '$definitionId'`r`n`t`t`tdefinitionParameters: json(loadTextContent('policy/policySetDefinitions/$parametersFileName')).$definitionReferenceId.parameters`r`n`t`t}"
        }
    }

    # Finish output file creation of Policy Set/Initiative Definitions for Bicep
    Add-Content -Path "./eslz/test/_policySetDefinitionsBicepInput.txt" -Encoding "utf8" -Value "`t]`r`n}"

}

$policyDefCount = Get-ChildItem -Recurse -Path "./eslz/test/policySetDefinitions" -Filter "*.json" -Exclude "*.parameters.json" | Measure-Object
$policyDefCountString = $policyDefCount.Count
Write-Information "====> Policy Set/Initiative Definitions Total: $policyDefCountString" -InformationAction Continue




var test = json(replace(replace(replace(string(actionGroups), '[{', '{'), '}]', '}'), '}},{', '},'))
var test2 = replace(replace(replace(string(actionGroups), '{"actionGroupId":"', '\''), '"}', '\''), '"},', '')

$test = "[{"actionGroupId":"/subscriptions/df3b1809-17d0-47a0-9241-d2724780bdac/resourceGroups/rg-lz50-usva-wl01/providers/Microsoft.insights/actiongroups/ag-lz50-usva-001"}]"
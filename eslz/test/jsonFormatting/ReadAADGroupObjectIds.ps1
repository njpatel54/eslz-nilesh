# Read the object IDs from the input text file
$groups = Get-Content -Path ".\eslz\test\jsonFormatting\groups.txt"

# Initialize an empty array to store the group objects
$jsonBase = @{}
$grouplists = @{}

# Iterate through the object IDs
foreach ($group in $groups)
{

    $aadgroupObjectId = New-Object System.Collections.ArrayList
    # Get the group object for the current object ID
    $aadgroupObjectId = az ad group show --group $group --query "{id:id}" -o tsv

        $grouplist = @{"$group"=$aadgroupObjectId;}
        $grouplists += $grouplist
    
    # Add the group object to the array
    # $aadgroups += $aadgroup
}

$jsonBase.Add("mgRoleAssignments",$grouplists)

# Convert the array of group objects to JSON and output to the output file
$jsonBase | ConvertTo-Json -Depth 10 | Out-File ".\eslz\test\jsonFormatting\groups.json"

# Creating complex JSON with Powershell
#  https://mattou07.net/posts/creating-complex-json-with-powershell/

$jsonBase = @{}
$list = New-Object System.Collections.ArrayList

$list.Add(@{"Name"="John";"Surname"="Smith";"OnSubscription"=$true;})
$list.Add(@{"Name"="Daniel";"Surname"="Cray";"OnSubscription"=$false;})
$list.Add(@{"Name"="James";"Surname"="Reed";"OnSubscription"=$true;})
$list.Add(@{"Name"="Jack";"Surname"="York";"OnSubscription"=$false;})

$customers = @{"Customers"=$list;}

$jsonBase.Add("Data",$customers)
$jsonBase | ConvertTo-Json -Depth 10 | Out-File ".\customers.json"

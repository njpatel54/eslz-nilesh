[if(
    

    empty(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix')), bool('true'), 
    
    ipRangeContains(current('allowedIPRanges'), if(or(greaterOrEquals
    
                                                                    (first(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix')), 'a'), 
                                                                    equals(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'), '*')
                                                                    
                                                    ), current('allowedIPRanges'), field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix')))
    
    
    
    
    
    
    
    
    )]



    {
        "count": {
            "field": "Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix",
            "where": {
                "count": {
                    "value": "[parameters('allowedIPRanges')]",
                    "name": "allowedIPRanges",
                    "where": {
                        "value": "[ipRangeContains(current('allowedIPRanges'), field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'))]",
                        "equals": true
                    },
                },
                "equals": 0
            }
        },
        "greater": 0
    }
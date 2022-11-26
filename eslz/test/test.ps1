[if(
    
    and(
        not(empty(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'))),
        not(contains(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'),'*')),
        not(contains(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'),'Internet'))        
    ),
        
    not(
        or( 
            ipRangeContains('10.0.0.0/8', field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix')),        
            ipRangeContains('172.16.0.0/12', field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix')),
            ipRangeContains('192.168.0.0/16', field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'))
        )
    ),
        
    'false')
]



[if
    (
    
        and(
            not(empty(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'))),
            not(contains(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'),'*')),
            not(contains(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'),'Internet'))        
        ),
        
        not(
            ipRangeContains(current('allowedIPRanges'), field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'))            
        ),            
    
    'false'
    )
]



[if(and(not(empty(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'))),not(contains(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'),'*')),not(contains(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'),'Internet'))),not(or(ipRangeContains(current('allowedIPRanges'), field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix')))),'false')]


===================================================================================

[if(
    
    empty(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix')), bool('true'), 
    
    ipRangeContains(current('allowedIPRanges'), if(
                                                    or(
        
                                                        greaterOrEquals(first(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix')), 'a'), 
                                                        equals(field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'), '*')
                                                    ), 
                                                    
                                                    current('allowedIPRanges'), field('Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'))
    
    
    )
)]
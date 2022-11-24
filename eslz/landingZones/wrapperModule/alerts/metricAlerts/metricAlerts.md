// Resource Manager template samples for metric alert rules in Azure Monitor 
// https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/resource-manager-alerts-metric?tabs=bicep

Multiple Resources
    Monitor multiple resources ....
        - Same type (e.g. Microsoft.Computer/VirtualMachines)
        - With Single Metric Alert Rule (e.g. "Percentage CPU) - Currently available with ONLY Platform Metrics (Custom metrics are not supported)
        - Within same Azure Region (e.g. USGovVirginia)

|                  |                                                                                                         |
|:-----------------------|:-----------------------------------------------------------------------------------------------------------------|
|    |                                                                            |

# Monitoring all virtual machines (in one Azure region) in one or more resource groups.
Static threshold metric alert rule that monitors Percentage CPU for all virtual machines (in one Azure region) in one or more resource groups.
Percentage-CPU-GreaterThan-80-Percent-RGs-Static-Thresholds.json
Percentage-CPU-LessThan-30-Percent-RGs-Static-Thresholds.json

Dynamic thresholds metric alert rule that monitors Percentage CPU for all virtual machines (in one Azure region) in one or more resource groups.
Percentage-CPU-GreaterOrLessThan-RGs-Dynamic-Thresholds.json

# Monitoring all virtual machines (in one Azure region) in a subscription.
Static threshold metric alert rule that monitors Percentage CPU for all virtual machines in one Azure region in a subscription.
Percentage-CPU-GreaterThan-80-Percent-Sub-Static-Thresholds.json
Percentage-CPU-LessThan-30-Percent-Sub-Static-Thresholds.json

Dynamic Thresholds metric alert rule that monitors Percentage CPU for all virtual machines (in one Azure region) in a subscription.
Percentage-CPU-GreaterOrLessThan-Sub-Dynamic-Thresholds.json

# Monitoring a list of virtual machines (in one Azure region) in a subscription.
Static threshold metric alert rule that monitors Percentage CPU for a list of virtual machines in one Azure region in a subscription.
Percentage-CPU-GreaterThan-80-Percent-VMs-Static-Thresholds.json
Percentage-CPU-LessThan-30-Percent-VMs-Static-Thresholds.json

Dynamic thresholds metric alert rule that monitors Percentage CPU for a list of virtual machines in one Azure region in a subscription.
Percentage-CPU-GreaterOrLessThan-VMs-Dynamic-Thresholds.json


All-VMs-In-
List-Of-VMs-In-Sub
#// code/vmPowerFunction.ps1

using namespace System.Net

# Input bindings are passed in via param block.
param($request, $TriggerMetadata)

#Set default value
$status = 200

Try{
    # Write to the Azure Functions log stream.
    Write-Output "PowerShell HTTP trigger function processed a request."

    # Interact with query parameters or the body of the request.
    Write-Output ($request | ConvertTo-Json -depth 99)

    $ResourceGroupName = "ResourceGroup"
    $VMName1 = "VM01"
    $VMName2 = "VM02"
    $Context =  "1d47430d-fbbf-4a50-8212-436a2ad92276"

    $null = Connect-AzAccount -Identity
    $null = Set-AzContext $Context

    $vmStatus1 = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName1 -Status
    Write-output $vmStatus1
    
    If(-not ($vmStatus1)){
        $status = 404
        Throw "ERROR! VM [$VMName1] not found. Please check if the 'Subscription ID', 'Resource Group Name' or 'VM name' is correct and exists."
    }
    [string]$Message = "Virtual machine [$VMName1]  status: " + $vmStatus1.statuses[-1].displayStatus

    If($vmStatus1.statuses[-1].displayStatus -ne 'VM running'){
        Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName1 -Verbose
        [string]$message += "... Virtual machine [$VMName1] is now starting"
    }
    Else{
        [string]$message += "... Virtual machine [$VMName1] is already running"
    }

    $vmStatus2 = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName2 -Status
    Write-output $vmStatus2
    
    If(-not ($vmStatus2)){
        $status = 404
        Throw "ERROR! VM [$VMName2] not found. Please check if the 'Subscription ID', 'Resource Group Name' or 'VM name' is correct and exists."
    }
    [string]$Message = "Virtual machine [$VMName2]  status: " + $vmStatus2.statuses[-1].displayStatus

    If($vmStatus2.statuses[-1].displayStatus -ne 'VM running'){
        Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName2 -Verbose
        [string]$message += "... Virtual machine [$VMName2] is now starting"
    }
    Else{
        [string]$message += "... Virtual machine [$VMName2] is already running"
    }
        
        
}
Catch{
    [string]$message += $_
}

Write-output $message

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value (
    [HttpResponseContext]@{
        StatusCode = $status
        body = [string]$message
        headers = @{ "content-type" = "text/plain" }
    }
)
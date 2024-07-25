##Purpose:  Set status to enabled or disalbed for all AutoShutdown for all VMs in a subscription.

function Set-AllVMAutoShutdown {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]  [String]$subscriptionName, ## subscription name
        [Parameter(Mandatory = $true)]  [String]$Status ## set all of the AutoShutdown status to enabled or disabled status
        ##NOTE: If a VM has never had a autoshutdown configured it won't have a Microsoft.DevTestLab/schedules type resource assigned to it.
    )

    ##Validate Status parameter input is either enabled or disabled
    if ($Status -notmatch '(?:^|\W)enabled|disabled(?:$|\W)i') {
        Write-Host -ForegroundColor Red "ERROR: Status parameter must be one of the following values: enabled or disabled." 
        Return
    } 

    ##Checking if powershell is already connected to Azure.  
    ##If powershell is connected Get-AzSubscription runs fine
    ##If powershell is not connected it throws an error that is checked in the IF statement
    Write-Verbose "Connecting to Azure..."
    Get-AzSubscription | Out-Null
    if ($error[0] -like "*Your Azure credentials have not been set up or have expired*") {  
        Connect-AzAccount | Out-Null
    }

    ##Set powershell azure connection to desired azure subscription.
    ##If a bad subscription name is provided.  It throws an error.
    try {
        Write-Verbose "Setting Azure connection to $subscriptionName subscription."
        Set-AzContext -Subscription $subscriptionName -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Host -ForegroundColor Red $error[0].exception.message
        Return
    }

    ##Get list of all Microsoft.DevTestLab/schedules type resources
    Write-Verbose "Getting a list of all Microsoft.DevTestLab/schedules type resources "
    $schedules = Get-AzResource -ResourceType Microsoft.DevTestLab/schedules

    ## if ever in the future microsoft decides to use Microsoft.DevTestLab/schedules type resources for anything other than VM shutdown
    ## hopefully this will filter out and keep only VM shutdown schedules...  Help me. where-object Kenobi. You are my only hope.
    $schedules = $Schedules | Where-Object ResourceId -Like "*shutdown-computevm*"

    foreach ($s in $schedules) {
        Write-Verbose "Getting more azure resource information..."
        ## Running Get-AzResource using the -ResourceID parameter instead of the -ResourceType returns the
        ## property Properties which has all of the schedule configuration; time, notification, status, etc
        $resourceSchedule = Get-AzResource -ResourceId $s.resourceID
        $resourceScheduleName = $resourceSchedule.Name

        if ($Status -eq "Enabled") {
            if ($resourceSchedule.properties.status -eq "Disabled") {

                Write-Verbose "$resourceScheduleName was Disabled.  Reconfiguring to enabled status."
    
                $resourceSchedule.properties.status = $resourceSchedule.properties.status.Replace("Disabled", "Enabled")
    
                ## in order to change the schedule status.  The schedule needs to be overwriten
                ## this is done using the New-AzResouce cmdlet
    
                New-AzResource -Location $resourceSchedule.Location -ResourceId $resourceSchedule.ResourceId -Properties $resourceSchedule.properties -Force
    
                Write-Verbose "$resourceScheduleName has been disabled."
            }
            else {
                Write-Verbose "$resourceScheduleName is enabled"
            }
        }

        elseif ($Status -eq "Disabled") {
            if ($resourceSchedule.properties.status -eq "Enabled") {

                Write-Verbose "$resourceScheduleName was Enabled.  Reconfiguring to disabled status."
    
                $resourceSchedule.properties.status = $resourceSchedule.properties.status.Replace("Enabled", "Disabled")
    
                ## in order to change the schedule status.  The schedule needs to be overwriten
                ## this is done using the New-AzResouce cmdlet
    
                New-AzResource -Location $resourceSchedule.Location -ResourceId $resourceSchedule.ResourceId -Properties $resourceSchedule.properties -Force
    
                Write-Verbose "$resourceScheduleName has been disabled."
            }
            else {
                Write-Verbose "$resourceScheduleName is disabled"
            }
        }
    }
    
}

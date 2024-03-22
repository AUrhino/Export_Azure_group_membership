<#
.SYNOPSIS
  This script will connect to Azure 
  Will export all members in LM groups 
  
.DESCRIPTION
  This should run from a host that can connect to Azure via Powershell

.INPUTS
  None

.OUTPUTS
  Will write to files as specified below.

.NOTES
  Author:         Ryan Gillan
  Creation Date:  22-Mar-2024
  1.0  live version

.EXAMPLE
   get-help .\Azure_export_group_membership.ps1
  
  #Run via:
  .\Azure_export_group_membership.ps1

.LINK

#>
#=================================================================================================

# Check if AzureAD module is installed
try {
  $azureADModule = Get-Module -Name AzureAD -ListAvailable
  if ($azureADModule) {
    Write-Host "AzureAD module is installed."
    }
  else {
    Write-Host "AzureAD module is not installed. Installing..." -ForegroundColor Red
    # Install the AzureAD module
    Install-Module -Name AzureAD -Force -AllowClobber
    Write-Host "AzureAD module installed successfully." -ForegroundColor Green
    }
}
catch {
  Write-Host "`n`nAn error occurred: $($_.Exception.Message)" -ForegroundColor Red
}

#Clear the screen
Clear-Host


# Connect to Azure AD but hide the output
Connect-AzureAD | out-null


# Get the groups based on the name filter in the next line
$grouplist = Get-AzureADGroup -Filter "startswith(Displayname, 'AU.Sec.G.XXX.YYY')"

foreach ($g in $grouplist.DisplayName) {
	Write-Host $g
	$group = Get-AzureADGroup -SearchString $g
	
	#Get Group Members:
	$members = Get-AzureADGroupMember -ObjectId $group.ObjectId -All $true
	
    $resultsArray = @()
    foreach ($member in $members) {
        if ($member.ObjectType -eq "User") {
            $user = Get-AzureADUser -ObjectId $member.ObjectId
            $resultsArray += [PSCustomObject]@{
                UserName = $user.UserPrincipalName
                DisplayName = $user.DisplayName
    			Country = $user.Country
            }
        }
    }
	$resultsArray | Export-Csv -Path "C:\temp\lm-users\LM_GroupMembers-$($g).csv" -append -NoTypeInformation
}
# Disconnect from Azure AD
Disconnect-AzureAD

# EOF

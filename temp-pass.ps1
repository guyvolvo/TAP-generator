param (
    [Parameter(Mandatory=$true)]
    [string]$UserUPN

Connect-MgGraph -Scopes "User.Read.All", "UserAuthenticationMethod.ReadWrite.All", "GroupMember.ReadWrite.All" -NoWelcome

# group id of the temp pass group
$GroupId = "CHANGE_TO_YOUR_TEMP_PASS_GROUP_ID (f4673c290-d89172... etc. for example"
$SleepTime = 30


try {
	# find user by upn
    $User = Get-MgUser -Filter "UserPrincipalName eq '$UserUPN'" -ErrorAction Stop

    # add to group
    $Members = Get-MgGroupMember -GroupId $GroupId -All
    if ($User.Id -notin $Members.Id) {
        New-MgGroupMember -GroupId $GroupId -DirectoryObjectId $User.Id
        Write-Host "Added user to group. Waiting for policy sync"
        Start-Sleep -Seconds $SleepTime
		
    }

    # remove existing TAP to prevent policy conflict
    $ExistingTAP = Get-MgUserAuthenticationTemporaryAccessPassMethod -UserId $User.Id -ErrorAction SilentlyContinue
    if ($ExistingTAP) {
        Remove-MgUserAuthenticationTemporaryAccessPassMethod -UserId $User.Id -TemporaryAccessPassAuthenticationMethodId $ExistingTAP.Id
    }

    $Params = @{
        isUsableOnce = $false
        lifetimeInMinutes = 120
    }

    $TAP = New-MgUserAuthenticationTemporaryAccessPassMethod -UserId $User.Id -BodyParameter $Params
    Write-Host "Temp Password for $UserUPN - " -NoNewline
	Write-Host "$($TAP.TemporaryAccessPass)" -ForegroundColor Green
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
}

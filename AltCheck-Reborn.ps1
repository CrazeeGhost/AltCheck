param ($monitoriDeviceInterval=120, $successInterval = 60, $iMobileDeviceFolder="imobiledevice", $altServerPath="C:\Program Files (x86)\AltServer\AltServer.exe", $appleServiceName="Apple Mobile Device Service")
$version = "1.0"

Set-Location -Path $PsScriptRoot

function startAltServer {
	Write-Host $(Get-Date) [ACTION] Started AltServer
	Start-Process $altServerPath
}

function checkAltServer {
	$process = Get-Process AltServer -ErrorAction SilentlyContinue
	if ($process) {
		return $true;
	} else {
		return $false;
	}
}

function restartAppleMobileDeviceService {
	Write-Host $(Get-Date) [INFO] Restarting $appleServiceName
	try {
		Restart-Service -Name $appleServiceName -ErrorAction Stop
		Write-Host $(Get-Date) [OK] Action completed
		Write-Host $(Get-Date) [INFO] Waiting $monitoriDeviceInterval seconds before $appleServiceName attempts detecting iPhone
	} catch {
		Write-Host $(Get-Date) [ERROR] Cannot restart $appleServiceName. Try running this script as Administrator. 
		Write-Host $(Get-Date) [INFO] Waiting $monitoriDeviceInterval seconds before attempting again.
		Write-Host $(Get-Date) [INFO] Grab the latest version on GitHub: https://github.com/DiscordDigital
	}
	Start-Sleep $monitoriDeviceInterval
}

while($true) {
	$deviceCount = 0
	Write-Host $(Get-Date) [INFO] Checking AltServer
	$altServerStatus = checkAltServer
	if ($altServerStatus) {
		Write-Host $(Get-Date) [INFO] AltServer is running
	}
	else {
		Write-Host $(Get-Date) [INFO] AltServer is not running. Calling startAltServer
		startAltServer
	}
	
	Write-Host $(Get-Date) [INFO] Checking $appleServiceName
	# $deviceCount = ("$iMobileDeviceFolder\idevice_id.exe -l" | Measure-Object).Count
	$deviceCount = (cmd /c $iMobileDeviceFolder\idevice_id.exe -l).Count
	if ($deviceCount -lt 1) {
		Write-Host $(Get-Date) [WARN] No devices found. Restarting $appleServiceName.
		restartAppleMobileDeviceService
	} else {
		Write-Host $(Get-Date) [INFO] $deviceCount devices found. No action needed.
		Write-Host $(Get-Date) [INFO] Waiting for $successInterval seconds before checking again.
		Start-Sleep $successInterval
	}
	Write-Host 
}

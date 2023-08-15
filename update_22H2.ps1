#This script will upgrade any edition of Windows 10 to Windows 10 22H2
If (!(Test-Path C:\WindowsSetup)) {
    New-Item -ItemType Directory -Path "C:\WindowsSetup"
}

$URI = .\Fido.ps1 -Win 10 -Rel 22H2 -Arch x64 -Ed Pro -Lang English -GetUrl
$DownloadPath = "C:\WindowsSetup\Windows_22H2.iso"

$BitsTransfer = Start-BitsTransfer -Source $URI -Destination $DownloadPath -Asynchronous -Priority Foreground

Do {
    If ((Get-BitsTransfer $BitsTransfer.JobId).JobState -ne "Transferred") {
        $Status = "NotDone"
        Start-Sleep 5
    }
    Else {
        Get-BitsTransfer $BitsTransfer.JobId | Complete-BitsTransfer
        $Status = "Done"
    }
}While ($Status -ne "Done")

$mountResult = Mount-DiskImage -ImagePath $DownloadPath
$driveLetter = ($mountResult | Get-Volume).DriveLetter
$ExtractPath = $driveLetter + ":\*"
Copy-Item -Path "$ExtractPath" -Destination "C:\WindowsSetup\" -Recurse -Force -Verbose
Dismount-DiskImage -ImagePath $DownloadPath
Remove-Item "C:\WindowsSetup\Windows_22H2.iso" -Force
$ArgumentList = "/auto upgrade /eula accept /quiet"
Start-Process -NoNewWindow -Wait -FilePath "C:\WindowsSetup\setup.exe" -ArgumentList $ArgumentList

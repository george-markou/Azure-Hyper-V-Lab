New-AzResourceGroup -Name "staging-rg" -Location "westeurope"
Get-AzVMImageSku -Location westeurope -PublisherName  "microsoftwindowsserver" -Offer "WindowsServer"
$img=Get-AzVMImage -Location "westeurope" -PublisherName  "microsoftwindowsserver" -Offer "WindowsServer" -SKU "2022-datacenter-smalldisk-g2" | Sort-Object Version -Descending | Select-Object -First 1
$imgId= $img.id
$imageOSDisk = @{Id = $ImgId}
$diskconfig = New-AzDiskConfig -Location "westeurope" -CreateOption "FromImage" -ImageReference $imageOSDisk
New-AzDisk -ResourceGroupName "staging-rg" -DiskName "2022datacentersmalldiskg2" -Disk $diskconfig
$output=Grant-AzDiskAccess -ResourceGroupName  "staging-rg"  -DiskName "2022datacentersmalldiskg2" -Access 'Read' -DurationInSecond 3600
$sas=$output.accesssas

New-Item -Path "F:\VMS\Templates" -ItemType Directory
azcopy.exe copy $sas "F:\VMS\2022datacentersmalldiskg2.vhd" --check-md5 NoCheck
Convert-VHD -Path "F:\VMS\Templates\2022datacentersmalldiskg2.vhd" -DestinationPath "F:\VMS\Templates\2022datacentersmalldiskg2.vhdx" -VHDType Dynamic -DeleteSource

Revoke-AzDiskAccess -ResourceGroupName "staging-rg"  -Name "2022datacentersmalldiskg2"
Remove-AzDisk -ResourceGroupName "staging-rg" -Name "2022datacentersmalldiskg2" -Force

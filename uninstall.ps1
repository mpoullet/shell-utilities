$apps = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE InstallDate like '20160628'"
# WHERE Name like '%Microsoft%' 

foreach ($app in $apps) {
    "Name = " + $app.name
    $app.Uninstall()
}
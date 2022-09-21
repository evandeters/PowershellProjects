#Hostname and IP
$Hostname = hostname
$IP = Get-NetIPAddress | where AddressFamily -eq 'IPv4' | Select IPAddress | where IPAddress -NotLike '127.0.0.1' | Select -ExpandProperty IPAddress
$BoardID = Get-TrelloBoard -Name CCDC | Select -Expand id

$ListID = Get-TrelloList -BoardId $BoardID | where name -eq 'Windows' | select -expand id

$CardName = "Hostname [IP]"
$CardName = $CardName -Replace "Hostname", $Hostname
$CardName = $CardName -Replace "IP", $IP
$Card = New-TrelloCard -ListId $ListID -Name $CardName

#Users
$Users = Get-LocalUser | select -expand name
New-TrelloCardChecklist -Card $Card -Name Users -Item $Users

#Network Connections
$NetworkConnections = Get-NetTCPConnection -State Listen,Established | where-object {($_.RemotePort -ne 443) -and ($_.LocalAddress -inotmatch '::' )}| sort-object state,localport | select localaddress,localport,remoteaddress,remoteport,@{'Name' = 'ProcessName';'Expression'={(Get-Process -Id $_.OwningProcess).Name}} | format-table -AutoSize
New-TrelloCardChecklist -Card $Card -Name Connections -Item $NetworkConnections


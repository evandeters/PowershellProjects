#Hostname and IP
$Hostname = hostname
$IP = Get-NetIPAddress | where AddressFamily -eq 'IPv4' | Select IPAddress | where IPAddress -NotLike '127.0.0.1' | Select -ExpandProperty IPAddress

$CardName = "Hostname [IP]"
$CardName = $CardName -Replace "Hostname", $Hostname
$CardName = $CardName -Replace "IP", $IP
$Card = New-TrelloCard -ListId $IncomingTicketsList -Name $CardName

#Users
$Comment = pwsh -c (Get-TrelloCard -Board $Board -Name Users | Get-TrelloCardChecklist | Get-TrelloCardChecklistItem | select -ExpandProperty Name) | Out-String
$Comment = $Comment.Substring($Comment.LastIndexOf('----') + 10)
New-TrelloCardComment -Card (Get-TrelloCard -Name Users -Board (Get-TrelloBoard -Name CCDC)) -Comment $Comment

#Network Connections
$NetworkConnections = Get-NetTCPConnection -State Listen,Established | where-object {($_.RemotePort -ne 443) -and ($_.LocalAddress -inotmatch '::' )} | sort-object state,localport | select localaddress,localport,remoteaddress,remoteport,state,owningprocess,@{'Name' = 'ProcessName';'Expression'={(Get-Process -Id $_.OwningProcess).Name}} | %{Write-Output (-join ($_.localaddress, ':',  $_.LocalPort, ' --- ', $_.ProcessName))} | out-string
New-TrelloCardComment -Card $Card -Comment $NetworkConnections


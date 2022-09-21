#Create Board
$Board = New-TrelloBoard -Name CCDC
$BoardID = Get-TrelloBoard -Name CCDC | Select -Expand id

#Create Lists
$IncomingTicketsList = New-TrelloList -BoardID $BoardID -Name 'Incoming Tickets' -Position 1 | Select -expand id
$ResolvedTicketsList = New-TrelloList -BoardID $BoardID -Name 'Resolved Tickets' -Position 2 | Select -expand id
$LinuxList = New-TrelloList -BoardID $BoardID -Name 'Linux' -Position 3 | Select -expand id
$WindowsList = New-TrelloList -BoardID $BoardID -Name 'Windows' -Position 4 | Select -expand id
$NetworkingList = New-TrelloList -BoardID $BoardID -Name 'Networking' -Position 5 | Select -expand id
$BusinessList = New-TrelloList -BoardID $BoardID -Name 'Business' -Position 6 | Select -expand id

#Create Cards for Incoming Tickets
$BoxTemplateCard = New-TrelloCard -ListId $IncomingTicketsList -Name 'Box Template [DO NOT TOUCH]'
New-TrelloCardChecklist -Card $BoxTemplateCard -Name Baselining -Item @('Inventory', 'Change Default Passwords', 'Configure Log Forwarding')

#Users
$Comment = pwsh -c (Get-TrelloCard -Board $Board -Name Users | Get-TrelloCardChecklist | Get-TrelloCardChecklistItem | select -ExpandProperty Name) | Out-String
$Comment = $Comment.Substring($Comment.LastIndexOf('----') + 10)
New-TrelloCardComment -Card (Get-TrelloCard -Name Users -Board (Get-TrelloBoard -Name CCDC)) -Comment $Comment

#Network Connections
$NetworkConnections = Get-NetTCPConnection -State Listen,Established | where-object {($_.RemotePort -ne 443) -and ($_.LocalAddress -inotmatch '::' )} | sort-object state,localport | select localaddress,localport,remoteaddress,remoteport,state,owningprocess,@{'Name' = 'ProcessName';'Expression'={(Get-Process -Id $_.OwningProcess).Name}} | %{Write-Output (-join ($_.localaddress, ':',  $_.LocalPort, ' --- ', $_.ProcessName))} | out-string
New-TrelloCardComment -Card (Get-TrelloCard -Name "Windows Network Inventory" -Board (Get-TrelloBoard -Name CCDC)) -Comment $NetworkConnections


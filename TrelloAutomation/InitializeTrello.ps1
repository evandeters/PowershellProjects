[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
wget https://github.com/evanjd711/PowershellProjects/archive/refs/heads/main.zip -UseBasicParsing -OutFile $env:ProgramFiles\Trello.zip
Expand-Archive $env:ProgramFiles\Trello.zip -DestinationPath $env:root\Trello\
$TrelloPath = "$env:ProgramFiles\PowershellProjects-main\TrelloAutomation\"

$TrelloAPI = Read-Host "Trello API Key (https://trello.com/app-key):"
$TrelloAccessToken = Read-Host "Trello Access Token:"


$Hostname = hostname
$Computers = Get-ADComputer -filter *| Where-Object name -NotLike $Hostname | Select-Object -ExpandProperty Name
foreach ($Computer in $Computers) {
    Copy-Item -Path $TrelloPath -Destination "$env:ProgramFiles" -toSession (New-PSSession -ComputerName $Computer) -Recurse
}

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

Invoke-Command $Computers -ScriptBlock {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-Module PowerTrello -Scope AllUsers -Confirm:$false -Force
    Set-TrelloConfiguration -ApiKey $Using:TrelloAPI -AccessToken $Using:TrelloAccessToken -ErrorAction SilentlyContinue
    . $env:ProgramFiles\Trello\TrelloAutomation.ps1


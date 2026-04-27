param(
[string]$HostName = "127.0.0.1",
[int]$Port = 8770,
[string]$Token = "",
[int]$Dx1 = 120,
[int]$Dy1 = 0,
[int]$Dx2 = 0,
[int]$Dy2 = 120
)

$ErrorActionPreference = "Stop"

$client = [System.Net.Sockets.TcpClient]::new($HostName, $Port)
$stream = $client.GetStream()
$writer = [System.IO.StreamWriter]::new($stream)
$writer.AutoFlush = $true
$reader = [System.IO.StreamReader]::new($stream)

function Send-Frame([string]$json) { $writer.WriteLine($json) }
function Read-Frame() {
$line = $reader.ReadLine()
if ($null -eq $line) { throw "No response from server." }
$line
}

Send-Frame '{"type":"HELLO","seq":1,"payload":{}}'
Write-Host (Read-Frame)

Send-Frame ('{"type":"AUTH","seq":2,"payload":{"token":"' + $Token + '"}}')
Write-Host (Read-Frame)

Send-Frame ('{"type":"MOVE","seq":3,"payload":{"dx":' + $Dx1 + ',"dy":' + $Dy1 + '}}')
Start-Sleep -Milliseconds 250
Send-Frame ('{"type":"MOVE","seq":4,"payload":{"dx":' + $Dx2 + ',"dy":' + $Dy2 + '}}')
Start-Sleep -Milliseconds 250

Send-Frame '{"type":"TAP","seq":5,"payload":{"button":"left","clicks":1}}'
Send-Frame '{"type":"DISCONNECT","seq":6,"payload":{}}'
Write-Host (Read-Frame)

$client.Close()
Write-Host "Real cursor test completed."



$ApiKey=""
$KeySecret=""




$Target = "self"
$bios = gwmi win32_bios
$ServiceTag = $bios.SerialNumber




if (!$token) {
$AuthURI = "https://apigtwb2c.us.dell.com/auth/oauth/v2/token"
$OAuth = "$ApiKey`:$KeySecret"
$Bytes = [System.Text.Encoding]::ASCII.GetBytes($OAuth)
$EncodedOAuth = [Convert]::ToBase64String($Bytes)
$Headers = @{ }
$Headers.Add("authorization", "Basic $EncodedOAuth")
$Authbody = 'grant_type=client_credentials'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$AuthResult = Invoke-RESTMethod -Method Post -Uri $AuthURI -Body $AuthBody -Headers $Headers
$token = $AuthResult.access_token
$headers = @{"Accept" = "application/json" }
$headers.Add("Authorization", "Bearer $token")
}

foreach ($thing in $ServiceTag){
$params = @{ }
$params = @{servicetags = $thing; Method = "GET" }
$response = Invoke-RestMethod -Uri "https://apigtwb2c.us.dell.com/PROD/sbil/eapi/v5/asset-entitlements" -Headers $headers -Body $params -Method Get -ContentType "application/json" -ea 0
$servicetag = $response.servicetag
$Json = $response | ConvertTo-Json
$response = $Json | ConvertFrom-Json
$Device = $response.productLineDescription
$ShipDate = $response.shipDate
$EndDate = ($response.entitlements | Select -Last 3).endDate
$Support = ($response.entitlements | Select -Last 1).serviceLevelDescription
$ShipDate = $ShipDate | Get-Date -f "MM-dd-y"
$EndDate = $EndDate | Get-Date -f "MM-dd-y"
$today = get-date
$type = $response.ProductID

}

$EndDatetest= $EndDate|Sort-Object -Descending |select -First 1



New-Item -Path HKLM:\Software\SCCM\
New-Item -Path HKLM:\Software\SCCM\DELL\

New-ItemProperty -Path HKLM:\Software\SCCM\DELL\ -Name Servicetag  -Value $ServiceTag
New-ItemProperty -Path HKLM:\Software\SCCM\DELL\ -Name Model -Value $Device
New-ItemProperty -Path HKLM:\Software\SCCM\DELL\ -Name ShipDate -Value $ShipDate
New-ItemProperty -Path HKLM:\Software\SCCM\DELL\ -Name warrantyEndDate -Value $EndDatetest




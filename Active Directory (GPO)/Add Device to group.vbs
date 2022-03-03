Const ADS_PROPERTY_APPEND = 3
Set WshShell = WScript.CreateObject("WScript.Shell")
'----Get Computer DN------
Set objADSysInfo = CreateObject("ADSystemInfo")
ComputerDN = objADSysInfo.ComputerName
strcomputerdn = "LDAP://" & computerDN
Set objADSysInfo = Nothing
'----Connect AD-----
Set oRoot = GetObject("LDAP://rootDSE")
strDomainPath = oRoot.Get("defaultNamingContext")
Set oConnection = CreateObject("ADODB.Connection")
oConnection.Provider = "ADsDSOObject"
oConnection.Open "Active Directory Provider"
'-----Read commandline---
Set args = WScript.Arguments
For i = 0 To Args.Count - 1
addgroup Args.Item( i )
next
Function Addgroup(groupname)
'----Get Group DN------
Set oRs = oConnection.Execute("SELECT adspath FROM 'LDAP://" & strDomainPath & "'" & "WHERE objectCategory='group' AND " & "Name='" & GroupName & "'")
If Not oRs.EOF Then
strAdsPath = oRs("adspath")
End If
Set objGroup = GetObject (stradspath)
Set objComputer = GetObject (strComputerDN)
If (objGroup.IsMember(objComputer.AdsPath) = False) Then
objGroup.PutEx ADS_PROPERTY_APPEND, "member", Array(computerdn)
objGroup.SetInfo
End If
End Function
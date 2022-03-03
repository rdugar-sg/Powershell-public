Set objNetwork = CreateObject("Wscript.Network")
strComputerName = objNetwork.ComputerName
'wscript.echo strComputerName
location=left(strComputerName,3)


'wscript.echo location


Const ADS_SCOPE_SUBTREE = 2

Set objConnection = CreateObject("ADODB.Connection")
Set objCommand =   CreateObject("ADODB.Command")
objConnection.Provider = "ADsDSOObject"
objConnection.Open "Active Directory Provider"
Set objCommand.ActiveConnection = objConnection
a
objCommand.Properties("Page Size") = 1000
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE 




objCommand.CommandText = _
    "SELECT ADsPath FROM 'LDAP://OU=LOC,dc=ekgroup,dc=org' WHERE objectCategory='organizationalUnit'"
Set objRecordSet = objCommand.Execute

objRecordSet.MoveFirst
Do Until objRecordSet.EOF
    Pfad=objRecordSet.Fields("ADsPath").Value
	

if InStr(pfad,location) then
loc1=pfad
exit do
end if

    objRecordSet.MoveNext
Loop


objCommand.CommandText = _
    "SELECT ADsPath FROM 'LDAP://dc=ekgroup,dc=org' WHERE objectCategory='computer' " & _
        "AND name='" & strComputerName & "'"
Set objRecordSet = objCommand.Execute

objRecordSet.MoveFirst
Do Until objRecordSet.EOF
    Pfad=objRecordSet.Fields("ADsPath").Value
	
'wscript.echo pfad
    objRecordSet.MoveNext
Loop


loc1=Replace(loc1,"//","//OU=Computers,")
'wscript.echo loc1





Const ADS_PROPERTY_APPEND = 3
Set objGroup = GetObject (loc1)
Set objComputer = GetObject (Pfad)

'Pfad=Replace(Pfad,"LDAP://","") 


'If (objGroup.IsMember(objComputer.AdsPath) = False) Then
 'objGroup.PutEx ADS_PROPERTY_APPEND, "member", Array(Pfad)
 'objGroup.SetInfo
'End If

objGroup.MoveHere Pfad, vbNullString

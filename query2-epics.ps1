Write-Host Starting
$starttime = get-date

#V1 API Headers
$reqHeaders = @{}
$reqHeaders.Add("ServerHost", "www10.v1host.com")
$reqHeaders.Add("Authorization", "Bearer 1.FunS5vVyUg1pF0KfuiAuTg1CQ7Y=")
$PostUri = 'https://www10.v1host.com/NIKE01a/query.v1'

#Send to file
$reportPath = 'C:\Users\lleoco\documents\sandbox\v1query1.csv'

#Create table object
$dt = New-Object System.Data.DataTable "Epics"

#Define columns
$coloid = New-Object System.Data.DataColumn("oid",[string])
$colKey = New-Object System.Data.DataColumn("Key",[string])
$colNumber = New-Object System.Data.DataColumn("Number",[string])
$colName = New-Object System.Data.DataColumn("Name",[string])
$colAssetType = New-Object System.Data.DataColumn("Asset Type",[string])
$colStatus = New-Object System.Data.DataColumn("Status",[string])
$colState = New-Object System.Data.DataColumn("State",[string])
$colSuperNum = New-Object System.Data.DataColumn("Parent Number",[string])
$colSuper = New-Object System.Data.DataColumn("Parent",[string])
$colSuperType = New-Object System.Data.DataColumn("Parent Type",[string])
$colScope = New-Object System.Data.DataColumn("Scope",[string])
$colPScope = New-Object System.Data.DataColumn("Parent Scope",[string])
$colGPScope = New-Object System.Data.DataColumn("Grandparent Scope",[string])
$colSubs = New-Object System.Data.DataColumn("Subs",[string])

#Add columns to table
$dt.Columns.Add($coloid)
$dt.Columns.Add($colKey)
$dt.Columns.Add($colNumber)
$dt.Columns.Add($colName)
$dt.Columns.Add($colAssetType)
$dt.Columns.Add($colStatus)
$dt.Columns.Add($colState)
$dt.Columns.Add($colSuperNum)
$dt.Columns.Add($colSuper)
$dt.Columns.Add($colSuperType)
$dt.Columns.Add($colScope)
$dt.Columns.Add($colPScope)
$dt.Columns.Add($colGPScope)
$dt.Columns.Add($colSubs)

#Define Query
$epicQuery = @"
{
  "from": "Epic",
  "select": [
    "Key",
    "Number",
    "Name",
    "AssetType",
    "Status.Name",
    "Status.RollupState",
    "Super.Number",
    "Super.Name",
    "Super.AssetType",
    "Scope.Name",
    "Scope.Parent.Name",
    "Scope.Parent.Parent.Name",
    "Subs[AssetState!='Dead'].@Count"
  ],
  "find": "FY19 Q2",
  "findin": "Scope.Name",
  "where": {
    "Scope.Parent.Parent.ID": "Scope:807715"
  }
}
"@


$epicResults = Invoke-RestMethod -Uri $PostUri -Body $epicQuery -Headers $reqHeaders -Method POST -ContentType 'application/json'

foreach($rslt in $epicResults[0]){
    $nr = $dt.NewRow()
    $nr.oid = $rslt._oid
    $nr.Key = $rslt.Key
    $nr.Number = $rslt.Number
    $nr.Name = $rslt.Name
    $nr.'Asset Type' = $rslt.AssetType
    $nr.Status = $rslt.'Status.Name'
    $nr.State = $rslt.'Status.RollupState'
    $nr.'Parent Number' = $rslt.'Super.Number'
    $nr.Parent = $rslt.'Super.Name'
    $nr.'Parent Type' = $rslt.'Super.AssetType'
    $nr.Scope = $rslt.'Scope.Name'
    $nr.'Parent Scope' = $rslt.'Scope.Parent.Name'
    $nr.'Grandparent Scope' = $rslt.'Scope.Parent.Parent.Name'
    $nr.Subs = $rslt."Subs[AssetState!='Dead'].@Count"
    $dt.Rows.Add($nr)

    #foreach($sub in $rslt.Number){
    #write-host $sub
    #}
}

Write-Host Exporting $reportPath
$dt | Export-Csv -Path $reportPath -NoTypeInformation

$endtime = get-date
$runtime = $endtime - $starttime
Write-Host Runtime: $runtime

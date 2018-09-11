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
$colKey = New-Object System.Data.DataColumn("Key",[string])
$colNumber = New-Object System.Data.DataColumn("Number",[string])
$colName = New-Object System.Data.DataColumn("Name",[string])
$colScope = New-Object System.Data.DataColumn("Scope",[string])
$colStatus = New-Object System.Data.DataColumn("Status",[string])
$colSubs = New-Object System.Data.DataColumn("Subs",[string])
$colSubsAndDown = New-Object System.Data.DataColumn("SubsAndDown",[string])

#Add columns to table
$dt.Columns.Add($colKey)
$dt.Columns.Add($colNumber)
$dt.Columns.Add($colName)
$dt.Columns.Add($colScope)
$dt.Columns.Add($colStatus)
$dt.Columns.Add($colSubs)
$dt.Columns.Add($colSubsAndDown)

#Define Query
$epicQuery = @"
{
  "from": "Epic",
  "select": [
    "Key",
    "Number",
    "Name",
    "Scope.Name",
    "Status.Name",
    "Subs[AssetState!='Dead'].@Count",
    "SubsAndDown[AssetState!='Dead'].@Count"
  ],
  "find": "FY19 Q2",
  "findin": "Scope.Name",
  "where": {
    "Status.RollupState": "Active"
  }
}
"@


$epicResults = Invoke-RestMethod -Uri $PostUri -Body $epicQuery -Headers $reqHeaders -Method POST -ContentType 'application/json'

foreach($rslt in $epicResults[0]){
    $nr = $dt.NewRow()
    $nr.Key = $rslt.Key
    $nr.Number = $rslt.Number
    $nr.Name = $rslt.Name
    $nr.Scope = $rslt.'Scope.Name'
    $nr.Status = $rslt.'Status.Name'
    $nr.Subs = $rslt."Subs[AssetState!='Dead'].@Count"
    $nr.SubsAndDown = $rslt."Subs[AssetState!='Dead'].@Count"
    $dt.Rows.Add($nr)
}

Write-Host Exporting $reportPath
$dt | Export-Csv -Path $reportPath -NoTypeInformation

$endtime = get-date
$runtime = $endtime - $starttime
Write-Host Runtime: $runtime

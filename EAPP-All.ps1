# EAPP Epics
Write-Host Starting
$starttime = get-date

#V1 API Headers
$reqHeaders = @{}
$reqHeaders.Add("ServerHost", "www10.v1host.com")
$reqHeaders.Add("Authorization", "Bearer 1.FunS5vVyUg1pF0KfuiAuTg1CQ7Y=")
$PostUri = 'https://www10.v1host.com/NIKE01a/query.v1'

#Send to file
$rptEpics = 'C:\Users\lleoco\documents\sandbox\Epics.csv'

$dtE = New-Object System.Data.DataTable "EAPP"

#Define columns and add to tables
[void]$dtE.Columns.Add("ID",[string])
[void]$dtE.Columns.Add("Key",[string])
[void]$dtE.Columns.Add("Number",[string])
[void]$dtE.Columns.Add("Name",[string])
[void]$dtE.Columns.Add("AssetType",[string])
[void]$dtE.Columns.Add("Category",[string])
[void]$dtE.Columns.Add("Status",[string])
[void]$dtE.Columns.Add("State",[string])
[void]$dtE.Columns.Add("ParentNumber",[string])
[void]$dtE.Columns.Add("ParentName",[string])
[void]$dtE.Columns.Add("ParentType",[string])
[void]$dtE.Columns.Add("Scope",[string])
[void]$dtE.Columns.Add("ParentScope",[string])
[void]$dtE.Columns.Add("GrandparentScope",[string])
[void]$dtE.Columns.Add("SubCount",[string])
[void]$dtE.Columns.Add("IsCompleted",[string])
[void]$dtE.Columns.Add("IsClosed",[string])
[void]$dtE.Columns.Add("IsInactive",[string])
[void]$dtE.Columns.Add("IsDead",[string])
[void]$dtE.Columns.Add("IsDeleted",[string])


$types = @{Epic = '"Category.Name",'; Story = '"AssetType",'; Defect = '"AssetType",'}

foreach($t in $types.keys){

$qEpics = @"
{
  "from": "$($t)",
  "select": [
    "Key",
    "Number",
    "Name",
    "AssetType",
    $($types.$t)    
    "Status.Name",
    "Status.RollupState",
    "Super.Number",
    "Super.Name",
    "Super.Scope.Name",
    "Super.Scope.Parent.Name",
    "Super.AssetType",
    "Scope.Name",
    "Scope.Parent.Name",
    "Scope.Parent.Parent.Name",
    "Subs[AssetState!='Dead'].@Count",
    "IsCompleted",
    "IsClosed",
    "IsInactive",
    "IsDead",
    "IsDeleted"
  ],
  "find": "EAPP",
  "findin": "Scope.ParentAndUp.Name"
}
"@
#write-host $qEpics}

#Run query on the API
$rEpics = Invoke-RestMethod -Uri $PostUri -Body $qEpics -Headers $reqHeaders -Method POST -ContentType 'application/json'

foreach($rw in $rEpics[0]){
    $nre = $dtE.NewRow()
    $nre.ID = $rw."_oid"
    $nre.Key = $rw."Key"
    $nre.Number = $rw."Number"
    $nre.Name = $rw."Name"
    $nre.AssetType = $rw."AssetType"
    $nre.Category = $rw."Category.Name"
    $nre.Status = $rw."Status.Name"
    $nre.State = $rw."Status.RollupState"
    $nre.ParentNumber = $rw."Super.Number"
    $nre.ParentName = $rw."Super.Name"
    $nre.ParentType = $rw."Super.AssetType"
    $nre.Scope = $rw."Scope.Name"
    $nre.ParentScope = $rw."Scope.Parent.Name"
    $nre.GrandparentScope = $rw."Scope.Parent.Parent.Name"
    $nre.SubCount = $rw."Subs[AssetState!='Dead'].@Count"
    $nre.IsCompleted = $rw."IsCompleted"
    $nre.IsClosed = $rw."IsClosed"
    $nre.IsInactive = $rw."IsInactive"
    $nre.IsDead = $rw."IsDead"
    $nre.IsDeleted = $rw."IsDeleted"

    $dtE.Rows.Add($nre)
}

}
#$dtE | Format-Table -AutoSize

Write-Host Exporting $rptEpics
$dtE | Export-Csv -Path $rptEpics -NoTypeInformation

$endtime = get-date
$runtime = $endtime - $starttime
Write-Host Runtime: $runtime
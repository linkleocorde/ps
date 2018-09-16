# EAPP Epics
Write-Host Starting
$starttime = get-date

#V1 API Headers
$reqHeaders = @{}
$reqHeaders.Add("ServerHost", "www10.v1host.com")
$reqHeaders.Add("Authorization", "Bearer 1.FunS5vVyUg1pF0KfuiAuTg1CQ7Y=")
$PostUri = 'https://www10.v1host.com/NIKE01a/query.v1'

#Send to file
$rptEpics = 'C:\Users\lleoco\Documents\My Tableau Repository\Datasources\EAPP-All.csv'
$rptScope = 'C:\Users\lleoco\Documents\My Tableau Repository\Datasources\EAPP-Scope.csv'

$dtE = New-Object System.Data.DataTable "EAPP"
$dtS = New-Object System.Data.DataTable "Scope"

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
[void]$dtE.Columns.Add("ParentCategory",[string])
[void]$dtE.Columns.Add("Scope",[string])
[void]$dtE.Columns.Add("ParentScope",[string])
[void]$dtE.Columns.Add("GrandparentScope",[string])
[void]$dtE.Columns.Add("SubCount",[string])
[void]$dtE.Columns.Add("IsCompleted",[string])
[void]$dtE.Columns.Add("IsClosed",[string])
[void]$dtE.Columns.Add("IsInactive",[string])
[void]$dtE.Columns.Add("IsDead",[string])
[void]$dtE.Columns.Add("IsDeleted",[string])

[void]$dtS.Columns.Add("ID",[string])
[void]$dtS.Columns.Add("Key",[string])
[void]$dtS.Columns.Add("Number",[string])
[void]$dtS.Columns.Add("Scope",[string])


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
    "Super.AssetType",
    "Super.Category.Name",
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
  "findin": "Scope.ParentMeAndUp.Name"
}
"@
#write-host $qEpics}

$qScope = @"
{
  "from": "$($t)",
  "select": [
    "Key",
    "Number",
    "Scope.Name"
  ],
  "find": "FY19 Q2",
  "findin": "Scope.Name"
}
"@

#Run query on the API
$rEpics = Invoke-RestMethod -Uri $PostUri -Body $qEpics -Headers $reqHeaders -Method POST -ContentType 'application/json'
$rScope = Invoke-RestMethod -Uri $PostUri -Body $qScope -Headers $reqHeaders -Method POST -ContentType 'application/json'

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
    $nre.ParentCategory = $rw."Super.Category.Name"
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

foreach($rw in $rScope[0]){
    $nrs = $dtS.NewRow()
    $nrs.ID = $rw."_oid"
    $nrs.Key = $rw."Key"
    $nrs.Number = $rw."Number"
    $nrs.Scope = $rw."Scope.Name"

    $dtS.Rows.Add($nrs)
}

}
#$dtE | Format-Table -AutoSize

Write-Host Exporting $rptEpics
$dtE | Export-Csv -Path $rptEpics -NoTypeInformation


Write-Host Exporting $rptScope
$dtS | Export-Csv -Path $rptScope -NoTypeInformation

$endtime = get-date
$runtime = $endtime - $starttime
Write-Host Runtime: $runtime
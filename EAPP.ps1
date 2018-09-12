Write-Host Starting
$starttime = get-date

#V1 API Headers
$reqHeaders = @{}
$reqHeaders.Add("ServerHost", "www10.v1host.com")
$reqHeaders.Add("Authorization", "Bearer 1.FunS5vVyUg1pF0KfuiAuTg1CQ7Y=")
$PostUri = 'https://www10.v1host.com/NIKE01a/query.v1'

#Send to file
$rptPortfolio = 'C:\Users\lleoco\documents\sandbox\EAPP.csv'
$rptEpics = 'C:\Users\lleoco\documents\sandbox\Epics.csv'

#Create table objects
$dtP = New-Object System.Data.DataTable "EAPP"
$dtE = New-Object System.Data.DataTable "Epics"

#Define columns and add to tables

#$cAssetType = New-Object System.Data.DataColumn("AssetType",[string])
    #$dt.Columns.Add($cAssetType)
$dtP.Columns.Add("ID",[string])
$dtP.Columns.Add("Name",[string])
$dtP.Columns.Add("PlanningLevel",[string])
$dtP.Columns.Add("AssetID",[string])
$dtP.Columns.Add("AssetType",[string])

$dtE.Columns.Add("ID",[string])
$dtE.Columns.Add("Key",[string])
$dtE.Columns.Add("Number",[string])
$dtE.Columns.Add("Name",[string])
$dtE.Columns.Add("AssetType",[string])
$dtE.Columns.Add("Status",[string])
$dtE.Columns.Add("State",[string])
$dtE.Columns.Add("ParentNumber",[string])
$dtE.Columns.Add("ParentName",[string])
$dtE.Columns.Add("ParentType",[string])
$dtE.Columns.Add("Scope",[string])
$dtE.Columns.Add("ParentScope",[string])
$dtE.Columns.Add("GrandparentScope",[string])
$dtE.Columns.Add("SubCount",[string])


#Define Query
$qEAAP = @"
{
  "from": "Scope",
  "select": [
    "Name",
    "PlanningLevel.Name",
    "Workitems[AssetState!='Dead'].ID"
  ],
  "where": {
    "ID": "Scope:807715"
  }
}
"@

#Run query on the API
$rEAPP = Invoke-RestMethod -Uri $PostUri -Body $qEAAP -Headers $reqHeaders -Method POST -ContentType 'application/json'
    <#
    The first query targets exactly one scope, so what we REALLY want is all the IDs belonging
    to that scope. We'll turn those IDs into a looping array that re-uses the SCOPE for each row.

    We'll also use this new array for subsequent queries.
    #>
$myAssets = $rEAPP."Workitems[AssetState!='Dead'].ID"

#Loop through, creating records...
$myAssets | foreach {
    $nr = $dtP.NewRow()
    $nr.ID = $rEAPP._oid
    $nr.Name = $rEAPP.Name
    $nr.PlanningLevel = $rEAPP.'PlanningLevel.Name'
    $nr.AssetID = $_._oid
    $nr.AssetType = $_._oid.Split(":")[0]

    $dtP.Rows.Add($nr)
}
#$dtP | Format-Table -AutoSize

#Get all of the Epics
$dtP | foreach {

    if($_.AssetType -in 'Theme','Test','Task'){return}
    
$qEpic=@"
{
  "from": "$($_.AssetType)",
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
  "where": {
    "ID": "$($_.AssetID)"
  }
}
"@

$rEpic = Invoke-RestMethod -Uri $PostUri -Body $qEpic -Headers $reqHeaders -Method POST -ContentType 'application/json'

    $nre = $dtE.NewRow()
    $nre.ID = $rEpic."_oid"
    $nre.Key = $rEpic."Key"
    $nre.Number = $rEpic."Number"
    $nre.Name = $rEpic."Name"
    $nre.AssetType = $rEpic."AssetType"
    $nre.Status = $rEpic."Status.Name"
    $nre.State = $rEpic."Status.RollupState"
    $nre.ParentNumber = $rEpic."Super.Number"
    $nre.ParentName = $rEpic."Super.Name"
    $nre.ParentType = $rEpic."Super.AssetType"
    $nre.Scope = $rEpic."Scope.Name"
    $nre.ParentScope = $rEpic."Scope.Parent.Name"
    $nre.GrandparentScope = $rEpic."Scope.Parent.Parent.Name"
    $nre.SubCount = $rEpic."Subs[AssetState!='Dead'].@Count"

    $dtE.Rows.Add($nre)
}

Write-Host Exporting $rptPortfolio
$dtP | Export-Csv -Path $rptPortfolio -NoTypeInformation

Write-Host Exporting $rptEpic
$dtE | Export-Csv -Path $rptEpics -NoTypeInformation

$endtime = get-date
$runtime = $endtime - $starttime
Write-Host Runtime: $runtime

#$dtP | foreach {Write-Host $_.AssetID}
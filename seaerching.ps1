#V1 API Headers
$reqHeaders = @{}
$reqHeaders.Add("ServerHost", "www10.v1host.com")
$reqHeaders.Add("Authorization", "Bearer 1.FunS5vVyUg1pF0KfuiAuTg1CQ7Y=")
$PostUri = 'https://www10.v1host.com/NIKE01a/query.v1'

$query = @"
{
  "from": "EpicCategory",
  "select": [
    "Name",
    "Description",
    "Order",
    "AssetState",
    "AssetType",
    "Epics[AssetState!='Dead'].@Count"
  ]
}
"@

$result = Invoke-RestMethod -Uri $PostUri -Body $query -Headers $reqHeaders -Method POST -ContentType 'application/json'

$result | Format-Table -AutoSize
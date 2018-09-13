#V1 API Headers
$reqHeaders = @{}
$reqHeaders.Add("ServerHost", "www10.v1host.com")
$reqHeaders.Add("Authorization", "Bearer 1.FunS5vVyUg1pF0KfuiAuTg1CQ7Y=")
$PostUri = 'https://www10.v1host.com/NIKE01a/query.v1'

$query = @"
{
  "from": "Epic",
  "select": [
    "Key",
    "Number",
    "Name",
    "Category.Name",
    "AssetType",
    "Status.Name",
    "Status.RollupState",
    "IsCompleted",
    "IsClosed",
    "IsInactive",
    "IsDead",
    "IsDeleted",
    "Super.Number",
    "Super.Name",
    "Super.Scope.Name",
    "Super.Scope.Parent.Name",
    "Super.AssetType",
    "Scope.Name",
    "Scope.Parent.Name",
    "Scope.Parent.Parent.Name",
    "Subs[AssetState!='Dead'].@Count"
  ],
  "find": "EAPP",
  "findin": "Scope.ParentAndUp.Name",
  "where": {
    "Number": "E-29718"
  }
}
"@

$result = Invoke-RestMethod -Uri $PostUri -Body $query -Headers $reqHeaders -Method POST -ContentType 'application/json'

$result | Format-List
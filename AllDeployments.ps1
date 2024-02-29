# Connect to Power BI Service
Connect-PowerBIServiceAccount | Out-Null
# Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups" -Method Get


# Function to call Power BI REST API
function Invoke-PowerBIApi {
    param (
        [string]$Url,
        [string]$Method = 'Get'
    )

    $response = Invoke-PowerBIRestMethod -Url $Url -Method $Method
    return $response | ConvertFrom-Json
}

# Retrieve all deployment pipelines
$pipelinesUri = "https://api.powerbi.com/v1.0/myorg/Pipelines"
$pipelines = Invoke-PowerBIApi -Url $pipelinesUri
# print($pipelines)
# Create an empty array to hold the deployment history
$deploymentHistories = @()

# Retrieve deployment history for each pipeline
foreach ($pipeline in $pipelines.value) {
    $pipelineId = $pipeline.id
    $historyUri = "https://api.powerbi.com/v1.0/myorg/Pipelines/$pipelineId/operations"
    $history = Invoke-PowerBIApi -Url $historyUri

    foreach ($item in $history.value) {
        $lastUpdatedTime = [datetime]::Parse($item.lastUpdatedTime) # Convert to DateTime object
        $noteContent = $item.note.content # Access the note content directly
        $deploymentHistories += [PSCustomObject]@{
            # PipelineId   = $pipelineId
            PipelineName = $pipeline.displayName
            # DeploymentId = $item.id
            # Status       = $item.status
            LastUpdatedTime    = $lastUpdatedTime
            NoteContent        = $noteContent
            DeployedDate = $item.createdDateTime
        }
    }
}

# Display the deployment history in a tabular format
$deploymentHistories | Format-Table -AutoSize

# Optionally, you can export the data to a CSV file
# $deploymentHistories | Export-Csv -Path "./deploymentHistory.csv" -NoTypeInformation

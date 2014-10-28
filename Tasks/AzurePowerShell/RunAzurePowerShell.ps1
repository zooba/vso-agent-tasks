[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $DeploymentEnvironmentName,

    [String] [Parameter(Mandatory = $false)]
    $CollectionUrl,

    [String] [Parameter(Mandatory = $false)]
    $TeamProject,

    [String] [Parameter(Mandatory = $true)]
    $ScriptPath,

    [String] [Parameter(Mandatory = $true)]
    $ScriptArguments
)

Write-Verbose "Entering script RunAzurePowerShell.ps1"

Write-Verbose "DeploymentEnvironmentName= $DeploymentEnvironmentName"
Write-Verbose "CollectionUrl= $CollectionUrl"
Write-Verbose "TeamProject= $TeamProject"

if (!$distributedTaskContext) #running directly via command line
{
    import-module "..\..\..\Agent\Worker\Modules\Microsoft.TeamFoundation.DistributedTask.Task.Common"
    import-module "..\..\..\Agent\Worker\Modules\Microsoft.TeamFoundation.DistributedTask.Task.Build"
    import-module "..\..\..\Agent\Worker\Modules\Microsoft.TeamFoundation.DistributedTask.Task.Deployment.Azure\Microsoft.TeamFoundation.DistributedTask.Task.Deployment.Azure.psm1"

    Write-Host "Using CollectionUrl and TeamProject from script parameters" -ForegroundColor Yellow
    $collectionUrl = $CollectionUrl
    $teamProject = $TeamProject

    if(!$collectionUrl)
    {
        throw "CollectionUrl was not passed on the command line and no distributedTaskContext was found."
    }
    if (!$teamProject)
    {
        throw "TeamProject was not passed on the command line and no distributedTaskContext was found."
    }

    #Call the function in the module to get the deployment environment set up here.  Function name is Setup-AzureSubscription
    Setup-AzureSubscription -DeploymentEnvironmentName $DeploymentEnvironmentName -CollectionUrl $collectionUrl -TeamProject $teamProject
}

Write-Host "Calling custom script!" -ForegroundColor Green

#ENSURE: We pass arguments verbatim on the command line to the custom script
Write-Host "ScriptArguments= " $ScriptArguments
Write-Host "ScriptPath= " $ScriptPath

$scriptCommand = "$ScriptPath $scriptArguments"
Write-Host "scriptCommand=" $scriptCommand
Invoke-Expression -Command $scriptCommand

Write-Host "Back from custom script!" -ForegroundColor Green

Write-Verbose "Leaving script RunAzurePowerShell.ps1"
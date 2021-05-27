﻿#---------------------------------------------------------------------------
# Name:        ProvisionOptiEnvironment.ps1
#
# Summary:     This script will provision a brand new Opti
#              environment without pushing new code. (Usually
#              the Preproduction and Production environments)
#              
# Version:     1.0
#
# Last Updated: 5/27/2021
#
# Author: Eric Markson - eric.markson@perficient.com | eric@ericmarkson.com | https://optimizelyvisuals.dev/
#
# License: GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
#---------------------------------------------------------------------------

#Setting up Parameters 
#Setting each Paramater has Mandatory, as they are not optional
#Validating each paramarer for being Null or Empty, using the built in Validator
param
  (
    [Parameter(Position=0, Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ClientKey,
    [Parameter(Position=1, Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ClientSecret,
    [Parameter(Position=2, Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectID,
    [Parameter(Position=3)]
    [ValidateNotNullOrEmpty()]
    [string]$ArtifactPath = "./Packages/ProvisionEnvironment.cms.app.1.nupkg",
	[ValidateSet("Integration", "Preproduction", "Production")]
    [string]$TargetEnvironment
  )

#Checking that the required params exist and are not white space
if([string]::IsNullOrWhiteSpace($ClientKey)){
    throw "A Client Key is needed. Please supply one."
}
if([string]::IsNullOrWhiteSpace($ClientSecret)){
    throw "A Client Secret Key is needed. Please supply one."
}
if([string]::IsNullOrWhiteSpace($ProjectID)){
    throw "A Project ID GUID is needed. Please supply one."
}
if([string]::IsNullOrWhiteSpace($ArtifactPath)){
    throw "A path for the NUPKG file location is needed. Please supply one."
}
if([string]::IsNullOrWhiteSpace($TargetEnvironment)){
    throw "A target deployment environment is needed. Please supply one."
}

Write-Host "If this environment has code on it, this can be destructive."

$confirmation = Read-Host "Do you want to proceed? 'y' to continue. 'n' to quit"
if ($confirmation.ToLower() -ne 'y') {
    exit
}

.\UploadEpiPackage.ps1 -ClientKey $ClientKey -ClientSecret $ClientSecret -ProjectID $ProjectID -ArtifactPath $ArtifactPath

.\DeployToEnvironment.ps1 -ClientKey $ClientKey -ClientSecret $ClientSecret -ProjectID $ProjectID -ArtifactPath $ArtifactPath -TargetEnvironment $TargetEnvironment -UseMaintenancePage $false

.\CompleteOrResetDeployment.ps1 -ClientKey $ClientKey -ClientSecret $ClientSecret -ProjectID $ProjectID -TargetEnvironment $TargetEnvironment -Action "Reset"
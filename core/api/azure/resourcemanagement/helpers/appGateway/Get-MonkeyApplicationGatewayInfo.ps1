# Monkey365 - the PowerShell Cloud Security Tool for Azure and Microsoft 365 (copyright 2022) by Juan Garrido
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Function Get-MonkeyApplicationGatewayInfo {
    <#
        .SYNOPSIS
		Get Application Gateway metadata from Azure

        .DESCRIPTION
		Get Application Gateway metadata from Azure

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyApplicationGatewayInfo
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>

	[CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Scope="Function")]
	Param (
        [Parameter(Mandatory=$True, ValueFromPipeline = $True)]
        [Object]$InputObject,

        [parameter(Mandatory=$false, HelpMessage="API version")]
        [String]$APIVersion = "2023-02-01"
    )
    Process{
        try{
            $msg = @{
				MessageData = ($message.AzureUnitResourceMessage -f $InputObject.Name,"Application Gateway");
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = 'info';
				InformationAction = $O365Object.InformationAction;
				Tags = @('AzureAppGatewayInfo');
			}
			Write-Information @msg
            $p = @{
			    Id = $InputObject.Id;
                Expand = 'frontendIPConfigurations/publicIPAddress';
                ApiVersion = $APIVersion;
                Verbose = $O365Object.verbose;
                Debug = $O365Object.debug;
                InformationAction = $O365Object.InformationAction;
		    }
		    $appGateway = Get-MonkeyAzObjectById @p
            if($null -ne $appGateway){
                $appGatewayObject = $appGateway | New-MonkeyApplicationGatewayObject
                #Get listeners
                $appGatewayObject.listeners = $appGatewayObject | Get-MonkeyApplicationGatewayListener
                #get WAF policies
                $appGatewayObject | Get-MonkeyAzApplicationGatewayWAFPolicy
                #Get Locks
                $appGatewayObject.locks = $appGatewayObject | Get-MonkeyAzLockInfo
                #Get diagnostic settings
                $p = @{
		            Id = $appGatewayObject.Id;
                    Verbose = $O365Object.verbose;
                    Debug = $O365Object.debug;
                    InformationAction = $O365Object.InformationAction;
	            }
	            $diag = Get-MonkeyAzDiagnosticSettingsById @p
                if($diag){
                    #Add to object
                    $appGatewayObject.diagnosticSettings.enabled = $true;
                    $appGatewayObject.diagnosticSettings.name = $diag.name;
                    $appGatewayObject.diagnosticSettings.id = $diag.id;
                    $appGatewayObject.diagnosticSettings.properties = $diag.properties;
                    $appGatewayObject.diagnosticSettings.rawData = $diag;
                }
                #Return object
                return $appGatewayObject
            }
        }
        catch{
            Write-Verbose $_
        }
    }
}

﻿# Monkey365 - the PowerShell Cloud Security Tool for Azure and Microsoft 365 (copyright 2022) by Juan Garrido
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

Function New-MonkeyNetworkWatcherFlowLogObject {
<#
        .SYNOPSIS
		Create a new Network Watcher NSG Flow Log object

        .DESCRIPTION
		Create a new Network Watcher NSG Flow Log object

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: New-MonkeyNetworkWatcherFlowLogObject
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
	[CmdletBinding()]
	Param (
        [parameter(Mandatory= $True, ValueFromPipeline = $True, HelpMessage="Network Watcher Flow Log object")]
        [Object]$InputObject
    )
    Process{
        try{
            #Create ordered dictionary
            $FLObject = [ordered]@{
                id = $InputObject.targetResourceId;
		        targetResourceId = $InputObject.targetResourceId;
                properties = $InputObject.properties;
                enabled = $InputObject.properties.enabled;
                retentionPolicyEnabled = $InputObject.properties.retentionPolicy.enabled;
                retentionPolicyPeriod = $InputObject.properties.retentionPolicy.days;
                resourceGroupName = if($null -ne $InputObject.Psobject.Properties.Item('targetResourceId') -and $null -ne $InputObject.targetResourceId){$InputObject.targetResourceId.Split("/")[4]};
                rawObject = $InputObject;
            }
            #Create PsObject
            $_obj = New-Object -TypeName PsObject -Property $FLObject
            #return object
            return $_obj
        }
        catch{
            $msg = @{
			    MessageData = ($message.MonkeyObjectCreationFailed -f "Network Watcher Flow Log object");
			    callStack = (Get-PSCallStack | Select-Object -First 1);
			    logLevel = 'error';
			    InformationAction = $O365Object.InformationAction;
			    Tags = @('NetworkWatcherObjectError');
		    }
		    Write-Error @msg
            $msg.MessageData = $_
            $msg.LogLevel = "Verbose"
            $msg.Tags+= "NetworkWatcherObjectError"
            [void]$msg.Add('verbose',$O365Object.verbose)
		    Write-Verbose @msg
        }
    }
}

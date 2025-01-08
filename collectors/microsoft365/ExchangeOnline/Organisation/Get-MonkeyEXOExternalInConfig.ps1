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


function Get-MonkeyEXOExternalInConfig {
<#
        .SYNOPSIS
		Collector to get information about the configuration of external sender identification

        .DESCRIPTION
		Collector to get information about the configuration of external sender identification

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyEXOExternalInConfig
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false,HelpMessage = "Background Collector ID")]
		[string]$collectorId
	)
	begin {
		#Collector metadata
		$monkey_metadata = @{
			Id = "exo0060";
			Provider = "Microsoft365";
			Resource = "ExchangeOnline";
			ResourceType = $null;
			resourceName = $null;
			collectorName = "Get-MonkeyEXOExternalInConfig";
			ApiType = "ExoApi";
			description = "Collector to get information about the configuration of external sender identification in Exchange Online";
			Group = @(
				"ExchangeOnline"
			);
			Tags = @(

			);
			references = @(
				"https://silverhack.github.io/monkey365/"
			);
			ruleSuffixes = @(
				"o365_exo_org_config"
			);
			dependsOn = @(

			);
			enabled = $true;
			supportClientCredential = $true
		}
		#Get instance
		$Environment = $O365Object.Environment
		#Get Exchange Online Auth token
		$ExoAuth = $O365Object.auth_tokens.ExchangeOnline
	}
	process {
		$msg = @{
			MessageData = ($message.MonkeyGenericTaskMessage -f $collectorId,"Exchange Online external sender identification",$O365Object.TenantID);
			callStack = (Get-PSCallStack | Select-Object -First 1);
			logLevel = 'info';
			InformationAction = $O365Object.InformationAction;
			Tags = @('ExoOrgExternalInInfo');
		}
		Write-Information @msg
		$p = @{
			Authentication = $ExoAuth;
			Environment = $Environment;
			ResponseFormat = 'clixml';
			Command = 'Get-ExternalInOutlook';
			Method = "POST";
			InformationAction = $O365Object.InformationAction;
			Verbose = $O365Object.Verbose;
			Debug = $O365Object.Debug;
		}
		$exo_externalInConfig = Get-PSExoAdminApiObject @p
	}
	end {
		if ($null -ne $exo_externalInConfig) {
			$exo_externalInConfig.PSObject.TypeNames.Insert(0,'Monkey365.ExchangeOnline.ExternalInConfig')
			[pscustomobject]$obj = @{
				Data = $exo_externalInConfig;
				Metadata = $monkey_metadata;
			}
			$returnData.o365_exo_externalIn_config = $obj
		}
		else {
			$msg = @{
				MessageData = ($message.MonkeyEmptyResponseMessage -f "Exchange Online external sender identification",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = "verbose";
				InformationAction = $O365Object.InformationAction;
				Tags = @('ExoOrgExternalInEmptyResponse');
				Verbose = $O365Object.Verbose;
			}
			Write-Verbose @msg
		}
	}
}










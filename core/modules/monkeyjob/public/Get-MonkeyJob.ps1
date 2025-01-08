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

Function Get-MonkeyJob{
    <#
        .SYNOPSIS
            Get a MonkeyJob
        .DESCRIPTION
            Get an automation job object
        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Remove-MonkeyJob
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
        .PARAMETER Job
            The job object to query for
        .PARAMETER Name
            The name of the jobs to query for
        .PARAMETER Id
            The Id of the jobs to query for
        .PARAMETER RunspacePoolId
            The runspacePool Id of the jobs to query for
        .PARAMETER State
            The State of the job that you want to display. Accepted values are:

            NotStarted
            Running
            Completed
            Failed
            Stopped
            Blocked
            Suspended
            Disconnected
            Suspending
            Stopping
            AtBreakpoint
    #>
    [cmdletbinding(DefaultParameterSetName='All')]
    Param
    (
        [Parameter(Mandatory=$true, ParameterSetName='Job', position=0, ValueFromPipeline=$true, HelpMessage="Job")]
        [Alias('InputObject')]
        [Object]$Job,

        [Parameter(Mandatory=$true, ParameterSetName='Name', HelpMessage="Job Name")]
        [String[]]$Name,

        [Parameter(Mandatory=$true, ParameterSetName='Id', HelpMessage="Job Id")]
        [Int[]]$Id,

        [Parameter(Mandatory=$true, ParameterSetName='RunspacePoolId', HelpMessage="Job RunspacePoolId")]
        [System.Guid[]]$RunspacePoolId,

        [Parameter(Mandatory=$false, HelpMessage="Job State")]
        [ValidateSet(
            "NotStarted","Running","Completed","Failed",
            "Stopped","Blocked","Suspended","Disconnected",
            "Suspending","Stopping","AtBreakpoint"
        )]
        [String]$State
    )
    Begin{
        $queries = [System.Collections.Generic.List[ScriptBlock]]::new()
    }
    Process{
        $psn = $PSCmdlet.ParameterSetName
        $items = $PSBoundParameters[$psn]
        foreach($item in $items){
            if($PSCmdlet.ParameterSetName -eq 'Job'){
                $rule = ('$_.{0} -eq "{1}"' -f "Id",$item.Id)
            }
            else{
                $rule = ('$_.{0} -eq "{1}"' -f $psn,$item)
                if($PSBoundParameters.ContainsKey('State')){
                    $rule = ('{0} -and $_.Job.State -eq "{1}"' -f $rule, $PSBoundParameters['State'])
                }
            }
            $sb = [ScriptBlock]::Create($rule)
            [void]$queries.Add($sb)
        }
    }
    End{
        if($PSCmdlet.ParameterSetName -eq 'All'){
            $MonkeyJobs
        }
        else{
            foreach($query in $queries){
                $MonkeyJobs | Where-Object $query -ErrorAction Ignore;
            }
        }
    }
}


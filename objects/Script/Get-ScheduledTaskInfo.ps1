﻿<#
.SYNOPSIS
    Gets the scheduled task command and arguments.
.DESCRIPTION
    Gets the scheduled task command and arguments from the task xml file.
.PARAMETER ComputerName
    Specifies the computer name. Default is: 'LocalHost'.
.PARAMETER TaskPath
    Specifies the task path. Default is: '\'.
.PARAMETER TaskName
    Specifies the task name. Supports wildcards. Default is: '*'
.EXAMPLE
    Get-ScheduledTaskInfo -ComputerName 'SomeComputerNameorIP' -TaskPath '\' -TaskName 'SomeTaskName'
.INPUTS
    None.
.OUTPUTS
    Sytem.Array
.NOTES
    Created by Ioan Popovici
.LINK
    https://MEM.Zone/
.LINK
    https://MEM.Zone/Issues
.COMPONENT
    Task Scheduler
.FUNCTIONALITY
    Get Task Info
#>

## Set script requirements
#Requires -Version 3.0

##*=============================================
##* VARIABLE DECLARATION
##*=============================================
#region VariableDeclaration

## Get script parameters
Param (
    [Parameter(Mandatory=$false,HelpMessage='Enter a computer name',Position=0)]
    [ValidateNotNullorEmpty()]
    [Alias('HostName')]
    [string]$ComputerName = 'LocalHost',
    [Parameter(Mandatory=$false,HelpMessage='Task folder name',Position=2)]
    [ValidateNotNullorEmpty()]
    [Alias('Path')]
    [string]$TaskPath = '\',
    [Parameter(Mandatory=$false,HelpMessage='Task the name',Position=3)]
    [ValidateNotNullorEmpty()]
    [Alias('Task')]
    [string]$TaskName = '*'
)

#endregion
##*=============================================
##* END VARIABLE DECLARATION
##*=============================================

##*=============================================
##* FUNCTION LISTINGS
##*=============================================
#region FunctionListings

#region Function Get-ScheduledTaskInfo
Function Get-ScheduledTaskInfo {
<#
.SYNOPSIS
    Gets the scheduled task command and arguments.
.DESCRIPTION
    Gets the scheduled task command and arguments from the task xml file.
.PARAMETER ComputerName
    Specifies the computer name. Default is: 'LocalHost'.
.PARAMETER TaskPath
    Specifies the task path. Default is: '\'.
.PARAMETER TaskName
    Specifies the task name. Supports wildcards. Default is: '*'
.EXAMPLE
    Get-ScheduledTaskInfo -ComputerName 'SomeComputerNameorIP' -TaskPath '\' -TaskName 'SomeTaskName'
.INPUTS
    None.
.OUTPUTS
    Sytem.Array
.NOTES
    This is an internal script function and should typically not be called directly.
.LINK
    https://MEM.Zone/
.LINK
    https://MEM.Zone/Issues
.COMPONENT
    Task Scheduler
.FUNCTIONALITY
    Get Task Info
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false,HelpMessage='Enter a computer name',Position=0)]
        [ValidateNotNullorEmpty()]
        [Alias('HostName')]
        [string]$ComputerName = 'LocalHost',
        [Parameter(Mandatory=$false,HelpMessage='Task folder name',Position=2)]
        [ValidateNotNullorEmpty()]
        [Alias('Path')]
        [string]$TaskPath = '\',
        [Parameter(Mandatory=$false,HelpMessage='Task the name',Position=3)]
        [ValidateNotNullorEmpty()]
        [Alias('Task')]
        [string]$TaskName = '*'
    )

    Begin {
        Try {
            [pscustomobject]$GetScheduledTaskInfo = @()
            [__comobject]$ScheduleServiceObject = New-Object -ComObject 'Schedule.Service' }
        Catch { Throw }
    }
    Process {
        Try {

            ## Connect to the schedule service
            $ScheduleServiceObject.Connect($ComputerName)

            ## Get scheduled tasks
            [object[]]$TaskObject = $ScheduleServiceObject.GetFolder($TaskPath).GetTasks(0) | Where-Object { $_.Enabled -eq $true -and $_.Name -like $TaskName }

            ## Get scheduled task info
            $GetScheduledTaskInfo = ForEach ($Task in $TaskObject) {
                $Command   = ([xml]$Task.xml).Task.Actions.Exec.Command
                $Arguments = ([xml]$Task.xml).Task.Actions.Exec.Arguments
                If ($command) {
                    [pscustomobject]@{
                        Device    = $env:COMPUTERNAME
                        Path      = $TaskPath
                        Name      = $Task.Name
                        Command   = $Command
                        Arguments = $Arguments
                    }
                }
            }
        }
        Catch {
            $GetScheduledTaskInfo = $_.Exception
            Write-Error -Message $_.Exception
        }
        Finally {

            ## Output result
            Write-Output -InputObject $GetScheduledTaskInfo
        }
    }
    End {
    }
}
#endregion

#endregion
##*=============================================
##* END FUNCTION LISTINGS
##*=============================================

##*=============================================
##* SCRIPT BODY
##*=============================================
#region ScriptBody

Get-ScheduledTaskInfo -ComputerName $ComputerName -TaskPath $TaskPath -TaskName $TaskName

#endregion
##*=============================================
##* END SCRIPT BODY
##*=============================================
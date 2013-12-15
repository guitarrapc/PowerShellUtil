#Requires -Version 3.0

function Set-PrinterPortExtend
{
<#
.Synopsis
   Add/check TCP/IP and assign to PrinterName you specified.
.DESCRIPTION
   This Cmdlet will check current TCP/IP Port include what you specified.
   If not exist, then add TCP/IP Port.
   Next, Get Printer Name as you desired and check Port Number which assigned to it.
   If PortNumber assigned was not same as Port Number you specified, then change it.
.EXAMPLE
    Set-PrinterPort -TCPIPport 192.168.1.2 -printerName "HP*"   
.EXAMPLE
    Set-PrinterPort -TCPIPport 192.168.1.2 -printerName "HP*" -Verbose
#>

    [CmdletBinding()]
    Param
    (
        # Input TCP/IP port number you want to create, assign to Printer
        [Parameter(
            Mandatory,
            Position = 0)]
        [ipaddress]
        $TCPIPport,

        # Input Printer Name to asshign Port Number you want
        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string]
        $printerName
    )

    process
    {
        if (-not(Get-PrinterPort | where Name -eq $TCPIPport))
        {
            if ($includeAddPort)
            {
                Write-Warning ("Printer port '{0}' not found. Adding port." -f $TCPIPport)
                Add-PrinterPort -PrinterHostAddress $TCPIPport -Name $TCPIPport
            }
            else
            {
                throw ("Printer Port '{0}' not found exception!" -f $TCPIPport)
            }
        }
        else
        {
            Write-Verbose ("Printer port '{0}' found." -f $TCPIPport)
            if ($PSBoundParameters.Verbose.IsPresent)
            {
                Get-PrinterPort | where Name -eq $TCPIPport
            }
        }

        $printers = Get-CimInstance -Class Win32_printer | where name -like $printerName

        if ($printers.count -ne 0)
        {
            foreach ($printer in $printers)
            {
                if ($printer.PortName -ne $TCPIPport)
                {
                    Write-Verbose ("Setting Printer '{0}' port from '{1}' to '{2}'" -f $printer.Name, $printer.PortName, $TCPIPport)
                    $printer.PortName = $TCPIPport
                }
                else
                {
                    Write-Verbose ("Printer '{0}' port '{1}' was already '{2}'" -f $printer.Name, $printer.PortName, $TCPIPport)
                }
            }
        }
        else
        {
            throw ("Printer name '{0}' not exist exception!" -f $printerName)
        }
    }
}
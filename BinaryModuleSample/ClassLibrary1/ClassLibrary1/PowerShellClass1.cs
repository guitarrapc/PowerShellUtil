using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Management;
using System.Management.Automation;

namespace PowerShellClass1
{
    [Cmdlet(VerbsCommon.Get, "string")]
    public class GetString : Cmdlet
    {
        protected override void EndProcessing()
        {
            WriteObject("hogehoge!");
        }
    }
}

Import-Module ServerManager

@("Web-Server",
"Web-Http-Errors",
"Web-App-Dev",
"Web-Asp-Net",
"Web-Net-Ext",
"Web-ASP",
"Web-CGI",
"Web-ISAPI-Ext",
"Web-ISAPI-Filter",
"Web-Includes",
"Web-Basic-Auth",
"Web-Windows-Auth",
"Web-Mgmt-Compat",
"Web-Metabase",
"Web-WMI",
"Web-Lgcy-Scripting",
"Web-Lgcy-Mgmt-Console"
)| Add-WindowsFeature
<#
    Configuration creates Azure SQL Database
#>
configuration CreateSqlDatabase 
{
    param
    (
        $workingDirectory,
        $name,
        $serverCredential,
        $serverName,
        $ruleName,
        $startIPAddress,
        $endIPAddress,
        $azureSubscriptionName,
        $azurePublishSettingsFile
    )

    Import-DscResource -Name MSFT_xAzureSubscription
    Import-DscResource -Name MSFT_xAzureSqlDatabase
    Import-DscResource -Name MSFT_xAzureSqlDatabaseServerFirewallRule

    # Verify working directory

    node localhost 
    {

        xAzureSubscription MSDN
        
        xAzureSqlDatabaseServerFirewallRule firewallRule 
        {
            RuleName = $ruleName        
            ServerName = $serverName    
            StartIPAddress = $startIPAddress
            EndIPAddress = $endIPAddress
            DependsOn = '[xAzureSubscription]MSDN'
        }

        xAzureSqlDatabase sqlDatabase 
        {
            Name = $name
            ServerCredential = $serverCredential
            ServerName = $serverName
            MaximumSizeInGB = 1
            DependsOn = '[xAzureSqlDatabaseServerFirewallRule]firewallRule'
        }

        #LocalConfigurationManager 
        #{ 
            #CertificateId = $node.Thumbprint 
        #} 

    }
}

$script:configData = 
@{  
    AllNodes = @(       
                    @{    
                        NodeName = "localhost"  
                        Role = "TestHost"  
                        #CertificateFile = Join-Path $workingdir 'publicKey.cer'
                        #Thumbprint = ''
                         
                    };  
                );      
}  

#Sample use (please change values of parameters according to your scenario):
$azureSubscriptionName = 'Visual Studio Ultimate with MSDN'
$azurePublishSettingsFile = Join-Path $workingDirectory 'visual.publishsettings'
$name = "databaseName"
$securePassword = ConvertTo-SecureString "P@ssword" -AsPlainText -Force
$serverCredential = New-Object System.Management.Automation.PSCredential ("mylogin", $securePassword)
$serverName = "serverName"
$ruleName = "ruleName"
$startIPAddress = "111.111.111.111"
$endIPAddress = "111.111.111.111"

CreateSqlDatabase -configurationData $script:configData -workingDirectory $workingDirectory `
                  -azureSubscriptionName $azureSubscriptionName -azurePublishSettingsFile $azurePublishSettingsFile `
                  -name $name -serverCredential $serverCredential -serverName $serverName -ruleName $ruleName `
                  -startIPAddress $startIPAddress -endIPAddress $endIPAddress
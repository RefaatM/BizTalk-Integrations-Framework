﻿Function DeleteService([string] $ServiceName) {
    [bool] $Return = $False
    $Service = Get-Service | Where-Object {$_.Name -eq $ServiceName}
    if ( $Service -ne $null ) {
		Stop-Service $ServiceName
		$serviceAfter = Get-Service | Where-Object {$_.Name -eq $ServiceName}

		"$ServiceName is now " + $serviceAfter.status

        $Service = Get-WmiObject -Class Win32_Service -Filter "Name='$ServiceName'"
        $Service.Delete()

        if ( $null -eq (Get-Service | Where-Object {$_.Name -eq $ServiceName} ) ) {
            $Return = $True
        }
    } else {
		write-host "$ServiceName does not exist"
        $Return = $True
    }
    Return $Return
}

Function StartService([string] $ServiceName) {
    [bool] $Return = $True
    Write-Host "Starting service <$ServiceName>"

    $servicePrior = Get-Service | Where-Object {$_.Name -eq $ServiceName}

    if($servicePrior -ne $null)
    {
        Write-Host "<$ServiceName> is now " $servicePrior.status
        Set-Service $ServiceName -startuptype manual
        Start-Service $ServiceName
        $serviceAfter = Get-Service $ServiceName
        Write-Host "<$ServiceName> is now " $serviceAfter.status
    }
    else
    {
        Write-Error "Service <$ServiceName> is not installed"
    }
    Return $Return
}

Function SetFolderPermission([string] $Folder) {
    [bool] $Return = $False
    Write-Host "Setting folder permission for <$Folder>"

    Remove-Item -Recurse -Force "$Folder\*.log"
    Remove-Item -Recurse -Force "$Folder\Logs\*.log"

    $Acl = Get-Acl "$Folder"
    $Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("Local Service","FullControl","Allow")
    $Acl.SetAccessRule($Ar)
    Set-Acl "$Folder\" $Acl


    $Acl2 = Get-Acl "$Folder\Logs"
    $Ar2 = New-Object  system.security.accesscontrol.filesystemaccessrule("Local Service","FullControl","Allow")
    $Acl2.SetAccessRule($Ar2)
    
    Set-Acl "$Folder\\Logs" $Acl2
    Return $True
}


$ServiceName = "Enterprise Library Semantic Logging Service"

$servicePrior = Get-Service | Where-Object {$_.Name -eq $ServiceName}

if($servicePrior -ne $null)
{
    Write-Host "<$ServiceName> is already installed - status: " $servicePrior.status
}
else
{
    Write-Host "Service <$ServiceName> is not installed. Installing it now...."

     $originalPath = PWD
    CD  ..\MSSLSvc\

    $currentPath = PWD
    
    .\SemanticLogging-svc.exe -i

    SetFolderPermission($currentPath);

    StartService($ServiceName);

    CD  $originalPath
}


# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUuHmgxO8Nt9ia4dAvqYmoa8Rx
# Ye6gggNCMIIDPjCCAiqgAwIBAgIQkohQbhsQuIRNpMd1csRMAjAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xMzA5MTAyMDUxMjlaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK4hC3hH
# e7xMOFNYAoSXHwb4OOWsr9Bz1S0HGEa1bqcl9xK5nQdonr83X16ExxrzrGqguu0n
# vsc6G5sTpCNjVpfZYJ9UJ92tc62CJNZZTCXQ6XsAnZraHVKIxSwNWIdTcTfuotsp
# iYxx09FN1eK7+yui9gvRt+YzLeBmVssdjiLckoXCdiREnUVgBZvYHvMzRtQUoEWS
# 9mF6ow3MIHIMbOQhMZQy7QY8teUIW9jxyb5YOqp4KJFdekydkiLfYi/yje4wTBCh
# ShvO67Jg9fupuFE/DND2RNdzCYWChnQie7iSwZp9tUCMroPvDujpmPPA7/oJ4vLN
# d76zrvK/8PWpjn8CAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwXQYDVR0B
# BFYwVIAQW7iTznPs2PX+bLyzHW9M+KEuMCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwg
# TG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQaghA+jTQlatCpyXQJvTosDAJBgUrDgMC
# HQUAA4IBAQDcfussgzKYFbaOuYzX5wjKzGcG6nGWJVtQzvY8eoOapVV6PQzXGKsn
# kjVZ7LcLTcilzIrEQmPg+sbBCCbcol4ebKq4tyCIzH5PDnVug/07SjPJFyDGxlw6
# KaNS2AAwLX5HwipiRtPEG1kApdM54ckIZuJe9b8/9uykEegWz6PnTvhFU9uIPjy1
# bjspj8SS3erASLetz8iyt3wDNHC4BOyWGnmMrMCXAQ6LydtCOkrFd/CwePZEfMbh
# uAepz9FhDnGH/BFvN5a+WjzGRSdz8aUdjXgaHg1OO5qoRLVgrykIyrJ4W0H9HjK2
# 3lGnaqZ19E8QKH/eeXqR3uComPfn3ha7MYIB4TCCAd0CAQEwQDAsMSowKAYDVQQD
# EyFQb3dlclNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3QCEJKIUG4bELiETaTH
# dXLETAIwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFJYj/Fo/Kz4dsVaEOLbTJOxaszg+MA0GCSqG
# SIb3DQEBAQUABIIBAEJud2pt4LCafII6IlcU5mFTN9PEuUMcWKLTgXxFVRx/wYOb
# jmdAMg1hW775eO5BQtUjoeObrOd5b3cw+5l3cGVN4OLVDmhkWsgYJGeTiLdgRKWa
# Vq9yI8fZrxlab+MuLjj1OfGx6n6LTpXEgoPM2ePse9mfmIrFDnbK8kubv8SyxwFk
# yD3mPlI4SLMssgmEPx/ORWAfZvKxz8ePXx5nEVR0R6wvI6ACOA+ciFYI7d8rN8HE
# DDsaBpixcQSyRfylg3GyvXV34joHGVcyXHN9XgNmuSJEkIp2pnk99+6U+2w1UGGv
# ZHeeEFJS5P90buouiUZ6FMPuEgpcjNIlpce34pc=
# SIG # End signature block

# PowerShell
# ----------

# Nouvelle ligne de commande sous Windows

# 2002: Monad (beta en 2005)
# 2006: Renommé PowerShell, intégré à Windows
# 2009: v2 pour Windows 7 et Server 2008 R2
# 2016: open-source et multi-plateforme pour version 6 (.Net Core)

#   Compatible avec les anciennes commandes

ping localhost


#   + nouvelles "cmdlets"

Test-Connection -ComputerName localhost


# Normalisation
# -------------
#   des noms de commandes: Verbe-Nom

Get-Verb

#       avec des alias

Get-Alias


#   du passage des paramètres
#       Cas général

Test-Connection -ComputerName localhost

#       Argument positionel

Test-Connection localhost

#       Switch

Test-Connection localhost -Quiet

#       Demande interactive

Test-Connection


#   du référencement des commandes

Get-Command

Get-Module -List

Get-Command -Module Microsoft.PowerShell.Management


#   de l'aide

Get-Help Test-Connection

function Write-Hello {
    <#
    .SYNOPSIS
    Greet someone
    .DESCRIPTION
    Will greet someone by saying hello to this person on the standard output
    .PARAMETER Name
    Name of the person to greet
    .EXAMPLE
    PS> Write-Hello World
    Output Hello, World!
    #>
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $Name
    )
    "Hello, $Name!"
}
Get-Help Write-Hello -ShowWindow


#   de certains comportement (Verbose, Debug, WhatIf)

Invoke-WebRequest -Uri 'http:\\localhost' | Out-Null

Invoke-WebRequest -Uri 'http:\\localhost' -Verbose | Out-Null

Remove-Item toto.txt -WhatIf


# 5 sorties standards
# -------------------
function Test-StandardOutput {
    [CmdletBinding()]
    param([Parameter(Position=0)]$Message)
    Write-Output "Output $Message"
    Write-Error "Error $Message"
    Write-Warning "Warning $Message"
    Write-Verbose "Verbose $Message"
    Write-Debug "Debug $Message"
    Write-Host "Host $Message"
}

Test-StandardOutput 'coucou'

Test-StandardOutput 'coucou' -Verbose

Test-StandardOutput 'coucou' -ErrorAction SilentlyContinue -ErrorVariable MyErrors -WarningAction SilentlyContinue
"MyErrors $MyErrors"

$Result = Test-StandardOutput 'coucou' 3>&1 -ErrorAction SilentlyContinue
"Result $Result"


# Gestion des erreurs par exception
# ---------------------------------
try {
    throw "Mon Exception"
} catch  {
    "Caught exception: $_"
}


# Manipule des objets...
#-----------------------

$Result = Test-Connection localhost -Count 1
$Result.IPV4Address


#  ... y compris dans le pipeline

Test-Connection localhost -Count 1 |
    Where-Object { $_.StatusCode -eq 0 } |
    Select-Object -Property __Server,Address |
    Format-List


# ... qui sont des objets .Net

$Random = New-Object System.Random
$Random.NextDouble()
$Random | Get-Member


# Programmation orientée objet
# ----------------------------
class Shape {
    static [string] $Name = "Shape"
    hidden [int] $X
    Shape([int] $X) {
        $this.X = $X
    }
    [string] Draw() {
        return "Drawing $([Shape]::Name) at $($this.X)..." # Pas d'output sur le pipeline sans return
    }
}

class Rect : Shape {
    [ValidateNotNullOrEmpty()] [int] $Width
    static [string] $Name = "Rect"
    Rect([int] $X) : base($X) {}
    [string] Draw() {
        return ([Shape]$this).Draw() + " Drawing with width $($this.Width)..."
    }
}

$MyRect = [Rect]::new(10)
$MyRect.Width = 20
$MyRect.Draw()


# Pas de notion d'interface, mais "fonctionnel" possible
# ------------------------------------------------------
$EvenPredicate = {
    param($Value)
    $value % 2 -eq 0
}
function Convert-ByFilter( [int[]] $Values, [ScriptBlock] $Predicate ) {
    $Values | Where-Object { & $Predicate $_ }
}
Convert-ByFilter @(1,2,3,4) $EvenPredicate

# !!!! pas de closure lexicale
# Scope dépend de l'éxecution et les variables sont juste copiées...


# Module perso
# ------------

Import-Module ".\DemoModule.psm1"
Write-FromModule
Write-Private


# VSCode nouvel éditeur officiel

# Quelques aides...
# -----------------

# ...Linter statique

function Foo-Bar {

}

# ...Dynamiques
$Unassigned
$Uncomplete = [PSCustomObject]@{}
$Uncomplete.Undefined

Set-StrictMode -Version 2.0

$Unassigned
$Uncomplete.Undefined


# Tests
# -----

Invoke-Pester .\demo.Tests.ps1 -CodeCoverage .\demo.Tests.ps1


# Pour les ITs
# ------------

# Remoting: execution sur 1 ou plusieurs machines distantes

Enter-PSSession Server1
# ... Execution sur la machine distante
Exit-PSSession

Invoke-Command -ComputerName Server1 -ScriptBlock {Get-UICulture}

# Desired State Configuration: décrire l'état souhaité plutôt que les actions à mener
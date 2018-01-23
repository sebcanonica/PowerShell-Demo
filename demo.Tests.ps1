function Add-Numbers($a, $b) {
    Write-ToExternalLog 'Logging...'
    return $a + $b
}

function Write-ToExternalLog($Message) {
    throw "Too slow for unit test"
}

Describe "Add-Numbers" {

    It "adds positive numbers" {
        Mock Write-ToExternalLog {}

        $Actual = Add-Numbers 2 3

        $Actual | Should -Be 5
        Assert-MockCalled Write-ToExternalLog -Times 1 -Scope It
    }

}
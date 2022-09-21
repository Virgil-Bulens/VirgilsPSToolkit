function ConvertTo-Base64String 
{
    [CmdletBinding()]
    param (
        # String to Convert to Base64
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [string]
        $String
    )

    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($String)
    $EncodedText = [Convert]::ToBase64String($Bytes)
    $EncodedText
    
}
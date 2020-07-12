function Global:Find-TagQuestions
{
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [String]$Tag
    )

    # Checks raw source code of https://stackoverflow.com/questions/tagged/tag?tab=newest&pagesize=50
    $query = Invoke-WebRequest "https://stackoverflow.com/questions/tagged/$($tag)?tab=newest&pagesize=50" | 
        Select-Object -ExpandProperty RawContent

    # Creates a variable with a regular expression
    $regex = [regex]'id="question-summary-(.+)"'
    # Finds matches of the regular expression and gets the question id (i.e. "/q/12345678")
    $CL = (($regex.Matches($query).value -replace 'id="question-summary-') -replace '"')

    # Creates a variable with the path to the history file for Brave
    $Path = "$Env:systemdrive\Users\$env:UserName\AppData\Local\BraveSoftware\Brave-Browser-Beta\User Data\Default\History"
    # Checks the content of the history file for a regular expression that looks for Stack Overflow questions then gets the id of it
    $History = Get-Content -Path $Path |
        Select-String -AllMatches 'stackoverflow\.com\/(questions|q)\/[\d]+\/' |
            ForEach-Object {(($_.Matches).Value -replace 'stackoverflow.com/(q|questions)/', '') -replace '/'}

    # Checks each line in the initial regular expression and sees if it is not in the history and if not opens it with brave
    ForEach ($item in $CL)
    {
        $URI = "stackoverflow.com/q/$item"
        if ($item -notin $History)
        {
            & "C:\Program Files (x86)\BraveSoftware\Brave-Browser-Beta\Application\brave.exe" $URI
        }
    }
}

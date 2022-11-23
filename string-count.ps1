# Output the length of all files and folders in the given directory path.
[CmdletBinding()]
param
(

# FILTERS >>
    [Parameter(HelpMessage = 'Directory to search(Can be edited below)')]
    [string] $DirectoryPathToScan = 'C:\robin\sharetest',

    [Parameter(HelpMessage = 'Minimum Path')]
    [int] $MinimumPathLengthsToShow = 0,

    [Parameter(HelpMessage = 'Print results to console or not')]
    [bool] $WriteResultsToConsole = $false,

    [Parameter(HelpMessage = 'Grid View')]
    [bool] $WriteResultsToGridView = $true,

    [Parameter(HelpMessage = 'If the results should be written to a file or not.')]
    [bool] $WriteResultsToFile = $true,

    [Parameter(HelpMessage = 'The file path to write the results to when $WriteResultsToFile is true.')]
    [string] $ResultsFilePath = 'C:\FilePaths.xls'
)

# Time
[datetime] $startTime = Get-Date
Write-Verbose "Starting script at '$startTime'." -Verbose

# Validate directory
[string] $resultsFileDirectoryPath = Split-Path $ResultsFilePath -Parent
if (!(Test-Path $resultsFileDirectoryPath)) { New-Item $resultsFileDirectoryPath -ItemType Directory }

# File Stream
if ($WriteResultsToFile) { $fileStream = New-Object System.IO.StreamWriter($ResultsFilePath, $false) }

$filePathsAndLengths = [System.Collections.ArrayList]::new()

# Find all file and directory paths and print.
Get-ChildItem -Path $DirectoryPathToScan -Recurse -Force |
    Select-Object -Property @{Name = "FullNameLength"; Expression = { ($_.FullName.Length) } }, FullName |
    Sort-Object -Property FullNameLength -Descending |
    ForEach-Object {

    $filePath = $_.FullName
    $length = $_.FullNameLength

    # Validate Filter
    if ($length -ge $MinimumPathLengthsToShow)
    {
        [string] $lineOutput = "$length : $filePath"

        if ($WriteResultsToConsole) { Write-Output $lineOutput }

        if ($WriteResultsToFile) { $fileStream.WriteLine($lineOutput) }

        $filePathsAndLengths.Add($_) > $null
    }
}

if ($WriteResultsToFile) { $fileStream.Close() }

# Time taken
[timespan] $elapsedTime = $finishTime - $startTime
Write-Verbose "Finished script at '$finishTime'. Took '$elapsedTime' to run." -Verbose

if ($WriteResultsToGridView) { $filePathsAndLengths | Out-GridView -Title "Paths under '$DirectoryPathToScan' longer than '$MinimumPathLengthsToShow'." }

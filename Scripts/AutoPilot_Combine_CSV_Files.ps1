# Sample Script to combine CSV Files with a single Autopilot entry, to a file with multiple entries.

# Sety generic variables
$APCSVFolder = "C:\AutoPilot\APCSVFiles"
$APCSVFileAllMachines = "$APCSVFolder\AutoPilot_AllMachines.csv"

# Combine the CSV files for easy upload
$CSVFiles = Get-ChildItem -Path $APCSVFolder -Filter "*.CSV" 
$CSVFiles | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv $APCSVFileAllMachines -NoTypeInformation -Encoding ASCII 
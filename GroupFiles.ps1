Param(
    [Parameter(Mandatory=$true)]
    [string]$sourcePath,
    [Parameter(Mandatory=$true)]
    [string]$targetPath
)

$global:fileTypeLookup = @{};
$folderDateTimeFormat = "yyyy-MM"

function Copy-FilesIntoFoldersByMonthAndType{
    param()

    $files = Get-ChildItem -Recurse -File -Path $sourcePath
    $filesProcessed = 0
    
    foreach($file in $files){
        $folder = Get-DirectoryForFile $file
        Copy-Item $file.FullName -Destination $folder
        
        $filesProcessed++
        Write-Progress -Activity "Grouping files" -Status "$($filesProcessed) out of $($files.Count) grouped" -PercentComplete (($filesProcessed / $files.Count) * 100) 
    }
}
function Get-DirectoryForFile{
    param($file)

    $monthYearDirLookup = Get-FilePathDictionary $file
    $modifiedTimeMonthYearInternal = $file.LastWriteTime.ToString("MMyyyy")
    
    if($monthYearDirLookup.ContainsKey($modifiedTimeMonthYearInternal)){
        return $monthYearDirLookup[$modifiedTimeMonthYearInternal]
    }

    #If the file has no extension, place it into a folder called "No Extension"
    if($file.Extension.Length -eq 0) {
        $extensionWithoutDot = "No Extension"
    } else {
        $extensionWithoutDot = $file.Extension.Substring(1, $file.Extension.Length - 1)
    }
    
    $dateFolderFileName = $file.LastWriteTime.ToString($folderDateTimeFormat)
    $newPath = $targetPath + "\" + $extensionWithoutDot + "\" + $dateFolderFileName
    $path = New-Item -ItemType Directory $newPath -Force
    
    $monthYearDirLookup[$modifiedTimeMonthYearInternal] = $path.FullName
    return $path.FullName
}

function Get-FilePathDictionary{
    param($file)

    if($global:fileTypeLookup.ContainsKey($file.Extension)){
        return $global:fileTypeLookup[$file.Extension]
    }

    $global:fileTypeLookup.Add($file.Extension, @{})
    return $global:fileTypeLookup[$file.Extension]
}

Copy-FilesIntoFoldersByMonthAndType

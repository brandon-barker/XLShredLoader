param(
    [String]$TargetName = $(throw "-TargetName is required."), 
    [String]$TargetPath = $(throw "-TargetPath is required."), 
    [String]$TargetDir = $(throw "-TargetDir is required."),
    [String]$ProjectDir = $(throw "-ProjectDir is required."),
    [String]$SolutionDir = $(throw "-SolutionDir is required."),
    [String]$ConfigurationName = $(throw "-ConfigurationName is required."),
    [Switch]$LoadLib
)

$configContent = Get-Content ([io.path]::combine($SolutionDir, "config.json")) | ConvertFrom-Json;

$gameDirectory = $configContent.game_directory;
$modTargetDir = [io.path]::combine( $gameDirectory, "Mods\", $TargetName);
$modTargetDirTmpParent = $modTargetDir + 'Tmp'
$modTargetDirTmp = $modTargetDirTmpParent + '\' + $TargetName;

Get-ChildItem $modTargetDir -Recurse -Exclude 'Settings.xml' | Remove-Item;

New-Item -ItemType directory -Path $modTargetDir -Force;

copy-item $TargetPath $modTargetDir -force;
if ($ConfigurationName -eq "Debug") {
    copy-item ([io.path]::combine( $TargetDir, $TargetName + ".pdb" )) $modTargetDir -force;
}
copy-item ([io.path]::combine( $ProjectDir, "Resources\Info.json" )) $modTargetDir -force;
If ($LoadLib) {
    copy-item ([io.path]::combine( $TargetDir, "XLShredLib.dll" )) $modTargetDir  -force;
    if ($ConfigurationName -eq "Debug") {
        copy-item ([io.path]::combine( $TargetDir, "XLShredLib.pdb" )) $modTargetDir -force;
    }
}

if ($ConfigurationName -eq "Release") {
    $infoContent = Get-Content ([io.path]::combine($ProjectDir, 'Resources\Info.json')) | ConvertFrom-Json;
    copy-item -Recurse -Force $modTargetDir $modTargetDirTmp -Exclude Settings.xml;
    Compress-Archive -Force -Path $modTargetDirTmp -DestinationPath ([io.path]::combine( $modTargetDir + '-' + $infoContent.version + '.zip' ));
    Remove-Item -Recurse -Force $modTargetDirTmpParent; 
}
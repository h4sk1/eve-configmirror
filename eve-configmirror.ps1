$osusername = $env:UserName
$path = "C:\Users\$osusername\AppData\Local\CCP\EVE\d_games_eve_sharedcache_tq_tranquility\settings_Default"

while (!(Test-Path -Path $path)) {
    $path = Read-Host -Prompt "Unable to set path to config files automatically, please enter it manually..."
}

$chars = Get-ChildItem -Path $path -File | Where-Object Name -match "core_char_([0-9]*).dat" | Sort-Object LastWriteTime -Descending
$users = Get-ChildItem -Path $path -File | Where-Object Name -match "core_user_([0-9]*).dat" | Sort-Object LastWriteTime -Descending

Write-Host "1 = default: will choose last logged in character and account to apply these settings to all other characters and accounts" -ForegroundColor Green
Write-Host "2 = advanced: lets you pick a character to apply these settings to all other characters but will leave account settings untouched" -ForegroundColor Yellow
$case = Read-Host -Prompt "Pick a mode of operation"

switch ($case) {
    1 
    { 
        Write-Host "You chose default mode of operation" -ForegroundColor Green
        
        $MainCharIDPrep = $chars[0] -split "core_char_"
        $MainCharID = $MainCharIDPrep -split ".dat"

        $GetCharNameReqURL = "https://esi.evetech.net/latest/characters/$MainCharID/?datasource=tranquility"
        $GetCharNameReqURL = $GetCharNameReqURL.replace(' ','')
        $GetCharNameReq = Invoke-WebRequest -Uri $GetCharNameReqURL

        $CharNamePrep = $GetCharNameReq -split ',"name":'
        $CharNamePrep =$CharNamePrep[1] -split ',"'
        $CharName = $CharNamePrep[0]

        Write-Host "################################################################################################################################" -ForegroundColor Green
        $answer = Read-Host -Prompt "If you want to apply all settings from $CharName to all other characters type yes to continue or CTRL+C to quit"

        if ($answer -eq "yes") {
            foreach ($user in $users)
            {
                if ($user.Name -eq $users[0].Name) {
                }
                else {
                    Remove-Item $user.FullName
                    Copy-Item -Path $users[0].FullName -Destination $user.FullName
                }
            }

            foreach ($char in $chars)
            {
                if ($char.Name -eq $chars[0].Name) {
                }
                else {
                    Remove-Item $char.FullName
                    Copy-Item -Path $chars[0].FullName -Destination $char.FullName
                }
            }
            Write-Host "Action successful" -ForegroundColor Green
        }
        else {
            Write-Host "Action aborted" -ForegroundColor Red
        }
    }
    2 
    { 
        Write-Host "You chose advanced mode of operation" -ForegroundColor Yellow
        Write-Host "################################################################################################################################" -ForegroundColor Yellow
        Write-Host "Choose a character from which you would like to apply your settings to the other characters:"
        $counter = 1
        foreach ($char in $chars)
        {
            $CharIDPrep = $char -split "core_char_"
            $CharID = $CharIDPrep -split ".dat"

            $GetCharNameReqURL = "https://esi.evetech.net/latest/characters/$CharID/?datasource=tranquility"
            $GetCharNameReqURL = $GetCharNameReqURL.replace(' ','')
            $GetCharNameReq = Invoke-WebRequest -Uri $GetCharNameReqURL

            $CharNamePrep = $GetCharNameReq -split ',"name":'
            $CharNamePrep = $CharNamePrep[1] -split ',"'
            $CharName = $CharNamePrep[0]

            
            Write-Host "$counter = $CharName"
            $counter ++
        }

        $counter = Read-Host -Prompt "Choose a character from which you would like to apply your settings to the other characters"
        $counter = $counter - 1

        foreach ($char in $chars)
        {
            if ($char.Name -eq $chars[$counter].Name) {
            }
            else {
                Remove-Item $char.FullName
                Copy-Item -Path $chars[$counter].FullName -Destination $char.FullName
            }
        }
        Write-Host "Action successful" -ForegroundColor Green
    }
    
    Default 
    {
        Write-Host "Action aborted" -ForegroundColor Red
    }
}

























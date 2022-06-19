global ultused := {}
global startTime := 0
global activeMonstersListSize := 

BushInitialize()
{
    g_SF.Hwnd := WinExist("ahk_exe IdleDragons.exe")
    g_SF.Memory.OpenProcessReader()
return
}

Bush_Run()
{
    BushInitialize()
    famFormation := 0
    BushZone := g_SF.Memory.ReadCurrentZone()
    startTime := A_TickCount - g_BushSettings.bushDelay * 1000
    g_SF.DirectedInput(,, "{e}" )
    loop, 10
        {
            ultUsed[A_Index] := 1
        }

    while (bushRunning)
    {
        sleep 10
        activeMonsters := % ReadActiveMonsters()

        timeScale := g_SF.Memory.ReadTimeScaleMultiplier()
        currentTime := ( A_TickCount - startTime ) / 1000 * timeScale
        cooldown := floor(g_BushSettings.bushDelay - currentTime)
        GuiControl, ICScriptHub:, BushDelaySaved, % cooldown > 0 ? "Cooldown left: " . cooldown:"Cooldown left: " . "Ready"
;, % BushDelay < 1 ? bushDelay:"Waiting for monsters to die..."
        GuiControl, ICScriptHub:, BushMonsters, Monsters in area: %activeMonsters%
        if(famFormation == 0)
        {
            GuiControl, ICScriptHub:, BushFormation, % "No Familiars on field"
        }
        else if(famFormation == 1)
        {   
            GuiControl, ICScriptHub:, BushFormation, % "Familiars on field"
        }
        else if(famFormation == 2)
        {
            GuiControl, ICScriptHub:, BushFormation, % "Knockback without spawning"
        }
        ;GuiControl, ICScriptHub:, BushFormation, % famFormation == 1 ? "Formation in use: familiars on field":"Formation in use: no familiars on field"

        if ( activeMonsters > g_BushSettings.MaxMonsters )
            {
            if ( famFormation == 0 )
                {
                    useUltimates(currentTime)
                }
            else if (famFormation == 1) ; set to W formation
                {
                    g_SF.DirectedInput(,, "{w}")
                    startTime := A_TickCount
                    famFormation = 2
                }
            else if (famFormation == 2 AND currentTime > g_BushSettings.knockbackDelay) ;set to E formation
                {
                    famFormation = 0
                    g_SF.DirectedInput(,, "{e}" )                
                    startTime := A_TickCount
                }
            }

        ;   GuiControl, ICScriptHub:, TestTXT, % ultUsed[3]

        if (famFormation == 0 AND activeMonsters <= g_BushSettings.MaxMonsters and g_BushSettings.bushDelay < currentTime ) ;set to Q formation
            {
            famFormation = 1
            g_SF.DirectedInput(,, "{q}" )
            loop, 10
                {
                    ultUsed[A_Index] := 0
                }
            }
    }
return
}

useUltimates(currentTime)
{
    timeScale := g_SF.Memory.ReadTimeScaleMultiplier()
  ; GuiControl, ICScriptHub:, TestTXT, % currentTime
   loop, 10
        {
            if ( g_BushSettings.Ult[A_Index] and g_BushSettings.UltDelay[A_Index] < currentTime and !ultused[A_Index])
                {
                    ultUsed[A_Index] := 1
                    g_SF.DirectedInput(,, A_Index )
                }
        }
}

ReadActiveMonsters()
{
    return g_SF.Memory.ReadActiveMonstersCount()

}

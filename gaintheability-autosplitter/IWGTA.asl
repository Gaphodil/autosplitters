state("I wanna gain the ability")
{
    int roomId : 0x6561E0;
    
    double deaths       : 0x00445C40, 0x60, 0x10, 0x1E4, 0x5F0;
    double seconds      : 0x00445C40, 0x60, 0x10, 0x1E4, 0x5E0;
    double microseconds : 0x00445C40, 0x60, 0x10, 0x1E4, 0x5D0;
    string32 saveRoom   : 0x00445C40, 0x60, 0x10, 0x1E4, 0x5C0, 0x0, 0x0;
    // can be used for rMiniBoss, rTransition2_2, rTransition3, rBoss3Dead

    double gameStarted  : 0x00445C40, 0x60, 0x10, 0x1E4, 0x250;
    double gameClear    : 0x00445C40, 0x60, 0x10, 0x1E4, 0x280;

    double machine : 0x00445C40, 0x60, 0x10, 0x1E4, 0x540; // boss 1
    // double gunface : 0x00445C40, 0x60, 0x10, 0x1E4, 0x430; // stage 2-2 - after one room after mb
    double chase   : 0x00445C40, 0x60, 0x10, 0x1E4, 0x550; // boss 2-1
    double core    : 0x00445C40, 0x60, 0x10, 0x1E4, 0x530; // boss 2-2

    double ena     : 0x00445C40, 0x60, 0x10, 0x1E4, 0x3F0; // final boss

    // there's only 6 items i'm not bothering with bytearrays
    double filth        : 0x00445C40, 0x60, 0x10, 0x5EC, 0x20, 0x4, 0xC, 0x110;
    double death        : 0x00445C40, 0x60, 0x10, 0x5EC, 0x20, 0x4, 0xC, 0x120;
    double purpleGem    : 0x00445C40, 0x60, 0x10, 0x5EC, 0x20, 0x4, 0xC, 0x130;
    double blueGem      : 0x00445C40, 0x60, 0x10, 0x5EC, 0x20, 0x4, 0xC, 0x140;
    double greenGem     : 0x00445C40, 0x60, 0x10, 0x5EC, 0x20, 0x4, 0xC, 0x150;
    double redGem       : 0x00445C40, 0x60, 0x10, 0x5EC, 0x20, 0x4, 0xC, 0x160;
}

startup
{
    settings.Add("boss1", true, "Enter Boss 1 (Machine)");
    settings.Add("item1", true, "Get Item 1 (Filth)");

    settings.Add("stage2", false, "Enter Stage 2 (Cave)"); // rStage2, 36
    settings.Add("miniBoss", true, "Enter Miniboss (Ogre)"); // autosave rMiniBoss, 37
    settings.Add("postBoss", true, "Beat Miniboss"); // rTransition2, 39
    settings.Add("stage2-2", false, "Enter Stage 2-2 (Gunface)"); // autosave rTransition2_2, 41
    settings.Add("boss2-1", true, "Enter Boss 2 (Chase)");
    settings.Add("boss2-2", false, "Enter Boss 2 (Core)");
    settings.Add("item2", true, "Get Item 2 (Death)");

    settings.Add("postItem2", false, "Press \"Shoot\""); // rShot, 46
    settings.Add("postBoss2", false, "Enter Post-Boss 2"); // autosave rHell, 47
    settings.Add("stage3", true, "Enter Stage 3 (Hub)"); // autosave rTransition3, 48
    settings.Add("stage3Repeat", false, "Split Every Entry to Hub", "stage3"); // rStage3Hub, 49
    settings.Add("item3", false, "Get Item 3 (Purple Gem)");
    settings.Add("item4", false, "Get Item 4 (Blue Gem)");
    settings.Add("item5", false, "Get Item 5 (Green Gem)");
    settings.Add("item6", false, "Get Item 6 (Red Gem)");

    settings.Add("boss3", true, "Enter Final Boss (ENA)");
    settings.Add("gameClear", true, "Game Clear");
}

start
{
    return (old.roomId != 33 && current.roomId == 33); // rStage1
}

onStart
{
    // for not re-splitting if e.g. you die after collecting an item
    vars.noRepeatItems = new bool[6];
}

reset
{
    // return to title screen
    return (old.gameStarted == 1 && current.gameStarted == 0);
}

split
{
    int oldRoom = old.roomId;
    int newRoom = current.roomId;
    string oldSaveRoom = old.saveRoom;
    string newSaveRoom = current.saveRoom;

    var oldItems = new[] {
        old.filth, old.death, old.purpleGem,
        old.blueGem, old.greenGem, old.redGem
    };
    var newItems = new[] {
        current.filth, current.death, current.purpleGem,
        current.blueGem, current.greenGem, current.redGem
    };
    for (int i = 0; i < 6; i++)
    {
        if (settings["item" + (i + 1)] && oldItems[i] != newItems[i] && !vars.noRepeatItems[i]) 
        {
            vars.noRepeatItems[i] = true;
            return true;
        }
    }

    if (settings["boss1"] && old.machine == 0 && current.machine == 1) return true;
    if (settings["boss2-1"] && old.chase == 0 && current.chase == 1) return true;
    if (settings["boss2-2"] && old.core == 0 && current.core == 1) return true;
    if (settings["boss3"] && old.ena == 0 && current.ena == 1) return true;

    if (settings["stage2"] && oldRoom != 36 && newRoom == 36) return true;
    if (settings["miniBoss"] && oldSaveRoom != newSaveRoom && newSaveRoom == "rMiniBoss") return true;
    if (settings["postBoss"] && oldRoom != 39 && newRoom == 39) return true;
    if (settings["stage2-2"] && oldSaveRoom != newSaveRoom && newSaveRoom == "rTransition2_2") return true;
    if (settings["postItem2"] && oldRoom != 46 && newRoom == 46) return true;
    if (settings["postBoss2"] && oldSaveRoom != newSaveRoom && newSaveRoom == "rHell") return true;
    if (settings["stage3"] && !settings["stage3Repeat"] &&
        oldSaveRoom != newSaveRoom && newSaveRoom == "rTransition3") return true;
    if (settings["stage3Repeat"] && oldRoom != 49 && newRoom == 49) return true;

    if (settings["gameClear"] && old.gameClear == 0 && current.gameClear == 1) return true;
}

gameTime
{
    int sec = Convert.ToInt32(current.seconds);
    int milli = Convert.ToInt32(current.microseconds / 1000);
    return new TimeSpan(0, 0, 0, sec, milli);
}

isLoading
{
    return true;
}

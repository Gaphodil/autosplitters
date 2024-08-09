state("SHOOT")
{
    int roomId : 0x6561E0;
    string16 version : 0x00445C40, 0x60, 0x10, 0x2EC, 0x0, 0x0, 0x0;
    
    double microseconds : 0x00445C40, 0x60, 0x10, 0x13C, 0x40;
    double seconds      : 0x00445C40, 0x60, 0x10, 0x13C, 0x50;
    double deaths       : 0x00445C40, 0x60, 0x10, 0x13C, 0x60;

    double gameStarted  : 0x00445C40, 0x60, 0x10, 0x13C, -48; //-0x30

    // only any%
    double gameClear    : 0x00445C40, 0x60, 0x10, 0x13C, -16; //-0x10

    // 5 weapons, 4 in use
    byte80 unlockedWeapons  : 0x00445C40, 0x60, 0x10, 0x220, 0x20, 0x4, 0x14, 0x100;

    // 50 gameflags ~39 in use
    // 16*50 = 800
    byte800 gameFlags : 0x00445C40, 0x60, 0x10, 0xA3C, 0x20, 0x4, 0x14, 0x0;
}

startup
{
    // ITEMS
    settings.Add("byItem", true, "Split Items");
    settings.SetToolTip("byItem", "Split on weapons, items, and coins, including those that are stored as game flags.");

    settings.Add("revolver", true, "Revolver", "byItem"); // weapon 0
    settings.Add("rocket", true, "Rocket Launcher", "byItem"); // weapon 3
    settings.Add("railgun", true, "Railgun", "byItem"); // weapon 2
    settings.Add("water", true, "Water Gun", "byItem"); // weapon 4
    settings.Add("gunboats", false, "GunBoats", "byItem"); // flag 2
    settings.Add("radio", false, "Pocket Radio", "byItem"); // flag 37
    settings.Add("keycardBlue", false, "Keycard (Blue)", "byItem"); // flag 6
    settings.Add("keycardRed", false, "Keycard (Red)", "byItem"); // flag 7
    settings.Add("keycardGreen", false, "Keycard (Green)", "byItem"); // flag 8
    settings.Add("greenCoins", true, "Green Coins", "byItem"); // flags 24-29 = 2

    // ROOMS
    settings.Add("byRoom", true, "Split Important Rooms");
    settings.SetToolTip("byRoom", "Split if the player's room ID matches that of important locations.");

    settings.Add("trash1", true, "Trash 1", "byRoom"); // rTrash1, 61
    settings.Add("waterplant1", true, "Waterplant 1", "byRoom"); // rWaterplant1, 54
    settings.Add("rooftops1", true, "Rooftops 1", "byRoom"); // rRooftops1, 97
    settings.SetToolTip("rooftops1", "The room with the first save, not right out of the hotel.");
    settings.Add("climb1", true, "Hotel Climb 1", "byRoom"); // rClimb1, 130
    settings.Add("bonusHub", false, "Bonus Hub", "byRoom"); // rBonusHub, 141
    settings.Add("bonusRoomA", false, "Bonus Room A", "byRoom"); // rBonusRoomA, 142 / flag 24 = 1
    settings.Add("bonusRoomB", false, "Bonus Room B", "byRoom"); // rBonusRoomB, 143 / flag 25 = 1
    settings.Add("bonusRoomC", false, "Bonus Room C", "byRoom"); // rBonusRoomC, 144 / flag 26 = 1
    settings.Add("bonusRoomD", false, "Bonus Room D", "byRoom"); // rBonusRoomD, 145 / flag 27 = 1
    settings.Add("bonusRoomE", false, "Bonus Room E", "byRoom"); // rBonusRoomE, 146 / flag 28 = 1
    settings.Add("bonusRoomF", false, "Bonus Room F", "byRoom"); // rBonusRoomF, 147 / flag 29 = 1
    settings.Add("enterBoss1", false, "Enter Boss 1", "byRoom"); // rCityBoss, 33
    settings.Add("beatBoss1", true, "Beat Boss 1", "byRoom"); // flag 1
    settings.Add("enterBoss2", false, "Enter Boss 2", "byRoom"); // rTrashBoss, 89
    settings.Add("beatBoss2", true, "Beat Boss 2", "byRoom"); // rTrashGravPostBoss, 90
    vars.roomCount = 14;

    // MISCELLANEA
    settings.Add("byMisc", false, "Split on Miscellaneous");
    settings.Add("activatePower", false, "Restore Power to City", "byMisc"); // flag 0
    settings.Add("openBlueDoor", false, "Open Blue Door", "byMisc"); // flag 13
    settings.Add("openRedDoor", false, "Open Red Door", "byMisc"); // flag 14
    settings.Add("openGreenDoor", false, "Open Green Door", "byMisc"); // flag 12
    settings.Add("openRevolverlessDoor", false, "Open Revolverless Door", "byMisc"); // flag 15

    // ENDINGS
    settings.Add("byEnd", true, "Split for Ending");
    settings.SetToolTip("byEnd", "Choose which ending(s) to split at.");

    settings.Add("sunsetEnding", true, "Sunset Ending", "byEnd"); // flag4, gameClear
    settings.Add("bonusEnding", true, "Bonus Ending", "byEnd");
    settings.SetToolTip("bonusEnding", "Splits on entering the final room, rather than clear text.");
    // no cutscene flag on bonusEnding, rBonusPath2/3 (149, 150)

    // SPLITTER FUNCTIONALITY

    // derived from https://stackoverflow.com/questions/7832120
    Func<byte[], double[]> ConvertBytes = data =>
    {
        double[] doubles = new double[data.Length / 16];
        for(int i = 0; i < doubles.Length; i++)
            doubles[i] = BitConverter.ToDouble(data, i * 16);
        return doubles;
    };
    vars.ConvertBytes = ConvertBytes;
}

start
{
    if (old.roomId != 14 && current.roomId == 14) // rCity1
        return true;
}

onStart
{
    // for not re-splitting if e.g. you die after collecting an item
    vars.noRepeatWeapons = new bool[6];
    vars.noRepeatFlags = new bool[50];
    vars.noRepeatRooms = new bool[vars.roomCount];
}

reset
{
    // return to title screen
    return (old.gameStarted == 1 && current.gameStarted == 0);
}

split
{
    double[] oldFlags  = vars.ConvertBytes(old.gameFlags);
    double[] newFlags  = vars.ConvertBytes(current.gameFlags);
    int oldRoom = old.roomId;
    int newRoom = current.roomId;

    Func<int, bool> GetFlag = index => 
    {
        return (oldFlags[index] == 0 && newFlags[index] == 1 && !vars.noRepeatFlags[index]);
    };

    if (settings["byItem"])
    {
        // weapons
        double[] oldWeapons  = vars.ConvertBytes(old.unlockedWeapons);
        double[] newWeapons  = vars.ConvertBytes(current.unlockedWeapons);
        for (int i = 0; i < oldWeapons.Length; i++)
        {
            if (i == 0 && !settings["revolver"])
                continue;
            if (i == 3 && !settings["rocket"])
                continue;
            if (i == 2 && !settings["railgun"])
                continue;
            if (i == 4 && !settings["water"])
                continue;

            if (oldWeapons[i] == 0 && newWeapons[i] == 1 && !vars.noRepeatWeapons[i])
            {
                vars.noRepeatWeapons[i] = true;
                return true;
            }
        }

        // non-weapons
        {
            if (settings["gunboats"] && GetFlag(2))
            {
                vars.noRepeatFlags[2] = true;
                return true;
            }
            if (settings["radio"] && GetFlag(37))
            {
                vars.noRepeatFlags[37] = true;
                return true;
            }
            if (settings["keycardBlue"] && GetFlag(6))
            {
                vars.noRepeatFlags[6] = true;
                return true;
            }
            if (settings["keycardRed"] && GetFlag(7))
            {
                vars.noRepeatFlags[7] = true;
                return true;
            }
            if (settings["keycardGreen"] && GetFlag(8))
            {
                vars.noRepeatFlags[8] = true;
                return true;
            }
        }

        // green coins
        if (settings["greenCoins"]) {
            if (oldFlags[24] == 1 && newFlags[24] == 2 && !vars.noRepeatFlags[24])
            {
                vars.noRepeatFlags[24] = true;
                return true;
            }
            if (oldFlags[25] == 1 && newFlags[25] == 2 && !vars.noRepeatFlags[25])
            {
                vars.noRepeatFlags[25] = true;
                return true;
            }
            if (oldFlags[26] == 1 && newFlags[26] == 2 && !vars.noRepeatFlags[26])
            {
                vars.noRepeatFlags[26] = true;
                return true;
            }
            if (oldFlags[27] == 1 && newFlags[27] == 2 && !vars.noRepeatFlags[27])
            {
                vars.noRepeatFlags[27] = true;
                return true;
            }
            if (oldFlags[28] == 1 && newFlags[28] == 2 && !vars.noRepeatFlags[28])
            {
                vars.noRepeatFlags[28] = true;
                return true;
            }
            if (oldFlags[29] == 1 && newFlags[29] == 2 && !vars.noRepeatFlags[29])
            {
                vars.noRepeatFlags[29] = true;
                return true;
            }
        }
    }
    if (settings["byRoom"])
    {
        double[] rooms = new double[] {
            61, 54, 97, 130, 141, 142, 143, 144, 145, 146, 147, 33, 89, 90
        };
        string[] roomOpts = new string[] { 
            "trash1", "waterplant1", "rooftops1", "climb1", "bonusHub",
            "bonusRoomA", "bonusRoomB", "bonusRoomC", "bonusRoomD", "bonusRoomE", "bonusRoomF",
            "enterBoss1", "enterBoss2", "beatBoss2"
        };
        for (int i = 0; i < rooms.Length; i++)
        {
            if (settings[roomOpts[i]] && oldRoom != rooms[i] && newRoom == rooms[i] && !vars.noRepeatRooms[i])
            {
                vars.noRepeatRooms[i] = true;
                return true;
            }
        }
        if (settings["beatBoss1"] && GetFlag(1))
        {
            vars.noRepeatFlags[1] = true;
            return true;
        }
    }
    if (settings["byMisc"])
    {
        if (settings["activatePower"] && GetFlag(0))
        {
            vars.noRepeatFlags[0] = true;
            return true;
        }
        if (settings["openBlueDoor"] && GetFlag(13))
        {
            vars.noRepeatFlags[13] = true;
            return true;
        }
        if (settings["openRedDoor"] && GetFlag(14))
        {
            vars.noRepeatFlags[14] = true;
            return true;
        }
        if (settings["openGreenDoor"] && GetFlag(12))
        {
            vars.noRepeatFlags[12] = true;
            return true;
        }
        if (settings["openRevolverlessDoor"] && GetFlag(15))
        {
            vars.noRepeatFlags[15] = true;
            return true;
        }
    }
    
    if (settings["byEnd"])  
    {
        if (settings["sunsetEnding"] && old.gameClear == 0 && current.gameClear == 1)
        {
            return true;
        }
        if (settings["bonusEnding"] && oldRoom != 149 && newRoom == 149)
        {
            return true;
        }
    }   
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

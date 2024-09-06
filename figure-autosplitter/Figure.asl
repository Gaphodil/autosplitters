state("new hundo")
{
    int roomId : 0x5CB860;
    double deaths       : 0x003BD168, 0x0, 0x34, 0x10, 0x340, 0x420;
    double seconds      : 0x003BD168, 0x0, 0x34, 0x10, 0x340, 0x410;
    double microseconds : 0x003BD168, 0x0, 0x34, 0x10, 0x340, 0x400;
    double gameStarted  : 0x003BD168, 0x0, 0x34, 0x10, 0x340, 0x300;
    double gameClear    : 0x003BD168, 0x0, 0x34, 0x10, 0x340, 0x340;

    double item0        : 0x003C95C0, 0x110, 0xA4, 0x190;
    double item1        : 0x003C95C0, 0x110, 0xA4, 0x1A0;
    double item2        : 0x003C95C0, 0x110, 0xA4, 0x1B0;
    double item3        : 0x003C95C0, 0x110, 0xA4, 0x1C0;
    double item4        : 0x003C95C0, 0x110, 0xA4, 0x1D0;
    double item5        : 0x003C95C0, 0x110, 0xA4, 0x1E0;
}

startup
{
    // first room = 6
    settings.Add("a1",  true,   "Grasslands / Floor 3");    // 9
    settings.Add("a2",  true,   "The Factory / Floor 8");   // 12
    settings.Add("a3",  false,  "Lola / Floor 12");         // 14
    settings.Add("a4",  true,   "Free Save / Floor 13");    // 15
    settings.Add("a5",  true,   "Block Masks / Floor 16");  // 16
    settings.Add("a6",  true,   "The Boys / Floors 17");    // 18
    settings.Add("a7",  true,   "Space / Floor 2");         // 19
    settings.Add("a8",  false,  "Impossible Save / Floor 10");  // 20
    settings.Add("a9",  true,   "Yellow / Floor 19");       // 22
    settings.Add("a10", true,   "A Thousand Times");        // 35
    settings.Add("a11", true,   "Kermit 3.5 / Floor 21");   // 37
    settings.Add("a12", true,   "My Body is a Cage / Floor 22");       // 38
    settings.Add("a13", false,  "The Drugs Don't Work / Floor 29");    // 39
    settings.Add("b1",  true,   "Avoidance");               // 40 / item0
    settings.Add("b1-1", false, "Split on Item instead of Warp", "b1");
    settings.Add("a14", true,   "Sorry!");                  // 41

    // ---
    settings.Add("a15", true,   "3X Sub-Settings");
    settings.SetToolTip("a15",  "For areas around floor 3X.");

    settings.Add("a15-1", true, "Water Needle", "a15");     // 44 -> 41 / item5
    settings.Add("a15-2", true, "Poland", "a15");           // 46 -> 41 / item3
    settings.Add("a15-3", true, "Down Under", "a15");       // 49 -> 41 / item1
    settings.Add("a15-4", true, "Baby Blue Sedan", "a15");  // 52 -> 41 / item4
    settings.Add("a15-5", true, "Gravity", "a15");          // 54 -> 41 / item2

    settings.Add("a15-1-1", false, "Split on Item instead of Warp", "a15-1");
    settings.Add("a15-2-1", false, "Split on Item instead of Warp", "a15-2");
    settings.Add("a15-3-1", false, "Split on Item instead of Warp", "a15-3");
    settings.Add("a15-4-1", false, "Split on Item instead of Warp", "a15-4");
    settings.Add("a15-5-1", false, "Split on Item instead of Warp", "a15-5");

    settings.Add("a15-6", false, "Split at Final 3X Exit", "a15"); // 55
    // ---

    settings.Add("a16", true,   "Release Me Maybe / Floor 45"); // 56
    settings.Add("b2",  true,   "Final Avoidance");             // 57 / gameClear

    int[] splitPoints = {9, 12, 14, 15, 16, 18, 19, 20, 22, 35, 37, 38, 39, 41};
    vars.splitPoints = splitPoints;
    int[] f3XSplitPoints = {44, 46, 49, 52, 54};
    vars.f3XSplitPoints = f3XSplitPoints;

    Func<int, int> F3XAreaToItem = optId =>
    {
        switch (optId)
        {
            case 1: return 5;
            case 2: return 3;
            case 3: return 1;
            case 4: return 4;
            case 5: return 2;
            default: return 99; // shouldn't happen
        } 
    };
    vars.F3XAreaToItem = F3XAreaToItem;
}

start
{
    return (old.roomId != 6 && current.roomId == 6);
}

onStart
{
    // for not re-splitting if e.g. you die after collecting an item
    vars.noRepeatsA = new bool[14]; // a1-14
    vars.noRepeatsB = new bool[8];  // b1, a15-16
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
    double[] oldItem = {old.item0, old.item1, old.item2, old.item3, old.item4, old.item5};
    double[] newItem = {current.item0, current.item1, current.item2, current.item3, current.item4, current.item5};

    // A
    for (int i = 0; i < 14; i++)
    {
        var optId = "a" + (i + 1);
        if (settings[optId] && !vars.noRepeatsA[i])
        {
            var room = vars.splitPoints[i];
            if (oldRoom != room && newRoom == room)
            {
                vars.noRepeatsA[i] = true;
                return true;
            }
        }
    }

    // B
    if (settings["b1"] && !vars.noRepeatsB[0])
    {
        if (settings["b1-1"])
        {
            if (oldItem[0] == 0 && newItem[0] == 1)
            {
                vars.noRepeatsB[0] = true;
                return true;
            }
        }
        else
        {
            if (oldRoom != 40 && newRoom == 40)
            {
                vars.noRepeatsB[0] = true;
                return true;
            }
        }
    }

    if (settings["a15"] && !vars.noRepeatsB[6])
    {
        for (int i = 1; i <= 5; i++)
        {
            var optId = "a15-" + i;
            var room = vars.f3XSplitPoints[i - 1];
            if (settings[optId] && !vars.noRepeatsB[i])
            {
                if (settings[optId + "-1"])
                {
                    var itemId = vars.F3XAreaToItem(i);
                    if (oldItem[itemId] == 0 && newItem[itemId] == 1)
                    {
                        vars.noRepeatsB[i] = true;
                        return true;
                    }
                }
                else
                {
                    if (oldRoom == room && newRoom == 41)
                    {
                        vars.noRepeatsB[i] = true;
                        return true;
                    }
                }
            }
        }
        if (settings["a15-6"] && !vars.noRepeatsB[6] && oldRoom != 55 && newRoom == 55)
        {
            vars.noRepeatsB[6] = true;
            return true;
        }
    }

    if (settings["a16"] && !vars.noRepeatsB[7] && oldRoom != 56 && newRoom == 56)
    {
        vars.noRepeatsB[7] = true;
        return true;
    }

    if (settings["b2"] && old.gameClear == 0 && current.gameClear == 1)
    {
        return true;
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

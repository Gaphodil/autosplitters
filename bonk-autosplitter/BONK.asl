state("BONK", "1.2.2")
{
    // i've heard SignatureScanner can find current room by name but i don't know how it works
    int roomId : 0x6561E0;
    
    double microseconds : 0x0043550C, 0x0, 0x60, 0x10, 0x3F4, 0x2C0;
    double seconds      : 0x0043550C, 0x0, 0x60, 0x10, 0x3F4, 0x2D0;
    double deaths       : 0x0043550C, 0x0, 0x60, 0x10, 0x3F4, 0x2E0;

    double gameStarted  : 0x0043550C, 0x0, 0x60, 0x10, 0x3F4, 0x200;

    // only endings C, D
    double gameClear    : 0x0043550C, 0x0, 0x60, 0x10, 0x3F4, 0x220;

    // num order: GlassShard, BonkFuelRod, GravitySun, ArrowDorito, SmallDumbell, SlimySpoon
    // stored as double array
    byte196 bossItems : 0x00446CE0, 0x0, 0x10, 0x3C, 0x2C, 0x188, 0x30, 0x300;
    byte196 projectorSlides : 0x00446CE0, 0x0, 0x10, 0x3C, 0x2C, 0x188, 0x30, 0x280;

    // 50 gameflags but only 34 in use
    // 16*50 = 800
    byte800 gameFlags : 0x00446CAC, 0x4, 0x8, 0x50, 0x14, 0xB48;

    // 100 coins but only 0-19 (red) and 76-83 (blue) in use
    byte1600 collectedCoins : 0x00445B7C, 0x794, 0x38, 0x4, 0x4, 0x4, 0x840;
}

startup
{
    // ITEMS
    settings.Add("byItem", true, "Split Items");
    settings.SetToolTip("byItem", "Split on item pickup, including those that are stored as game flags.");

    settings.Add("bossItems", true, "Odd Snacks", "byItem");
    settings.Add("projectorSlides", true, "Projector Slides", "byItem");
    settings.Add("manorkey1", false, "Manor Key - Bottom", "byItem"); // flag 10
    settings.Add("manorkey2", false, "Manor Key - Top", "byItem"); // flag 11
    settings.Add("oldkey1", false, "Old Expo Keycard - EZ", "byItem"); // flag 14
    settings.Add("oldkey2", false, "Old Expo Keycard - Silver", "byItem"); // flag 15
    settings.Add("walkie1", true, "Old Lab Walkie-Talkie", "byItem"); // flag 16
    settings.Add("walkie2", false, "Surface Walkie-Talkie", "byItem"); // flag 17
    settings.Add("nulldriver", true, "NULLDRIVER", "byItem"); // flag 20
    settings.Add("cookie", false, "Cookie", "byItem"); // flag 27

    // ROOMS
    settings.Add("byRoom", true, "Split Important Rooms");
    settings.SetToolTip("byRoom", "Split if the player's room id matches that of important locations.");

    settings.Add("grav1", false, "Gravity 1", "byRoom"); // rGravity1, 103
    settings.Add("arrow1", false, "Arrow 1", "byRoom"); // rArrow1, 128
    settings.Add("glass1", false, "Glass 1", "byRoom"); // rGlass1, 46
    settings.Add("slime1", false, "Slime 1", "byRoom"); // rSlime1, 166
    settings.Add("dumbbell1", false, "Dumbbell 1", "byRoom"); // rDumbbell1, 149
    settings.Add("nuclear1", false, "Nuclear 1", "byRoom"); // rBonk8, 72
    settings.Add("oldExpo", false, "Old Expos", "byRoom"); // rHubOldExpos, 24 or flag13
    settings.Add("glassBoss1Room", true, "Glass Boss 1", "byRoom"); // rGlass8, 54
    settings.Add("glassBoss2Room", true, "Glass Boss 2", "byRoom"); // rGlass11, 67
    settings.Add("gravMeteor", true, "Meteor Escape", "byRoom"); // rGravityH7, 123
    settings.Add("slimeCrab", true, "Crab Boss", "byRoom"); // rSlimeHCrabBoss, 195
    settings.Add("slimeCrab2", false, "Crab Boss Rematch", "byRoom"); // rSlimeHCrabRematchBoss, 200
    settings.Add("oBoss", true, "O Boss", "byRoom"); // rOldLabFinalBoss, 220
    vars.roomCount = 13;

    // MISCELLANEA
    settings.Add("byNullSecrets", true, "Split NULLDRIVER Switches"); // flags 3-8
    settings.SetToolTip("byNullSecrets", "Split on glitch room secret switches.");

    settings.Add("byRedCoin", false, "Split Red Coins");
    settings.Add("byBlueCoin", false, "Split Blue Coins");

    settings.Add("splitEnd", true, "Split for Ending");
    settings.SetToolTip("splitEnd", "Choose a final room to split in, and which ending is being gone for.");

    settings.Add("namedEndingB", true, "Ending B allowed", "splitEnd"); // flag 32 = 0
    settings.SetToolTip("namedEndingB", "Must be disabled to only split on ending C.");
    settings.Add("namedEndingC", false, "Ending C allowed", "splitEnd"); // flag 32 = 1
    settings.Add("namedEndingD", false, "Ending D allowed", "splitEnd"); // flag 32 = 2
    settings.Add("jokeEnding", false, "Ending G allowed", "splitEnd"); // rDumbbellGym1Secret2, 154
    settings.Add("creditsRoom", true, "Split at Credits Room", "splitEnd"); // rCredits1, 223
    settings.Add("postCreditsRoom", false, "Split at Post-Credits Room", "splitEnd"); // rCredits2, 224
    settings.SetToolTip("postCreditsRoom", "(Currently no way to end when BONK slide appears)");
    settings.Add("namedEnding", false, "Split at Ending Label (i.e. B, C, D)", "splitEnd"); // rCredits3, 225

    settings.Add("autoReset", false, "Auto Reset");
    settings.SetToolTip("autoReset", "Resets if IGT = 0.00, most often when hitting F2 to return to main menu.");

    // SPLITTER FUNCTIONALITY

    // for not re-splitting if e.g. you die after collecting an item or before crab autosave
    // red and blue coins are autosaved
    bool[] noRepeatItems = new bool[6];
    bool[] noRepeatSlides = new bool[6];
    bool[] noRepeatFlags = new bool[50];
    bool[] noRepeatRooms = new bool[vars.roomCount];
    vars.noRepeatItems = noRepeatItems;
    vars.noRepeatSlides = noRepeatSlides;
    vars.noRepeatFlags = noRepeatFlags;
    vars.noRepeatRooms = noRepeatRooms;

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
    Array.Clear(vars.noRepeatItems, 0, 6);
    Array.Clear(vars.noRepeatSlides, 0, 6);
    Array.Clear(vars.noRepeatFlags, 0, 50);
    Array.Clear(vars.noRepeatRooms, 0, vars.roomCount);

    if (old.roomId != 11 && current.roomId == 11) // rIntro1
    {
        return true;
    }
}

reset
{
    // return to title screen
    if (settings["autoReset"])
    {
        return (old.gameStarted == 1 && current.gameStarted == 0);
    }
}

split
{
    double[] oldItems  = vars.ConvertBytes(old.bossItems);
    double[] newItems  = vars.ConvertBytes(current.bossItems);
    double[] oldSlides = vars.ConvertBytes(old.projectorSlides);
    double[] newSlides = vars.ConvertBytes(current.projectorSlides);
    double[] oldFlags  = vars.ConvertBytes(old.gameFlags);
    double[] newFlags  = vars.ConvertBytes(current.gameFlags);
    double[] oldCoins  = vars.ConvertBytes(old.collectedCoins);
    double[] newCoins  = vars.ConvertBytes(current.collectedCoins);
    int oldRoom = old.roomId;
    int newRoom = current.roomId;
    double[] rooms = new double[] { 103, 128, 46, 166, 149, 72, 24, 54, 67, 123, 195, 200, 220 };

    if (settings["byItem"])
    {
        if (settings["bossItems"])
        {
            for (int i = 0; i < oldItems.Length; i++)
            {
                if (oldItems[i] == 0 && newItems[i] == 1 && !vars.noRepeatItems[i])
                {
                    vars.noRepeatItems[i] = true;
                    return true;
                }
            }
        }
        if (settings["projectorSlides"])
        {
            for (int i = 0; i < oldSlides.Length; i++)
            {
                if (oldSlides[i] == 0 && newSlides[i] == 1 && !vars.noRepeatSlides[i])
                {
                    vars.noRepeatSlides[i] = true;
                    return true;
                }
            }
        }
        if (settings["manorkey1"] && oldFlags[10] == 0 && newFlags[10] == 1 && !vars.noRepeatFlags[10])
        {
            vars.noRepeatFlags[10] = true;
            return true;
        }
        if (settings["manorkey2"] && oldFlags[11] == 0 && newFlags[11] == 1 && !vars.noRepeatFlags[11])
        {
            vars.noRepeatFlags[11] = true;
            return true;
        }
        if (settings["oldkey1"] && oldFlags[14] == 0 && newFlags[14] == 1 && !vars.noRepeatFlags[14])
        {
            vars.noRepeatFlags[14] = true;
            return true;
        }
        if (settings["oldkey2"] && oldFlags[15] == 0 && newFlags[15] == 1 && !vars.noRepeatFlags[15])
        {
            vars.noRepeatFlags[15] = true;
            return true;
        }
        if (settings["walkie1"] && oldFlags[16] == 0 && newFlags[16] == 1 && !vars.noRepeatFlags[16])
        {
            vars.noRepeatFlags[16] = true;
            return true;
        }
        if (settings["walkie2"] && oldFlags[17] == 0 && newFlags[17] == 1 && !vars.noRepeatFlags[17])
        {
            vars.noRepeatFlags[17] = true;
            return true;
        }
        if (settings["nulldriver"] && oldFlags[20] == 0 && newFlags[20] == 1 && !vars.noRepeatFlags[20])
        {
            vars.noRepeatFlags[20] = true;
            return true;
        }
        if (settings["cookie"] && oldFlags[27] == 0 && newFlags[27] == 1 && !vars.noRepeatFlags[27])
        {
            vars.noRepeatFlags[27] = true;
            return true;
        }
    }
    if (settings["byRoom"])
    {
        string[] roomOpts = new string[] { 
            "grav1", "arrow1", "glass1", "slime1", "dumbbell1", "nuclear1", "oldExpo",
            "glassBoss1Room", "glassBoss2Room", "gravMeteor", "slimeCrab", "slimeCrab2", "oBoss" };
        for (int i = 0; i < rooms.Length; i++)
        {
            if (settings[roomOpts[i]] && oldRoom != rooms[i] && newRoom == rooms[i] && !vars.noRepeatRooms[i])
            {
                vars.noRepeatRooms[i] = true;
                return true;
            }
        }
    }
    if (settings["byNullSecrets"])
    {
        for (int i = 3; i <= 8; i++)
        {
            if (oldFlags[i] == 0 && newFlags[i] == 1 && !vars.noRepeatFlags[i])
            {
                vars.noRepeatFlags[i] = true;
                return true;
            }
        }
    }
    if (settings["byRedCoin"])
    {
        for (int i = 0; i <= 19; i++)
        {
            if (oldCoins[i] == 0 && newCoins[i] == 1)
                return true;
        }
    }
    if (settings["byBlueCoin"])
    {
        for (int i = 76; i <= 83; i++)
        {
            if (oldCoins[i] == 0 && newCoins[i] == 1)
                return true;
        }
    }
    if (settings["splitEnd"])  
    {
        if (settings["jokeEnding"] && oldRoom != 154 && newRoom == 154)
            return true;
        
        if ((settings["namedEndingB"] && newFlags[32] == 0) ||
            (settings["namedEndingC"] && newFlags[32] == 1) ||
            (settings["namedEndingD"] && newFlags[32] == 2))
        {
            if ((settings["creditsRoom"] && oldRoom != 223 && newRoom == 223) ||
                (settings["postCreditsRoom"]  && oldRoom != 224 && newRoom == 224) ||
                (settings["namedEnding"] && oldRoom != 225 && newRoom == 225))
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

state("IWSTS")
{
    int roomId : 0x6561E0;
    
    double microseconds : 0x00445C40, 0x60, 0x10, 0x28, 0x460;
    double seconds      : 0x00445C40, 0x60, 0x10, 0x28, 0x470;
    double deaths       : 0x00445C40, 0x60, 0x10, 0x28, 0x480;

    double gameStarted  : 0x00445C40, 0x60, 0x10, 0x28, 0x380;
    double gameClear    : 0x00445C40, 0x60, 0x10, 0x28, 0x3B0;
}
state("I wanna stop the simulation")
{
    int roomId : 0x6561E0;
    
    double microseconds : 0x00445C40, 0x60, 0x10, 0x28, 0x460;
    double seconds      : 0x00445C40, 0x60, 0x10, 0x28, 0x470;
    double deaths       : 0x00445C40, 0x60, 0x10, 0x28, 0x480;

    double gameStarted  : 0x00445C40, 0x60, 0x10, 0x28, 0x380;
    double gameClear    : 0x00445C40, 0x60, 0x10, 0x28, 0x3B0;
}

startup
{
    settings.Add("b1", false, "Enter Runman Boss"); // 28
    settings.Add("tr1", true, "Transition to Super Mario Bros. 2"); // 15
    settings.Add("b2", false, "Enter Mecha Birdo"); // 38
    settings.Add("b2-i", false, "Use Intro Cutscene", "b2"); // 37
    settings.Add("tr2", true, "Transition to Baba is You"); // 16
    settings.Add("b3", false, "Enter Ghost is Boos"); // 50
    settings.Add("tr3", true, "Transition to Binding of Isaac: Rebirth"); // 17
    settings.Add("tr4", true, "Transition to Spelunky"); // 18
    settings.Add("b5", false, "Enter Mr. Ribbit"); // 63
    settings.Add("b5-2", false, "Enter Mr. Ribbit Phase 2"); // 64
    settings.Add("tr5", true, "Transition to Contra"); // 19
    settings.Add("b6", false, "Enter Tower of Death (real)"); // 71
    settings.Add("tr6", true, "Transition to Super Castlevania IV"); // 20
    settings.Add("b7", false, "Enter Simon Belmont"); // 77
    settings.Add("tr7", true, "Transition to ???"); // 21
    settings.Add("b8-1", false, "Enter Final Boss Intro"); // 94
    settings.Add("b8-2", false, "Enter Final Boss Phase 1"); // 95
    settings.Add("b8-3", false, "Enter Final Boss Phase 2"); // 97
    settings.Add("b8-4", true, "Beat Final Boss"); // 98 / gameClear / noPause
    settings.SetToolTip("b8-4", "This isn't exactly on final hit, but when the transition starts 100 frames / 2 seconds after. You may choose to retime.");

    // fun fact! while making i found an unfinished boss with dev textures titled "true final boss"

    int[] transitions = new int[7];
    for (int i = 15; i <= 21; i++)
        transitions[i-15] = i;
    vars.transitions = transitions;
    int[] rooms = {28, 38, 50, -1, 63, 71, 77};
    vars.rooms = rooms;
    int[] fbRooms = {94, 95, 97, 98};
    vars.fbRooms = fbRooms;

    bool[] noRepeatsA = new bool[7];
    bool[] noRepeatsB = new bool[7];
    bool[] noRepeatsC = new bool[4];
    vars.noRepeatsA = noRepeatsA;
    vars.noRepeatsB = noRepeatsB;
    vars.noRepeatsC = noRepeatsC;
}

start
{
    return (old.roomId != 22 && current.roomId == 22); // rRunman_Intro
}

reset
{
    // return to title screen
    return (old.gameStarted == 1 && current.gameStarted == 0);
}

split
{
    Func<String, int, bool> CheckRoom = (settingId, room) => {
        if (room < 0) throw new Exception("Room number must be >= 0");
        return (settings[settingId] && old.roomId != room && current.roomId == room);
    };

    // area transitions
    for (int i = 0; i < 7; i++)
    {
        var settingId = "tr" + (i + 1);
        if (!vars.noRepeatsA[i] && CheckRoom(settingId, vars.transitions[i])) {
            vars.noRepeatsA[i] = true;
            return true;
        }
    }

    // boss entrances
    for (int i = 0; i < 7; i++)
    {
        if (i == 3) continue; // no distinct isaac boss gm room
        if (vars.noRepeatsB[i]) continue;
        var settingId = "b" + (i + 1);
        if (i == 1 && settings["b2-i"]) {
            if (CheckRoom(settingId, vars.rooms[i] - 1)) {
                vars.noRepeatsB[i] = true;
                return true;
            }
        }
        else if (CheckRoom(settingId, vars.rooms[i])) {
            vars.noRepeatsB[i] = true;
            return true;
        }
    }

    // reuse a noRepeatsB for lunky 2
    if (!vars.noRepeatsB[3] && CheckRoom("b5-2", 64)) {
        vars.noRepeatsB[3] = true;
        return true;
    }

    // final boss
    for (int i = 0; i < 3; i++)
    {
        var settingId = "b8-" + (i + 1);
        if (!vars.noRepeatsC[i] && CheckRoom(settingId, vars.fbRooms[i])) {
            vars.noRepeatsC[i] = true;
            return true;
        }
    }
    
    return (settings["b8-4"] && old.gameClear == 0 && current.gameClear == 1);
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

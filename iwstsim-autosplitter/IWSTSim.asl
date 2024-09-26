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
    settings.Add("b4-1", false, "Enter Isaac Floor Transition"); // 52
    settings.Add("b4-2", false, "Enter Isaac Floor 2"); // 53
    settings.Add("tr4", true, "Transition to Spelunky"); // 18
    settings.Add("b5", false, "Enter Mr. Ribbit"); // 63
    settings.Add("b5-2", false, "Enter Mr. Ribbit Phase 2"); // 64
    settings.Add("tr5", true, "Transition to Contra"); // 19
    settings.Add("b6", false, "Enter Tower of Death (real)"); // 71
    settings.Add("tr6", true, "Transition to Super Castlevania IV"); // 20
    settings.Add("b7", false, "Enter Simon Belmont"); // 77
    settings.Add("tr7", true, "Transition to ???"); // 21
    settings.Add("a7", false, "Splits during Final Area");
    settings.Add("a7-1", false, "Enter RtM-Mario", "a7"); // 79
    settings.Add("a7-2", false, "Enter RtM-VVVVVV", "a7"); // 80
    settings.Add("a7-3",  true, "Enter WtW-Super Meat Boy", "a7"); // 85
    settings.Add("a7-4", false, "Enter WtW-Kirby", "a7"); // 88
    settings.Add("a7-5",  true, "Enter FaC-Mega Man X", "a7"); // 90
    settings.Add("a7-6", false, "Enter FaC-The End is Nigh", "a7"); // 92
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
    int[] faRooms = {79, 80, 85, 88, 90, 92};
    vars.faRooms = faRooms;
    int[] fbRooms = {94, 95, 97, 98};
    vars.fbRooms = fbRooms;
}

start
{
    return (old.roomId != 22 && current.roomId == 22); // rRunman_Intro
}

onStart
{
    // for not re-splitting if e.g. you die after collecting an item
    vars.noRepeatsA = new bool[7]; // transitions
    vars.noRepeatsB = new bool[7]; // boss rooms
    vars.noRepeatsC = new bool[4]; // final boss rooms
    vars.noRepeatsD = new bool[6]; // final area rooms
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

    // added isaac rooms
    if (CheckRoom("b4-1", 52))
    {
        return true; // tbh if you hit r here it's your fault
    }
    if (CheckRoom("b4-2", 53)) return true;

    // lunky 2 
    if (CheckRoom("b5-2", 64)) return true;

    // final area
    if (settings["a7"])
    {
        for (int i = 0; i < 6; i++)
        {
            var settingId = "a7-" + (i + 1);
            if (!vars.noRepeatsD[i] && CheckRoom(settingId, vars.faRooms[i])) {
                vars.noRepeatsD[i] = true;
                return true;
            }
        }
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

state("iwt2Uber")
{
    int roomId : 0x6561E0;
    double gameStarted  : 0x00445C40, 0x60, 0x10, 0x1E4, -200;
}

startup
{
    // first room = 10
    settings.Add("area1", false, "Split on Entering Area 1"); // area 1 start = 11
    settings.Add("area1finish", false, "Split on Completing Area 1"); // area 1 end = 17
    settings.Add("area2", true, "Split on Entering Area 2"); // area 2 start = 19
    settings.Add("area2finish", false, "Split on Completing Area 2");// area 2 end = 23
    settings.Add("area3", true, "Split on Entering Area 3"); // area 3 start = 25
    settings.Add("area3finish", false, "Split on Completing Area 3"); // area 3 end = 34
    settings.Add("area4", true, "Split on Entering Area 4"); // area 4 start = 36
    settings.Add("area4finish", false, "Split on Completing Area 4"); // area 4 end = 47
    settings.Add("pre-final", true, "Split on Entering Pre-Final"); // pre-final true = 50
    settings.Add("final", false, "Split on Entering Final"); // boss room = 54
    settings.Add("clear", true, "Split on Clear Room"); // clear room = 55

    int[] entryRooms = {11, 19, 25, 36};
    vars.entryRooms = entryRooms;
    int[] finishRooms = {17, 23, 34, 47};
    vars.finishRooms = finishRooms;
}

start
{
    return (old.roomId != 10 && current.roomId == 10);
}

onStart
{
    vars.noRepeatRooms = new bool[4];
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

    
    for (int i = 1; i <= 4; i++)
    {
        var entry = "area" + i;
        var finish = entry + "finish";
        var entryRoom = vars.entryRooms[i - 1];
        var finishRoom = vars.finishRooms[i - 1];
        if (settings[entry] && !vars.noRepeatRooms[i - 1] && oldRoom != entryRoom && newRoom == entryRoom)
        {
            vars.noRepeatRooms[i - 1] = true;
            return true;
        }
        if (settings[finish] && oldRoom == finishRoom && newRoom == 54) return true;
    }
    if (settings["pre-final"] && oldRoom != 50 && newRoom == 50) return true;
    if (settings["final"] && oldRoom == 50 && newRoom == 54) return true;
    if (settings["clear"] && oldRoom != 55 && newRoom == 55) return true;

}

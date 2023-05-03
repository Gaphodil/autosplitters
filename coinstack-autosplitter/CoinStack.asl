state("I wanna CoinStack 1000")
{
    int roomId : 0x64E608;
    
    double microseconds : 0x0042F504, 0x0, 0x60, 0x10, 0x5EC, 0x0, 0x28, 0x420;
    double seconds      : 0x0042F504, 0x0, 0x60, 0x10, 0x5EC, 0x0, 0x28, 0x430;
    double deaths       : 0x0042F504, 0x0, 0x60, 0x10, 0x5EC, 0x0, 0x28, 0x440;

    double gameStarted  : 0x0042F504, 0x0, 0x60, 0x10, 0x5EC, 0x0, 0x28, 0x270;
    double gameClear    : 0x0042F504, 0x0, 0x60, 0x10, 0x5EC, 0x0, 0x28, 0x290;
    // double saveGameClear: 0x0042F504, 0x0, 0x60, 0x10, 0x5EC, 0x0, 0x28, 0x2A0;
}

startup
{
    settings.Add("hubEntry", false, "Split on Every Hub Entry");
    settings.Add("gameClear", true, "Split on Game Clear");
}

start
{
    if (old.gameStarted == 0 && current.gameStarted == 1)
        return true;
}

reset
{
    // return to title screen
    return (old.gameStarted == 1 && current.gameStarted == 0);
}

split
{
    if (settings["hubEntry"] && old.roomId > 14 && current.roomId == 14) // rHub
        return true;
    if (settings["gameClear"] && old.gameClear == 0 && current.gameClear == 1)
        return true;
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

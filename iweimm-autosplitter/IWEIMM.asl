state("I Wanna Escape Into My Mind") {}

startup {
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "I Wanna Escape Into My Mind";
    vars.Helper.LoadSceneManager = true;

    vars.sceneNames = new[] {
        "Level1_6",
        "Level1_11",
        "Level1Boss_4",
        "Transition2",
        "Level2_7",
        "Level2_14",
        "Level2Boss",
        "Transition3",
        "Level3_7",
        "Level3_13",
        "Level3_20",
        "Transition4",
        "Level4_7",
        "Level4_15",
        "Level4Boss_1",
        "Transition5",
        "Level5_8",
        "Level5_16",
        "Level5_22",
        "Level5_31",
        "Level5Boss_1",
        "EndingPart1",
    };
}

init {
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => {
        return true;
    });
}

update
{
    current.Scene = vars.Helper.Scenes.Active.Name;
}

start
{
    if (current.Scene == "IntroCutscene")
        return true;
}

split
{
    for (int i = 0; i < vars.sceneNames.Length; i++)
    {
        if (old.Scene != current.Scene && current.Scene == vars.sceneNames[i])
        {
            return true;
        }
    }
}

reset
{
    if (current.Scene == "Title")
        return true;
}

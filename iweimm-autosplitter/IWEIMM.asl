state("I Wanna Escape Into My Mind") {}

startup {
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "I Wanna Escape Into My Mind";
    vars.Helper.LoadSceneManager = true;

    vars.sceneNames = new[] {
        "Level1_1", // -turret
        "Level1_6", // glitch
        "Level1_11", // throwback
        "Level1Boss_2", // -norton
        "Level1Boss_4", // cherry

        "Transition2", // post-cherry, pre-mode
        "Level2_7", // atari
        "Level2_14", // post void
        "Level2Boss", // post^2 void, nehema
        "Transition3", // post-nehema, pre-smiles
        
        "Level3_7", // steppies
        "Level3_13", // eyes
        "Level3_20", // wlfgrl
        "Transition4", // post-wlfgrl, pre-girl
        "Level4_7", // my first game :)
        
        "Level4_15", // heaven
        "Level4Boss_1", // queen
        "Level4Boss_3", // -queen core
        "Transition5", // post-queen, pre-final1
        "Level5_8", // throwback^2
        
        "Level5_15", // -cherry/wlf miniboss
        "Level5_16", // final2
        "Level5_22", // final3 (void/girl)
        "Level5_30", // -nehema/queen miniboss
        "Level5_31", // final4
        
        "Level5Boss_1", // final boss phase1
        "Level5Boss_3", // -final boss phase2
        "Level5Boss_6", // -final boss phase3
        "Level5Boss_8", // -final boss phase4
        "EndingPart1", // post-phase4
    };
    var settingDesc = new[] {
        "Stage 1-1", "Stage 1-2", "Stage 1-3", "Norton Antivirus", "Contrarian Cherry",
        "Stage 2-1", "Stage 2-2", "Stage 2-3", "Nehema",
        "Stage 3-1", "Stage 3-2", "Stage 3-3", "Wlfgrl",
        "Stage 4-1", "Stage 4-2", "Stage 4-3", "Queen", "Queen Core",
        "Stage 5-1", "Stage 5-Throwback", "Stage 5-Cherry/Wlfgrl",
        "Stage 5-2", "Stage 5-Post Void/The Girl", "Stage 5-Nehema/Queen",
        "Stage 5-3", "Final Boss-Phase 1", "Final Boss-Phase 2",
        "Final Boss-Phase 3", "Final Boss-Phase 4", "Ending",
    };
    var nonDefault = new[] {0, 3, 17, 20, 23, 26, 27, 28};
    for (int i = 0; i < vars.sceneNames.Length; i++)
    {
        settings.Add(vars.sceneNames[i], !nonDefault.Contains(i), settingDesc[i]);
    }
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

onStart
{
    vars.sceneVisited = new int[vars.sceneNames.Length];
}

split
{
    for (int i = 0; i < vars.sceneNames.Length; i++)
    {
        if (current.Scene == vars.sceneNames[i] && vars.sceneVisited[i] == 0 && settings[vars.sceneNames[i]])
        {
            vars.sceneVisited[i] = 1;
            return true;
        }
    }
}

reset
{
    if (current.Scene != old.Scene && (current.Scene == "Title" || current.Scene == "WarpRoom"))
        return true;
}

using System.IO;
using DailyGambit;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace DailyGambit.Editor
{
    public static class DailyGambitBuild
    {
        private const string ScenePath = "Assets/Scenes/Main.unity";
        private const string ApkPath = "Builds/Android/DailyGambitUnity.apk";

        [MenuItem("Daily Gambit/Create Or Refresh Main Scene")]
        public static void CreateOrRefreshMainScene()
        {
            Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            GameObject root = new("Daily Gambit Game");
            root.AddComponent<DailyGambitGame>();
            EditorSceneManager.MarkSceneDirty(scene);
            Directory.CreateDirectory("Assets/Scenes");
            EditorSceneManager.SaveScene(scene, ScenePath);
            EditorBuildSettings.scenes = new[]
            {
                new EditorBuildSettingsScene(ScenePath, true)
            };
        }

        [MenuItem("Daily Gambit/Build Android Release APK")]
        public static void BuildAndroidRelease()
        {
            CreateOrRefreshMainScene();
            Directory.CreateDirectory(Path.GetDirectoryName(ApkPath));
            EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Android, BuildTarget.Android);
            PlayerSettings.productName = "Daily Gambit";
            PlayerSettings.companyName = "Valiantlion Apps";
            PlayerSettings.bundleVersion = "0.1.0";
            PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android, "com.valiantlion.dailygambit");
            PlayerSettings.Android.bundleVersionCode = 1;
            PlayerSettings.Android.minSdkVersion = AndroidSdkVersions.AndroidApiLevel23;
            PlayerSettings.Android.targetSdkVersion = AndroidSdkVersions.AndroidApiLevelAuto;
            EditorUserBuildSettings.androidBuildSystem = AndroidBuildSystem.Gradle;

            BuildPlayerOptions options = new()
            {
                scenes = new[] { ScenePath },
                locationPathName = ApkPath,
                target = BuildTarget.Android,
                options = BuildOptions.None
            };
            BuildPipeline.BuildPlayer(options);
        }
    }
}

using System;
using System.IO;
using DailyGambit;
using UnityEditor;
using UnityEditor.Android;
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
            PlayerSettings.bundleVersion = "1.0.15";
            PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android, "com.valiantlion.dailygambit.unity");
            PlayerSettings.Android.bundleVersionCode = 15;
            PlayerSettings.Android.minSdkVersion = AndroidSdkVersions.AndroidApiLevel25;
            PlayerSettings.Android.targetSdkVersion = AndroidSdkVersions.AndroidApiLevelAuto;
            PlayerSettings.defaultInterfaceOrientation = UIOrientation.Portrait;
            PlayerSettings.allowedAutorotateToPortrait = true;
            PlayerSettings.allowedAutorotateToPortraitUpsideDown = false;
            PlayerSettings.allowedAutorotateToLandscapeLeft = false;
            PlayerSettings.allowedAutorotateToLandscapeRight = false;
            EditorUserBuildSettings.androidBuildSystem = AndroidBuildSystem.Gradle;
            ConfigureAndroidToolchain();

            BuildPlayerOptions options = new()
            {
                scenes = new[] { ScenePath },
                locationPathName = ApkPath,
                target = BuildTarget.Android,
                options = BuildOptions.None
            };
            BuildPipeline.BuildPlayer(options);
        }

        private static void ConfigureAndroidToolchain()
        {
            string androidSdk = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "Android",
                "Sdk");
            string androidNdk = LatestDirectory(Path.Combine(androidSdk, "ndk"));
            string jdk = FirstExistingDirectory(
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Eclipse Adoptium", "jdk-17.0.18.8-hotspot"),
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Java", "jdk-24"));

            if (!Directory.Exists(androidSdk) || string.IsNullOrEmpty(androidNdk) || string.IsNullOrEmpty(jdk))
            {
                throw new DirectoryNotFoundException($"Android toolchain missing. SDK={androidSdk}, NDK={androidNdk}, JDK={jdk}");
            }

            AndroidExternalToolsSettings.sdkRootPath = androidSdk;
            AndroidExternalToolsSettings.ndkRootPath = androidNdk;
            AndroidExternalToolsSettings.jdkRootPath = jdk;
        }

        private static string LatestDirectory(string path)
        {
            if (!Directory.Exists(path))
            {
                return null;
            }

            string[] directories = Directory.GetDirectories(path);
            Array.Sort(directories, StringComparer.OrdinalIgnoreCase);
            return directories.Length == 0 ? null : directories[^1];
        }

        private static string FirstExistingDirectory(params string[] paths)
        {
            foreach (string path in paths)
            {
                if (Directory.Exists(path))
                {
                    return path;
                }
            }

            return null;
        }
    }
}

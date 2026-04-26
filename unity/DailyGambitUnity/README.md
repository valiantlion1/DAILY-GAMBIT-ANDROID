# Daily Gambit Unity

This is the game-engine track for Daily Gambit. The existing Flutter app stays in place as the published prototype, while this Unity project owns the real-time 2.5D board, camera, materials, animation loop, and Android build path.

## Target

- Unity 6 LTS or newer.
- Android Build Support with SDK, NDK, and OpenJDK child modules.
- Mobile-first 60/120 FPS chess feel.

## Build

After Unity is installed, open Unity Hub, choose `Add project from disk`, and select:

```powershell
C:\Users\valiantlion\Desktop\GAME\unity\DailyGambitUnity
```

To create the scene and build an APK from command line, replace the Unity version in the path with the editor installed on the machine:

```powershell
& "C:\Program Files\Unity\Hub\Editor\6000.3.7f1\Editor\Unity.exe" -batchmode -quit -projectPath "C:\Users\valiantlion\Desktop\GAME\unity\DailyGambitUnity" -executeMethod DailyGambit.Editor.DailyGambitBuild.BuildAndroidRelease
```

The build script writes to `unity/DailyGambitUnity/Builds/Android/DailyGambitUnity.apk`.

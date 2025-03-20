# 💡 Lighting Profile

Quickly create lighting profiles from the current lighting 💡,<br>
great for quickly switching between different lighting while building 🧱,<br> or for scripted lighting changes between scenes! 📜<br>

# Installing 📥

You can get the plugin [on roblox](https://www.roblox.com/library/8811872666/Lighting-Profile-Creator) or from the [releases tab!](https://github.com/hexa0/lighting-profile/releases)<br>
alternatively you can build it from source ⬇️

# API 📜

for the API docs, [see here.](https://github.com/hexa0/lighting-profile-api/blob/main/docs/api.md)

# Building 🧱

This plugin uses [Rojo](https://github.com/rojo-rbx/rojo) for building,<br>
To build this plugin from scratch, install rojo then clone the repository with
```bash
git clone
```
then update the submodules
```bash
git submodule update --recursive --remote
```
and then run this if you're on windows

```bash
./build.bat
```

or if you're on linux or mac run:

```bash
./build.sh
```

Next, copy `LightingProfilePlugin.rbxmx` from the builds folder into Roblox Studio's plugin folder

For more help, check out [the Rojo documentation](https://rojo.space/docs)
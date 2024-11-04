# Spruce Auto Updater
This is for updating your existing spruce install and for versions 2.3.0 and below. This will allow you to update to the latest version of Spruce painlessly and keep all your relevant configurations and settings.

If you are looking for first time installation instructions go to our wiki on the spruceUI repo

[Spruce Install Instructions](https://github.com/spruceUI/spruceOS/wiki/Installation-Instructions)

If you are on spruce 3.0.0 or above you do not need this, it should be included in some form on those versions.

## Preparation

You don't need to do much except make sure you have enough free space on your SDCard for the latest version of spruce, and some room to spare. Make sure you have at least 30% battery left or charging when you run the updater.

Your SDCard and A30

## Usage
To use this get the latest release and plug your A30's SDCard into your computer. AutoUpdater should be a contained zip file with all the parts you'll need to update your spruce install. You'll need the latest AutoUpdater compatiblie spruce file.

This should just be the 7zip file in the [latest spruce release](https://github.com/spruceUI/spruceOS/releases).

Unzip the AutoUpdater.zip file and place the contents directly onto your SDCard's root. They should align somewhat with the already existing spruce folders, like `Apps`. If it prompts you to overwrite be sure to accept.

Place your spruceVxx.xx.xx.7z on the root of your SDCard. **Do not extract this file!** You should place the 7z directly on your SDCard. This will be used by AutoUpdater for you.

Once you've place the Auto Updater files and the latest release 7z file on your SDCard put it back into your A30 and startup.

Once back on your A30, go to your Apps and you should see a new `spruce Updater` app in your list of apps. Just launch this and sit back. This will backup your current install, install the update, restore your install, upgrade any files that need it, and then shut down. You'll need to power back on manually afterwards.

Afterward you should go through our fresh update process to finish setting up the install. During the Auto Updater process your back up was automatically restored so you should be good to go. Happy gaming!

## F.A.Q

### "Will I loose all my configs and settings running this?"
No, this contains a self contained version of our spruce Backup app to backup your valuable data. This includes but is not limited to: PPSSPP saves/configs, NDS saves/configs, Syncthing setup, PICO8 saves/bios, and your RetroArch config. Your Saves, Roms, and BIOS folders will be left untouched.

### "What versions of spruce does this work for?"
The currently targeted version of spruce this was written for was 2.0.0 to 2.3.0. But it should work _well_ if not entirely with lower versions. We'll work to getting lower versions the official stamp of approval but overall they should work perfectly fine with AutoUpdater. If we hear/find otherwise we'll update this.

## AutoUpdater Messages

### Message "No update file found"
If you see this you do not have an update file, the update file is not in the right place (the root of your SDCard), or the update file isn't named with our naming convention. Be sure you have a file on the root of your SDCard named `spruceVxx.xx.xx.7z` with the `xx.xx.xx` being the version number you have.

### Message "Battery level too low"
Should be obvious, charge your device! If you have less than 30% battery auto updater will not run. You can also plug your device in and run it again if you don't want to wait.

### Message "Detected current installation is invalid. Allowing reinstall."
This is a rather rudimentary check if your current spruce install is in a good state or not. If this appears your current installation isn't in a good state. But we'll allow you to run the updater and skip the version check. This mostly just an informative warning. More details can be found in `SDCARD/Updater/update.log`

### Message "Invalid update file structure"
If you see this the spruce 7z you provided could not be validated as a proper spruce update file. Be sure you're using the proper update file from our [latest spruce release](https://github.com/spruceUI/spruceOS/releases). If you continue to get this message reach out to us and be sure to include your update log file. Log can be found in `SDCARD/Updater/update.log`

### Message "Updated completed with errors, check log for details"
If you see this the update process successfully ran but a file wasn't able to be extracted from the update file. Hopefully this shouldn't appear, but if it does it can be mostly harmless. But check the update log in your `SDCARD/Updater/update.log` file for more details. 

### Message "Update extraction incomplete: `directory`"
This is a post install verfication. If you see this something went wrong with your install, the updater stopped running immediatly. If this happens to you it's most likely an SDCard failure of some kind, be sure to verify your SDCard. During the process a compatible backup file was made. You should hold onto that and after checking your SDCard manually update and run spruce Restore afterwards.


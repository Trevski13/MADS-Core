# MADS
Modular Application Deployment System

### Goal:
MADS provides a simple system to easily build and deploy application updates complete with error checking and logging

### Component Overview:
MADS_core.bat  -- The heart of MADS, this script calls all other scripts and handles logging of overall progress  
MADS_core.ps1  -- The other heart of MADS, this script is the same as the .bat version but implemented in powershell  
settings.ini   -- The primary settings file, edit this to set directories and preferences  
room_*.ini     -- The room configuration file, it contains the list of modules to run for a given room  
run_script.bat -- The entry point, this file contains all the code needed to launch everything else, it can either load settings from a settings.ini file in the same directory, read them from settings imbedded in itself, or prompt for them on run.  
extensions     -- The extra bits, put any files that might be needed by numerous modules here, examples are 7z.exe & psexec.exe  
modlets        -- The heart of simple script creation, the modlets are designed to simplify common actions needed to deploy updates  

## How to Use:

### Setup:
1. Copy the core directory to where ever you will be deploying apps from, this could be a network share drive or a usb flash drive  
2. Create a room_*.ini file for each set of computers (idealy one's you will update all at one time)  
3. Copy the run_script file to an easily accessible location USB, already mounted network share, or even load it ahead of time to the computers themselves  
4. Edit the core settings.ini file, setting the directories appropriately for your configuration  
5. Modify the run_script for your use, you can either put a settings.ini file with it or edit it directly with your configuration settings. It is also recommended that you rename it to indicate what it will do.

Alternatively you can use the setup.bat included in the MADS-Utilities to assist in setup

### Running:

1. Modify the appropriate room_*.ini file to contain a space separated list of modules you would like to run this can be done manually or through the GUI
2. Run your modified run_script, which will start the update process

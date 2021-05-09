# GraphTastic Dialog Player
## _plugin for the godot game-engine_

https://github.com/vincepr/graphtastic

online demo version(takes a while to load): https://htmlpreview.github.io/?https://github.com/vincepr/graphtastic/blob/main/exports/html/index.html

Graphtastic extends godot with a custom editor to create and edit, mindmap-like branching dialog files on the one hand.
An fully customizable framework to display that dialog on the other hand. 

## Disclaimer
This still a fairly early build, so dont expect a polished project. I highly appreciate all critique, suggestions and every reported bug. 

## Features

- The mindmap like Graphs make it easy to visualize the paths a dialog can take, while providing the structure for the dialog to get parsed trough on runtime.
- Save dialog-data as common .tsv database tables to open in excel/googledocs.
- 4 prebuild nodes make it easy to include dialogs into projects:
    - Textbox
    - Pictureframes 
    - Speakerlabel
    - List to display player-choices
- BB-code like functionality extends your text to be able to:
    - Change and display variables from within your texbox.
    - Send custom signals.
    - lock parts of your text/commands behind if statements.


## Installation

        for Godot version v3.3:
        copy the addons folder from github to res://addons of your game. 
        Enable the addon [Project]-> [Project Settings]->[Plugins] in godot.
        Afterwards press [update] near the pluginlist or close and restart godot.
        To access the main window click the new icon next to  [2D] [3D] [Script] [AssetLib].
        To add custom nodes, click add a child node and search for GTD.


## Help
For now just refer to the in editor help-button, you can also try hovering over stuff to check for help-tooltips.
I plan to do a decent documentary and a small guide at some later point.
## License

- MIT :
- Feel free to use this in whatever project you want, or salvage this code for your own doings, no need to give any credit.

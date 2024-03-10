# Fluxlib

## Docs
sortof

###  ID's MUST BE UNIQUE TO AN ITEM SO THEY DONT GET OVERRIDDEN BY OTHER ITEMS IN THE SAVE FILE
```lua
local FluxLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/Fluxlib/main/fluxlib.lua",true))()

-- Window
local Window = FluxLib:Window(
    {
        ['replaceOld'] = true, -- optional default: false  |  Replaces old Flux Window
        ['enableSaving'] = true, -- optional default: false  |  Allows for config saving
        ['Title'] = 'Test', -- required
        ['Description'] = 'Test desc', -- required
        ['mainclr'] = Color3.fromRGB(66, 134, 255), -- optional default: Color3.fromRGB(66, 134, 255)  |  Main color for the gui
        ['SaveFolder'] = '', -- optional default: '' aka no folder  |  Name for the folder where save file is located
        ['SaveFile'] = 'TestSave' -- required (ONLY IF "enableSaving" IS TRUE)  |  Name for the save file
    }
)

-- Toggle the window on and off
Window:ToggleUI()

-- Destroy window
Window:Remove()

-- Set the accent color
Window:ChangeColor(color<Color3>)

-- Notification
Flux:Notification('Description', 'ButtonText')

-- Tab
local tab = Window:Tab(Title<string>, icon<string?>)

-- Toggle
local Toggle = tab:Toggle(Id<string>, Title<string>, Description<string>, DefaultValue<bool>, Callback<function> => bool)

Toggle:Save()

Toggle:Set(<bool>)

-- Button
tab:Button(Title<string>, Description<string>, Callback<function>)

-- Slider
local Slider = tab:Slider(Id<string>, Title<string>,Description<string>, Minvalue<number>, MaxValue<number>, Default<number>, Callback<function> => number)

Slider:Save()

Slider:Set(<number>)

-- Dropdown
-- List should look like this: {'hello', 'test'}
local Dropdown = tab:Dropdown(Id<string>, Title<string>, Description<string>, List<table>, Callback<function> => string)

-- add string to dropdown list
Dropdown:Add(<string>)

Dropdown:Clear()
    
Dropdown:Save()

-- Multi-Select Dropdown
-- List should look like this: {'hello', 'test'}
local MultiDropdown = tab:MultiDropdown(Id<string>, Title<string>, Description<string>, List<table>, Callback<function> => table)

-- add table to dropdown list
Dropdown:Add(<table>)

Dropdown:Clear()
    
Dropdown:Save()

-- Colorpicker
local Colorpicker = tab:Colorpicker(Id<string>, Title<string>, Default<Color3>, Callback<function> => Color3)

Colorpicker:Set(Color<Color3>)

Colorpicker:Save()

-- Textbox
local Textbox = tab:Textbox(Id<string>, Title<string>, Description<string>, Disappear<bool>, Callback<function> => string)

Textbox:Save()

-- Bind
local Bind = tab:Bind(Id<string>, Title<string>, DefaultKey<KeyCode>, Callback<function>)

Bind:Save()

-- Line
tab:Line()

-- Label
local Label = tab:Label(Title<string>)

Label:Set(<string>)
```

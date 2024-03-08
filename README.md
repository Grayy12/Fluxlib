# Fluxhub

## Docs
sortof

###  ID's MUST BE UNIQUE TO AN ITEM
```lua
local FluxLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/Fluxhub/main/fluxlib.lua",true))()

-- Cleans up Fluxlib
FluxLib:Remove(<nil>)

-- Window
local Window = FluxLib:Window(Replace_Old_Gui<bool>, SaveFolder<string>, Title<string>, BottomText<string?>, MainColor<Color3?>)

-- Notification
Flux:Notification(Description<string>, ButtonText<string>)

-- Tab
local tab = Window:Tab(Title<string>, icon<string?>)

-- Toggle
local Toggle = tab:Toggle(Id<string>, Title<string>, Description<string>, DefaultValue<bool>, Callback<function> => number)

-- Saves to file
Toggle:Save(<nil>)

-- Sets the toggle to value
Toggle:Set(<bool>)

-- Button
tab:Button(Title<string>, Description<string>, Callback<function>)

-- Slider
local Slider = tab:Slider(Id<string>, Title<string>,Description<string>, Minvalue<number>, MaxValue<number>, Default<number>, Callback<function> => number)

-- Sets slider to value
Slider:Change(<number>)

Slider:Save(<nil>)

-- Dropdown
-- List should look like this: {'hello', 'test'}
local Dropdown = tab:Dropdown(Id<string>, Title<string>, Description<string>, List<table>, Callback<function> => string)

-- add string to dropdown list
Dropdown:Add(<string>)

Dropdown:Clear(<nil>)

Dropdown:Save(<nil>)
-- Multi-Select Dropdown
-- List should look like this: {'hello', 'test'}
local MultiDropdown = tab:MultiDropdown(Id<string>, Title<string>, Description<string>, List<table>, Callback<function> => table)

Dropdown:Add(<table>)

Dropdown:Clear(<nil>)

Dropdown:Save(<nil>)

-- Texbox
local Textbox = tab:Textbox(Id<string>, Title<string>, Description<string>, Disappear<bool>, Callback<function> => string)

Textbox:Save(<nil>)

-- Bind
local Bind = tab:Bind(Id<string>, Title<string>, DefaultKey<KeyCode>, Callback<function>)

Bind:Save(<nil>)

-- Line
tab:Line(<nil>)

-- Label
tab:Label(Title<string>)
```

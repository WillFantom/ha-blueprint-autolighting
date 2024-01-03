# Blueprint: Auto Lighting

A simple automated per-room lighting blueprint for Home Assistant.

[![Open your Home Assistant instance and show the blueprint import dialog with a specific blueprint pre-filled.](https://my.home-assistant.io/badges/blueprint_import.svg)](https://my.home-assistant.io/redirect/blueprint_import/?blueprint_url=https%3A%2F%2Fgithub.com%2FWillFantom%2Fha-blueprint-autolighting%2Fblob%2Fmain%2Fauto-light.yaml)


## Features

This blueprint will create looping automations that:

 - Set the light brightness of a room relative to the sun's elevation
 - Set the color temperature of a room's lights based on the sun's position
 - Reduce the brightness of all the lights in a room when it is not occupied
 - Limit the brightness of "main" lights relative to non-main lights such as lamps
 - Only modify the room lights if a given switch/toggle is set to on
 - Have an alternative max brightness whilst in "night mode"

The goal of this blueprint is not to be super configurable since it is unlikely
to be used by anybody but me, so the feature set is pretty much always
the same. That said, many of the options have customizable bounds to tweak
the impact of given features from room-to-room.

## Usage

The idea behind this is to have some form of 'default' loop for lighting control
outside any scenes. However, so scenes can still be easily used, the loop should
respect a given control toggle/switch that should be set to 'off' as part of any
scene for the room.

For example, this could run in a living room as the default lighting control
loop. However, the TV media player state changes to playing so another
automation runs the scene 'livingroom-media-lights'. This scene should turn off
the helper toggle 'livingroom-auto-lights-switch' so that the main control loop
will not impact the lights any further (until the toggle changes state to on).
To make turning the toggle back to on easier, a simple
'livingroom-default-lights' scene could be created that simply sets the
toggle/switch to on.

## Logic

Since there is some automation based on external inputs (e.g. sun elevation) the
logic for each calculation is as follows:

### Brightness

This is determined based on the sun elevation where:
  - `bmax`: is the user-configured maximum brightness percentage
  - `eon`: is the user-configured elevation at which the lights should be at
    their brightest (negative or 0 elevation)
  - `eoff`: is the user-configured elevation at which the lights should be off
    (positive elevation)
  - `erange`: is equal to `eoff - eon`
  - `ecurr`: is the current elevation at the time of the automation loop iteration


Base brightness percentage is used when the room is occupied (or regardless if
no motion sensor is given) and is calculated with:
<br>**```basebrightness = 1 - (((ecurr - eon) / erange)) * bmax ```**<br>
Where conditional logic limits the values to be between 0 and 100.

Since main lights can be given a scale factor to reduce their brightness
relative to lamps etc, the user-configured main light scale percentage
(`mlscale`) is multiplied against the base brightness before being applied to
lights that contain the substring _main_ in their entity id. Otherwise, the
`mlscale` given to a light is forced to be 1.

Finally, conditional logic checks for room occupancy. If unoccupied the
user-configured vacancy scale factor (`vscale`) is applied to base brightnesses
for main and non-main lights. If the room is occupied, the `vscale` is forced to
be 1.

Ultimately, the following is the light brightness logic:
<br>**```(1 - ((ecurr - eon) / erange)) * bmax * mlscale * vscale ```**<br>

### Color Temperature

Auto color temperature changes (circadian lighting) are largely based from the template that can be found [here on the exchange](https://community.home-assistant.io/t/automatic-circadian-lighting-match-your-lights-color-temperature-to-the-sun/472105). Only the lights that support the "color_temp" feature will be sent messages regarding color changes.

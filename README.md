# Custom Analog Watch Face — Forerunner 165 Music

A custom analog watch face built with Garmin's Connect IQ SDK for the **Forerunner 165 / 165 Music**, written in Monkey C.

![Platform](https://img.shields.io/badge/platform-Connect%20IQ-blue)
![Device](https://img.shields.io/badge/device-Forerunner%20165%20Music-teal)

## Features

- **Analog hour and minute hands** — smooth, angle-calculated positioning based on system time
- **Sweeping second hand** (red) active only while the display is awake to preserve battery
- **Hour and minute tick marks** — hour ticks slightly larger/bolder than minute ticks
- **Date display** in `DAY, MON DD` format (e.g. `MON, JUN 21`)
- **Battery indicator** — icon + percentage, drawn with native graphics primitives (no image assets)
- Solid background color, easily customizable via a single hex value

## Screenshots

<img width="561" height="840" alt="image" src="https://github.com/user-attachments/assets/79bb9da8-63e4-4048-81b2-9e48d07f6afd" />


## Requirements

- [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) `9.2.0` or later
- [Visual Studio Code](https://code.visualstudio.com/)
- The official **Monkey C** VS Code extension (published by Garmin)
- A Garmin Connect IQ developer account (free) — required to generate a signing key, even for sideloading to your own device
- A Forerunner 165 or 165 Music (or the Connect IQ Simulator for testing)

## Project Structure

```
custom-watchface/
├── manifest.xml
├── monkey.jungle
├── resources/
│   ├── drawables/       # background/icon image resources (if used)
│   ├── fonts/           # custom Montserrat .fnt/.png + fonts.xml
│   ├── layouts/
│   ├── settings/
│   └── strings/
└── source/
    ├── custom-watchfaceApp.mc
    ├── custom-watchfaceBackground.mc
    └── custom-watchfaceView.mc      # main drawing logic
```

## Setup

1. Install the Connect IQ SDK and the Monkey C VS Code extension.
2. Clone this repo:
   ```bash
   git clone https://github.com/caiovini980/garmin-custom-watchface.git
   ```
3. Open the project folder directly in VS Code (the folder containing `monkey.jungle` should be your workspace root).
4. Generate a developer signing key if you don't already have one:
   - Command Palette → **Monkey C: Generate Developer Key**
   - Set the key path in VS Code settings under `monkeyC.developerKeyPath`

## Running in the Simulator

1. Command Palette → **Monkey C: Run Current Project in Simulator**
2. Select **fr165m** (Forerunner 165 Music) as the target device

## Installing on a Physical Watch (Sideloading)

1. Command Palette → **Monkey C: Build for Device**
2. Connect the watch via USB-C (make sure it's unlocked/awake)
3. Copy the generated `.prg` file from the project's `bin/` folder into:
   ```
   GARMIN/APPS/
   ```
   on the watch's mounted drive
4. Safely eject the watch and disconnect
5. On the watch: hold the watch face, or go to **Settings → Watch Face**, and select the new face from the list

## Customization

- **Background color**: change the hex value in the `dc.setColor()` call at the top of `onUpdate()` in `custom-watchfaceView.mc`
- **Font**: swap in a different `.fnt`/`.png` pair generated via [BMFont](https://www.angelcode.com/products/bmfont/), registered in `resources/fonts/fonts.xml`
- **Date format**: adjust the `Lang.format()` string in `drawDate()`
- **Second hand shadow offset/color**: tweak the `offsetX`/`offsetY` and color values passed to `drawHandOffset()`

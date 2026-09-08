# Omarchy Terminal Screensaver

A simple terminal screensaver inspired by [Omarchy](https://omarchy.org/), powered by [Terminal Text Effects](https://github.com/ChrisBuilds/terminaltexteffects).

![Omarchy-style terminal screensaver](screensaver.gif)

## Features

- Random terminal animations
- Runs entirely in the terminal
- Press **any key** to exit
- No GUI or desktop environment required

## Requirements

- Bash
- Python & `pipx`
- [Terminal Text Effects](https://github.com/ChrisBuilds/terminaltexteffects)

## Installation

Install `pipx` and Python if you don't already have it.

Then install Terminal Text Effects:

```bash
pipx install terminaltexteffects
```

Make the screensaver executable:

```bash
chmod +x screensaver.sh
```

## Usage

Run: 

```bash
./screensaver.sh
```

Press **any key** to exit.

## Customizing

The screensaver reads its ASCII artwork from `ascii.txt` in the directory. 
Edit that file to change what is displayed.

> **Note:** I'm also planning to make an Omarchy's font ASCII generator!

## Credits

- Inspired by [Omarchy](https://omarchy.org/)
- Animations powered by [Terminal Text Effects](https://github.com/ChrisBuilds/terminaltexteffects)

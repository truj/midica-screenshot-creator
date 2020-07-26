# What

Shell script to auto-generate screenshots of the Midica application.

It's used to re-create screenshot images for the documentation website (midica.org).

Therefore it starts Midica several times with different soundfonts and import files
and emulates keyboard and mouse actions, while taking screenshots and storing them to
the right place.

# Why

It's a lot of work to recreate the screenshots manually after a change in the GUI.
Automization solves this problem.

# Requirements

- Unix-like OS
- Bash
- Java 1.7 or higher
- midica.jar
- xdotool
- scrot
- maim

# Getting started

- `git clone git@github.com:truj/midica-screenshot-creator.git`
- Download midica.jar from the [latest Midica release](https://github.com/truj/midica/releases/latest)
- Add some soundfonts to data/soundfonts
- Add some test files that can be loaded by musescore to data/mscore/demo
- Add some MidicaPL files to data/examples
- Add some MIDI files to data/demo
- Open `create_screenshots.sh` and adjust the configuration section
- Probably you need to adjust something more in the script as well
- Run `create_screenshots.sh`

# Limits

- Tested only on my personal computer. Maybe it even works only there.
- This repository provides only the script but no example files to be imported/exported and also no soundfont files. This is mainly due to copyright issues but it's also because of lazyness.
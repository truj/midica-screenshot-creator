#!/bin/bash

# This Source Code Form is subject to the terms of the
# Mozilla Public License, v. 2.0. 
# If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.

#################
# CONFIGURATION
#################

MIDICA_JAR=~/github/midica/midica.jar                        # path to midica.jar
REPO_DIR=~/github/midica-screenshot-creator                  # path to this repository
SCR_DIR=~/github/midica.org/src/assets/img                   # target path for most screenshots
TUT_DIR=~/github/midica.org/src/assets/examples              # target path for screenshots for the tutorial
SF2_DIR=$REPO_DIR/data/soundfonts                            # soundfont directory
MPL_DIR=$REPO_DIR/data/examples                              # directory with MidicaPL examples
MIDI_DIR=$REPO_DIR/data/demo                                 # directory with MIDI file examples
ALDA_DIR=$REPO_DIR/data/demo                                 # directory with ALDA file examples
ABC_DIR=$REPO_DIR/data/demo                                  # directory with ABC file examples
LY_DIR=$REPO_DIR/data/demo                                   # directory with LilyPond examples
MSCORE_DIR=$REPO_DIR/data/mscore/demo                        # directory with examples that can be imported by MuseScore
DECOMPILE_DIR=$REPO_DIR/data/decompile                       # directory for exporting temporary decompiled files
TUT_FILES_DIR=$REPO_DIR/data/tutorial                        # directory with files needed for tutorial-related screenshots
SF2_PATH_DEFAULT="$SF2_DIR/FluidR3_GM.sf2"                   # path to the default soundfont
SF2_PATH_GU="$SF2_DIR/GeneralUser GS FluidSynth v1.44.sf2"   # path to a soundfont that can demonstrate multi-channel drumkits


##############
# FUNCTIONS
##############

# Kills a previously started Midica instance, if one exists.
# Starts a new instance.
# 
# Parameters:
# - soundfont parameter to midica, including the parameter name (--soundfont=PATH)
# - import file parameter to midica, including the parameter name (--import=PATH or --import-midi=PATH)
function start_midica {
	if [[ "$MIDICA_PID" != "" ]]; then
		kill -9 $MIDICA_PID
	fi
	SOUNDFONT=$1
	IMPORT=$2
	java -jar "$MIDICA_JAR" --ignore-local-config "$SOUNDFONT" "$IMPORT" & MIDICA_PID=$!
	sleep 6
}

# Creates a screenshot of the currently active window
# and saves it in the target directory for screenshots
# 
# parameter:
# - target filename (without '.png' extension)
function screenshot_active_window {
	FILE=$1
	scrot --overwrite --focused --border "$SCR_DIR/$FILE.png"
}

# Creates a screenshot of a screen region
# and saves it in the target directory for screenshots
# 
# parameters:
# - target filename (without '.png' extension)
# - x value of the upper left corner of the region
# - y value of the upper left corner of the region
# - width of the region in pixels
# - height of the region in pixels
function screenshot_region {
	FILE=$1
	X=$2
	Y=$3
	WIDTH=$4
	HEIGHT=$5
	maim --format=png --hidecursor -g ${WIDTH}x${HEIGHT}+$X+$Y > "$SCR_DIR/$FILE.png"
}

# Creates a screenshot of a screen region
# and saves it in the target directory for the tutorial's screenshots
# 
# parameters:
# - target filename (without '.png' extension)
# - x value of the upper left corner of the region
# - y value of the upper left corner of the region
# - width of the region in pixels
# - height of the region in pixels
function screenshot_region_tutorial {
	FILE=$1
	X=$2
	Y=$3
	WIDTH=$4
	HEIGHT=$5
	maim --format=png --hidecursor -g ${WIDTH}x${HEIGHT}+$X+$Y > "$TUT_DIR/$FILE.png"
}

# Opens a file chooser for an import or soundfont file (if not yet done),
# switches to the given tab,
# opens the given directory,
# and selects the given file.
# 
# Assumes that the file chooser is already open, if the tab number is 0 or 1.
# 
# parameters:
# - import|soundfont
# - tab number
# - file index
# - directory
function open_file_chooser {
	OPEN=$1
	TAB=$2
	DOWN=$3
	DIR=$4
	if [ "import" = "$OPEN" ]; then
		OPEN="ctrl+o"
	elif [ "soundfont" = "$OPEN" ]; then
		OPEN="ctrl+shift+s"
	fi
	if [[ $TAB < 2 ]]; then
		xdotool key "$OPEN"  # open import file chooser
		sleep 0.1
	fi
	xdotool key "ctrl+$TAB"
	xdotool key "alt+n"
	xdotool key "ctrl+a"
	xdotool type "$DIR"
	xdotool key "Return"
	xdotool key "alt+i"
	xdotool key "Down"
	xdotool key "Return"
	xdotool key "alt+n"
	xdotool key "shift+Tab"
	xdotool key "Down"
	xdotool key "Up"
	for ((i=0; i<$DOWN; i++)); do
		xdotool key "Down"
	done
	sleep 0.2
}

# Opens the export file chooser (if not yet done),
# switches to the given tab,
# opens the given directory,
# and selects the given file.
# 
# Assumes that the file chooser is already open, if the tab number is not 1.
# 
# parameters:
# - tab number
# - directory
# - file name
function open_export_file_chooser {
	TAB=$1
	DIR=$2
	FILE=$3
	if [ "$TAB" = "1" ]; then
		OPEN="ctrl+s"
		xdotool key "$OPEN"
		sleep 0.4
	fi
	xdotool key "ctrl+$TAB"
	xdotool key "alt+n"
	xdotool key "ctrl+a"
	xdotool type "$DIR"
	xdotool key "Return"
	xdotool key "alt+n"
	xdotool key "ctrl+a"
	xdotool type "$FILE"
	sleep 0.1
}

# Goes to the given tick in the player.
# Assumes that the player window is open and currently active.
function go_to_tick {
	TICK=$1
	xdotool key "f"           # focus the text field to enter the tick number
	xdotool type "$TICK"      # enter the tick number
	xdotool key "Return"
	xdotool key "ctrl+a"      # select the tick number
	xdotool key "Delete"      # delete the tick number
	xdotool key "Return"      # remove red color in the text field
	sleep 0.1
	xdotool key "shift+Tab"   # move the focus away
	xdotool key "shift+Tab"
}

# Resizes a window to the given width and height.
# 
# parameters:
# - a part of the window name (window title) to find the window
# - width
# - height
function resize {
	NAME=$1
	WIDTH=$2
	HEIGHT=$3
	WIN_ID=`xdotool search --onlyvisible --name "$NAME"`  # find the window ID
	xdotool windowsize $WIN_ID $WIDTH $HEIGHT             # resize the window
	sleep 0.5
}

##############
# MAIN WINDOW
##############

cd "$REPO_DIR"

MIDICA_PID=""

# start Midica (main window)
start_midica "--soundfont=$SF2_PATH_DEFAULT" "--import=$MPL_DIR/london_bridge.midica"

xdotool mousemove 382 236 click 1  # click remember soundfont
screenshot_active_window main

# config section
xdotool key "alt+l"   # open combobox: language
sleep 0.1
screenshot_region config_1_language 129 60 220 67
xdotool key "alt+n"   # open combobox: note system
sleep 0.1
screenshot_region config_2_notes 129 90 220 142
xdotool key "alt+h"   # open combobox: half tone symbol
sleep 0.1
screenshot_region config_3_halftone 129 120 220 84
xdotool key "alt+d"   # open combobox: default half tone
sleep 0.1
screenshot_region config_4_ht_default 129 149 220 65
xdotool key "alt+o"   # open combobox: octave naming
sleep 0.1
screenshot_region config_5_octave 129 178 220 103
xdotool key "alt+s"   # open combobox: syntax
sleep 0.1
screenshot_region config_6_syntax 129 207 220 84
xdotool key "alt+p"   # open combobox: percussion IDs
sleep 0.1
screenshot_region config_7_percussion 129 236 220 66
xdotool key "alt+i"   # open combobox: instrument IDs
sleep 0.1
screenshot_region config_8_instrument 129 264 220 67
xdotool key "Escape"  # close open combobox
sleep 0.1

screenshot_region import_0 364 43 193 141      # import area
screenshot_region soundfont_0 364 195 193 100  # soundfont area
screenshot_region export_0 364 307 193 78      # export area
screenshot_region player_0 12 331 346 55       # player area

##############
# PLAYER: ICONS - SUCCESS / FAILED
##############

xdotool key "p"                                        # open player
sleep 7
screenshot_region player_8_parse_success 327 37 36 36  # success icon
echo test >> $MPL_DIR/london_bridge.midica             # add extra line to make the file fail
xdotool key "F5"                                       # reload
sleep 3
xdotool key "Escape"                                   # close error message
sleep 0.3
screenshot_region player_9_parse_failure 327 37 36 36  # failed icon
sed -i '$ d' $MPL_DIR/london_bridge.midica             # remove the extra line
xdotool key "F5"                                       # reload
sleep 3
xdotool key "alt+F4"                                   # close player
sleep 0.3

##############
# FILE CHOOSERS
##############

# import file chooser
open_file_chooser import 1 0 $MPL_DIR     # MidicaPL import
screenshot_active_window import_1_midica
open_file_chooser import 2 0 $MIDI_DIR    # MIDI import
screenshot_active_window import_2_midi
open_file_chooser import 3 3 $ALDA_DIR    # ALDA import
screenshot_active_window import_3_alda
open_file_chooser import 4 1 $ABC_DIR     # ABC import
screenshot_active_window import_4_abc
open_file_chooser import 5 2 $LY_DIR      # LilyPond import
screenshot_active_window import_5_ly
open_file_chooser import 6 1 $MSCORE_DIR  # MuseScore import
screenshot_active_window import_6_mscore
xdotool key "Escape"                      # close file chooser
sleep 0.1

# soundfont file chooser
open_file_chooser soundfont 0 0 $SF2_DIR
screenshot_active_window soundfont_1
xdotool key "Escape"
sleep 0.3

# export file chooser
open_export_file_chooser 1 $MIDI_DIR my-own-song.mid                           # MIDI export
screenshot_active_window export_1_midi
open_export_file_chooser 2 $MPL_DIR a-midi-song-i-found-on-the-internet.mpl    # MidicaPL export
screenshot_active_window export_2_midica
open_export_file_chooser 3 $ALDA_DIR a-midi-song-i-found-on-the-internet.alda  # ALDA export
screenshot_active_window export_3_alda

##############
# DECOMPILE CONFIG
##############

# decompile config button (default and mouseover)
screenshot_region dc_button           168 336 36 37
xdotool mousemove 180 350      # hover the button
sleep 0.1
screenshot_region dc_button_mouse 168 336 36 37
xdotool mousemove 5 5          # un-hover the button

# decompile config window
xdotool key "alt+d"
sleep 0.5
screenshot_active_window dc_1_debugging
xdotool key "2"
sleep 0.1
screenshot_active_window dc_2_note_length
xdotool key "3"
sleep 0.1
screenshot_active_window dc_3_chords
xdotool key "4"
sleep 0.1
screenshot_active_window dc_4_notes_rests
xdotool key "5"
sleep 0.1
screenshot_active_window dc_5_karaoke
xdotool key "6"
sleep 0.1
screenshot_active_window dc_6_control_change
xdotool key "7"
sleep 0.1
screenshot_active_window dc_7_extra_slices

# decompile config button (default and invalid)
xdotool key "ctrl+e"    # go to the text area (edit directly)
xdotool key "x"         # invalid character
xdotool key "Escape"    # close decompile confifg window
sleep 0.1
screenshot_region dc_button_invalid 168 336 36 37
xdotool mousemove 180 350      # hover the button
sleep 0.1
screenshot_region dc_button_invalid_mouse 168 336 36 37

##############
# PLAYER
##############
start_midica "--soundfont=$SF2_PATH_GU" "--import-midi=$MIDI_DIR/achy_breaky_heart.kar"

# open player
xdotool key "p"
sleep 7
go_to_tick "8902"
sleep 0.2

# player screenshots
screenshot_active_window player_1
screenshot_region player_2_jump 13 42 204 28         # memorize button, textfield, go button
screenshot_region player_3_time 589 41 130 28        # time/ticks (upper right corner)
screenshot_region player_4_progress 10 73 705 50     # progress bar
screenshot_region player_5_control 10 122 520 30     # control buttons (stop, <<, <, play, >, >>)
screenshot_region player_6_sliders 529 120 182 436   # sliders for volume, tempo and transposition
screenshot_region player_7_reparse 533 556 76 29     # reparse button

# channel overview
xdotool key "alt+0"                                  # mute channel 0
xdotool key "alt+4"                                  # mute channel 4
screenshot_region channel_1_overview 16 162 367 448  # channel overview (all channels still closed)
xdotool key "1"                                      # open details of channel 1
sleep 0.2
screenshot_region channel_2_details 16 207 451 351   # channel details (opened)
xdotool key "1"

# karaoke mode
go_to_tick "20217"
xdotool key "l"     # switch to karaoke mode
sleep 0.5
screenshot_active_window karaoke

###############
# SOUNDCHECK
###############
xdotool key "s"       # open soundcheck window
sleep 1
xdotool key "ctrl+i"  # focus instruments table
sleep 0.2
xdotool key "Down"
xdotool key "Down"
xdotool key "Down"
xdotool key "Down"    # focus room drums
sleep 0.2
xdotool key "ctrl+n"  # focus note/percussion table
sleep 0.2
xdotool key "Up"
sleep 0.1
xdotool key "Down"
xdotool key "shift+v"  # focus volume slider
sleep 1
screenshot_active_window soundcheck_1

# drumkits
xdotool key "9"                                      # select channel 9 (percussion)
resize "Midica Soundcheck" 593 1400                  # make the window higher
xdotool key "ctrl+i"                                 # focus instruments/drumkits table
xdotool key "Down"
xdotool key "Down"
xdotool key "Down"
xdotool key "Down"                                   # select room drumkit
sleep 1
screenshot_region soundcheck_2_drum 93 39 492 425    # drumkits table

# chromatic instruments
xdotool key "2"                                      # select channel 2 (chromatic)
sleep 0.2
xdotool key "ctrl+i"                                 # focus instruments table
sleep 0.1
for ((i=0; i<33; i++)); do
	xdotool key "Down"
done
sleep 0.5
for ((i=0; i<13; i++)); do
	xdotool key "Up"                             # select electric grand piano
done
xdotool key "ctrl+n"                                 # focus notes table
sleep 0.1
for ((i=0; i<10; i++)); do
	xdotool key "Down"
done
sleep 0.5
for ((i=0; i<10; i++)); do
	xdotool key "Up"
done
sleep 2
xdotool key "ctrl+shift+v"                           # focus velocity slider
sleep 2
screenshot_region soundcheck_3_chromatic 93 39 492 775  # combobox, instruments table and notes table

# percussion
xdotool key "9"                  # select channel 9 (percussion)
sleep 0.2
xdotool key "ctrl+n"             # focus note/percussion table
for ((i=0; i<11; i++)); do
	xdotool key "Up"
done
sleep 2
for ((i=0; i<11; i++)); do
	xdotool key "Down"
done
sleep 2
screenshot_region soundcheck_4_percussion 93 465 492 345  # percussion instruments table

# close soundcheck window
xdotool key "Escape"
sleep 0.3

###############
# INFO
###############

# open info window
xdotool key "i"
sleep 1

# config
screenshot_active_window info_conf_note
xdotool key "p"
sleep 0.1
screenshot_active_window info_conf_percussion
xdotool key "d"
sleep 0.1
screenshot_active_window info_conf_drumkit
xdotool key "s"
resize "Midica Info" 973 770               # make the window higher
sleep 0.1
screenshot_active_window info_conf_syntax
xdotool key "i"
sleep 0.1
screenshot_active_window info_conf_instr
xdotool key "Escape"                       # close info window
sleep 0.5

# soundfont
xdotool key "i"                            # open info window
sleep 0.5
xdotool key "Down"                         # select soundfont tab
sleep 0.2
screenshot_active_window info_soundfont_general
xdotool key "r"                            # select resources tab
sleep 0.1
screenshot_active_window info_soundfont_sample
xdotool key "Tab"
xdotool key "Tab"
xdotool key "Tab"                          # focus table
sleep 0.1
xdotool key "ctrl+End"                     # go to table bottom
for ((i=0; i<14; i++)); do
	xdotool key "Page_Up"              # go up (until some lines above the layers headline)
done
sleep 1
for ((i=0; i<4; i++)); do
	xdotool mousemove 382 236 click 5  # scroll down (so that the layers headline is in the second visible line)
done
sleep 0.3
screenshot_active_window info_soundfont_layer
xdotool key "i"                            # select tab "Instruments & Drum Kits"
sleep 0.1
resize "Midica Info" 973 1200              # make the window higher
screenshot_active_window info_soundfont_instr

# midi info
start_midica "--soundfont=$SF2_PATH_DEFAULT" "--import=$MPL_DIR/sk_london_bridge.midica"
xdotool key "i"                            # open info window
sleep 1
xdotool key "m"                            # select tab: MIDI
sleep 0.1
screenshot_active_window info_midi_general
xdotool key "k"                            # select sub tab: Karaoke
sleep 0.1
screenshot_active_window info_midi_karaoke
start_midica "--soundfont=$SF2_PATH_DEFAULT" "--import-midi=$MIDI_DIR/achy_breaky_heart.kar"
xdotool key "i"                            # open info window
sleep 1
xdotool key "m"                            # select tab: MIDI
xdotool key "b"                            # select sub tab: banks/instruments/notes
resize "Midica Info" 973 800               # make the window higher
sleep 0.3
screenshot_active_window info_midi_banks_1
xdotool mousemove 818 82 click 1           # click per-channel +
xdotool mousemove 365 82 click 1           # click total +
xdotool key "shift+Tab"
xdotool key "shift+Tab"
xdotool key "shift+Tab"                    # focus main tab (MIDI sequence)
sleep 0.5
screenshot_active_window info_midi_banks_2
xdotool key "m"                            # select sub tab: messages
sleep 0.5
screenshot_active_window info_midi_messages_1
xdotool mousemove 588 260 mousedown 1 mousemove_relative --sync 0 340 mouseup 1  # drag divider down
xdotool mousemove 396 82 click 1                                                 # click +
sleep 0.1
xdotool key "alt+t"                        # focus tree
xdotool key "ctrl+End"                     # go to end of tree (last tree node)
for ((i=0; i<7; i++)); do
	xdotool key "Up"                   # select node: track name
done
sleep 0.5
screenshot_active_window info_midi_messages_2
xdotool key "ctrl+Home"                    # go to beginning of tree (first tree node)
for ((i=0; i<3; i++)); do
	xdotool key "Down"                 # select node: Note-ON
done
xdotool mousemove 588 600 mousedown 1 mousemove_relative --sync 0 -280 mouseup 1  # drag divider up
xdotool key "ctrl+t"                                                              # focus the table
for ((i=0; i<8; i++)); do
	xdotool key "Page_Down"            # go some pages down in the message table
done
sleep 1
xdotool key "Page_Up"
for ((i=0; i<13; i++)); do
	xdotool key "Up"                   # go some lines up in the messages table
done
sleep 1
xdotool key "Down"
xdotool key "Down"
xdotool key "Down"                         # focus Note-ON (bass_drum_1, tick 400, channel 9)
sleep 0.2
screenshot_active_window info_midi_messages_3
xdotool key "Escape"                       # close info window
sleep 0.5

# key bindings
xdotool key "i"       # open info window
sleep 1
xdotool key "Down"
xdotool key "Down"
xdotool key "Down"    # select tab: key bindings
sleep 0.2
xdotool key  "f"      # focus the filter field
xdotool type "Ctrl"   # write into the filter field
xdotool key  "Tab"    # focus the tree
xdotool key  "Down"
xdotool key  "Down"
xdotool key  "Down"
xdotool key  "Down"   # focus soundcheck node
xdotool key  "Right"  # open soundcheck node
xdotool key  "Up"
xdotool key  "Up"     # focus main node
xdotool key  "Right"  # open main node
xdotool key  "Down"
xdotool key  "Down"
xdotool key  "Down"   # focus node: "Load soundfont file"
sleep 0.2
screenshot_active_window info_keybinding_1
xdotool key  "f"          # focus the filter field
xdotool key  "ctrl+a"     # mark all text
xdotool key  "Delete"     # delete the text
xdotool key  "shift+Tab"  # leave the text field
xdotool key  "t"          # focus the tree
xdotool key  "Up"
xdotool key  "Up"
xdotool key  "Up"         # focus soundcheck node
xdotool key  "Left"       # close soundcheck node
xdotool key  "ctrl+Home"  # go to top node
xdotool key  "Down"       # focus main node
xdotool key  "Left"       # close main node
xdotool key  "Down"
xdotool key  "Down"
xdotool key  "Down"
xdotool key  "Down"       # focus message window node
xdotool key  "Right"      # open message window node
xdotool key  "Down"       # focus "close the message window"
xdotool key  "ctrl+k"     # focus text field: "add key binding"
xdotool key  "ctrl+alt+shift+space"  # simulate new key binding
sleep 0.2
screenshot_active_window info_keybinding_2

# about
xdotool key "Tab"  # leave field: "add key binding"
xdotool key "a"    # select "about" tab
sleep 0.2
screenshot_active_window info_about

###############
# TABLE FILTER
###############

xdotool key "shift+Tab"                                        # focus the tabs
xdotool key "c"                                                # focus the configuration tab
sleep 0.1
screenshot_region table_filter_btn 564 66 28 28                # filter button (default)
xdotool mousemove 575 77                                       # hover the button
sleep 0.1
screenshot_region table_filter_btn_mouse 564 66 28 28          # filter button (default + mouseover)
xdotool mousemove 5 5                                          # un-hover the button
xdotool key "f"                                                # open the table filter
sleep 0.1
xdotool type "a#"                                              # type a string into the filter field
sleep 0.1
screenshot_active_window table_filter
xdotool key "Escape"                                           # close the table filter
sleep 0.1
screenshot_region table_filter_btn_changed 564 66 28 28        # filter button (changed)
xdotool mousemove 575 77                                       # hover the button
sleep 0.1
screenshot_region table_filter_btn_changed_mouse 564 66 28 28  # filter button (changed + mouseover)

###############
# DECOMPILE RESULT
###############

rm $DECOMPILE_DIR/tmpfile.mpl                            # delete the exported file, if not yet done
xdotool key "Escape"                                     # close info window
sleep 0.5
open_export_file_chooser 1 . x                           # open exporter
open_export_file_chooser 2 $DECOMPILE_DIR tmpfile.mpl    # switch to the MidicaPL tab
sleep 0.1
xdotool key "Return"                                     # export the file
sleep 1.0
xdotool mousemove 566 207 click 1                        # focus the first table row
for ((i=0; i<16; i++)); do
	xdotool key "Page_Down"                          # go down a few pages
done
for ((i=0; i<10; i++)); do
	xdotool key "Down"                               # go down a few lines
done
sleep 0.1
xdotool key "Page_Up"                                    # go up one page
sleep 0.1
for ((i=0; i<5; i++)); do
	xdotool key "Down"                               # go down a few lines
done
sleep 0.5
screenshot_active_window dc_result
rm $DECOMPILE_DIR/tmpfile.mpl                            # delete the exported file

###############
# TUTORIAL
###############

start_midica "--soundfont=$SF2_PATH_GU" "--import=$TUT_FILES_DIR/happy_birthday_instruments.midica"
xdotool key "p"                                        # open player
sleep 7
screenshot_region_tutorial instruments-2 17 162 395 449
go_to_tick 7000
sleep 0.2
screenshot_region_tutorial instruments-3 17 162 395 449
go_to_tick 7400
sleep 0.2
screenshot_region_tutorial instrument    17 162 395 89
go_to_tick 2900
xdotool key "l"                                        # switch to karaoke mode
sleep 0.2
screenshot_region_tutorial happy-birthday-3 9 37 275 255

###############
# FINALIZE
###############

if [[ "$MIDICA_PID" != "" ]]; then
	kill -9 $MIDICA_PID
fi

echo FINISHED

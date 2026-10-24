## All text the player sees, kept in one place so it can be translated later.
class_name Strings

const GAME_TITLE := "ESCAPE BOOM"
const PLAY := "Play"
const QUIT := "Quit"
const PAUSED := "Paused"
const RESUME := "Resume"
const RESTART_ROUND := "Restart round"
const MENU := "Menu"
const PLAY_AGAIN := "Play again"

const WIN_TITLE := "ESCAPED!"
const SECRET_CODE := "Secret code"
## Time used, for example "Time 5:42".
const TIME_USED_FORMAT := "Time %s"
const LOSE_TITLE := "BOOM"
const REASON_TIMEOUT := "Out of time"
const REASON_DEATH := "You died"

const MAP_NAMES := {
	&"boss": "Boss Chamber",
	&"maze": "Labyrinth",
	&"arena": "Enemy Arena",
}

const INFINITE_AMMO := "∞"
## Magazine count and reserve, for example "8 / ∞".
const AMMO_FORMAT := "%d / %s"
const RELOADING := "Reloading"
## Shown above chests and guns on the floor.
const INTERACT_PROMPT := "E"

## Enemy Arena: shown while the code chest is chained, for example "Chest locked: wave 3/7".
const CHEST_LOCKED_FORMAT := "Chest locked: wave %d/%d"
const CHEST_OPEN := "Chest open!"

## The map key (Tab) in the labyrinth.
const NO_MAP := "No map in the labyrinth"

## Above the boss's health bar.
const BOSS_NAME := "Root"

## Shown while an Officer Kin has the player handcuffed, with the presses still needed: "Mash E! 7".
const MASH_E_FORMAT := "Mash E! %d"

## The password menu on the TV.
const ACCESS_PROMPT := "ENTER ACCESS CODE"
const TRY_CODE := "TRY CODE"
const ACCESS_HINT := "TYPE THE CODE · ENTER TO TRY"
const ACCESS_GRANTED := "ACCESS GRANTED"

## F3 overlay: FPS, map, seconds left, player position, enemy count, arena wave ("-" elsewhere).
const DEBUG_FORMAT := "FPS %d\nMap %s\nTime left %.1f s\nPlayer %d, %d\nEnemies %d\nWave %s"
const NO_WAVE := "-"

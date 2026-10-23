## Autoload: game-wide signals, so objects deep in a map can tell the round what happened.
extends Node

## The secret code was picked up: the round is won.
signal code_collected
## An enemy died.
signal enemy_died(enemy: Node2D)
## A new wave started in the Enemy Arena (wave 1 is the first). The HUD and the code chest listen.
signal wave_started(wave: int)

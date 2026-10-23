## Autoload: game-wide signals, so objects deep in a map can tell the round what happened.
extends Node

## The secret code was picked up: the round is won.
signal code_collected
## The hourglass was picked up: the round adds time to the timer.
signal hourglass_collected
## An enemy died.
signal enemy_died(enemy: Node2D)
## The boss's hit points changed: `share` is what is left, from 1 to 0. The HUD's bar listens.
signal boss_health_changed(share: float)
## A new wave started in the Enemy Arena (wave 1 is the first). The HUD and the code chest listen.
signal wave_started(wave: int)

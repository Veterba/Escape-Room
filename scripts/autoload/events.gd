## Autoload: game-wide signals, so objects deep in a map can tell the round what happened.
extends Node

## The secret code was picked up: the round is won.
signal code_collected
## An enemy died (used by the debug overlay and, later, by arena waves).
signal enemy_died(enemy: Node2D)

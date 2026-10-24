## Autoload: loads the balance and lighting configs once so any script can read Config.balance
## and Config.lighting.
extends Node

var balance: BalanceConfig = preload("res://config/balance.tres")
var lighting: LightingConfig = preload("res://config/lighting.tres")

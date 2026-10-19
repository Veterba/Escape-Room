## Autoload: loads the balance config once so any script can read Config.balance.
extends Node

var balance: BalanceConfig = preload("res://config/balance.tres")

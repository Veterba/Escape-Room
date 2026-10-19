## Plays a particle burst once and removes it when it is done.
extends CPUParticles2D


func _ready() -> void:
	emitting = true
	finished.connect(queue_free)

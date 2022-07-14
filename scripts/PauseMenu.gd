extends ColorRect


onready var music_slider = $CenterContainer/VBoxContainer/MusicSlider
onready var sfx_slider = $CenterContainer/VBoxContainer/SFXSlider


const BUS_LAYOUT : String = "res://default_bus_layout.tres"
const MUSIC_VOLUME_DEFAULT_VALUE : int = 0
const SFX_VOLUME_DEFAULT_VALUE : int = 0
const MASTER_IDX : int = 0
const MUSIC_IDX : int = 4
const SFX_IDX : int = 5


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_IDX, value)


func _on_SFXSlider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_IDX, value)


func _on_MasterSlider_value_changed(value):
	AudioServer.set_bus_volume_db(MASTER_IDX, value)


func _on_CloseButton_pressed():
	visible = false

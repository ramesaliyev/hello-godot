tool
extends Sprite

func _ready():
	update_sprite_scale()

func _on_water_item_rect_changed():
	update_sprite_scale()
	
func update_sprite_scale():
	material.set_shader_param("sprite_scale", scale);

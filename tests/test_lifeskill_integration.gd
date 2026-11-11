extends SceneTree

# test_lifeskill_integration.gd - Bridge to TestLifeSkillScene.tscn
func _init() -> void:
	change_scene_to_file("res://tests/TestLifeSkillScene.tscn")

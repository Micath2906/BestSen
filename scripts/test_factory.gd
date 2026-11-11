@tool
extends SceneTree

const CatAnimationFactory = preload("res://scripts/CatAnimationFactory.gd")

func _init() -> void:
	print("\n--- TESTING CatAnimationFactory ---")
	for i in range(8):
		var sf = CatAnimationFactory.get_sprite_frames(i)
		assert(sf != null, "sf is null")
		assert(sf.has_animation("idle"), "missing idle")
		assert(sf.has_animation("idle2"), "missing idle2")
		assert(sf.has_animation("run"), "missing run")
		assert(sf.has_animation("sit"), "missing sit")
		assert(sf.has_animation("sleep"), "missing sleep")
		assert(sf.has_animation("jump"), "missing jump")
		assert(sf.has_animation("hurt"), "missing hurt")
		print("Breed %d: idle=%d, idle2=%d, run=%d, sleep=%d PASS!" % [
			i,
			sf.get_frame_count("idle"),
			sf.get_frame_count("idle2"),
			sf.get_frame_count("run"),
			sf.get_frame_count("sleep")
		])
	quit()

extends Node

# SoundManager.gd - Singleton AutoLoad
# Quản lý toàn bộ hệ thống âm thanh cho Best Sen
# Tích hợp bộ âm thanh Cute Cat UI Audio Pack (Cute_Cat_UI_Sounds_Demo_Reel.mp3 & các clip âm thanh chuẩn)
# Hỗ trợ đa kênh âm thanh (Polyphonic Channels) & Fallback procedural tone

const SOUND_PATHS = {
	"click": "res://assets/sounds/clips/clip_01.wav",
	"card_pop": "res://assets/sounds/clips/clip_03.wav",
	"cancel": "res://assets/sounds/clips/clip_05.wav",
	"chomp": "res://assets/sounds/clips/clip_07.wav",
	"meow_general": "res://assets/sounds/clips/clip_08.wav",
	"bounce": "res://assets/sounds/clips/clip_12.wav",
	"meow_cheerful": "res://assets/sounds/clips/clip_19.wav",
	"fail_short": "res://assets/sounds/clips/clip_22.wav",
	"meow_curious": "res://assets/sounds/clips/clip_29.wav",
	"talking": "res://assets/sounds/clips/clip_30.wav",
	"meow_sweet": "res://assets/sounds/clips/clip_31.wav",
	"fail_ngoao": "res://assets/sounds/clips/clip_35.wav",
	"meow_bold": "res://assets/sounds/clips/clip_37.wav",
	"giggle": "res://assets/sounds/clips/clip_38.wav",
	"success_chime": "res://assets/sounds/clips/clip_43.wav",
	"purr": "res://assets/sounds/clips/clip_44.wav",
	"success_fanfare": "res://assets/sounds/clips/clip_45.wav",
	# Cozy Audio Suite
	"cozy_click": "res://assets/sounds/cozy/Button_Pressed.wav",
	"confirm": "res://assets/sounds/cozy/Confirm.wav",
	"cancel_cozy": "res://assets/sounds/cozy/Cancel.wav",
	"currency": "res://assets/sounds/cozy/Currency.wav",
	"dialogue_blip": "res://assets/sounds/cozy/Dialogue_Blip.wav",
	"purchase": "res://assets/sounds/cozy/Purchase.wav",
	"unlock": "res://assets/sounds/cozy/Unlock.wav",
	"menu_open": "res://assets/sounds/cozy/Menu_Open.wav",
	"menu_close": "res://assets/sounds/cozy/Menu_Close.wav",
}

const REEL_PATH = "res://assets/sounds/Cute_Cat_UI_Sounds_Demo_Reel.mp3"

# Demo Reel Cue Timestamps (giây bắt đầu, thời lượng)
const REEL_CUES = {
	"click": Vector2(0.0, 0.20),
	"card_pop": Vector2(2.32, 0.18),
	"meow_general": Vector2(7.00, 0.72),
	"meow_cheerful": Vector2(22.66, 0.56),
	"fail_short": Vector2(27.44, 0.76),
	"meow_curious": Vector2(38.26, 0.36),
	"talking": Vector2(39.40, 0.66),
	"meow_sweet": Vector2(40.84, 0.74),
	"fail_ngoao": Vector2(47.98, 1.68),
	"purr": Vector2(62.82, 2.28),
	"success": Vector2(65.92, 1.52),
}

var sound_cache: Dictionary = {}
var reel_stream: AudioStream = null

# Dedicated audio player channels
var cat_channel: AudioStreamPlayer
var ui_channel: AudioStreamPlayer
var sfx_channel: AudioStreamPlayer
var reel_channel: AudioStreamPlayer
var bgm_channel: AudioStreamPlayer
var tone_players: Array = []
var tone_player_idx: int = 0
var last_click_time_msec: int = 0

# Cài đặt âm thanh (Volume Settings)
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var bgm_volume: float = 0.8
var haptic_enabled: bool = true

func _ready() -> void:
	# Khởi tạo các kênh âm thanh chuyên biệt để không bị ngắt tiếng lẫn nhau
	cat_channel = AudioStreamPlayer.new()
	cat_channel.name = "CatVoiceChannel"
	add_child(cat_channel)
	
	ui_channel = AudioStreamPlayer.new()
	ui_channel.name = "UIChannel"
	add_child(ui_channel)
	
	sfx_channel = AudioStreamPlayer.new()
	sfx_channel.name = "SFXChannel"
	add_child(sfx_channel)
	
	reel_channel = AudioStreamPlayer.new()
	reel_channel.name = "ReelChannel"
	add_child(reel_channel)
	
	bgm_channel = AudioStreamPlayer.new()
	bgm_channel.name = "BGMChannel"
	add_child(bgm_channel)
	
	# Pre-allocate pool cho procedural fallback tones để tránh cấp phát động gây leak RID
	for i in range(3):
		var tp = AudioStreamPlayer.new()
		tp.name = "TonePlayer_%d" % i
		add_child(tp)
		tone_players.append(tp)
	
	_load_sound_assets()

func _load_sound_assets() -> void:
	# 1. Load các file clip WAV đã cắt lọc chuẩn
	for key in SOUND_PATHS:
		var path = SOUND_PATHS[key]
		if ResourceLoader.exists(path):
			var stream = load(path)
			if stream:
				sound_cache[key] = stream
				
	# 2. Load file demo reel MP3 chính
	if ResourceLoader.exists(REEL_PATH):
		reel_stream = load(REEL_PATH)
	elif FileAccess.file_exists(REEL_PATH):
		var file = FileAccess.open(REEL_PATH, FileAccess.READ)
		if file:
			var mp3 = AudioStreamMP3.new()
			mp3.data = file.get_buffer(file.get_length())
			reel_stream = mp3
			
	if reel_stream:
		reel_channel.stream = reel_stream

# --- HÀM PHÁT ÂM THANH CHÍNH ---

## Tiếng kêu mèo meo meo đa dạng biểu cảm
func play_meow(pitch: float = 1.0) -> void:
	var stream: AudioStream = null
	if pitch < 0.92 and sound_cache.has("meow_curious"):
		stream = sound_cache["meow_curious"]
	elif pitch > 1.18 and sound_cache.has("meow_sweet"):
		stream = sound_cache["meow_sweet"]
	elif sound_cache.has("meow_cheerful"):
		stream = sound_cache["meow_cheerful"]
	elif sound_cache.has("meow_general"):
		stream = sound_cache["meow_general"]
		
	if stream:
		_play_on_channel(cat_channel, stream, pitch, 0.0)
	else:
		play_tone(440.0 * pitch, 0.25, 0.4)
	vibrate(35)

## Phát âm thanh theo 4 bước ngữ điệu dạy mèo
func play_action_word(step_index: int) -> void:
	match step_index:
		0: # Bước 1: "Meo-o?" (Tò mò, nghi vấn)
			if sound_cache.has("meow_curious"):
				_play_on_channel(cat_channel, sound_cache["meow_curious"], 1.0, 0.0)
			else:
				play_meow(0.95)
		1: # Bước 2: "Méo meo!" (Hào hứng, đồng ý)
			if sound_cache.has("meow_cheerful"):
				_play_on_channel(cat_channel, sound_cache["meow_cheerful"], 1.05, 0.0)
			else:
				play_meow(1.08)
		2: # Bước 3: "Meoo~" (Nũng nịu, tập trung)
			if sound_cache.has("meow_sweet"):
				_play_on_channel(cat_channel, sound_cache["meow_sweet"], 1.15, 0.0)
			else:
				play_meow(1.22)
		3: # Bước 4: "Ngoao!" (Quyết tâm, về đích)
			if sound_cache.has("meow_bold"):
				_play_on_channel(cat_channel, sound_cache["meow_bold"], 1.25, 0.0)
			else:
				play_meow(1.35)
		_:
			play_meow(1.0 + step_index * 0.1)
	vibrate(40)

## Tiếng mèo gừ gừ purr dễ chịu khi được vuốt ve
func play_purr() -> void:
	if sound_cache.has("purr"):
		_play_on_channel(cat_channel, sound_cache["purr"], 1.0, -1.0)
	else:
		play_tone(180.0, 0.4, 0.2)
	vibrate(25)

## Tiếng chuông / fanfare chiến thắng khi giải đúng chuỗi hoặc nhận quà
func play_success() -> void:
	if sound_cache.has("success_fanfare"):
		_play_on_channel(sfx_channel, sound_cache["success_fanfare"], 1.0, 1.0)
	elif sound_cache.has("success_chime"):
		_play_on_channel(sfx_channel, sound_cache["success_chime"], 1.0, 1.0)
	else:
		play_sequence([523.25, 659.25, 783.99, 1046.50], 0.12)
	vibrate(100)

## Tiếng mèo kêu "Ngoao.." buồn rầu / safe failure khi xếp sai thứ tự
func play_fail() -> void:
	if sound_cache.has("fail_ngoao"):
		_play_on_channel(cat_channel, sound_cache["fail_ngoao"], 1.0, 0.5)
	elif sound_cache.has("fail_short"):
		_play_on_channel(cat_channel, sound_cache["fail_short"], 1.0, 0.5)
	else:
		play_sequence([320.0, 260.0, 200.0], 0.18)
	vibrate(80)

## Tiếng bấm nút giao diện (Crisp UI Click với Debounce chống spam)
func play_click() -> void:
	var now = Time.get_ticks_msec()
	if now - last_click_time_msec < 45:
		return
	last_click_time_msec = now
	
	if sound_cache.has("click"):
		_play_on_channel(ui_channel, sound_cache["click"], 1.0, -2.0)
	else:
		play_tone(600.0, 0.05, 0.2)
	vibrate(15)

## Tiếng gắn thẻ âm thanh vào khay puzzle (Snappy Card Pop)
func play_card_pop() -> void:
	if sound_cache.has("card_pop"):
		_play_on_channel(ui_channel, sound_cache["card_pop"], 1.05, 0.0)
	else:
		play_click()
	vibrate(20)

func play_pop() -> void:
	play_card_pop()

## Tiếng gõ gỗ lách cách vui tai (Wooden Pop) cho ngăn kéo gỗ & bục kệ
func play_wooden_pop() -> void:
	if sound_cache.has("card_pop"):
		_play_on_channel(ui_channel, sound_cache["card_pop"], randf_range(1.18, 1.32), 1.5)
	elif sound_cache.has("click"):
		_play_on_channel(ui_channel, sound_cache["click"], randf_range(1.20, 1.35), 0.5)
	else:
		play_tone(850.0, 0.04, 0.25)
	vibrate(18)

## Tiếng gỡ thẻ khỏi khay puzzle (Light Cancel/Dismiss)
func play_card_cancel() -> void:
	if sound_cache.has("cancel"):
		_play_on_channel(ui_channel, sound_cache["cancel"], 0.95, -1.0)
	else:
		play_click()
	vibrate(15)

func play_cancel() -> void:
	if sound_cache.has("cancel_cozy"):
		_play_on_channel(ui_channel, sound_cache["cancel_cozy"], 1.0, -1.0)
	elif sound_cache.has("cancel"):
		_play_on_channel(ui_channel, sound_cache["cancel"], 0.95, -1.0)
	else:
		play_click()
	vibrate(15)

func play_confirm() -> void:
	if sound_cache.has("confirm"):
		_play_on_channel(ui_channel, sound_cache["confirm"], 1.0, 0.0)
	else:
		play_click()
	vibrate(25)

func play_currency() -> void:
	if sound_cache.has("currency"):
		_play_on_channel(ui_channel, sound_cache["currency"], 1.0, 0.0)
	else:
		play_click()
	vibrate(30)

func play_purchase() -> void:
	if sound_cache.has("purchase"):
		_play_on_channel(sfx_channel, sound_cache["purchase"], 1.0, 0.0)
	elif sound_cache.has("currency"):
		play_currency()
	else:
		play_success()
	vibrate(40)

func play_dialogue_blip() -> void:
	if sound_cache.has("dialogue_blip"):
		_play_on_channel(ui_channel, sound_cache["dialogue_blip"], randf_range(0.95, 1.05), -4.0)
	else:
		play_click()

func play_unlock() -> void:
	if sound_cache.has("unlock"):
		_play_on_channel(sfx_channel, sound_cache["unlock"], 1.0, 1.0)
	else:
		play_success()
	vibrate(50)

func play_menu_open() -> void:
	if sound_cache.has("menu_open"):
		_play_on_channel(ui_channel, sound_cache["menu_open"], 1.0, -1.0)
	else:
		play_click()

func play_menu_close() -> void:
	if sound_cache.has("menu_close"):
		_play_on_channel(ui_channel, sound_cache["menu_close"], 1.0, -1.0)
	else:
		play_cancel()

## Tiếng ăn nhồm nhoàm "nom nom"
func play_chomp() -> void:
	if sound_cache.has("chomp"):
		_play_on_channel(sfx_channel, sound_cache["chomp"], 1.0, 1.0)
	elif is_inside_tree():
		for i in range(3):
			get_tree().create_timer(i * 0.12).timeout.connect(func():
				play_tone(220.0 + (i % 2) * 60.0, 0.08, 0.35)
			)
	vibrate(40)

## Tiếng cười khúc khích khi cù lét bụng mèo
func play_giggle() -> void:
	if sound_cache.has("giggle"):
		_play_on_channel(cat_channel, sound_cache["giggle"], 1.05, 0.0)
	elif is_inside_tree():
		for i in range(4):
			get_tree().create_timer(i * 0.08).timeout.connect(func():
				play_tone(700.0 + (i % 2) * 150.0, 0.06, 0.25)
			)
	vibrate(30)

## Tiếng bật nảy tưng tưng khi nhảy hoặc chọc chân
func play_bounce() -> void:
	if sound_cache.has("bounce"):
		_play_on_channel(sfx_channel, sound_cache["bounce"], 1.0, 0.0)
	else:
		play_tone(350.0, 0.1, 0.3)
	vibrate(45)

## Tiếng nhại giọng Talking Tom (Helium cat chatter)
func play_talking_mimic() -> void:
	if sound_cache.has("talking"):
		_play_on_channel(cat_channel, sound_cache["talking"], 1.25, 1.0)
	elif is_inside_tree():
		var notes = [659.25, 783.99, 880.00, 783.99, 1046.50, 987.77]
		for i in range(notes.size()):
			get_tree().create_timer(i * 0.09).timeout.connect(func():
				play_tone(notes[i], 0.08, 0.3)
			)
	vibrate(60)

## Tiếng thăng cấp Cat Mastery Level
func play_level_up() -> void:
	if sound_cache.has("success_fanfare"):
		_play_on_channel(sfx_channel, sound_cache["success_fanfare"], 1.1, 2.0)
	else:
		play_success()
	vibrate(120)

## Phát trực tiếp từ điểm mốc (Cue) trong master Demo Reel MP3
func play_reel_cue(cue_name: String, pitch: float = 1.0) -> void:
	if not reel_stream or not REEL_CUES.has(cue_name):
		return
	if not is_inside_tree() or not reel_channel.is_inside_tree():
		return
	var cue_data: Vector2 = REEL_CUES[cue_name]
	var start_sec = cue_data.x
	var duration = cue_data.y
	
	reel_channel.pitch_scale = pitch
	reel_channel.volume_db = 0.0
	reel_channel.play(start_sec)
	
	var stop_timer = get_tree().create_timer(duration / pitch)
	stop_timer.timeout.connect(func():
		if reel_channel.playing:
			reel_channel.stop()
	)

# --- TRỢ GIÚP PHÁT KÊNH & VIBRATE ---

func set_master_volume(vol: float) -> void:
	master_volume = clampf(vol, 0.0, 1.0)
	_update_channel_volumes()

func set_sfx_volume(vol: float) -> void:
	sfx_volume = clampf(vol, 0.0, 1.0)
	_update_channel_volumes()

func set_bgm_volume(vol: float) -> void:
	bgm_volume = clampf(vol, 0.0, 1.0)
	_update_channel_volumes()

func set_haptic_enabled(enabled: bool) -> void:
	haptic_enabled = enabled

func _update_channel_volumes() -> void:
	if bgm_channel:
		var eff_bgm = master_volume * bgm_volume
		if eff_bgm <= 0.01:
			bgm_channel.volume_db = -80.0
		else:
			bgm_channel.volume_db = linear_to_db(eff_bgm)

func _play_on_channel(player: AudioStreamPlayer, stream: AudioStream, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	if not player or not stream:
		return
	if not player.is_inside_tree():
		return
	var eff_sfx = master_volume * sfx_volume
	if eff_sfx <= 0.01:
		return
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = volume_db + linear_to_db(eff_sfx)
	player.play()

func vibrate(ms: int = 30) -> void:
	if not haptic_enabled:
		return
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(ms)

# --- PROCEDURAL SINE FALLBACK ---

func play_tone(freq: float, duration: float, volume: float = 0.5) -> void:
	var stream = generate_tone_wav(freq, duration, volume)
	if stream and tone_players.size() > 0:
		var p = tone_players[tone_player_idx]
		tone_player_idx = (tone_player_idx + 1) % tone_players.size()
		p.stream = stream
		p.volume_db = linear_to_db(clampf(volume * master_volume * sfx_volume, 0.001, 1.0))
		p.play()

func play_sequence(notes: Array, note_duration: float) -> void:
	for i in range(notes.size()):
		get_tree().create_timer(i * note_duration).timeout.connect(func():
			play_tone(notes[i], note_duration * 1.2, 0.35)
		)

func generate_tone_wav(freq: float, duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_frames = int(sample_rate * duration)
	var byte_array = PackedByteArray()
	byte_array.resize(total_frames)
	
	for i in range(total_frames):
		var t = float(i) / float(sample_rate)
		var envelope = 1.0
		if t < 0.03:
			envelope = t / 0.03
		elif t > duration - 0.05:
			envelope = (duration - t) / 0.05
			
		var val = sin(2.0 * PI * freq * t) * envelope * volume
		var byte_val = int((val + 1.0) * 0.5 * 255.0)
		byte_array[i] = clampi(byte_val, 0, 255)
		
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = byte_array
	return wav

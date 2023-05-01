extends CanvasLayer

var time = 0

@export var star2_time: float
@export var star3_time: float

var running = false
var ended = false

func _ready():
	$Overlay.visible = false
	$WellDone.visible = false
	$TimerBig.visible = false
	$Score.visible = false
	$Buttons.visible = false
	get_node("Score/Parcel").visible = false
	get_node("Score/Star1").visible = false
	get_node("Score/Star2").visible = false
	get_node("Score/Star3").visible = false

	get_node("Score/StarSound1").stop()
	get_node("Score/StarSound2").stop()
	get_node("Score/StarSound3").stop()

	var minutes = star2_time / 60
	var seconds = fmod(star2_time, 60)
	var milliseconds = fmod(star2_time, 1) * 100
	get_node("Goals/Label2").text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

	minutes = star3_time / 60
	seconds = fmod(star3_time, 60)
	milliseconds = fmod(star3_time, 1) * 100
	get_node("Goals/Label3").text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

func start():
	running = true

func stop():
	running = true

func end_level():
	if not ended:
		ended = true
		await get_tree().create_timer(0.5).timeout
		get_node("Score/ParcelSound").play()
		$Goals.visible = true

		$Overlay.visible = true
		$WellDone.visible = true

		if time < star3_time:
			$WellDone.text = "[center][rainbow][wave]Well done![/wave][/rainbow][/center]"

		await get_tree().create_timer(0.3).timeout
		get_node("Score/ParcelSound").play()
		$TimerBig.visible = true
		$Score.visible = true

		# Score

		await get_tree().create_timer(0.3).timeout
		get_node("Score/Parcel").visible = true
		get_node("Score/ParcelSound").play()

		await get_tree().create_timer(0.3).timeout
		get_node("Score/Star1").visible = true
		get_node("Score/StarSound1").play()

		if time < star2_time:
			await get_tree().create_timer(0.3).timeout
			get_node("Score/Star2").visible = true
			get_node("Score/StarSound2").play()

		if time < star3_time:
			await get_tree().create_timer(0.3).timeout
			get_node("Score/Star3").visible = true
			get_node("Score/StarSound3").play()

		await get_tree().create_timer(0.3).timeout
		$Buttons.visible = true
		#get_node("Score/ParcelSound").play()


func _process(delta):
	if running and not ended:
		time += delta

		var minutes = time / 60
		var seconds = fmod(time, 60)
		var milliseconds = fmod(time, 1) * 100

		$Timer.text = "[right]Time: %02d:%02d:%02d[/right]" % [minutes, seconds, milliseconds]
		$TimerBig.text = "[right]Time: %02d:%02d:%02d[/right]" % [minutes, seconds, milliseconds]


func _on_next_level_button_up():
	get_node("../Postman").ended = true
	await get_tree().create_timer(0.1).timeout
	get_node("/root/Game").next_level()


func _on_retry_button_up():
	get_node("../Postman").ended = true
	await get_tree().create_timer(0.1).timeout
	get_node("/root/Game").restart()


func _on_restart_button_up():
	get_node("../Postman").ended = true
	await get_tree().create_timer(0.1).timeout
	get_node("/root/Game").restart()





func camera_shake(intensity = 1, duration = 1):
	var camera = get_node("../Camera2D")

	for i in range(duration):
		camera.position.x += intensity
		await get_tree().create_timer(0.1).timeout
		camera.position.x -= intensity
		await get_tree().create_timer(0.1).timeout

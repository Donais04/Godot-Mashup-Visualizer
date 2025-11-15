extends Control

var dataArray: Array
var myName: RichTextLabel
var myIcon: TextureRect
var myIconGray: TextureRect
var myWaves: Array
var queue: int
var isActive = false
var goTimer = 0.0
var startY = 0
var endY = 0
var whichWave = 0
var waveTimer = 0.0
var wavIndex = 0
var appear = false
@export
var waveBoostVocals = 1.8
@export
var waveSpeed = 1.2
@export
var spacing = 180
@export
var appearTime = 8.0
# Called when the node enters the scene tree for the first time.

func start(dA) -> void:
	modulate.a = 0
	queue = -1
	dataArray = dA
	myIcon = $trackIcon.duplicate()
	myIconGray = $trackIconGray.duplicate()
	add_child(myIcon)
	add_child(myIconGray)
	if dataArray[1]:
		myIcon.texture = load("res://art/pinkSquareMic.png")
		myIconGray.texture = load("res://art/pinkSquareMicGray.png")
	else:
		myIcon.texture = load("res://art/pinkSquareInst.png")
		myIconGray.texture = load("res://art/pinkSquareInstGray.png")
	myName = $trackName.duplicate()
	add_child(myName)
	myName.text = dataArray[0]
	#myName.push_font_size(20-myName.text.length())
	print("DB starting icon " + dataArray[0] + ", vocals " + str(dataArray[1]))
	
	await get_tree().create_timer(dataArray[2]).timeout
	
	position.y = -180
	myIcon.scale = Vector2(0.15,0.15)
	myIcon.position.x = 200
	myIcon.position.y = 0
	myIconGray.scale = Vector2(0.15,0.15)
	myIconGray.position.x = 200
	myIconGray.position.y = 0
	myIconGray.modulate.a = 0.0
	myName.position.x = 25
	myName.position.y = 15
	myIcon.visible = true
	myIconGray.visible = true
	myName.visible = true
	isActive = true
	appearTime = appearTime/waveSpeed
	myIcon.position.x = 200
	myName.position.x = 100
	print("timer for  " + dataArray[0] + " done")
	waveTimer = 1.0/float(get_tree().root.get_child(0).wavesPerSecond)
	for i: int in dataArray[3]:
		var newWave = $wave.duplicate()
		add_child(newWave)
		myWaves.append(newWave)
		newWave.position.x = 1920
		if (i > 1):
			newWave.scale.x = 0.8*waveSpeed/float(get_tree().root.get_child(0).wavesPerSecond)
			newWave.visible = true
			newWave.scale.y = i*0.01 * (waveBoostVocals if dataArray[1] else 1.0)
			newWave.position.y = -1*i* (waveBoostVocals if dataArray[1] else 1.0) + 50
		await get_tree().create_timer(0.3335 / (float(get_tree().root.get_child(0).wavesPerSecond))).timeout
		await get_tree().create_timer(1.0 / (float(get_tree().root.get_child(0).wavesPerSecond))).timeout
	await get_tree().create_timer(float(dataArray[3].size())/float(2*get_tree().root.get_child(0).wavesPerSecond)+11.0/waveSpeed).timeout
	get_parent().removeFromQueue(self)
	for i in range(10):
		myIconGray.modulate.a += 0.1
		myIcon.modulate.a += -0.1
		await get_tree().create_timer(0.1).timeout
	pass


func _process(delta: float) -> void:
	if (isActive and wavIndex < dataArray[3].size()):
		waveTimer -= delta
		if (waveTimer < 0):
			waveTimer += 1.0/(2.0*float(get_tree().root.get_child(0).wavesPerSecond))
			var newWave = $wave.duplicate()
			add_child(newWave)
			myWaves.append(newWave)
			newWave.position.x = 1920
			newWave.scale.y = dataArray[3][wavIndex]*0.01 * (waveBoostVocals if dataArray[1] else 1.0)
			newWave.position.y = -1*dataArray[3][wavIndex]* (waveBoostVocals if dataArray[1] else 1.0) + 50
			newWave.scale.x = waveSpeed/float(get_tree().root.get_child(0).wavesPerSecond)
			if (dataArray[3][wavIndex] > 0.1):
				newWave.visible = true
			wavIndex += 1
	if (!appear and isActive):
		appearTime += -1 * delta
		if (appearTime < 0):
			appear = true
			get_parent().addToQueue(self)
	if (appear and modulate.a < 1 and ((isActive and goTimer <= 0) or (modulate.a > 0))):
		modulate.a += delta * 0.5
	if (myWaves.size() > 0 and myWaves[0].position.x < 320):
		myWaves[0].queue_free()
		myWaves.pop_front()
	if (goTimer > 0):
		position.y = ((queue)*spacing-startY) * pow((atan((1.0-goTimer) * PI/2)),0.5)+startY+10
		goTimer += -1 * delta
		myName.text = str(queue) + ", " + str(startY).substr(0,5) + ", " + str(position.y).substr(0,5)
	for i in range(myWaves.size()):
		myWaves[i].position.x += -150.0*delta*waveSpeed
	pass

func isVoc() -> bool:
	await get_tree().create_timer(0.05).timeout
	return dataArray[1] #aaaaaaaaaaaaaaaa

func updateMove() -> void:
	if isActive:
		startY = position.y
		queue = get_parent().getQueue(self)
		goTimer = 1.0
	if position.y > 1300:
		if (get_parent().deleteMe(self)):
			queue_free()
	pass

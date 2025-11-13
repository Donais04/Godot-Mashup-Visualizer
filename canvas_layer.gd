extends CanvasLayer

var contArr = Array()
var instArr = Array()
var vocalArr = Array()
var inactArr = Array()
func _process(delta: float) -> void:
	if (instArr.size() == 0 and vocalArr.size() == 0 and inactArr.size() > 0):
		get_tree().quit(0)

func birth(parsedArray) -> void:
	for i: Array in parsedArray:
		var nodee = find_child("Control").duplicate()
		add_child(nodee)
		nodee.start(i)
		contArr.append(nodee)


func moveAll() -> void:
	for i: Control in instArr:
		i.updateMove()
	for i: Control in vocalArr:
		i.updateMove()
	for i: Control in inactArr:
		i.updateMove()

func getQueue(c: Control) -> int:
	var inQ = instArr.find(c)
	if (inQ == -1):
		var inQ2 = vocalArr.find(c)
		if (inQ2 == -1):
			return instArr.size() + vocalArr.size() + inactArr.find(c)
		return instArr.size() + inQ2
	return inQ
	
func removeFromQueue(c: Control) -> void:
	var at = instArr.find(c)
	if (at == -1):
		inactArr.insert(0,vocalArr.pop_at(vocalArr.find(c)))
	else:
		inactArr.insert(0,instArr.pop_at(at))
	moveAll()
	
func addToQueue(c: Control) -> void:
	if (await c.isVoc()):
		vocalArr.insert(0,c)
	else:
		instArr.append(c)
	moveAll()

func deleteMe(c: Control) -> bool:
	var at = inactArr.find(c)
	if (at == -1):
		return false
	inactArr.pop_at(at)
	return true

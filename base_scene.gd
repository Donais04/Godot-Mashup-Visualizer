extends Node


var parsedArray = Array() #each indexx is new file, in index, first is name str, second is vocals bool, third is position float, last is waves as int array
var songTimeActive = 0
@export var wavesPerSecond = 10
@export var songDelay = 8.8
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var extention = "C:\\Users\\Coolb\\OneDrive\\Documents\\REAPER Media\\Media"
	#var file = FileAccess.open("C:\\Users\\Coolb\\OneDrive\\Documents\\REAPER Media\\Whore Under Moonlight_1.rpp", FileAccess.READ)
	#var file = FileAccess.open("C:\\Users\\Coolb\\OneDrive\\Documents\\REAPER Media\\Tilted Towers_1.rpp", FileAccess.READ)
	var file = FileAccess.open("C:\\Users\\Coolb\\OneDrive\\Documents\\REAPER Media\\Mach 1_2.rpp", FileAccess.READ)
	#var file = FileAccess.open("C:\\Users\\Coolb\\OneDrive\\Documents\\REAPER Media\\Sad Skies.rpp", FileAccess.READ)
	#var file = FileAccess.open("C:\\Users\\Coolb\\OneDrive\\Documents\\REAPER Media\\Call Me [Big Shot]_1.rpp", FileAccess.READ)
	#var file = FileAccess.open("C:\\Users\\Coolb\\OneDrive\\Documents\\REAPER Media\\starting.rpp", FileAccess.READ)
	#var file = FileAccess.open("C:\\Users\\Coolb\\OneDrive\\Documents\\REAPER Media\\Finale_1.rpp", FileAccess.READ)
	var fileStrings = file.get_as_text().split("<TRACK").slice(1)
	file.close()
	var loadingBarCounter = 0.0
	var offset = 0
	var originalName = ""
	#986
	for i: String in fileStrings:
		var splI = i.split("\n")
		var listOfItems = i.split("ITEM")
		listOfItems.remove_at(0)
		for m: String in listOfItems:
			var splM = m.split("\n")
			var arrayBuilder = Array()
			arrayBuilder.append(splI[1].substr(9,splI[1].length()-10))
			originalName = arrayBuilder[0]
			if (arrayBuilder[0].substr(0,1) == "\""):
				arrayBuilder[0] = arrayBuilder[0].substr(1,arrayBuilder[0].length()-2)
			if (arrayBuilder[0].substr(0,1) == ")"):
				arrayBuilder[0] = arrayBuilder[0].substr(1)
				arrayBuilder.append(true)
			else:
				arrayBuilder.append(false)
			if (arrayBuilder[0].substr(0,1).is_valid_int()):
				offset = arrayBuilder[0].substr(0,1).to_int()
				arrayBuilder[0] = arrayBuilder[0].substr(1)
			var soffs = 0.0
			var length = 0.0
			for j: String in splM:
				if (j.contains("POSITION")):
					arrayBuilder.append(j.substr(15,j.length()-16).to_float())
				elif (j.contains("LENGTH")):
					length = j.substr(13, j.length()-14).to_float()
				elif (j.contains("SOFFS")):
					soffs = j.substr(12, j.length()-13).to_float()
					if (soffs > 0.1):
						assert("RANDY YOUR SOFFS")
				elif (j.contains("FILE")):
					var wavF = FileAccess.get_file_as_bytes(extention + "\\" + j.split("\\")[j.split("\\").size()-1].left(-2))
					#print("file: " + extention + "\\" + j.split("\\")[j.split("\\").size()-1].left(-2))
					#find data secion
					var dataSecIndex = 0
					var hits = 0
					for l in range(0,wavF.size()):
						#print(str(wavF[l]) + ", " + str(l) + ", " + str(hits))
						match hits:
							0:
								if (wavF[l] == 100):
									hits = 1
							1:
								if (wavF[l] == 97):
									hits = 2
								else:
									hits = 0
							2:
								if (wavF[l] == 116):
									hits = 3
								else:
									hits = 0
							3:
								if (wavF[l] == 97):
									dataSecIndex = l-4
									break
								else:
									hits = 0
						if (l == wavF.size()-1):
							assert("line 46")
					#print("data is at: " + str(dataSecIndex))
					var dataBlockSize = wavF[32]
					var numChannels = wavF[22]
					var sampleRate = (wavF[25]*256+wavF[24]);
					#print(sampleRate)
					var averageHolder = []
					var countForAv = 0.0
					var amount = 0
					var readEvery = dataBlockSize/numChannels
					var startFrom = int(dataSecIndex+8+soffs*sampleRate*readEvery)
					var readTo = int(startFrom + length*sampleRate*readEvery*2)
					if (readTo > wavF.size()):
						readTo = wavF.size()
					#if (startFrom % 2 == 0):
					#	startFrom += -1
					#startFrom += -1 * offset
					print("\n\ncompiling file " + j.substr(14,j.length()-16))
					print("originalName: " + originalName)
					print("soffs: " + str(soffs))
					print("dBlockSize: " + str(dataBlockSize))
					print("sample rate: " + str(sampleRate))
					print("position: " + str(arrayBuilder[2]))
					print("length: " + str(length))
					print("read from " + str(startFrom) + 
						", read to " + str(readTo) + 
						", out of " + str(wavF.size()))
					print("readEvery: " + str(readEvery))
					print("dataSecIndex: " + str(dataSecIndex))
					#print("loading, " + str(loadingBarCounter*10.0/float(listOfItems.size())).substr(0,3) + "%")
					#no idea what the two is doing below here
					for k in range(startFrom,readTo,readEvery):
						var countForCountForAv = 0.0
						for l in range(k-dataBlockSize/numChannels+1,k+1):
							countForCountForAv = countForCountForAv / 256 + wavF[l]
						countForAv +=  countForCountForAv if (countForCountForAv<128) else 255-countForCountForAv
						amount += 1
						if (amount >= sampleRate/wavesPerSecond):
							averageHolder.append(int(countForAv / (sampleRate/wavesPerSecond)))
							countForAv = 0.0
							amount = 0
					print(str(averageHolder.size()) + " elements compiled")
					arrayBuilder.append(averageHolder)
			loadingBarCounter += 1.0
			parsedArray.append(arrayBuilder)
	print("sorting array")
	#print("DB " + parsedArray[0][0] + "   " + parsedArray[1][0])
	var sortedArray = Array()
	sortedArray.append(parsedArray[0])
	for i in range(1,parsedArray.size()):
		for j in range(sortedArray.size()):
			if parsedArray[i][2]<sortedArray[j][2]:
				sortedArray.insert(j,parsedArray[i])
				break
			elif j == sortedArray.size()-1:
				sortedArray.append(parsedArray[i])
	parsedArray = sortedArray
	#print("DB2 " + parsedArray[0][0] + "   " + parsedArray[1][0])
	print("creating objects")
	$CanvasLayer.birth(parsedArray)
	await get_tree().create_timer(songDelay/$CanvasLayer/Control.waveSpeed).timeout
	$song.play()
	pass

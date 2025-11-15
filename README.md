# Mashup Visualizer

###This is a way to give your mashup projects a visual element

###Requirements:
* Godot (https://godotengine.org/download/)
* REAPER (https://www.reaper.fm/download.php)


###How to use
* Create a new REAPER project
* Paste the project file's address into line 6 of base_scene.gd (should be a .RPP file)
* Pick a directory for your .wav files. It is recomended to use the /REAPER Media/Media directory
* Paste that directory into line 7 of base_scene.gd
* Create your mashup in that project, ensuring each different song only goes onto one track
* Once you have finished, use the glue feature of REAPER to ensure sections with multiple of the same sample are registered as one sample
* To differenciate between instrumentals and vocals, add a ) at the beginning of the track's name
* To add lyrics, add a natural number less than 10 right after the ) as an identifier. Then make markers at the positions the lyrics start, whose names are the identifier, followed by the lyrics they are for


###Examples
* https://youtu.be/v-vopBTXPqw
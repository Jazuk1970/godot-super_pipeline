extends Node
signal MusicFinished
onready var sfx:Object = $sfx_players
onready var music_player:Object = $music_player
export (int) var sfx_channels = 10
export (String) var music_bus = "Music"
export (String) var sfx_bus = "SFX"
export (Array, AudioStream) var samples
var sfx_list = {}
var sfx_queue = []
var available_players = []
var active_players = {}
var retrigger:float = 1.0/60.0*2


func _ready():
	#Add the audio players for the sfx
	for _channel in sfx_channels:
		var _audio_player = AudioStreamPlayer.new()
		sfx.add_child(_audio_player)
		available_players.append(_audio_player)
		_audio_player.connect("finished",self,"_on_stream_finished", [_audio_player])
		_audio_player.bus = sfx_bus
	#Add the samples to the sample list
	for _sample in samples:
		sfx_list[_sample.get_path().get_file().get_basename()] = samples.find(_sample)
	music_player.bus = music_bus

func _process(_delta):
	if sfx_queue:
		var _sample:String = sfx_queue[0]
		if active_players.has(_sample):
			var _player:AudioStreamPlayer = active_players[_sample]
			if _player.get_playback_position() > retrigger:
				_player.play()
				sfx_queue.pop_front()
	if not sfx_queue.empty() and not available_players.empty():
		var _sample:String = sfx_queue.pop_front()
		var _stream:int = sfx_list[_sample]
		available_players[0].stream = samples[_stream]
		available_players[0].play()
		active_players[_sample] = available_players[0]
		available_players.pop_front()

func sfx_play(_sample):
	if sfx_list.has(_sample):
		sfx_queue.append(_sample)

func sfx_stop(_sample):
	if active_players.has(_sample):
		_stop_player(active_players[_sample])

func _on_stream_finished(_audio_player):
	_stop_player(_audio_player)

func _stop_player(_audio_player):
	_audio_player.stop()
	available_players.append(_audio_player)
	active_players.erase(_audio_player)

func music_play(_sample:String, _start:float = 0.0):
	if sfx_list.has(_sample):
		var _stream:int = sfx_list[_sample]
		music_player.stream = samples[_stream]
		if globals.InGameMusic:
			music_player.play(_start)
		
func music_stop():
	music_player.stop()


func _on_music_player_finished():
	music_player.stop()
	emit_signal("MusicFinished")

func set_music_mode(_val):
	if _val:
		if !music_player.playing:
			music_player.play()
	else:
		music_stop()
	

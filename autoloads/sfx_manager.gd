extends Node
var audio_channels = 10
var bus = "master"
var available = []
var queue = []
var active = []
var retrigger:float = 1.0/60.0*2


func _ready():
	for i in audio_channels:
		var _ac = AudioStreamPlayer.new()
		add_child(_ac)
		available.append(_ac)
		_ac.connect("finished",self,"_on_stream_finished", [_ac])
		_ac.bus = bus

func _on_stream_finished(stream):
	available.append(stream)
	active.erase(stream)
	
func play(sound_path):
	queue.append(sound_path)

func _process(_delta):
	if queue:
		if active.has(queue[0]):
			var _player:AudioStreamPlayer = active[queue[0]]
			if _player.get_playback_position() > retrigger:
				_player.play()
				queue.pop_front()
	if not queue.empty() and not available.empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		active.append(available[0])
		available.pop_front()


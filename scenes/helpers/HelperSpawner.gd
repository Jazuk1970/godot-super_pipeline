extends Node
# warning-ignore:unused_class_variable
export (PackedScene) var Standard

var helpers:Dictionary = {}
var helpersForRemoval:Dictionary = {}
var helpersForRespawn:Dictionary = {}
var helpersToRemove:int setget remove_helpers

func _ready():
	var _helpers = globals.Level_Data.Helpers
	for _helperType in _helpers:
		for _helper in _helpers[_helperType]:
			if _helpers[_helperType][_helper].spawn_frequency != "-1":
				if _helpers[_helperType][_helper].has("initial_delay"):
					if _helpers[_helperType][_helper].initial_delay == "0":
						globals.helpers.add_child(spawn(_helperType,_helper))
					else:
						add_respawn(_helperType,_helper,_helpers[_helperType][_helper].initial_delay)
				else:
					globals.helpers.add_child(spawn(_helperType,_helper))

func _process(delta):
	if helpersForRemoval.size() > 0:
		self.helpersToRemove = helpersForRemoval.size()
	if helpersForRespawn.size() > 0 and globals.Game_State.statename == "Play":
		for _helperType in helpersForRespawn:
			for _helper in helpersForRespawn[_helperType]:
				helpersForRespawn[_helperType][_helper].elapsed += delta
				if helpersForRespawn[_helperType][_helper].elapsed > helpersForRespawn[_helperType][_helper].delay.to_float():
					var _new_helper = spawn(_helperType,helpersForRespawn[_helperType][_helper].id)
					_new_helper.initial_delay = 0.0
					globals.helpers.add_child(_new_helper)
					helpersForRespawn[_helperType].erase(helpersForRespawn[_helperType][_helper].id)
					if helpersForRespawn[_helperType].size() == 0:
						helpersForRespawn.erase(_helperType)
	return delta

func remove_helpers(_num):
	helpersToRemove = _num
	if _num > 0:
		for _type in helpersForRemoval:
			if helpers.has(_type):
				for _idx in helpersForRemoval[_type].size():
					if helpers[_type].has(helpersForRemoval[_type][_idx]):
						helpers[_type].erase(helpersForRemoval[_type][_idx])
					helpersForRemoval[_type].remove(_idx)
				if helpers[_type].size() == 0:
					helpers.erase(_type)
			helpersForRemoval.erase(_type)

func add_respawn(_type,_id,_delay):
	if not helpersForRespawn.has(_type):
		helpersForRespawn[_type] = {}
	var _respawn = {"id":_id,"delay":_delay,"elapsed":0}
	helpersForRespawn[_type][_id] = _respawn

func spawn(_type,_id) -> Object:
	var _helpers = globals.Level_Data.Helpers
	if _helpers.has(_type):
		if _helpers[_type].has(_id):
			var _helper = _helpers[_type][_id]
			var _e = getType(_type)
			if _e != null:
				_e.name = _type + "_" + _id
				_e.id = _id
				_e.speed = _helper.speed.to_float()
				_e.follow_dist = _helper.follow_dist.to_float()
				_e.work_effeciency = _helper.work_effeciency.to_float()
				match _type:
					"Standard":
						_e.spawn_frequency = _helper.spawn_frequency.to_float()
						_e.initial_delay = _helper.initial_delay.to_float()
				return _e
	return null

func getType(_type) -> Object:
	match _type:
		"Standard":
			return Standard.instance()
	return null

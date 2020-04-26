extends Range

export(int) var bus = 0
export(String) var text = ""

func _ready():
	value = db2linear(AudioServer.get_bus_volume_db(bus))
	connect("value_changed", self, "_on_value_changed")

func _on_value_changed(value):
	print("linear " + str(value) + " -> db " + str(linear2db(value)))
	AudioServer.set_bus_volume_db(bus, linear2db(value))


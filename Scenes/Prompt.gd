extends Control

#dictionary of label nodes with names as keys

var labels = {"don": null, "doff": null}
var current_label = "don"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	labels["don"] = $Don
	labels["doff"] = $Doff
	enable_label(current_label)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func enable_label(label_name) -> void:
	if label_name == current_label:
		pass
	else:
		# no input validation, TODO add input validation
		current_label = label_name
		labels[label_name].hide(false)
		for label in labels.keys:
			if label != current_label:
				labels[label].hide(true)

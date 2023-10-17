@tool #run in editor
extends Node3D
class_name Sight

signal value_changed

@export var horizontal_fov:float
@export var vertical_fov:float
@export var far_clipping_plane:float

var frustum_area: Area3D
var frustum_model: MeshInstance3D

func _ready():
	frustum_model = MeshInstance3D.new()
	frustum_area = Area3D.new()
	
	self.add_child(frustum_model)
	update_frustum()

#func _process(delta):
#	print(Engine.is_editor_hint())

func update_frustum():
	
	var mesh = generate_frustum_mesh(horizontal_fov, vertical_fov, far_clipping_plane)
	
	#update display mesh
	self.frustum_model.set_mesh(mesh)
	
	#update area collider
	var shape = mesh.create_convex_shape(false)
	#TODO update collision mesh

func generate_frustum_mesh(h_fov:float, v_fov:float, farclip:float):
	var mesh_data = []
	mesh_data.resize(ArrayMesh.ARRAY_MAX)
	var h_point = frustum_points(h_fov, farclip)
	var v_point = frustum_points(v_fov, farclip)
	mesh_data[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array([
		Vector3(0,0,0),
		Vector3(-h_point,v_point,farclip),
		Vector3(h_point,v_point,farclip),
		Vector3(h_point,-v_point,farclip),
		Vector3(-h_point,-v_point,farclip)
	])
	mesh_data[ArrayMesh.ARRAY_INDEX] = PackedInt32Array([
		0,2,1,
		0,3,2,
		0,4,3,
		0,1,4,
		
		1,2,4,
		4,2,3
	])
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	return mesh

func frustum_points(theta:float, l:float):
	var t = deg_to_rad(theta)/2
	return l*tan(t)

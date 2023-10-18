class_name Sight
extends Node3D

signal frustum_area_enter(area: Area3D)
signal frustum_area_exit(area: Area3D)

@export var horizontal_fov:float = 90
@export var vertical_fov:float = 30
@export var far_clipping_plane:float=10

var frustum_area: Area3D
var frustum_shape: CollisionShape3D

func _ready():
	#setup frustum data
	frustum_area = Area3D.new()
	frustum_shape = CollisionShape3D.new()
	
	self.add_child(frustum_area)
	frustum_area.add_child(frustum_shape)
	
	frustum_area.set_collision_mask_value(1, false)
	frustum_area.set_collision_mask_value(3, true)
	update_frustum()
	
	#create signal functions
	frustum_area.connect("area_entered", _on_frustum_area_enter)
	frustum_area.connect("area_exited", _on_frustum_area_exit)
	self.connect("property_list_changed", update_frustum)

func _on_frustum_area_enter(area: Area3D):
	frustum_area_enter.emit(area)
	
func _on_frustum_area_exit(area):
	frustum_area_exit.emit(area)

func update_frustum():
	var mesh = generate_frustum_mesh(horizontal_fov, vertical_fov, far_clipping_plane)
	#update area collider
	var shape = mesh.create_convex_shape(false)
	frustum_shape.shape = shape

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

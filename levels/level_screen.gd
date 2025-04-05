class_name LevelScreen extends Node2D

@onready var spawners_container: Node2D = $Spawners
@onready var area: Area2D = $Area
@onready var coll_shape: CollisionShape2D = $Area/CollisionShape2D

@export var max_enemies_at_once: int = 2

var current: bool = false
var num_enemies_alive: int = 0

func _ready() -> void:
	area.body_entered.connect(body_entered)

func body_entered(body: Node2D) -> void:
	if current:
		return
	var character = body as Character
	if !character:
		return
	if character.faction == Character.Faction.PLAYER:
		Events.main_char_entered_screen.emit(self)

func enemy_spawned() -> void:
	num_enemies_alive += 1

func enemy_died() -> void:
	num_enemies_alive -= 1

func begin() -> void:
	print("screen.begin()")
	current = true
	for spawner: Spawner in spawners_container.get_children():
		spawner.should_spawn = true

func _physics_process(_delta: float) -> void:
	if !current:
		return

	if num_enemies_alive == 0 and spawners_container.get_children().size() == 0:
		Events.screen_ended.emit(self)
		current = false
		print("end screen")
		return

	for spawner: Spawner in spawners_container.get_children():
		spawner.should_spawn = num_enemies_alive < max_enemies_at_once

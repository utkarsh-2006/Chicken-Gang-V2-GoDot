extends Marker2D
class_name SpawnPoint

enum SpawnType {
	PLAYER_1,
	PLAYER_2,
	HUNTER,
	WORM_ZONE
}

@export var spawn_type: SpawnType = SpawnType.PLAYER_1

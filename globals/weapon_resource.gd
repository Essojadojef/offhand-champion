extends Resource
class_name WeaponResource, "weapon_resource.png"

enum Level {
	UNCATEGORIZED,
	FLIMSY, USEFUL, # common, match starting weapons, have few good moves
	RESPECTABLE, EFFECTIVE, # rare, mid match weapons, overall good
	THREATENING, DEVASTATING, # hard to obtain during a match but still fair
	CATACLYSMIC, APOCALYPTIC, # legendary, singleplayer only
	GOD}
export(Level) var level : int = Level.USEFUL

export var icon : Texture
export var scene : PackedScene


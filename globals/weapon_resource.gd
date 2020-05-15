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
export var entity_scene : PackedScene # added to the player entity when the weapon is equipped
export var panel_scene : PackedScene # added to the player panel when the weapon is equipped
export var item_scene : PackedScene # the weapon when it's an item

export var is_item : bool

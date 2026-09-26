@tool
extends Node2D
## Decorative only. Bottom-centred at the bank; atlas regions preserve original art proportions.
@export_enum("cottage", "treehouse", "windmill", "blue_house", "tower", "pavilion", "bench", "barrel", "crate", "flowerpot", "fence", "arch", "stump", "sign", "birdhouse", "column", "planter", "bush", "pine", "banner", "cart", "mushrooms", "fountain", "rope_banner", "rock", "wood_arch", "ruin_arch", "crystal_shrine") var piece := "cottage":
	set(value):piece = value;queue_redraw()
@export var art_height := 180.0:
	set(value):art_height = value;queue_redraw()
@export var mirrored := false:
	set(value):mirrored = value;queue_redraw()
const HOUSES = preload("res://assets/world_expansion/houses.png")
const GARDEN = preload("res://assets/world_expansion/garden_props.png")
const VILLAGE = preload("res://assets/world_expansion/village_props.png")
const PIECES = {
	"cottage": [0, Rect2(15, 60, 358, 383)], "treehouse": [0, Rect2(379, 11, 354, 430)],
	"windmill": [0, Rect2(737, 13, 343, 439)], "blue_house": [0, Rect2(408, 456, 369, 370)],
	"tower": [0, Rect2(815, 456, 244, 379)], "pavilion": [0, Rect2(380, 853, 296, 216)],
	"bench": [1, Rect2(29, 111, 309, 181)], "barrel": [1, Rect2(367, 88, 183, 191)],
	"crate": [1, Rect2(570, 97, 209, 180)], "flowerpot": [1, Rect2(798, 81, 182, 208)],
	"fence": [1, Rect2(20, 372, 232, 219)], "arch": [1, Rect2(274, 315, 291, 252)],
	"stump": [1, Rect2(581, 396, 241, 195)], "sign": [1, Rect2(825, 315, 183, 276)],
	"birdhouse": [1, Rect2(1265, 315, 154, 276)], "column": [1, Rect2(31, 598, 127, 220)],
	"planter": [1, Rect2(174, 639, 283, 173)], "bush": [1, Rect2(475, 625, 247, 187)],
	"pine": [1, Rect2(741, 592, 166, 233)], "banner": [1, Rect2(936, 611, 257, 204)],
	"cart": [1, Rect2(1210, 626, 219, 202)], "mushrooms": [1, Rect2(310, 895, 176, 148)],
	"fountain": [1, Rect2(512, 837, 229, 215)], "rope_banner": [1, Rect2(757, 880, 289, 166)],
	"rock": [1, Rect2(1054, 877, 192, 168)],
	"wood_arch": [2, Rect2(8, 473, 331, 232)], "ruin_arch": [2, Rect2(351, 475, 230, 231)],
	"crystal_shrine": [2, Rect2(1077, 477, 179, 230)]
}

func _ready() -> void:
	z_index = -6
	queue_redraw()

func _draw() -> void:
	var entry: Array = PIECES[piece]
	var source: Rect2 = entry[1]
	var art_width := art_height * source.size.x / source.size.y
	draw_set_transform(Vector2.ZERO, 0, Vector2(-1 if mirrored else 1, 1))
	draw_texture_rect_region([HOUSES, GARDEN, VILLAGE][entry[0]], Rect2(-art_width / 2, -art_height, art_width, art_height), source)
	draw_set_transform(Vector2.ZERO)

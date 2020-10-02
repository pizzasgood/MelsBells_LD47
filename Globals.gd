extends Node

var mute_bgm := false setget mute_bgm_set, mute_bgm_get

func mute_bgm_set(new_value):
	mute_bgm = new_value

func mute_bgm_get():
	return mute_bgm

"Resource/UI/Econ/ItemModelPanelCharWeaponInspect.res"
{	
	"default_weapons"
	{
		"rule"
		{
			// Default rule matches all weapons and sets up all default settings
		}
		"config"
		{
			"root_mdl"					    ""		                                // Which pedestal model to load, weapon model is merged to the pedestal, null => weapon model is the scene
			"root_anim"					    ""                          			// Which activity to play on the pedestal
			"root_anim_loop"			    ""				                        // Which activity to play on the pedestal after the initial pedestal animation finishes
			"weapon_anim"				    ""						                // Which activity to play on the weapon
			"weapon_anim_loop"			    ""	                					// Which activity to play on the weapon after the initial weapon animation finishes
			"root_camera"				    "cam_inspect"							// Which attachment specifies camera location
			"light_directional_clearall" "1"
			"light_directional_add"      "rgb{0.89 0.89 0.89} dir[-0.34 -0.90 -0.29] rot[0.0 0.0 0.0] flicker[0.00 0.00 0.00 0.00]"
			"light_directional_add"      "rgb{0.73 0.73 0.73} dir[0.23 0.94 -0.24] rot[0.0 0.0 0.0] flicker[0.00 0.00 0.00 0.00]"
			"light_directional_add"      "rgb{0.88 0.88 0.88} dir[0.97 0.02 -0.23] rot[0.0 0.0 0.0] flicker[0.00 0.00 0.00 0.00]"
			"shadow_light_offset"        "36.42 26.30 15.58"
			"shadow_light_orient"        "33.72 -112.77 0.00"
			"shadow_light_brightness"    "2.7"
			"shadow_light_color"         "[1.00 1.00 1.00]"
			"shadow_light_rotation"      "[0.00 0.00 0.00]"
			"shadow_light_flicker"       "[0.00 0.00 0.00 0.00]"
			"shadow_light_hfov"       "53.9"
			"shadow_light_vfov"       "53.9"
			"shadow_light_znear"       "23.9"
			"shadow_light_zfar"       "59.7"
			"shadow_light_atten_farz"       "119.4"
			"light_ambient"              "[0.06 0.06 0.06]"
			"item_rotate"		"x[-180 180] z[-180 180] y[-180 180]"			// rotate bounds and order of rotation for mouse drag in x then y axis, i.e. y[-10 10] z[20 -20] means dragging mouse horizontally results in a rotation around y between -10 and 10 degrees, and dragging mouse vertically results in a rotation around z between 20 and -20 degrees (sign of bounds indicate which flipped 'sense' the rotation is in)
			"item_orient"	   "0.0 0.0 0.0"									// initial orientation of item (if not attached)
		}
	}
	"SMGs"
	{
		"rule"
		{
			"type" "SubMachinegun"
		}
		"config"
		{
			"camera_offset"   "43.08 19.85 -6.68"
			"camera_orient"   "0.23 -128.48 0.00"
			"orbit_pivot"     "22.67 -5.83 -6.81"
			"item_rotate"	  "y[-360 360] x[ 0 0 ]"
		}
	}
	"mw2019_aug"
	{
		"rule"
		{
			"model" "v_sm_aug"
		}
		"config"
		{
			"camera_offset"   "39.98 32.14 -7.62"
			"camera_orient"   "-2.98 -117.94 0.00"
			"orbit_pivot"     "20.13 -5.28 -5.41"
			"item_rotate"	  "y[-360 360] x[ 0 0 ]"
			"weapon_anim"		"inv"
			"weapon_anim_loop"		"inv"
		}
	}
}

if (!("migi_initDeployWeapons" in this))
	migi_allocateEntityScope("initial_deploy.nut")

// sound precache
self.PrecacheScriptSound("Weapon_R90.Rechamber_01");
self.PrecacheScriptSound("Weapon_R90.Rechamber_02");
self.PrecacheScriptSound("Weapon_R90.Reload_Empty_End_Chamber");

::dpapa12_GetCurrentAnim <- function(vm)
{
	local anim_track = vm.LookupAttachment("a_flag");
	local anim_track_start = vm.LookupAttachment("a_flag_start");
	local anim_track_state = "none";
		
    local org = vm.GetAttachmentOrigin(anim_track) - vm.GetOrigin();
    local org_base = vm.GetAttachmentOrigin(anim_track_start) - vm.GetOrigin();
	local org_dist = org - org_base;
	if (org_dist.z > 0.8 && org_dist.z < 1.2) anim_track_state = "fire";
	else if (org_dist.z < -0.8 && org_dist.z > -1.2) anim_track_state = "reload_end";
	
	return anim_track_state;
}

::dpapa12_GetSoundscript <- function(vm)
{
	local snd_track = vm.LookupAttachment("snd_flag");
	local snd_track_start = vm.LookupAttachment("snd_flag_start");
	local snd_track_script = "none";
		
    local org = vm.GetAttachmentOrigin(snd_track) - vm.GetOrigin();
    local org_base = vm.GetAttachmentOrigin(snd_track_start) - vm.GetOrigin();
	local org_dist = org - org_base;
	if (org_dist.z > 0.8 && org_dist.z < 1.2) snd_track_script = "sound1";
	else if (org_dist.z < -0.8 && org_dist.z > -1.2) snd_track_script = "sound2";
	
	return snd_track_script;
}

function dpapa12_CustomDeployCheck(vm)
{
	local ply = vm.GetMoveParent()
	local dpapa12_index = MIGI_InitDeploy_GetWpnIndex("models/weapons/v_sh_r90.mdl", "weapon_sawedoff");
	if (dpapa12_index < 0) return;
	
	ply.ValidateScriptScope();
	local draw_scope = ply.GetScriptScope();
	if(!draw_scope.rawin("dpapa12_sndPlayTime"))
	{
		draw_scope.dpapa12_sndCanPlay <- false
		draw_scope.dpapa12_sndPlayTime <- Time()
	}
	if (ply.GetHealth() < 1)
	{
		draw_scope.plyOwnedWpn[dpapa12_index] = false;
		draw_scope.dpapa12_sndCanPlay = false;
	}
	
	if (dpapa12_GetCurrentAnim(vm) == "fire")
	{
		if (dpapa12_GetSoundscript(vm) != "none")
			draw_scope.dpapa12_sndCanPlay = true;
		else draw_scope.dpapa12_sndPlayTime <- Time();
			
		if (draw_scope.dpapa12_sndCanPlay == true)
		{
			if (dpapa12_GetSoundscript(vm) == "sound1" && Time() - draw_scope.dpapa12_sndPlayTime > 0.04)
			{
				ply.EmitSound("Weapon_R90.Rechamber_01");
				draw_scope.dpapa12_sndPlayTime <- Time();
				draw_scope.dpapa12_sndCanPlay = false;
			}
			if (dpapa12_GetSoundscript(vm) == "sound2" && Time() - draw_scope.dpapa12_sndPlayTime > 0.04)
			{
				ply.EmitSound("Weapon_R90.Rechamber_02");
				draw_scope.dpapa12_sndPlayTime <- Time();
				draw_scope.dpapa12_sndCanPlay = false;
			}
		}
	}
	
	if (dpapa12_GetCurrentAnim(vm) == "reload_end")
	{
		if (dpapa12_GetSoundscript(vm) != "none")
			draw_scope.dpapa12_sndCanPlay = true;
		else draw_scope.dpapa12_sndPlayTime <- Time();
		
		if (draw_scope.dpapa12_sndCanPlay == true)
		{
			if (dpapa12_GetSoundscript(vm) == "sound2" && Time() - draw_scope.dpapa12_sndPlayTime > 0.05)
			{
				ply.EmitSound("Weapon_R90.Reload_Empty_End_Chamber");
				draw_scope.dpapa12_sndPlayTime <- Time();
				draw_scope.dpapa12_sndCanPlay = false;
			}
		}
	}
		
	if (draw_scope.plyWeapon_FD[dpapa12_index] == false)
	{
		draw_scope.plyWeapon_FD[dpapa12_index] = true
		vm.__KeyValueFromInt("sequence", 7)
	}
}

MIGI_InitDeployWeapon("models/weapons/v_sh_r90.mdl", "weapon_sawedoff", [7], null, this.dpapa12_CustomDeployCheck)
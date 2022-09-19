dpapa12_MDL <- "models/weapons/v_sh_r90.mdl"
dpapa12_sequence <- 7
// sound precache
self.PrecacheScriptSound("Weapon_R90.Rechamber_01");
self.PrecacheScriptSound("Weapon_R90.Rechamber_02");
self.PrecacheScriptSound("Weapon_R90.Reload_Empty_End_Chamber");

function dpapa12_GetCurrentAnim(vm)
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

function dpapa12_GetSoundscript(vm)
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

function dpapa12_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("dpapa12_owned"))
		{
			draw_scope.dpapa12_FD <- false
			draw_scope.dpapa12_sndCanPlay <- false
			draw_scope.dpapa12_sndPlayTime <- Time()
			draw_scope.dpapa12_owned <- false
		}
		
		draw_scope.dpapa12_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, dpapa12_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_sawedoff" && wpnInst.GetOwner() == ply)
			{
				draw_scope.dpapa12_owned = true;
				break;
			}
		}
		
		if (ply.GetHealth() < 1)
		{
			draw_scope.dpapa12_owned = false;
			draw_scope.dpapa12_sndCanPlay = false;
		}
		if (draw_scope.dpapa12_owned == false) draw_scope.dpapa12_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != dpapa12_MDL)
			continue
		
		local ply = vm.GetMoveParent()
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("dpapa12_FD") )
		{
			draw_scope.dpapa12_FD <- false
			draw_scope.dpapa12_owned <- false
		}
		
		if (ply.GetHealth() < 1) continue;
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
					continue;
				}
				if (dpapa12_GetSoundscript(vm) == "sound2" && Time() - draw_scope.dpapa12_sndPlayTime > 0.04)
				{
					ply.EmitSound("Weapon_R90.Rechamber_02");
					draw_scope.dpapa12_sndPlayTime <- Time();
					draw_scope.dpapa12_sndCanPlay = false;
					continue;
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
					continue;
				}
			}
		}
		if (draw_scope.dpapa12_FD == false)
		{
			vm.__KeyValueFromInt("sequence", dpapa12_sequence)
			draw_scope.dpapa12_FD = true
		}
	}
}

// Call the think function repetitively
deployTimerEnt <- Entities.FindByName(null, "MIGIdeployTimer")
if (deployTimerEnt == null)
{
	MIGI_deploy_timer <- Entities.CreateByClassname("logic_timer")
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "targetname MIGIdeployTimer", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "RefireTime 0.01", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "classname move_rope", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:dpapa12_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:dpapa12_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}
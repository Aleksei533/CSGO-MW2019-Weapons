charlie9_MDL <- "models/weapons/v_sm_iso.mdl"
charlie9_sequence <- 7

function charlie9_GetAmmoState(vm)
{
	local ammo_track = vm.LookupAttachment("a_flag");
	local ammo_track_start = vm.LookupAttachment("a_flag_start");
	local ammo_track_state = "full";
		
    local org = vm.GetAttachmentOrigin(ammo_track) - vm.GetOrigin();
    local org_base = vm.GetAttachmentOrigin(ammo_track_start) - vm.GetOrigin();
	local org_dist = org - org_base;
	if (org_dist.z > 0.8 && org_dist.z < 1.2) ammo_track_state = "empty";
	
	return ammo_track_state;
}

function charlie9_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent();
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("charlie9_owned"))
		{
			draw_scope.charlie9_FD <- false
			draw_scope.charlie9_owned <- false
		}
		
		draw_scope.charlie9_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, charlie9_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_deagle" && wpnInst.GetOwner() == ply)
			{
				draw_scope.charlie9_owned = true;
				break;
			}
		}
		
		if (ply.GetHealth() < 1) draw_scope.charlie9_owned = false;
		if (draw_scope.charlie9_owned == false) draw_scope.charlie9_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != charlie9_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("charlie9_FD") )
		{
			draw_scope.charlie9_FD <- false
			draw_scope.charlie9_owned <- false
		}
		
		if (draw_scope.charlie9_FD == false)
		{
			if (charlie9_GetAmmoState(vm) != "empty") vm.__KeyValueFromInt("sequence", charlie9_sequence)
			draw_scope.charlie9_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:charlie9_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:charlie9_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}
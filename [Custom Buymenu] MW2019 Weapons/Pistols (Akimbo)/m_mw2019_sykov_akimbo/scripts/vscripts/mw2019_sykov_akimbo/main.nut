mike_dual_MDL <- "models/weapons/v_pi_sykov_akimbo.mdl"
mike_dual_sequence <- 8

function mike_dual_GetAmmoState(vm)
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

function mike_dual_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("mike_dual_owned"))
		{
			draw_scope.mike_dual_FD <- false
			draw_scope.mike_dual_owned <- false
		}
		
		draw_scope.mike_dual_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, mike_dual_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_elite" && wpnInst.GetOwner() == ply)
			{
				draw_scope.mike_dual_owned = true;
				break;
			}
		}
		
		if (ply.GetHealth() < 1) draw_scope.mike_dual_owned = false;
		if (draw_scope.mike_dual_owned == false) draw_scope.mike_dual_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != mike_dual_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("mike_dual_FD") )
		{
			draw_scope.mike_dual_FD <- false
			draw_scope.mike_dual_owned <- false
		}
		
		if (draw_scope.mike_dual_FD == false)
		{
			if (mike_dual_GetAmmoState(vm) != "empty") vm.__KeyValueFromInt("sequence", mike_dual_sequence)
			draw_scope.mike_dual_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:mike_dual_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:mike_dual_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}
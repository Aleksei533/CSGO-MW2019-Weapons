if (!("migi_ProjWeapons" in this))
	migi_allocateEntityScope("projectiles.nut")

kgolf_MDL <- "models/weapons/v_la_strela-p.mdl"
kgolf_sequence <- 3

function kgolf_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("kgolf_owned"))
		{
			draw_scope.kgolf_FD <- false
			draw_scope.kgolf_owned <- false
		}
		
		draw_scope.kgolf_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, kgolf_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_ump45" && wpnInst.GetOwner() == ply)
			{
				draw_scope.kgolf_owned = true;
				break;
			}
		}
		if (ply.GetHealth() < 1) draw_scope.kgolf_owned = false;
		if (draw_scope.kgolf_owned == false) draw_scope.kgolf_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != kgolf_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("kgolf_FD") )
		{
			draw_scope.kgolf_FD <- false
			draw_scope.kgolf_owned <- false
		}
		if (draw_scope.kgolf_FD == false)
		{
			vm.__KeyValueFromInt("sequence", kgolf_sequence)
			draw_scope.kgolf_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:kgolf_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:kgolf_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}

function VM_STRELA_GetAnim(vm)
{
	local anim_track = vm.LookupAttachment("a_flag");
	local anim_track_start = vm.LookupAttachment("a_flag_start");
	local tracked_anim = false;
		
    local org = vm.GetAttachmentOrigin(anim_track) - vm.GetOrigin();
    local org_base = vm.GetAttachmentOrigin(anim_track_start) - vm.GetOrigin();
	local org_dist = org - org_base;
	if (org_dist.z > 0.8 && org_dist.z < 1.2) tracked_anim = true;
	
	return tracked_anim;
}

MIGI_Projectile(10, 0.9, 2600, "weapon_strela", 500, 200, 1.0, 60.0, 2.0, 90.0, 10.0, null, null, null, null, null, 650, false, "STRELA", "prop_dynamic", "models/weapons/w_la_strela-p_rocket.mdl", "models/weapons/v_la_strela-p.mdl", "Weapon_STRELA-P.Explode", this.VM_STRELA_GetAnim)
if (!("migi_ProjWeapons" in this))
	migi_allocateEntityScope("projectiles.nut")

mike32_MDL <- "models/weapons/v_la_mgl32.mdl"
mike32_sequence <- 4

function mike32_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("mike32_owned"))
		{
			draw_scope.mike32_FD <- false
			draw_scope.mike32_owned <- false
		}
		draw_scope.mike32_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, mike32_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_ump45" && wpnInst.GetOwner() == ply)
			{
				draw_scope.mike32_owned = true;
				break;
			}
		}
		if (ply.GetHealth() < 1) draw_scope.mike32_owned = false;
		if (draw_scope.mike32_owned == false) draw_scope.mike32_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != mike32_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("mike32_FD") )
		{
			draw_scope.mike32_FD <- false
			draw_scope.mike32_owned <- false
		}
		
		if (draw_scope.mike32_FD == false)
		{
			vm.__KeyValueFromInt("sequence", mike32_sequence)
			draw_scope.mike32_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:mike32_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:mike32_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}

function VM_MGL32_GetAnim(vm)
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

MIGI_Projectile(10, 0.6, 3000, "weapon_mgl32", 400, 200, 1.0, 60.0, 2.0, 90.0, 10.0, null, null, null, null, null, 600, false, "MGL32", "prop_dynamic", "models/weapons/w_la_mgl32_charge.mdl", "models/weapons/v_la_mgl32.mdl", "Weapon_MGL32.Explode", this.VM_MGL32_GetAnim)
if (!("migi_ProjWeapons" in this))
	migi_allocateEntityScope("projectiles.nut")

gromeo_MDL <- "models/weapons/v_la_pila.mdl"
gromeo_sequence <- 3

function gromeo_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("gromeo_owned"))
		{
			draw_scope.gromeo_FD <- false
			draw_scope.gromeo_owned <- false
		}
		
		draw_scope.gromeo_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, gromeo_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_ump45" && wpnInst.GetOwner() == ply)
			{
				draw_scope.gromeo_owned = true;
				break;
			}
		}
		if (ply.GetHealth() < 1) draw_scope.gromeo_owned = false;
		if (draw_scope.gromeo_owned == false) draw_scope.gromeo_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != gromeo_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("gromeo_FD") )
		{
			draw_scope.gromeo_FD <- false
			draw_scope.gromeo_owned <- false
		}
		if (draw_scope.gromeo_FD == false)
		{
			vm.__KeyValueFromInt("sequence", gromeo_sequence)
			draw_scope.gromeo_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:gromeo_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:gromeo_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}

function VM_PILA_GetAnim(vm)
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

MIGI_Projectile(10, 0.9, 2100, "weapon_pila", 1050, 350, 1.0, 60.0, 2.0, 90.0, 10.0, null, null, null, null, null, 700, false, "PILA", "prop_dynamic", "models/weapons/w_la_pila_rocket.mdl", "models/weapons/v_la_pila.mdl", "Weapon_PILA.Explode", this.VM_PILA_GetAnim)
cpapa_dual_MDL <- "models/weapons/v_pi_357_akimbo.mdl"
cpapa_dual_sequence <- 3

function cpapa_dual_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("cpapa_dual_owned"))
		{
			draw_scope.cpapa_dual_FD <- false
			draw_scope.cpapa_dual_owned <- false
		}
		
		draw_scope.cpapa_dual_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, cpapa_dual_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_deagle" && wpnInst.GetOwner() == ply)
			{
				draw_scope.cpapa_dual_owned = true;
				break;
			}
		}
		if (ply.GetHealth() < 1) draw_scope.cpapa_dual_owned = false;
		if (draw_scope.cpapa_dual_owned == false) draw_scope.cpapa_dual_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != cpapa_dual_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("cpapa_dual_FD") )
		{
			draw_scope.cpapa_dual_FD <- false
			draw_scope.cpapa_dual_owned <- false
		}
		
		if (draw_scope.cpapa_dual_FD == false)
		{
			vm.__KeyValueFromInt("sequence", cpapa_dual_sequence)
			draw_scope.cpapa_dual_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:cpapa_dual_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:cpapa_dual_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}
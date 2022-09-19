pkilo_MDL <- "models/weapons/v_lm_pkm.mdl"
pkilo_sequence <- 5

function pkilo_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("pkilo_owned"))
		{
			draw_scope.pkilo_FD <- false
			draw_scope.pkilo_owned <- false
		}
		
		draw_scope.pkilo_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, pkilo_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_deagle" && wpnInst.GetOwner() == ply)
			{
				draw_scope.pkilo_owned = true;
				break;
			}
		}
		if (ply.GetHealth() < 1) draw_scope.pkilo_owned = false;
		if (draw_scope.pkilo_owned == false) draw_scope.pkilo_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != pkilo_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("pkilo_FD") )
		{
			draw_scope.pkilo_FD <- false
			draw_scope.pkilo_owned <- false
		}
		
		if (draw_scope.pkilo_FD == false)
		{
			vm.__KeyValueFromInt("sequence", pkilo_sequence)
			draw_scope.pkilo_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:pkilo_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:pkilo_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}
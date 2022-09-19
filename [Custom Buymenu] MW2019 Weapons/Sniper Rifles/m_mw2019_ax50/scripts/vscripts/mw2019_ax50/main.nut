alpha50_MDL <- "models/weapons/v_sn_ax50.mdl"
alpha50_sequence <- 7

function alpha50_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("alpha50_owned"))
		{
			draw_scope.alpha50_FD <- false
			draw_scope.alpha50_owned <- false
		}
		
		draw_scope.alpha50_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, alpha50_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_deagle" && wpnInst.GetOwner() == ply)
			{
				draw_scope.alpha50_owned = true;
				break;
			}
		}
		if (ply.GetHealth() < 1) draw_scope.alpha50_owned = false;
		if (draw_scope.alpha50_owned == false) draw_scope.alpha50_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != alpha50_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("alpha50_FD") )
		{
			draw_scope.alpha50_FD <- false
			draw_scope.alpha50_owned <- false
		}
		
		if (draw_scope.alpha50_FD == false)
		{
			vm.__KeyValueFromInt("sequence", alpha50_sequence)
			draw_scope.alpha50_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:alpha50_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:alpha50_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}
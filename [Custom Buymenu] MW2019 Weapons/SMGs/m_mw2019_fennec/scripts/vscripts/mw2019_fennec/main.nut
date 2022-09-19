victor_MDL <- "models/weapons/v_sm_fennec.mdl"
victor_sequence <- 6

function victor_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("victor_owned"))
		{
			draw_scope.victor_FD <- false
			draw_scope.victor_owned <- false
		}
		
		draw_scope.victor_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, victor_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_deagle" && wpnInst.GetOwner() == ply)
			{
				draw_scope.victor_owned = true;
				break;
			}
		}
		if (ply.GetHealth() < 1) draw_scope.victor_owned = false;
		if (draw_scope.victor_owned == false) draw_scope.victor_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != victor_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("victor_FD") )
		{
			draw_scope.victor_FD <- false
			draw_scope.victor_owned <- false
		}
		
		if (draw_scope.victor_FD == false)
		{
			vm.__KeyValueFromInt("sequence", victor_sequence)
			draw_scope.victor_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:victor_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:victor_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}
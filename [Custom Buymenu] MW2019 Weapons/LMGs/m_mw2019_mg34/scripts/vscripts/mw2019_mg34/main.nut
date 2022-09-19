mgolf34_MDL <- "models/weapons/v_lm_mg34.mdl"
mgolf34_sequence <- 6

function mgolf34_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("mgolf34_owned"))
		{
			draw_scope.mgolf34_FD <- false
			draw_scope.mgolf34_owned <- false
		}
		
		draw_scope.mgolf34_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, mgolf34_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_deagle" && wpnInst.GetOwner() == ply)
			{
				draw_scope.mgolf34_owned = true;
				break;
			}
		}
		if (ply.GetHealth() < 1) draw_scope.mgolf34_owned = false;
		if (draw_scope.mgolf34_owned == false) draw_scope.mgolf34_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != mgolf34_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("mgolf34_FD") )
		{
			draw_scope.mgolf34_FD <- false
			draw_scope.mgolf34_owned <- false
		}
		
		if (draw_scope.mgolf34_FD == false)
		{
			vm.__KeyValueFromInt("sequence", mgolf34_sequence)
			draw_scope.mgolf34_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:mgolf34_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:mgolf34_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}
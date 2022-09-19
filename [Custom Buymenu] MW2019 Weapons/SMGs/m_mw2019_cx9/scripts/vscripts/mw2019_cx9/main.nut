secho_MDL <- "models/weapons/v_sm_cx9.mdl"
secho_sequence <- 6

function secho_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("secho_owned"))
		{
			draw_scope.secho_FD <- false
			draw_scope.secho_owned <- false
		}
		
		draw_scope.secho_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, secho_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_deagle" && wpnInst.GetOwner() == ply)
			{
				draw_scope.secho_owned = true;
				break;
			}
		}
		if (ply.GetHealth() < 1) draw_scope.secho_owned = false;
		if (draw_scope.secho_owned == false) draw_scope.secho_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != secho_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("secho_FD") )
		{
			draw_scope.secho_FD <- false
			draw_scope.secho_owned <- false
		}
		
		if (draw_scope.secho_FD == false)
		{
			vm.__KeyValueFromInt("sequence", secho_sequence)
			draw_scope.secho_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:secho_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:secho_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}
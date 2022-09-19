kilo433_MDL <- "models/weapons/v_ar_kilo141.mdl"
kilo433_sequence <- 7

function kilo433_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("kilo433_owned"))
		{
			draw_scope.kilo433_FD <- false
			draw_scope.kilo433_owned <- false
		}
		
		draw_scope.kilo433_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, kilo433_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_deagle" && wpnInst.GetOwner() == ply)
			{
				draw_scope.kilo433_owned = true;
				break;
			}
		}
		if (ply.GetHealth() < 1) draw_scope.kilo433_owned = false;
		if (draw_scope.kilo433_owned == false) draw_scope.kilo433_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != kilo433_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("kilo433_FD") )
		{
			draw_scope.kilo433_FD <- false
			draw_scope.kilo433_owned <- false
		}
		
		if (draw_scope.kilo433_FD == false)
		{
			vm.__KeyValueFromInt("sequence", kilo433_sequence)
			draw_scope.kilo433_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:kilo433_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:kilo433_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}
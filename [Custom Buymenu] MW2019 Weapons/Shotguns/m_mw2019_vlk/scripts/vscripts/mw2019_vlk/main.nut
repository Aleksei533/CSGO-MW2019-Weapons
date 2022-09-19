mike26_MDL <- "models/weapons/v_sh_vlkrogue.mdl"
mike26_sequence <- 7

function mike26_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("mike26_owned"))
		{
			draw_scope.mike26_FD <- false
			draw_scope.mike26_owned <- false
		}
		
		draw_scope.mike26_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, mike26_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_deagle" && wpnInst.GetOwner() == ply)
			{
				draw_scope.mike26_owned = true;
				break;
			}
		}
		if (ply.GetHealth() < 1) draw_scope.mike26_owned = false;
		if (draw_scope.mike26_owned == false) draw_scope.mike26_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != mike26_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("mike26_FD") )
		{
			draw_scope.mike26_FD <- false
			draw_scope.mike26_owned <- false
		}
		
		if (draw_scope.mike26_FD == false)
		{
			vm.__KeyValueFromInt("sequence", mike26_sequence)
			draw_scope.mike26_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:mike26_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:mike26_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}
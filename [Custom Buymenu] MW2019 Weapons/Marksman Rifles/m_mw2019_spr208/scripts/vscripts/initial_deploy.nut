// -----------------------------------------------------
// Simple initial deploy VScript made by CrazySlavModder
// -----------------------------------------------------

::migi_initDeployWeapons <- [];
::MIGI_InitDeployWeapon <- class
{
	weaponMDL = null;
	weaponClass = null;
	weaponSequence = [];
	weaponEmptyCheckFunc = null;
	weaponCustomCheckFunc = null;
	
	constructor(weaponMDL, weaponClass, weaponSequence, weaponEmptyCheckFunc, weaponCustomCheckFunc)
	{
		this.weaponMDL = weaponMDL;
		this.weaponClass = weaponClass;
		this.weaponSequence = weaponSequence;
		this.weaponEmptyCheckFunc = weaponEmptyCheckFunc;
		this.weaponCustomCheckFunc = weaponCustomCheckFunc;
		
		migi_initDeployWeapons.append(this);
	}
}

::MIGI_InitDeploy_GetWpnIndex <- function(wpnVMDL, wpnClass = null)
{
	local curIndex = 0;
	foreach(x in migi_initDeployWeapons)
	{
		if (wpnVMDL == x.weaponMDL)
		{
			if (wpnClass == null || (x.weaponClass != null && wpnClass == x.weaponClass))
				return curIndex;
		}
		curIndex++;
	}
	return -1;
}

function MIGI_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("plyOwnedWpn"))
		{
			draw_scope.plyWeapon_FD <- []
			draw_scope.plyOwnedWpn <- []
			foreach(wpn in migi_initDeployWeapons)
			{
				draw_scope.plyWeapon_FD.push(false);
				draw_scope.plyOwnedWpn.push(false);
			}
		}
		
		local weaponVMDL = vm.GetModelName();
		for(local i = 0; i < migi_initDeployWeapons.len(); i++)
		{
			local curWpn = migi_initDeployWeapons[i];
			if (curWpn == null) continue;
			
			draw_scope.plyOwnedWpn[i] = false;
			local wpnInst = null;
			while (wpnInst = Entities.FindByModel(wpnInst, curWpn.weaponMDL))
			{
				if (wpnInst.GetClassname() == curWpn.weaponClass && wpnInst.GetOwner() == ply)
				{
					draw_scope.plyOwnedWpn[i] = true;
					break;
				}
			}
			
			if (ply.GetHealth() < 1) draw_scope.plyOwnedWpn[i] = false;
			if (draw_scope.plyOwnedWpn[i] == false) draw_scope.plyWeapon_FD[i] = false
			
			// Skip if it isn't the weapon we're looking for
			if(weaponVMDL != curWpn.weaponMDL || curWpn.weaponSequence.len() < 1)
				continue
				
			if(curWpn.weaponCustomCheckFunc != null)
			{
				curWpn.weaponCustomCheckFunc(vm);
				continue;
			}
			
			local curSequenceIndex = 0;
			if (draw_scope.plyWeapon_FD[i] == false)
			{
				draw_scope.plyWeapon_FD[i] = true
				if (curWpn.weaponEmptyCheckFunc != null && curWpn.weaponEmptyCheckFunc(vm) == true) continue;
				
				if (curWpn.weaponSequence.len() > 1) curSequenceIndex = RandomInt(0, curWpn.weaponSequence.len()-1);
				vm.__KeyValueFromInt("sequence", curWpn.weaponSequence[curSequenceIndex])
			}
		}
	}
}

deployTimerEnt <- Entities.FindByName(null, "MIGIdeployTimer")
if (deployTimerEnt == null)
{
	MIGI_deploy_timer <- Entities.CreateByClassname("logic_timer")
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "targetname MIGIdeployTimer", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "RefireTime 0.01", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "classname move_rope", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:MIGI_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
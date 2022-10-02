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
	
	constructor(weaponMDL, weaponClass, weaponSequence, weaponCustomCheckFunc, weaponEmptyCheckFunc)
	{
		this.weaponMDL = weaponMDL;
		this.weaponClass = weaponClass;
		this.weaponSequence = weaponSequence;
		this.weaponCustomCheckFunc = weaponCustomCheckFunc;
		this.weaponEmptyCheckFunc = weaponEmptyCheckFunc;
		
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

function MIGI_BasicDeployCheck(vm)
{
	local owner = vm.GetMoveParent();
	if (!owner || !owner.IsValid() || owner.GetHealth() < 1) 
		return;
	
	local curSequenceIndex = 0;
	local VMDL = vm.GetModelName();
	local curWpnIndex = MIGI_InitDeploy_GetWpnIndex(VMDL);
	if (curWpnIndex < 0) return;
	
	local curWpn = migi_initDeployWeapons[curWpnIndex];
	if (curWpn == null || VMDL != curWpn.weaponMDL) return;
	
	owner.ValidateScriptScope();
	local draw_scope = owner.GetScriptScope();
	if (draw_scope.plyWeapon_FD[curWpnIndex] == false)
	{
		draw_scope.plyWeapon_FD[curWpnIndex] = true;
		if (curWpn.weaponEmptyCheckFunc != null && curWpn.weaponEmptyCheckFunc(vm) == true) return;
		
		if (curWpn.weaponSequence.len() > 1) curSequenceIndex = RandomInt(0, curWpn.weaponSequence.len()-1);
		vm.__KeyValueFromInt("sequence", curWpn.weaponSequence[curSequenceIndex])
	}
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
			
			// Skip if it doesn't need any check
			if(curWpn.weaponSequence == null || curWpn.weaponSequence.len() < 1 || curWpn.weaponCustomCheckFunc == null)
				continue
			
			// let the different viewmodels call their own check functions
			if (curWpn.weaponCustomCheckFunc == "basic") MIGI_BasicDeployCheck(vm);
			else curWpn.weaponCustomCheckFunc(vm);
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
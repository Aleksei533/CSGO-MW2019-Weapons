if (!("migi_initDeployWeapons" in this))
	migi_allocateEntityScope("initial_deploy.nut")

function decho_dual_GetAmmoState(vm)
{
	local ammo_track = vm.LookupAttachment("a_flag");
	local ammo_track_start = vm.LookupAttachment("a_flag_start");
	local ammo_track_state = "full";
		
    local org = vm.GetAttachmentOrigin(ammo_track) - vm.GetOrigin();
    local org_base = vm.GetAttachmentOrigin(ammo_track_start) - vm.GetOrigin();
	local org_dist = org - org_base;
	if (org_dist.z > 0.8 && org_dist.z < 1.2) ammo_track_state = "empty";
	
	return ammo_track_state;
}

MIGI_InitDeployWeapon("models/weapons/v_pi_50gs_akimbo.mdl", "weapon_elite", [6], "basic", this.decho_dual_GetAmmoState)
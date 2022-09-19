MW2019serverName <- self.GetName();

function MW2019_SemTex_Kaboom()
{
	local MW2019_SemTex_exp = Entities.CreateByClassname("env_explosion")
	MW2019_SemTex_exp.__KeyValueFromInt("spawnflags", 2 + 4 + 64 + 256 + 512)
	MW2019_SemTex_exp.__KeyValueFromFloat("iMagnitude", 600)
	MW2019_SemTex_exp.__KeyValueFromFloat("iRadiusOverride", 300)
	MW2019_SemTex_exp.SetOrigin(self.GetOrigin());
	EntFireByHandle(MW2019_SemTex_exp, "AddOutput", "classname weapon_tagrenade", 0, null, null)
	MW2019_SemTex_exp.EmitSound("Equipment_SemTex.Explode")
	DispatchParticleEffect("explosion_basic", self.GetOrigin(), Vector(0,0,0))
	EntFireByHandle(MW2019_SemTex_exp, "Explode", "", 0, null, null)
	EntFireByHandle(self, "Kill", "", 0.01, null, null)
	EntFireByHandle(MW2019_SemTex_exp, "Kill", "", 0.01, null, null)
}

function MW2019_SemTex_Check()
{
	local semtexWpn = null;
	while (semtexWpn = Entities.FindByModel(semtexWpn, "models/weapons/v_eq_tagrenade.mdl"))
	{
		if (semtexWpn.GetClassname() != "weapon_decoy") continue;
		local semtexOwner = semtexWpn.GetOwner();
		if (!semtexOwner) continue;
		
		EntFireByHandle(MW2019_SemTex_Giver, "Use", "", 0, semtexOwner, semtexOwner);
		EntFireByHandle(semtexWpn, "Kill", "", 0, null, null);
	}
	
	local semtexThingy = null;
	while (semtexThingy = Entities.FindByClassname(semtexThingy, "tagrenade_projectile"))
	{
		local semtexThingyUser = null;
		semtexThingy.ValidateScriptScope();
		local semtexScope = semtexThingy.GetScriptScope();
		
		if(!semtexScope.rawin("semtexTrigger"))
		{
			semtexThingy.EmitSound("Equipment_Semtex.Activate");
			semtexScope.semtexKaboom <- MW2019_SemTex_Kaboom;
			semtexScope.semtexTime <- Time();
			semtexScope.semtexTrigger <- false;
		}
		
		if(Time() - semtexScope.semtexTime > 1.99 && semtexScope.semtexTrigger == false)
		{
			semtexScope.semtexTrigger = true;
			semtexThingy.StopSound("Equipment_Semtex.Activate");
			EntFireByHandle(semtexThingy, "RunScriptCode", "semtexKaboom()", 0, null, null);
		}
	}
}

MW2019_SemTex_Timer <- Entities.CreateByClassname("logic_timer")
MW2019_SemTex_Timer.__KeyValueFromFloat("RefireTime", 0.01)
MW2019_SemTex_Timer.__KeyValueFromString("classname", "move_rope")
EntFireByHandle(MW2019_SemTex_Timer, "AddOutput", "OnTimer "+MW2019serverName+":RunScriptCode:MW2019_SemTex_Check():0:-1", 0, null, null)
EntFireByHandle(MW2019_SemTex_Timer, "Enable", "", 0.1, null, null)

MW2019_SemTex_Giver <- Entities.CreateByClassname("game_player_equip")
MW2019_SemTex_Giver.__KeyValueFromString("targetname", "MW2019_SemTex_Giver")
MW2019_SemTex_Giver.__KeyValueFromString("classname", "move_rope");
MW2019_SemTex_Giver.__KeyValueFromInt("spawnflags", 1+4);
MW2019_SemTex_Giver.__KeyValueFromInt("weapon_tagrenade", 0);
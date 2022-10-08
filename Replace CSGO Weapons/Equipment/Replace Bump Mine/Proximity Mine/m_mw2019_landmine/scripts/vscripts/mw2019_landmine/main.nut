MW2019serverName <- self.GetName();

function MW2019_Mine_Kaboom()
{
	local MW2019_Mine_exp = Entities.CreateByClassname("env_explosion")
	MW2019_Mine_exp.__KeyValueFromInt("spawnflags", 2 + 4 + 64 + 256 + 512)
	MW2019_Mine_exp.__KeyValueFromFloat("iMagnitude", 16000)
	MW2019_Mine_exp.__KeyValueFromFloat("iRadiusOverride", 200)
	MW2019_Mine_exp.SetOrigin(self.GetOrigin());
	EntFireByHandle(MW2019_Mine_exp, "AddOutput", "classname weapon_bumpmine", 0, null, null)
	MW2019_Mine_exp.EmitSound("Equipment_Mine.Explode")
	DispatchParticleEffect("explosion_basic", self.GetOrigin(), Vector(0,0,0))
	EntFireByHandle(MW2019_Mine_exp, "Explode", "", 0, null, null)
	EntFireByHandle(self, "Kill", "", 0.01, null, null)
	EntFireByHandle(MW2019_Mine_exp, "Kill", "", 0.01, null, null)
}

function MW2019_Mine_Check()
{
	local mine = null;
	while(mine = Entities.FindByClassname(mine, "bumpmine_projectile"))
	{
		local mineUser = null;
		mine.ValidateScriptScope();
		
		local mineScope = mine.GetScriptScope();
		if(!mineScope.rawin("mineTrigger"))
		{
			mine.SetHealth(500);
			mine.__KeyValueFromInt("solid", 6);
			EntFireByHandle(mine, "AddOutput", "OnHealthChanged self:RunScriptCode:MW2019_Mine_Kaboom():0:-1", 0, null, null);
			mineScope.playerKaboom <- MW2019_Mine_Kaboom;
			mineScope.mineTrigger <- false;
		}
		
		if(mine.GetVelocity().LengthSqr() < 0.01 && mineScope.mineTrigger == false)
		{
			mineUser = Entities.FindByClassnameWithin(mineUser, "player", mine.GetOrigin(), 96);
			if (mineUser == null)
			{
				mineUser = Entities.FindByClassnameWithin(mineUser, "cs_bot", mine.GetOrigin(), 96);
				if (mineUser == null) continue;
			}
			
			mineScope.mineTrigger = true;
			EntFireByHandle(mine, "RunScriptCode", "playerKaboom()", 0, null, null);
		}
	}
}

MW2019_Mine_Timer <- Entities.CreateByClassname("logic_timer")
MW2019_Mine_Timer.__KeyValueFromFloat("RefireTime", 0.01)
MW2019_Mine_Timer.__KeyValueFromString("classname", "move_rope")
EntFireByHandle(MW2019_Mine_Timer, "AddOutput", "OnTimer "+MW2019serverName+":RunScriptCode:MW2019_Mine_Check():0:-1", 0, null, null)
EntFireByHandle(MW2019_Mine_Timer, "Enable", "", 0.1, null, null)
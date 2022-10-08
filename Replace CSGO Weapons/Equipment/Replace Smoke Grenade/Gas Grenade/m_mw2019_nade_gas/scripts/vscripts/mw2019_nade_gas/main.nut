MW2019serverName <- self.GetName();

function MW2019_GasNade_Check()
{
	local gasNade = null;
	while(gasNade = Entities.FindByClassname(gasNade, "smokegrenade_projectile"))
	{
		local gasNadeUser = null;
		gasNade.ValidateScriptScope();
		local gasNadeScope = gasNade.GetScriptScope();
		if(!gasNadeScope.rawin("gasNadeTrigger"))
		{
			gasNadeScope.gasDropTime <- Time();
			gasNadeScope.gasNadeTrigger <- false;
		}
		
		if(gasNade.GetVelocity().LengthSqr() < 0.01)
		{
			if (gasNadeScope.gasNadeTrigger == false)
			{
				gasNadeScope.gasDropTime = Time();
				gasNadeScope.gasNadeTrigger = true;
			}
			if (Time() - gasNadeScope.gasDropTime < 0.49 || Time() - gasNadeScope.gasDropTime > 16.49) continue;
			foreach(gasTarget in ["player", "cs_bot"])
			while(gasNadeUser = Entities.FindByClassnameWithin(gasNadeUser, gasTarget, gasNade.GetOrigin(), 100))
			{
				if (!gasNadeUser || !gasNadeUser.IsValid() || gasNadeUser.GetHealth() < 1) continue;
				local curUserHP = gasNadeUser.GetHealth();
				if (curUserHP > 1) gasNadeUser.SetHealth(curUserHP - 1);
				if (curUserHP == 1)
				{
					local playerKiller = Entities.CreateByClassname("env_explosion")
					playerKiller.__KeyValueFromInt("spawnflags", 2 + 4 + 64 + 256 + 512)
					playerKiller.__KeyValueFromFloat("iMagnitude", 64)
					playerKiller.__KeyValueFromFloat("iRadiusOverride", 32)
					playerKiller.SetOrigin(gasNadeUser.GetOrigin() + Vector(0, 0, 32));
					EntFireByHandle(playerKiller, "Explode", "", 0, null, null)
					EntFireByHandle(playerKiller, "Kill", "", 0.01, null, null)
				}
			}
		}
	}
}

MW2019_GasNade_Timer <- Entities.CreateByClassname("logic_timer")
MW2019_GasNade_Timer.__KeyValueFromFloat("RefireTime", 0.33)
MW2019_GasNade_Timer.__KeyValueFromString("classname", "move_rope")
EntFireByHandle(MW2019_GasNade_Timer, "AddOutput", "OnTimer "+MW2019serverName+":RunScriptCode:MW2019_GasNade_Check():0:-1", 0, null, null)
EntFireByHandle(MW2019_GasNade_Timer, "Enable", "", 0.1, null, null)
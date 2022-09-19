MW2019serverName <- self.GetName();

function MW2019_Claymore_Kaboom()
{
	local MW2019_Claymore_exp = Entities.CreateByClassname("env_explosion")
	MW2019_Claymore_exp.__KeyValueFromInt("spawnflags", 2 + 4 + 64 + 256 + 512)
	MW2019_Claymore_exp.__KeyValueFromFloat("iMagnitude", 4000)
	MW2019_Claymore_exp.__KeyValueFromFloat("iRadiusOverride", 100)
	MW2019_Claymore_exp.SetOrigin(self.GetOrigin());
	EntFireByHandle(MW2019_Claymore_exp, "AddOutput", "classname breachcharge_projectile", 0, null, null)
	MW2019_Claymore_exp.EmitSound("Equipment_Claymore.Explode")
	DispatchParticleEffect("explosion_basic", self.GetOrigin(), Vector(0,0,0))
	EntFireByHandle(MW2019_Claymore_exp, "Explode", "", 0, null, null)
	EntFireByHandle(self, "Kill", "", 0.01, null, null)
	EntFireByHandle(MW2019_Claymore_exp, "Kill", "", 0.01, null, null)
}

function MW2019_Claymore_Check()
{
	local claymore = null;
	while(claymore = Entities.FindByClassname(claymore, "bumpmine_projectile"))
	{
		if (!claymore || !claymore.IsValid()) continue;
		
		local clayVel = claymore.GetVelocity()
		local claymoreUser = null;
		claymore.ValidateScriptScope();
		local claymoreScope = claymore.GetScriptScope();
		if(!claymoreScope.rawin("claymoreOwner"))
		{
			claymoreScope.claymoreVel <- claymore.GetVelocity();
			claymoreScope.claymoreOwner <- Entities.FindByClassnameWithin(null, "player", claymore.GetOrigin(), 128);
			if (claymoreScope.claymoreOwner == null)
				claymoreScope.claymoreOwner <- Entities.FindByClassnameWithin(null, "cs_bot", claymore.GetOrigin(), 128);
		}
		if(claymoreScope.claymoreOwner != null)
			claymore.SetVelocity(Vector(clayVel.x,clayVel.y,-2048));
		
		if(clayVel.x != claymoreScope.claymoreVel.x || clayVel.y != claymoreScope.claymoreVel.y || isGrounded(claymore))
		{
			claymore.SetVelocity(Vector(0,0,0));
			local fakeClaymore = CreateProp("prop_dynamic", claymore.GetOrigin(), "models/weapons/w_eq_bumpmine_dropped.mdl", 0);
			fakeClaymore.__KeyValueFromString("targetname", "claymore_prop");
			fakeClaymore.ValidateScriptScope();
			local fakeScope = fakeClaymore.GetScriptScope()
			fakeScope.claymoreOwner <- claymoreScope.claymoreOwner;
			fakeClaymore.SetHealth(500);
			EntFireByHandle(fakeClaymore, "AddOutput", "OnHealthChanged self:RunScriptCode:MW2019_Claymore_Kaboom():0:-1", 0, null, null);
			fakeScope.playerKaboom <- MW2019_Claymore_Kaboom;
			fakeScope.claymoreTrigger <- false;
			claymore.EmitSound("Equipment_Claymore.Sensors_On")
			claymore.StopSound("Survival.BumpIdle")
			claymore.Destroy()
		}
	}
	
	local claymoreProp = null
	while (claymoreProp = Entities.FindByName(claymoreProp, "claymore_prop"))
	{
		if (claymoreProp.GetModelName() != "models/weapons/w_eq_bumpmine_dropped.mdl") continue;
		
		claymoreProp.ValidateScriptScope();
		local fakeClayScope = claymoreProp.GetScriptScope();
		if (!fakeClayScope.rawin("onGround"))
			fakeClayScope.onGround <- TraceLine(claymoreProp.GetOrigin(), claymoreProp.GetOrigin() + Vector(0,0,-5), claymoreProp) < 1
		
		while (fakeClayScope.onGround == false)
		{
			local curPos = claymoreProp.GetOrigin();
			claymoreProp.SetOrigin(Vector(curPos.x, curPos.y, curPos.z-5));
			if(TraceLine(claymoreProp.GetOrigin(), claymoreProp.GetOrigin() + Vector(0,0,-5), claymoreProp) < 1)
				fakeClayScope.onGround = true;
		}
		if (fakeClayScope.claymoreTrigger == true) continue;
		
		local fakeClaymoreUser = Entities.FindByClassnameWithin(null, "player", claymoreProp.GetOrigin(), 64);
		if (fakeClaymoreUser == fakeClayScope.claymoreOwner) continue;
		if (fakeClaymoreUser == null || fakeClaymoreUser.GetHealth() < 1)
		{
			fakeClaymoreUser = Entities.FindByClassnameWithin(null, "cs_bot", claymoreProp.GetOrigin(), 64);
			if (fakeClaymoreUser == null || fakeClaymoreUser == fakeClayScope.claymoreOwner || fakeClaymoreUser.GetHealth() < 1) continue;
		}
		
		if (fakeClaymoreUser != null && fakeClayScope.claymoreTrigger == false)
		{
			fakeClayScope.claymoreTrigger = true;
			EntFireByHandle(claymoreProp, "RunScriptCode", "playerKaboom()", 0.5, null, null);
		}
	}
}

function isGrounded(ply){return zSquareCheck(ply,-5)}
function zSquareCheck(ply,dist)
{
	local offsets = 
	[
		Vector(0,0,0),
		Vector(0,16,0),
		Vector(0,-16,0),
		
		Vector(-16,0,0),
		Vector(-16,16,0),
		Vector(-16,-16,0),
		
		Vector(16,0,0),
		Vector(16,16,0),
		Vector(16,-16,0),
	]
	
	foreach(o in offsets)
		if(TraceLine(ply.GetOrigin()+o, ply.GetOrigin()+o + Vector(0,0,dist), ply) < 1)
			return true
	return false
}

MW2019_Claymore_Timer <- Entities.CreateByClassname("logic_timer")
MW2019_Claymore_Timer.__KeyValueFromFloat("RefireTime", 0.01)
MW2019_Claymore_Timer.__KeyValueFromString("classname", "move_rope")
EntFireByHandle(MW2019_Claymore_Timer, "AddOutput", "OnTimer "+MW2019serverName+":RunScriptCode:MW2019_Claymore_Check():0:-1", 0, null, null)
EntFireByHandle(MW2019_Claymore_Timer, "Enable", "", 0.1, null, null)
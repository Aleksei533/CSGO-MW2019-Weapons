// --------------------------------------------------
// Projectile & Lunge VScripts created by ZooL Smith
// Edits and additions made by CrazySlavModder
// --------------------------------------------------

::migi_ProjWeapons <- [];
migi_ProjUsers <- [];

migi_ProjectileUser <- class
{
	handle = null
	handle_vm = null
	handle_proj = null
	name = "unknown"
	
	constructor(handle, handle_vm, handle_proj, name)
	{
		this.handle = handle
		this.handle_vm = handle_vm
		this.handle_proj = handle_proj
		this.name = name
	}
}

projUser_current <- null
projUser_process <- 0
projectile_RefireTime <- 0.01

::MIGI_Projectile <- class
{
	timeout = null
	refireDelay = null
	movespeed = null
	iconname = null
	magnitude = null
	radius = null
	MDLscale = null
	inaccuracy_air = null
	inaccuracy_crouch = null
	inaccuracy_move = null
	inaccuracy_stand = null
	lunge_rangeMax = null
	lunge_rangeMin = null
	lunge_upFix = null
	lunge_speed = null
	lunge_upangoffset = null
	gravity = null
	timedDetonation = null
	projectileName = null
	projectileClass = null
	projectileModel = null
	projectileVMDL = null
	projectileExpSound = null
	readyToFireFunc = null
	
	constructor(timeout, refireDelay, movespeed, iconname, magnitude, radius, MDLscale, inaccuracy_air, inaccuracy_crouch, inaccuracy_move,
	inaccuracy_stand, lunge_rangeMax, lunge_rangeMin, lunge_upFix, lunge_speed, lunge_upangoffset, gravity, timedDetonation, 
	projectileName, projectileClass, projectileModel, projectileVMDL, projectileExpSound, readyToFireFunc)
	{
		this.timeout = timeout;
		if (refireDelay == null || refireDelay <= 0.00)
			this.refireDelay = 0.0;
		else this.refireDelay = refireDelay;
		
		if (movespeed == null || movespeed <= 0.00)
			this.movespeed = 0.0;
		else this.movespeed = movespeed;
		
		this.iconname = iconname;
		if (magnitude == null || magnitude <= 0.00)
			this.magnitude = 0.0;
		else this.magnitude = magnitude;
		
		if (radius == null || radius <= 0.00)
			this.radius = 0.0;
		else this.radius = radius;
		
		if (MDLscale == null || MDLscale <= 0.00)
			this.MDLscale = 1.0;
		else this.MDLscale = MDLscale;
		
		this.inaccuracy_air = inaccuracy_air;
		this.inaccuracy_crouch = inaccuracy_crouch;
		this.inaccuracy_move = inaccuracy_move;
		this.inaccuracy_stand = inaccuracy_stand;
		this.lunge_rangeMax = lunge_rangeMax;
		this.lunge_rangeMin = lunge_rangeMin;
		this.lunge_upFix = lunge_upFix;
		this.lunge_speed = lunge_speed;
		this.lunge_upangoffset = lunge_upangoffset;
		
		if (gravity == null || gravity <= 0.00)
			this.gravity = 0.0;
		else this.gravity = gravity;
		
		if (timedDetonation == null)
		this.timedDetonation = false;
			else this.timedDetonation = timedDetonation;
		
		this.projectileClass = projectileClass;
		if (projectileClass == "molotov_projectile")
			this.projectileName = "migi_MolotovProj_" + projectileName;
		else if (projectileClass == "prop_dynamic")
			this.projectileName = "migi_RPGproj_" + projectileName;
		else if (projectileClass == "lunge")
			this.projectileName = "migi_Lunge_" + projectileName;
		else this.projectileName = projectileName;
			
		this.projectileModel = projectileModel;
		this.projectileVMDL = projectileVMDL;
		this.projectileExpSound = projectileExpSound;
		this.readyToFireFunc = readyToFireFunc;
		
		migi_ProjWeapons.append(this);
	}
}

function MIGI_ProjectileCheck()
{
	local glitchedProjUser = Entities.FindByName(null, "migi_projUser")
	if(glitchedProjUser) 
		glitchedProjUser.__KeyValueFromString("targetname", "")
	
	local projectileHandle = projUser_current.handle
	local projectileHandleVM = projUser_current.handle_vm
	local projectileThing = projUser_current.handle_proj
	local projUserOldTargetname = projUser_current.name
	
	if( projectileHandle == null || !projectileHandle.IsValid() || projectileHandle.GetHealth() < 1 || projectileThing == null || projectileThing.projectileClass == "lunge")
		return
	
	local dir = proj_lmm.GetForwardVector()
	local ang = proj_lmm.GetAngles()
	projectileHandle.__KeyValueFromString("targetname", projUserOldTargetname == "migi_projUser" ? "" : projUserOldTargetname)
	
	local projectileEnt = CreateProp("prop_dynamic", projectileHandle.EyePosition(), projectileThing.projectileModel, 0)
	projectileEnt.__KeyValueFromString("targetname", projectileThing.projectileName)
	projectileEnt.__KeyValueFromFloat("modelscale", projectileThing.MDLscale)
	projectileEnt.SetAngles( ang.x, ang.y, ang.z )
	projectileEnt.SetOwner(projectileHandle)
	EntFireByHandle(projectileEnt, "SetAnimationNoReset", "idle", 0, null, null)
	
	projectileEnt.ValidateScriptScope()
	local scope = projectileEnt.GetScriptScope()
	local actualDir = null
	
	if( TraceLinePlayersIncluded(projectileHandle.GetOrigin(), projectileHandle.GetOrigin() - Vector(0,0,16), projectileHandle) == 1.0 &&
		projectileHandle.GetVelocity().z != 0) 																								/* In the air */
	{
		actualDir = getInaccurateDir( dir, projectileThing.inaccuracy_air )
	}
	else if( projectileHandle.GetVelocity().Length() > 20 )																					 /* Moving */
	{
		local inacc = projectileThing.inaccuracy_stand + projectileThing.inaccuracy_move * (projectileHandle.GetVelocity().Length() / 250)
		actualDir = getInaccurateDir( dir, inacc )
	}
	else if( isCrouching( projectileHandle ) )																								/* Crouching */
	{
		actualDir = getInaccurateDir( dir, projectileThing.inaccuracy_crouch )
	}
	else																																	/* Standing */
	{		
		actualDir = getInaccurateDir( dir, projectileThing.inaccuracy_stand )
	}
	
	scope.dir <- actualDir
	scope.movespeed <- projectileThing.movespeed
	scope.iconname <- projectileThing.iconname
	scope.magnitude <- projectileThing.magnitude
	scope.radius <- projectileThing.radius
	scope.boomsound <- projectileThing.projectileExpSound
	scope.projClass <- projectileThing.projectileClass
	scope.ticks <- 0
	scope.gravity <- projectileThing.gravity
	scope.isTimedDetonation <- projectileThing.timedDetonation
	scope.detonationStart <- Time()
	scope.thinkRPG <- function()
	{		
		if (projClass != "prop_dynamic") return;
		
		local owner = self.GetOwner()
		local nextPos = self.GetOrigin() + ( dir * movespeed * 0.01 ) + ( Vector(0,0,-1) * gravity * 0.01 ) * (ticks*0.01)
		local hitfrac = TraceLinePlayersIncluded(self.GetOrigin(), nextPos, owner)
		local hit = hitfrac < 1.0
		if(isTimedDetonation == true) hit = (hitfrac < 1.0) || (Time() - detonationStart > timeout - 0.01)
		
		if(hit)
		{
			local projExp = Entities.CreateByClassname("env_explosion")
			projExp.SetOrigin( self.GetOrigin() )
			projExp.__KeyValueFromInt("spawnflags", 2 + 4 + 64 + 256 + 512)
			projExp.__KeyValueFromInt("iMagnitude", magnitude)
			projExp.__KeyValueFromInt("iRadiusOverride", radius)
			EntFireByHandle( projExp, "AddOutput", "classname " + iconname, 0, null, null )
			projExp.SetOwner( owner )
			EntFireByHandle( projExp, "Explode", "", 0, null, null )
			EntFireByHandle( projExp, "Kill", "", 0.01, null, null )
			
			if (boomsound != null)
			self.EmitSound(boomsound)
			
			DispatchParticleEffect( "explosion_basic", self.GetOrigin(), Vector(0,0,0) )
			
			EntFireByHandle(self, "Kill", "", 0, null, null)
			return
		}
		
		self.SetOrigin( nextPos )
		ticks++
	}
	//if (projectileThing.timedDetonation == false)
	EntFireByHandle(projectileEnt, "Kill", "", projectileThing.timeout, null, null)
}

function MIGI_MolotovCheck()
{
	local glitchedProjUser = Entities.FindByName(null, "migi_projUser")
	if(glitchedProjUser) 
		glitchedProjUser.__KeyValueFromString("targetname", "")
	
	local projectileHandle = projUser_current.handle
	local projectileHandleVM = projUser_current.handle_vm
	local projectileThing = projUser_current.handle_proj
	local projUserOldTargetname = projUser_current.name
	
	if( projectileHandle == null || !projectileHandle.IsValid() || projectileHandle.GetHealth() < 1 || projectileThing == null || projectileThing.projectileClass == "lunge" )
		return
	
	local dir = proj_lmm.GetForwardVector()
	local ang = proj_lmm.GetAngles()
	projectileHandle.__KeyValueFromString("targetname", projUserOldTargetname == "migi_projUser" ? "" : projUserOldTargetname)
	
	local projectileEnt = CreateProp("molotov_projectile", projectileHandle.EyePosition(), projectileThing.projectileModel, 0)
	projectileEnt.__KeyValueFromString("targetname", projectileThing.projectileName)
	projectileEnt.__KeyValueFromFloat("modelscale", projectileThing.MDLscale)
	projectileEnt.SetAngles( ang.x, ang.y, ang.z )
	projectileEnt.SetOwner(projectileHandle)
	EntFireByHandle(projectileEnt, "InitializeSpawnFromWorld", "", 0, null, null)
	EntFireByHandle(projectileEnt, "SetAnimationNoReset", "idle", 0, null, null)
	
	projectileEnt.ValidateScriptScope()
	local scope = projectileEnt.GetScriptScope()
	local actualDir = null
	
	if( TraceLinePlayersIncluded(projectileHandle.GetOrigin(), projectileHandle.GetOrigin() - Vector(0,0,16), projectileHandle) == 1.0 &&
		projectileHandle.GetVelocity().z != 0) 																								/* In the air */
	{
		actualDir = getInaccurateDir( dir, projectileThing.inaccuracy_air )
	}
	else if( projectileHandle.GetVelocity().Length() > 20 )																					 /* Moving */
	{
		local inacc = projectileThing.inaccuracy_stand + projectileThing.inaccuracy_move * (projectileHandle.GetVelocity().Length() / 250)
		actualDir = getInaccurateDir( dir, inacc )
	}
	else if( isCrouching( projectileHandle ) )																								/* Crouching */
	{
		actualDir = getInaccurateDir( dir, projectileThing.inaccuracy_crouch )
	}
	else																																	/* Standing */
	{		
		actualDir = getInaccurateDir( dir, projectileThing.inaccuracy_stand )
	}
	
	scope.dir <- actualDir
	scope.movespeed <- projectileThing.movespeed
	scope.iconname <- projectileThing.iconname
	scope.magnitude <- projectileThing.magnitude
	scope.radius <- projectileThing.radius
	scope.boomsound <- projectileThing.projectileExpSound
	scope.projClass <- projectileThing.projectileClass
	scope.ticks <- 0
	scope.gravity <- projectileThing.gravity
	scope.isTimedDetonation <- projectileThing.timedDetonation
	scope.detonationStart <- Time()
	scope.thinkMolotov <- function()
	{		
		if (projClass != "molotov_projectile") return;
		
		local owner = self.GetOwner()
		local nextPos = self.GetOrigin() + ( dir * movespeed * 0.01 ) + ( Vector(0,0,-1) * gravity * 0.01 ) * (ticks*0.01)
		local hitfrac = TraceLinePlayersIncluded(self.GetOrigin(), nextPos, owner)
		local hit = hitfrac < 1.0
		
		if(hit)
		{
			EntFireByHandle( self, "AddOutput", "classname " + iconname, 0, null, null )
			self.SetOwner( owner )
			EntFireByHandle( self, "AddOutput", "rendermode 10", 0, null, null )
			return
		}
		
		self.SetOrigin( nextPos )
		ticks++
	}
	
	//if (projectileThing.timedDetonation == false)
	EntFireByHandle(projectileEnt, "Kill", "", projectileThing.timeout, null, null)
}

function MIGI_LungeCheck()
{
	local glitchedProjUser = Entities.FindByName(null, "migi_projUser")
	if(glitchedProjUser) 
		glitchedProjUser.__KeyValueFromString("targetname", "")
	
	local projectileHandle = projUser_current.handle
	local projectileHandleVM = projUser_current.handle_vm
	local projectileThing = projUser_current.handle_proj
	local projUserOldTargetname = projUser_current.name
	
	if( projectileHandle == null || !projectileHandle.IsValid() || projectileHandle.GetHealth() < 1 )
		return
	
	local dir = proj_lmm.GetForwardVector()
	local ang = proj_lmm.GetAngles()
	projectileHandle.__KeyValueFromString("targetname", projUserOldTargetname == "migi_projUser" ? "" : projUserOldTargetname)
	
	local frac = TraceLinePlayersIncluded(projectileHandle.EyePosition(), projectileHandle.EyePosition() + dir*projectileThing.lunge_rangeMax, projectileHandle)
	local target = null
	foreach(c in ["player", "cs_bot"])
	{
		local tmp = null
		while(tmp = Entities.FindByClassnameWithin(tmp, c, projectileHandle.EyePosition() + (dir*projectileThing.lunge_rangeMax)*frac, 32))
		{
			if( tmp == null || !tmp.IsValid() || tmp.GetHealth() < 1 )
				continue
			
			target = tmp
			break
		}
		if(target) break
	}
	
	if( !target )
		return
	
	local lungeDist = (target.GetOrigin() - projectileHandle.GetOrigin()).Length()
	if(lungeDist < projectileThing.lunge_rangeMin)
		return
	
	// Lunge
	local lungeDir = target.EyePosition() - projectileHandle.EyePosition() + Vector(0,0,projectileThing.lunge_upangoffset)
	lungeDir.Norm()
	
	if(!zTraceTest(projectileHandle, 72+projectileThing.lunge_upFix) && zTraceTest(projectileHandle, -projectileThing.lunge_upFix))
		projectileHandle.SetOrigin(projectileHandle.GetOrigin()+Vector(0,0,projectileThing.lunge_upFix)) // TP me up a bit so Vel doesn't break
	
	projectileHandle.SetVelocity(lungeDir * projectileThing.lunge_speed * ((lungeDist/projectileThing.lunge_rangeMax)+0.2))
	if (projectileThing.projectileExpSound != null)
		projectileHandle.EmitSound( projectileThing.projectileExpSound )
	return;
}

function getInaccurateDir( dir, inacc )
{
	if (inacc == null || inacc == 0.00) return dir;
	
	local inaccurateDir = dir
	inaccurateDir += Vector(RandomFloat(-inacc,inacc),RandomFloat(-inacc,inacc),RandomFloat(-inacc,inacc))*0.0009
	inaccurateDir.Norm()
	return inaccurateDir
}

function isCrouching( ply )
{
	return (ply.EyePosition() - ply.GetOrigin()).z < 63
}

function MIGI_ProjectileWpnCheck()
{
	EntFire("migi_MolotovProj_*", "RunScriptCode", "thinkMolotov()")
	EntFire("migi_RPGproj_*", "RunScriptCode", "thinkRPG()")
	
	if( migi_ProjUsers.len() || projUser_process != 0 )
	{
		projUser_process += 0.01
		if(projUser_process > 0.02)
			projUser_process = 0
	}
	
	if( migi_ProjUsers.len() && !projUser_process )
	{
		projUser_current = migi_ProjUsers.pop()
		projUser_current.handle.__KeyValueFromString("targetname", "migi_projUser")
		EntFireByHandle(proj_lmm, "SetMeasureTarget", "migi_projUser", 0, null, null)
		
		if (projUser_current.handle_proj.projectileClass == "prop_dynamic")
			EntFireByHandle(proj_lmm, "FireUser1", "", 0.01, null, null)
		else if (projUser_current.handle_proj.projectileClass == "molotov_projectile")
			EntFireByHandle(proj_lmm, "FireUser2", "", 0.01, null, null)
		else if (projUser_current.handle_proj.projectileClass == "lunge")
			EntFireByHandle(proj_lmm, "FireUser3", "", 0.01, null, null)
	}
	
	local vm = null
	foreach(projVMDL in migi_ProjWeapons)
	{
		if (projVMDL == null) continue;
		while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
		{
			if(vm.GetModelName() != projVMDL.projectileVMDL || projVMDL.projectileVMDL == null || projVMDL.readyToFireFunc == null)
				continue
			
			local ply = vm.GetMoveParent()
			if(!ply || !ply.IsValid() || ply.GetHealth() < 1)
				continue
			
			if (projVMDL.projectileModel != null)
				ply.PrecacheModel(projVMDL.projectileModel)
			
			if( projVMDL.readyToFireFunc(vm) == true )
			{
				vm.ValidateScriptScope()
				local scope = vm.GetScriptScope()
				if( !scope.rawin("projectile_lastFire") )
					scope.projectile_lastFire <- 0
				
				if( scope.projectile_lastFire < Time() - projVMDL.refireDelay )
				{
					scope.projectile_lastFire = Time()
					migi_ProjUsers.push( migi_ProjectileUser(ply, vm, projVMDL, ply.GetName()) )
				}
			}
		}
	}
}

function zTraceTest(ply,dist)
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
		if(TraceLinePlayersIncluded(ply.GetOrigin()+o, ply.GetOrigin()+o + Vector(0,0,dist), ply) < 1)
			return true
	
	return false
}

proj_lmm <- Entities.FindByName(null, "migi_proj_lmm")
if (proj_lmm == null)
{
	proj_lmm <- Entities.CreateByClassname("logic_measure_movement")
	EntFireByHandle(proj_lmm, "AddOutput", "targetname migi_proj_lmm", 0, null, null)
	EntFireByHandle(proj_lmm, "AddOutput", "classname move_rope", 0, null, null)
	EntFireByHandle(proj_lmm, "AddOutput", "MeasureType 1", 0, null, null)
	EntFireByHandle(proj_lmm, "SetMeasureReference", "migi_proj_lmm", 0, null, null)
	EntFireByHandle(proj_lmm, "SetTargetReference", "migi_proj_lmm", 0, null, null)
	EntFireByHandle(proj_lmm, "SetMeasureTarget", "migi_projUser", 0, null, null)
	EntFireByHandle(proj_lmm, "SetTarget", "migi_proj_lmm", 0, null, null)
	EntFireByHandle(proj_lmm, "SetTargetScale", "1", 0, null, null)
	EntFireByHandle(proj_lmm, "AddOutput", "OnUser1 "+self.GetName()+":RunScriptCode:MIGI_ProjectileCheck():0:-1", 0, null, null)
	EntFireByHandle(proj_lmm, "AddOutput", "OnUser2 "+self.GetName()+":RunScriptCode:MIGI_MolotovCheck():0:-1", 0, null, null)
	EntFireByHandle(proj_lmm, "AddOutput", "OnUser3 "+self.GetName()+":RunScriptCode:MIGI_LungeCheck():0:-1", 0, null, null)
	EntFireByHandle(proj_lmm, "Enable", "", 0.01, null, null)
}

proj_timer <- Entities.FindByName(null, "migi_projTimer")
if (proj_timer == null)
{
	proj_timer <- Entities.CreateByClassname("logic_timer")
	EntFireByHandle(proj_timer, "AddOutput", "targetname migi_projTimer", 0, null, null)
	EntFireByHandle(proj_timer, "AddOutput", "RefireTime " + projectile_RefireTime, 0, null, null)
	EntFireByHandle(proj_timer, "AddOutput", "classname move_rope", 0, null, null)
	EntFireByHandle(proj_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:MIGI_ProjectileWpnCheck():0:-1", 0, null, null)
	EntFireByHandle(proj_timer, "Enable", "", 0.1, null, null)
}

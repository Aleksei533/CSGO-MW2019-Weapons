gromeo_MDL <- "models/weapons/v_la_pila.mdl"
gromeo_sequence <- 3

function gromeo_deployCheck()
{
	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		local ply = vm.GetMoveParent()
		if (!ply || !ply.IsValid()) continue;
		
		ply.ValidateScriptScope();
		local draw_scope = ply.GetScriptScope();
		if(!draw_scope.rawin("gromeo_owned"))
		{
			draw_scope.gromeo_FD <- false
			draw_scope.gromeo_owned <- false
		}
		draw_scope.gromeo_owned = false;
		local wpnInst = null;
		while (wpnInst = Entities.FindByModel(wpnInst, gromeo_MDL))
		{
			if (wpnInst.GetClassname() == "weapon_ump45" && wpnInst.GetOwner() == ply)
			{
				draw_scope.gromeo_owned = true;
				break;
			}
		}
		if (ply.GetHealth() < 1) draw_scope.gromeo_owned = false;
		if (draw_scope.gromeo_owned == false) draw_scope.gromeo_FD = false
		
		// Not the weapon we're looking for
		if(vm.GetModelName() != gromeo_MDL)
			continue
		
		// initial deploy check
		ply.ValidateScriptScope()
		local draw_scope = ply.GetScriptScope()
		if( !draw_scope.rawin("gromeo_FD") )
		{
			draw_scope.gromeo_FD <- false
			draw_scope.gromeo_owned <- false
		}
		if (draw_scope.gromeo_FD == false)
		{
			vm.__KeyValueFromInt("sequence", gromeo_sequence)
			draw_scope.gromeo_FD = true
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
	EntFireByHandle(MIGI_deploy_timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:gromeo_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(MIGI_deploy_timer, "Enable", "", 0.1, null, null)
}
else
{
	EntFireByHandle(deployTimerEnt, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:gromeo_deployCheck():0:-1", 0, null, null)
	EntFireByHandle(deployTimerEnt, "Enable", "", 0.1, null, null)
}

// ah yes, the holy graal of how projectile-based weapons are made
timeout <- 10
refireDelay <- 0.9
tickstep <- 0.01 // FrameTime()
tickrate <- 0.01 // FrameTime()
movespeed <- 2100
gravity <- 700

exp_iconname <- "weapon_pila"
exp_magnitude <- 1050
exp_radius <- 350

wpn_inaccuracy_air <- 60.0
wpn_inaccuracy_crouch <- 2.0
wpn_inaccuracy_stand <- 10.0
wpn_inaccuracy_move <- 90.0


projectileModel <- "models/weapons/w_la_pila_rocket.mdl"
self.PrecacheModel( projectileModel )

function VM_RPGGetAnim(vm)
{
	local anim_track = vm.LookupAttachment("a_flag");
	local anim_track_start = vm.LookupAttachment("a_flag_start");
	local tracked_anim = "none";
		
    local org = vm.GetAttachmentOrigin(anim_track) - vm.GetOrigin();
    local org_base = vm.GetAttachmentOrigin(anim_track_start) - vm.GetOrigin();
	local org_dist = org - org_base;
	if (org_dist.z > 0.8 && org_dist.z < 1.2) tracked_anim = "fire";
	
	return tracked_anim;
}

function fireRocket()
{
	local rocketmanHandle = rocketman_current.handle
	local rocketmanOldTargetname = rocketman_current.name
	
	if( rocketmanHandle == null || !rocketmanHandle.IsValid() || rocketmanHandle.GetHealth() < 1 )
		return
	
	// Get the info then lose the information + restore player targetname
	local dir = lmm.GetForwardVector()
	local ang = lmm.GetAngles()
	rocketmanHandle.__KeyValueFromString("targetname", rocketmanOldTargetname)
	
	// DebugDrawLine(rocketmanHandle.EyePosition() + dir, rocketmanHandle.EyePosition() + dir*1000, 255, 0, 255, false, 10)

	// Build a rocket
	local rocket = CreateProp("prop_dynamic", rocketmanHandle.EyePosition(), projectileModel, 0)
	rocket.__KeyValueFromString("targetname", "PILA_rocket")
	rocket.__KeyValueFromFloat("modelscale", 1.5)
	rocket.SetAngles( ang.x, ang.y, ang.z )
	rocket.SetOwner(rocketmanHandle)
	rocket.EmitSound( "Weapon_PILA.Travel" )
	
	EntFireByHandle(rocket, "SetAnimationNoReset", "idle", 0, null, null)
	
	// Add a VScript scope
	rocket.ValidateScriptScope()
	local scope = rocket.GetScriptScope()
	
	// Inaccuracy
	local actualDir = null

	if( TraceLinePlayersIncluded(rocketmanHandle.GetOrigin(), rocketmanHandle.GetOrigin() - Vector(0,0,16), rocketmanHandle) == 1.0 &&
		rocketmanHandle.GetVelocity().z != 0) 																								/* In the air */
	{
		actualDir = getInaccurateDir( dir, wpn_inaccuracy_air )
	}
	else if( rocketmanHandle.GetVelocity().Length() > 20 )																					 /* Moving */
	{
		local inacc = wpn_inaccuracy_stand + wpn_inaccuracy_move * (rocketmanHandle.GetVelocity().Length() / 250)
		actualDir = getInaccurateDir( dir, inacc )
	}
	else if( isCrouching( rocketmanHandle ) )																								/* Crouching */
	{
		actualDir = getInaccurateDir( dir, wpn_inaccuracy_crouch )
	}
	else																																	/* Standing */
	{		
		actualDir = getInaccurateDir( dir, wpn_inaccuracy_stand )
	}

	// Assign default vars
	scope.dir <- actualDir
	scope.script <- this // keep this main scope for config vars
	scope.ticks <- 0 // used for gravity speed
	scope.movetime <- Time()
	
	// Create think function
	scope.think <- function()
	{		
		local owner = self.GetOwner()
		
		// Get time since last loop -> use in nextPos
		local movetimeDelta = Time() - movetime
		movetime = Time()
		
		// Next position, takes into account the tickrate, moves toward what the lmm was at when it got created, also applies fake gravity
		local nextPos = self.GetOrigin() + ( dir * script.movespeed * movetimeDelta ) + ( Vector(0,0,-1) * script.gravity * script.tickrate ) * (ticks*script.tickrate)
		
		// 1.0 when reached destination without obstacles, less if hit something.
		// boolean to if it has hit
		local hitfrac = TraceLinePlayersIncluded(self.GetOrigin(), nextPos, owner)
		local hit = hitfrac < 1.0
		
		if(hit)
		{
			// Actual explosion
			script.exp.SetOrigin( self.GetOrigin() )
			EntFireByHandle( script.exp, "AddOutput", "classname " + script.exp_iconname, 0, null, null )
			script.exp.SetOwner( owner )
			EntFireByHandle( script.exp, "Explode", "", 0, null, null )
			EntFireByHandle( script.exp, "AddOutput", "classname move_rope", 0, null, null )

			// Effects
			self.StopSound( "Weapon_PILA.Travel" )
			self.EmitSound("MW2019_Rocket.Explode")	
			DispatchParticleEffect( "explosion_basic", self.GetOrigin(), Vector(0,0,0) )
			
			EntFireByHandle(self, "Kill", "", 0, null, null)
			return
		}
		
		self.SetOrigin( nextPos )
		ticks++
	}
	
	// Kill it if it lasts too long
	EntFireByHandle(rocket, "Kill", "", timeout, null, null)
}

function getInaccurateDir( dir, inacc )
{
	local inaccurateDir = dir
	inaccurateDir += Vector(RandomFloat(-inacc,inacc),RandomFloat(-inacc,inacc),RandomFloat(-inacc,inacc))*0.0009
	inaccurateDir.Norm()
	return inaccurateDir
}

function isCrouching( ply )
{
	return (ply.EyePosition() - ply.GetOrigin()).z < 63
}

function checkRPGFire()
{
	// Fire think() on all rockets
	EntFire("PILA_rocket", "RunScriptCode", "think()")
	
	// Add delay so the LMM has time to process
	if( rocketters.len() || rocketman_process != 0 )
	{
		rocketman_process += tickstep
		if(rocketman_process > 0.02)
			rocketman_process = 0
	}
	
	// Fire Rockets
	if( rocketters.len() && !rocketman_process )
	{
		// Backup and make handles to access them later
		rocketman_current = rocketters.pop()
		
		// Update the Measure Movement
		rocketman_current.handle.__KeyValueFromString("targetname", "rocketman")
		EntFireByHandle(lmm, "SetMeasureTarget", "rocketman", 0, null, null)
		EntFireByHandle(lmm, "FireUser1", "", tickstep, null, null)
	}

	// Find all viewmodels
	local vm = null
	while( vm = Entities.FindByClassname(vm, "predicted_viewmodel") )
	{
		// Not a nade lancer
		if(vm.GetModelName() != gromeo_MDL)
			continue
		
		local current_anim = VM_RPGGetAnim(vm)
		local ply = vm.GetMoveParent()
		
		if (ply.GetHealth() < 1) continue;
		// If the attachment is moved to signal that we need to fire
		if( current_anim == "fire" )
		{
			vm.ValidateScriptScope()
			local scope = vm.GetScriptScope()
			if( !scope.rawin("PILA_lastFire") )
				scope.PILA_lastFire <- 0
			
			// If it has been long enough, fire.
			if( scope.PILA_lastFire < Time()-refireDelay )
			{
				scope.PILA_lastFire = Time()
				
				rocketters.push( Rocketman(ply, ply.GetName()) )
			}
		}
	}
}

// Call the think function repetitively
timer <- Entities.CreateByClassname("logic_timer")
EntFireByHandle(timer, "AddOutput", "RefireTime " + tickrate, 0, null, null)
EntFireByHandle(timer, "AddOutput", "classname move_rope", 0, null, null)
EntFireByHandle(timer, "AddOutput", "OnTimer "+self.GetName()+":RunScriptCode:checkRPGFire():0:-1", 0, null, null)
EntFireByHandle(timer, "Enable", "", 0.1, null, null)

// Entity to find where the firing player is looking at
lmm <- Entities.CreateByClassname("logic_measure_movement")
EntFireByHandle(lmm, "AddOutput", "targetname PILA_lmm", 0, null, null)
EntFireByHandle(lmm, "AddOutput", "classname move_rope", 0, null, null)
EntFireByHandle(lmm, "AddOutput", "MeasureType 1", 0, null, null)
EntFireByHandle(lmm, "SetMeasureReference", "PILA_lmm", 0, null, null)
EntFireByHandle(lmm, "SetTargetReference", "PILA_lmm", 0, null, null)
EntFireByHandle(lmm, "SetMeasureTarget", "rocketman", 0, null, null)
EntFireByHandle(lmm, "SetTarget", "PILA_lmm", 0, null, null)
EntFireByHandle(lmm, "SetTargetScale", "1", 0, null, null)
EntFireByHandle(lmm, "AddOutput", "OnUser1 "+self.GetName()+":RunScriptCode:fireRocket():0:-1", 0, null, null)

// Used to make damage explosions
exp <- Entities.CreateByClassname("env_explosion")
EntFireByHandle(exp, "AddOutput", "classname move_rope", 0, null, null)
exp.__KeyValueFromInt("spawnflags", 2 + 4 + 64 + 256 + 512)
exp.__KeyValueFromFloat("iMagnitude", exp_magnitude)
exp.__KeyValueFromFloat("iRadiusOverride", exp_radius)

// Rocketman Handler
Rocketman <- class
{
	handle = null;
	name = "unknown";
	
	constructor(handle, name)
	{
		this.handle = handle;
		this.name = name;
	}
}

rocketters <- []
rocketman_current <- null
rocketman_process <- 0
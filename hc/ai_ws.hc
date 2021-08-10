float IsEnemyOwned (entity ent)
{
	if (ent.owner==self.enemy || ent.controller==self.enemy || ent.owner.controller==self.enemy || ent.owner.owner==self.enemy || ent.controller.owner==self.enemy)
		return TRUE;
	
	return FALSE;
}

float IsPlayerOwned (entity ent)
{
	if (ent.owner.flags&FL_CLIENT || ent.controller.flags&FL_CLIENT || ent.owner.controller.flags&FL_CLIENT || ent.owner.owner.flags&FL_CLIENT || ent.controller.controller.flags&FL_CLIENT || ent.controller.owner.flags&FL_CLIENT)
		return TRUE;
	
	return FALSE;
}

float IsMissile (entity ent)
{
	if (ent.movetype==MOVETYPE_FLYMISSILE || ent.movetype == MOVETYPE_BOUNCE || ent.movetype==MOVETYPE_BOUNCEMISSILE)
		return TRUE;
	
	if (IsPlayerOwned(ent) || ent.owner.flags&FL_MONSTER || ent.controller.flags&FL_MONSTER)
	{
		if (ent.movetype==MOVETYPE_FLY && !ent.flags&FL_MONSTER && !ent.flags2&FL_SUMMONED)
			return TRUE;
	}
	
	return FALSE;
}

float EnemyIsValid (entity ent)
{
	if (ent==world)								return FALSE;
	if (ent==self)								return FALSE;
	if (ent.health<=0)							return FALSE;
	if (!ent.flags&FL_CLIENT && !ent.flags2&FL_ALIVE)					return FALSE;
	if (ent.artifact_active&ARTFLAG_FROZEN
		&& self.classname!="monster_yakman")	return FALSE;
	if (ent.artifact_active&ARTFLAG_ASH
		|| ent.skin==GLOBAL_SKIN_ASH)			return FALSE;
	if (self.playercontrolled
		&& ent.classname=="monster_undying"
		&& !ent.takedamage)						return FALSE;
	
	return TRUE;
}

float IsAlly (entity ent)
{
	if (teamplay && self.team)
		if (ent.team == self.team || ent.owner.team == self.team || ent.controller.team == self.team || ent.team == self.owner.team || ent.team == self.controller.team)
			return TRUE;
	if (coop && self.flags&FL_CLIENT && ent.flags&FL_CLIENT)
		return TRUE;
	if (self.playercontrolled) {
		if (coop && (ent.flags&FL_CLIENT || ent.owner.flags&FL_CLIENT || ent.controller.flags&FL_CLIENT))
			return TRUE;
		if (self.owner)
			if (ent == self.owner || ent.owner == self.owner || ent.controller == self.owner)
				return TRUE;
		if (self.controller)
			if (ent == self.controller || ent.controller == self.controller || ent.owner == self.controller)
				return TRUE;
	}
	else if (self.movetype==MOVETYPE_FLYMISSILE)
	{
		if (self.owner)
			if (ent == self.owner || ent.owner == self.owner || ent.controller == self.owner)
				return TRUE;
		if (self.controller)
			if (ent == self.controller || ent.controller == self.controller || ent.owner == self.controller)
				return TRUE;
	}
	return FALSE;
}

//ws: copy of ChangeYaw adapted for pitch. useful for flying & swimming enemies. uses entity's turn_time in place of yaw_speed.
void ChangePitch (void)
{
	float		ideal, move, current_pitch;
	
	vector vec = vectoangles( (self.enemy.absmin + self.enemy.absmax) * 0.5 - self.origin );
	self.idealpitch = vec_x;
	current_pitch = anglemod( self.angles_x );
	ideal = self.idealpitch;
	
	if (current_pitch == ideal)
		return;
	
	move = ideal - current_pitch;
	if (ideal > current_pitch)
	{
		if (move > 180)
			move = move - 360;
	}
	else
	{
		if (move < -180)
			move = move + 360;
	}
	
	if (move > 0)
	{
		if (move > self.turn_time)
			move = self.turn_time;
	}
	else
	{
		if (move < 0-self.turn_time )
			move = 0-self.turn_time;
	}
	
	current_pitch = anglemod (current_pitch + move);
	self.angles_x = current_pitch;
}

float PlayerHasMelee (entity player)
{
	if (!player || !player.flags&FL_CLIENT)
		return FALSE;
	if (player.weapon==IT_WEAPON1)
		return TRUE;
	if (player.playerclass==CLASS_PALADIN && player.weapon==IT_WEAPON2 && !player.altfiring)
		return TRUE;
	
	return FALSE;
}

float CanSpawnAtSpot (vector spot, vector mins, vector maxs, entity ignore)
{
vector dest;
	makevectors(self.angles);
	
	if (!self.flags&FL_SWIM && (pointcontents(spot)==CONTENT_WATER || pointcontents(spot)==CONTENT_SLIME))
		return FALSE;
	
	dest = spot + ('0 0 1' * maxs_z*1.25);
	
	traceline (spot, dest, TRUE, ignore);	//try simple trace first
	if (trace_fraction != 1 || trace_allsolid)
		return FALSE;
	
	tracearea (spot, dest, mins, maxs, FALSE, ignore);	//if line wasnt blocked, trace with bbox
	
	if (trace_fraction == 1 && !trace_allsolid)
		return TRUE;
	else
		return FALSE;
}

vector FindSpawnSpot (float rangemin, float rangemax, float anglemax, entity ignore)
{
	vector spot,newangle;
	float loop_cnt,forward;
	
	vector min, max;
	if (self.orgnl_mins)
		min = self.orgnl_mins;
	else
		min = self.mins;
	if (self.orgnl_maxs)
		max = self.orgnl_maxs;
	else
		max = self.maxs;
	
	trace_fraction = 0;
	loop_cnt = 0;
	do
	{
		newangle = self.angles;
		newangle_y += random(anglemax);
   		makevectors (newangle);
		forward = random(rangemin,rangemax);
		spot = self.origin + v_forward * forward;
		if (!self.flags&FL_FLY) {
			traceline (spot, (spot - (v_up * 200)), TRUE, ignore);
			if (trace_fraction == 1)	// Didn't hit anything?  There was no floor
				return VEC_ORIGIN;
		}
		spot = trace_endpos;
		
		if (CanSpawnAtSpot(spot, min, max, ignore))
			trace_fraction = 1;
		else
			trace_fraction = 0;		// So it will loop
		
		loop_cnt += 1;
		
		if (loop_cnt > 500)   // No endless loops
			return VEC_ORIGIN;

	} while (trace_fraction != 1);
	
	return spot;
}

float (float dist) ai_backfromenemy =
{
float	away;
	if (!self.enemy)
		away = -self.angles_y;
	else
		away = vectoyaw (self.origin - self.enemy.origin);
	
	return (walkmove (away, dist,FALSE));
};

void(float mindist, float maxdist) SetNewWanderPoint;

void WanderPointTouch ()
{
	if (!self.controller) {
		remove(self);
		return;
	}
	if (other!=self.controller)
		return;
	
	SetNewWanderPoint(self.t_width, self.t_length);
	remove(self);
}

void SetNewWanderPoint (float mindist, float maxdist)
{
	entity waypoint, us;
	vector dest;
	float i;
	
	if (self.classname=="wanderpoint")
		us = self.controller;
	else
		us = self;
	
	dest = FindSpawnSpot(mindist, maxdist, 360, self);
	do {
		i++;
		dest = FindSpawnSpot(mindist, maxdist, 360, self);
		if (pointcontents(dest)==CONTENT_LAVA)
			dest = VEC_ORIGIN;
	}
	while (dest == VEC_ORIGIN && i<100);
	
	if (dest==VEC_ORIGIN) {
		self.goalentity = world;
		return;
	}
	
	waypoint = spawn();
	waypoint.controller = us;
	waypoint.classname = "wanderpoint";
	waypoint.t_width = mindist;
	waypoint.t_length = maxdist;
	waypoint.effects = EF_NODRAW;
	waypoint.movetype = MOVETYPE_NONE;
	waypoint.movetype = MOVETYPE_PUSH;
	waypoint.solid = SOLID_TRIGGER;
	waypoint.touch = WanderPointTouch;
	setmodel(waypoint, "models/null.spr");
	setsize(waypoint,'-2 -2 -2','2 2 2');
	setorigin(waypoint, dest);
	
	us.enemy = us.goalentity = waypoint;
}

void NavigateWanderPoints ()
{
	if (self.goalentity && self.goalentity.classname!="wanderpoint" && !self.goalentity.flags&FL_CLIENT)
		return;
	
	if(!self.goalentity || self.goalentity.flags&FL_CLIENT)
		SetNewWanderPoint(40,180);
	if (vlen(self.goalentity.origin-self.origin)<16 && self.goalentity.classname=="wanderpoint") {
		remove(self.goalentity);
		SetNewWanderPoint(40,180);
	}
}

//ws: check to make sure we can see enemy and have a clear path forward from our feet
//the visible and clear_path functions arent suitable because they check from our bbox center to enemy's bbox center, and we need to check from the ground
float CanChargeForward(float dist)
{
	makevectors(self.angles);
	traceline(self.origin+'0 0 1', self.origin+'0 0 1'+v_forward*dist, FALSE, self);	//try simple trace first
	if (trace_ent && trace_ent.flags2&FL_ALIVE && trace_ent.takedamage)
		return TRUE;
	else if (trace_fraction<1)
		return FALSE;
	tracearea(self.origin+'0 0 1', self.origin+'0 0 1'+v_forward*dist, self.mins, self.maxs, FALSE, self);
	if (trace_ent && trace_ent.flags2&FL_ALIVE && trace_ent.takedamage)
		return TRUE;
	else if (trace_fraction<1)
		return FALSE;
	
	return FALSE;
}

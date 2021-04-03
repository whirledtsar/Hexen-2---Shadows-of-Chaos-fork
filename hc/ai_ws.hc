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
	if (!ent.flags2&FL_ALIVE)					return FALSE;
	if (ent.health<=0)							return FALSE;
	if (ent.artifact_active&ARTFLAG_FROZEN)		return FALSE;
	if (ent.artifact_active&ARTFLAG_STONED
		&& self.classname!="monster_medusa")	return FALSE;
	if (ent.artifact_active&ARTFLAG_ASH
		|| ent.skin==GLOBAL_SKIN_ASH)			return FALSE;
	
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
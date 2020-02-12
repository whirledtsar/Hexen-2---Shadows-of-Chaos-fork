/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/combat.hc,v 1.3 2007-02-07 16:56:59 sezero Exp $
 */
void(vector org, vector vel, float damage, entity victim) SpawnPuff;

void Knockback (entity victim, entity attacker, entity inflictor, float force, float zmod)
{
	if (!victim)
	{
		dprint ("No victim for Knockback in combat.hc\n");
		return;
	}
	else if (!attacker || !inflictor) {
		dprint ("No attacker and/or inflictor for Knockback in combat.hc\n");
		return;
	}
	else if (victim.solid==SOLID_BSP || victim.movetype==MOVETYPE_PUSH) 	{
		return;
	}
	if (!zmod)
		zmod = 1;
	
	vector dir;
	float inertia;
	
	if(victim.mass<=10)
		inertia=1;
	else
		inertia=victim.mass/10;

	if(inertia>100)//don't move anything more than 1000 mass
		return;
	
	force*=10;
	if (attacker.strength)
		force+=attacker.strength*1.5;
	if (attacker.strength && force > 200)
		force = 200;
	
	dir = normalize(victim.origin - inflictor.origin);	//using inflictor origin rather than attacker because of the flying warhammer
	victim.velocity = dir*(1/inertia)*force;
	
	if(self.flags&FL_FLY)
	{
		if(victim.flags&FL_ONGROUND || zmod < 0)	//ws: i want certain attacks to knock flying enemies downwards
			victim.velocity_z=(1/inertia)*force*zmod;
	}
	else
		victim.velocity_z = (1/inertia)*force*zmod;
	
	victim.flags(-)FL_ONGROUND;
}

float MetalHitSound (float targettype)
{
	if(targettype==THINGTYPE_FLESH)
	{
		sound (self, CHAN_WEAPON, "weapons/met2flsh.wav", 1, ATTN_NORM);
		return TRUE;
	}
	else if(targettype==THINGTYPE_WOOD)
	{
		sound (self, CHAN_WEAPON, "weapons/met2wd.wav", 1, ATTN_NORM);
		return TRUE;
	}
	else if(targettype==THINGTYPE_METAL)
	{
		sound (self, CHAN_WEAPON, "weapons/met2met.wav", 1, ATTN_NORM);
		return TRUE;
	}
	else if(targettype==THINGTYPE_BROWNSTONE||targettype==THINGTYPE_GREYSTONE)
	{
		sound (self, CHAN_WEAPON, "weapons/met2stn.wav", 1, ATTN_NORM);
		return TRUE;
	}
	return FALSE;
}


/*
================
FireMelee
================
*/
void FireMelee (float damage_base,float damage_mod)
{
	vector	source;
	vector	org;
	float damg, backstab;
	float chance,point_chance;

	makevectors (self.v_angle);
	source = self.origin+self.proj_ofs;
	traceline (source, source + v_forward*64, FALSE, self);

	if (trace_fraction == 1.0)
	{
		traceline (source, source + v_forward*64 - (v_up * 30), FALSE, self);  // 30 down
		if (trace_fraction == 1.0)
		{
			traceline (source, source + v_forward*64 + v_up * 30, FALSE, self);  // 30 up
			if (trace_fraction == 1.0)
				return;
		}
	}

	org = trace_endpos + (v_forward * 4);

	if (trace_ent.takedamage)
	{
		//FIXME:Add multiplier for level and strength
		if(self.playerclass == CLASS_ASSASSIN && self.weapon == IT_WEAPON1)
		{
		  if(self.level > 5) /* Pa3PyX: this ability starts at clvl 6 */ {
		    if((trace_ent.flags2 & FL_ALIVE) && !infront_of_ent(self, trace_ent) &&
							random(1, 40) < self.dexterity) {
			CreateRedFlash(trace_endpos);
			damage_base*=random(2.5,4);
			backstab=TRUE;
		    }
		  }
		}

		damg = random(damage_mod+damage_base,damage_base);
		SpawnPuff (org, '0 0 0', damg,trace_ent);
		T_Damage (trace_ent, self, self, damg);
		if(!(trace_ent.flags2 & FL_ALIVE) && backstab)
		{
			dprint("Backstab from combat.hc");
			centerprint(self,"Critical Hit Backstab!\n");
			AwardExperience(self,trace_ent,10);
		}
		
		if (!MetalHitSound(trace_ent.thingtype))
			sound (self, CHAN_WEAPON, "weapons/slash.wav", 1, ATTN_NORM);

		// Necromancer stands a chance of vampirically stealing health points
		if (self.playerclass == CLASS_NECROMANCER)
		{
			if ((trace_ent.flags & FL_MONSTER) || (trace_ent.flags & FL_CLIENT))
			{
				chance = self.level * .05;

				if (chance > random())
				{
					point_chance = self.level;
					point_chance *= random();
					if (point_chance < 1)
						point_chance = 1;

					sound (self, CHAN_BODY, "weapons/drain.wav", 1, ATTN_NORM);

					self.health += point_chance;
					if (self.health>self.max_health)
						self.health = self.max_health;
				}
			}
		}
	}
	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "weapons/hitwall.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
}


/*
 * h2/weapons.hc
 */

void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage,entity victim) SpawnPuff;
void() PlayerCrouch;
void() UseInventoryItem;
void() ImpulseCommands;

//============================================================================

vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*random(-0.5,0.5) + v_right*random(-0.5,0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};

/*
================
spawn_touchpuff
================
*/
void(float damage,entity victim) spawn_touchpuff =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnPuff (self.origin + vel*0.01, vel, damage,victim);
};

void() T_MissileTouch =
{
	float	damg;
//	vector delta;  // Quantis never crashes

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = random(100,120);
	if(self.classname=="dragonspike")
		damg=damg * 0.25;
	else if(self.classname=="dragonball")
		damg=damg * 0.5;
	else if (self.classname == "mummymissile")
		damg = random(5,15);
	
	if (other.health)
	{
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	if(self.classname=="dragonspike")
		T_RadiusDamage (self, self.owner, 60, other);
	else if ((self.classname=="mummymissile") || (self.classname=="green_arrow") || (self.classname=="red_arrow"))
		damg = damg;  // No radius damage
	else
		T_RadiusDamage (self, self.owner, 120, other);


//	sound (self, CHAN_WEAPON, "weapons/explode.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion (FALSE);
};

void() T_PhaseMissileTouch =
{
	local float	damg;
//	entity new;

	self.flags (-) FL_ONGROUND;	// So it never thinks it is touching the ground

	if (other == self.owner)
		return;		// don't explode on owner

	if ((self.enemy == other) && (other != world))  // Can't hit same enemy twice in a row but you can hit world twice
		return;

	if (self.netname=="axeblade")
	{
		//self.cnt +=1;
		self.velocity = self.velocity * 0.75;
		self.angles = vectoangles(self.velocity);
		//sound (self, CHAN_WEAPON, "paladin/axric1.wav", 1, ATTN_NORM);
		if (self.goalentity)
		{
			if (self.goalentity.classname=="ax_tail")
			{
				self.goalentity.think = axetail_run;
				self.goalentity.nextthink = time + HX_FRAME_TIME;
			}
		}
	}
	else if (self.model=="models/fablade.mdl")
		self.angles = vectoangles(self.velocity);
	
	self.cnt +=1;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		stopSound(self,CHAN_VOICE);
		stopSound(self,CHAN_WEAPON);
		if ((self.classname == "axeblade") || (self.classname == "powerupaxeblade"))
			remove(self.goalentity); // Remove tail
		remove(self);
		return;
	}

	if (other.health)	// Hit something that can be hurt
	{
		spawn_touchpuff (damg, other);
		T_Damage (other, self, self.owner, self.dmg);
		self.counter -=1;
		self.enemy = other;
	}
	else
	{
		self.enemy = other;
		if (self.cnt < self.hoverz)	//hit wall, so create appropriate effect
			self.blocked();
		else
			self.counter = 0;
	}	

	// Time is up
	if (self.lifetime < time)
		self.counter = 0;

	if ((other.health) || (self.counter < 1))
	{
		self.th_die();
	}
	else
		sound (self, CHAN_WEAPON, self.sightsound, 1, ATTN_IDLE);

	if (self.counter < 1)
	{
		if (self.netname=="axeblade")
			remove(self.goalentity); // Remove tail

		stopSound(self,CHAN_VOICE);
		remove(self);
	}
};

//=============================================================================

//=============================================================================

void() spike_touch;
//void() superspike_touch;


/*
===============
launch_spike
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "models/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};



void() spike_touch =
{
//float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchpuff (9,other);
		T_Damage (other, self, self.owner, 9);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};


/*void() superspike_touch =
{
local float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchpuff (18,other);
		T_Damage (other, self, self.owner, 18);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};*/

/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/
void() Nec_Change_Weapon;
void() Pal_Change_Weapon;
void() Cru_Change_Weapon;
void() Ass_Change_Weapon;

void W_SetCurrentAmmo (void)
{
	if(self.sheep_time>time)
		return;

	wp_deselect = 0;

	self.button0=FALSE;
	//attck_cnt=0;

	if (self.oldweapon==self.weapon)		// Until we get multi skinned weapons
		return;

	if(self.attack_finished<time)
		self.attack_finished=time;

	if (self.weapon == IT_WEAPON1)
	{		
		self.weaponmodel="";
		self.weaponframe = 0;
		if (self.playerclass == CLASS_PALADIN)
			gauntlet_select();
		else if (self.playerclass == CLASS_NECROMANCER)
			sickle_select();
		else if (self.playerclass == CLASS_CRUSADER)
			warhammer_select();
		else if (self.playerclass == CLASS_ASSASSIN)
			punchdagger_select();
	}
	else if (self.weapon == IT_WEAPON2)
	{
		self.weaponmodel="";
		self.weaponframe = 0;
		if (self.playerclass == CLASS_PALADIN)
			vorpal_select();
		else if (self.playerclass == CLASS_ASSASSIN)
			crossbow_select();
		else if (self.playerclass == CLASS_CRUSADER)
			icestaff_select();
		else if (self.playerclass == CLASS_NECROMANCER)
		{
			if(self.oldweapon!=IT_WEAPON3)
				magicmis_select();
			else
				magicmis_select_from_bone();
		}
	}
	else if (self.weapon == IT_WEAPON3)
	{	
		self.weaponmodel="";
		self.weaponframe = 0;
		if (self.playerclass == CLASS_PALADIN)
			axe_select();
		else if (self.playerclass == CLASS_ASSASSIN)
			grenade_select();
		else if (self.playerclass == CLASS_CRUSADER)
			meteor_select();
		else if (self.playerclass == CLASS_NECROMANCER)
		{
			if(self.oldweapon!=IT_WEAPON2)
				boneshard_select();
			else
				boneshard_select_from_mmis();
		}
	}
	else if (self.weapon == IT_WEAPON4)
	{		
		self.weaponmodel="";
		self.weaponframe = 0;
		if (self.playerclass == CLASS_PALADIN)
			purifier_select();
		else if (self.playerclass == CLASS_CRUSADER)
			sunstaff_select();
		else if(self.playerclass==CLASS_ASSASSIN)
			setstaff_select();
		else if (self.playerclass == CLASS_NECROMANCER)
			ravenstaff_select();
	}
	else if (self.weapon == IT_WEAPON5)
	{		
		self.weaponmodel="";
		self.weaponframe = 0;
		if (self.playerclass == CLASS_PALADIN)
			gauntlet_select();
		else if (self.playerclass == CLASS_NECROMANCER)
			sickle_select();
		else if (self.playerclass == CLASS_CRUSADER)
			warhammer_select();
		else if (self.playerclass == CLASS_ASSASSIN)
			punchdagger_select();
	}
	else if (self.weapon == IT_WEAPON6)
	{		
		self.weaponmodel="";
		self.weaponframe = 0;
		if (self.playerclass == CLASS_PALADIN)
			gauntlet_select();
		else if (self.playerclass == CLASS_NECROMANCER)
			sickle_select();
		else if (self.playerclass == CLASS_CRUSADER)
			warhammer_select();
		else if (self.playerclass == CLASS_ASSASSIN)
			punchdagger_select();
	}

//All players will have to do this eventually, to reset
//the stand, pain, run & fly functions for the different weapons
	if(self.weapon!=self.oldweapon)
	{
		if(self.playerclass==CLASS_NECROMANCER)
			Nec_Change_Weapon();
		else if(self.playerclass==CLASS_PALADIN)
			Pal_Change_Weapon();
		else if(self.playerclass==CLASS_CRUSADER)
			Cru_Change_Weapon();
		else if(self.playerclass==CLASS_ASSASSIN)
			Ass_Change_Weapon();
		if(self.hull!=HULL_CROUCH)
			self.act_state=ACT_STAND;
	}

/*	if (self.flags2&FL_CAMERA_VIEW)
	{  // FIXME - couldn't this use oldweapon??? rather than lastweapon
		self.lastweapon=self.weaponmodel;
		self.weaponmodel="";
	}
*/

	if(self.flags2&FL_SUMMONED&&self.weapon!=IT_WEAPON3)
	{
		self.flags2(-)FL_SUMMONED;
		self.effects(-)EF_DARKLIGHT;
	}
//	if (self.deselect_time < time)
		self.oldweapon=self.weapon;	
}

float W_CheckNoAmmo (float check_weapon)
{
	if (check_weapon == IT_WEAPON1)
		return TRUE;
	
	if(self.playerclass==CLASS_ASSASSIN)
	{
		if (check_weapon==IT_WEAPON6)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.greenmana >= 12)
					return TRUE;
			}
			else if(self.greenmana >= 3)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON5)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.bluemana >= 5)
					return TRUE;
			}
			else if(self.bluemana >= 2)
				return TRUE;
		}
		else if (check_weapon==IT_WEAPON4)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.bluemana >= 20 && self.greenmana >= 20)
					return TRUE;
			}
			else if(self.bluemana >= 1 && self.greenmana >= 1)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON3)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.greenmana >= 12)
					return TRUE;
			}
			else if(self.greenmana >= 3)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON2)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.bluemana >= 5)
					return TRUE;
			}
			else if(self.bluemana >= 2)
				return TRUE;
		}
	}
	else if(self.playerclass==CLASS_CRUSADER)
	{
		if (check_weapon==IT_WEAPON6)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.greenmana >= 12)
					return TRUE;
			}
			else if(self.greenmana >= 8)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON5)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.bluemana >= 10)
					return TRUE;
			}
			else if(self.bluemana >= 1)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON4)
		{
			if(self.bluemana >= 2 && self.greenmana >= 2)
				return TRUE;
			self.effects(-)EF_BRIGHTLIGHT;
		}
		else if (check_weapon==IT_WEAPON3)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.greenmana >= 12)
					return TRUE;
			}
			else if(self.greenmana >= 8)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON2)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.bluemana >= 10)
					return TRUE;
			}
			else if(self.bluemana >= 1)
					return TRUE;
		}
	}
	else if(self.playerclass==CLASS_NECROMANCER)
	{
		if (check_weapon==IT_WEAPON6)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.greenmana >= BONE_NORMAL_COST + BONE_TOMED_COST)
					return TRUE;
			}
			else if(self.greenmana >= BONE_NORMAL_COST)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON5)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.bluemana >= MMIS_TOME_COST)
					return TRUE;
			}
			else if(self.bluemana >= MMIS_COST)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON4)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.bluemana >= 16 && self.greenmana >= 16)
					return TRUE;
			}
			else if(self.bluemana >= 8 && self.greenmana >= 8)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON3)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.greenmana >= BONE_NORMAL_COST + BONE_TOMED_COST)
					return TRUE;
			}
			else if(self.greenmana >= BONE_NORMAL_COST)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON2)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if (self.button1)
					if (self.bluemana >= MMIS_ALT_COST)
						return TRUE;
				if(self.bluemana >= MMIS_TOME_COST)
					return TRUE;
			}
			else if(self.bluemana >= MMIS_COST)
					return TRUE;
		}
	}
	else if(self.playerclass==CLASS_PALADIN)
	{
		if (check_weapon==IT_WEAPON6)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.greenmana >= 12)
					return TRUE;
			}
			else if(self.greenmana >= 8)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON5)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.bluemana >= 10)
					return TRUE;
			}
			else if(self.bluemana >= 1)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON4)
		{
			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.bluemana >= PFLAME_COST && self.greenmana >= PFLAME_COST)
					return TRUE;
			}
			else if(self.bluemana >= 1 && self.greenmana >= 1)
					return TRUE;
		}
		else if (check_weapon==IT_WEAPON3) //can use even without ammo
		{
			return TRUE;
		}
		else if (check_weapon==IT_WEAPON2) //Can use even without ammo
		{
/*			if(self.artifact_active&ART_TOMEOFPOWER)
			{
				if(self.bluemana >= 4)
					return TRUE;
			}
			else if(self.bluemana >= 2) 
					return TRUE;*/
			return TRUE;
		}
	}
	return FALSE;
}

//=========================
// W_BestWeapon : choose the most powerful weapon the player has ammo for
//=========================
void() W_BestWeapon =
{
	if (W_CheckNoAmmo (IT_WEAPON4) && (self.items & IT_WEAPON4))
		self.weapon = IT_WEAPON4;
	else if (W_CheckNoAmmo (IT_WEAPON3) && (self.items & IT_WEAPON3))
		self.weapon = IT_WEAPON3;
	else if (W_CheckNoAmmo (IT_WEAPON6) && (self.items & IT_WEAPON6))
		self.weapon = IT_WEAPON6;
	else if (W_CheckNoAmmo (IT_WEAPON2) && (self.items & IT_WEAPON2))
		self.weapon = IT_WEAPON2;
	else if (W_CheckNoAmmo (IT_WEAPON5) && (self.items & IT_WEAPON5))
		self.weapon = IT_WEAPON5;
	else self.weapon = IT_WEAPON1;

/*float	test_weapon;

	test_weapon = IT_WEAPON4;
	while((!W_CheckNoAmmo (test_weapon)||(!self.items&test_weapon)))
	{
		if(test_weapon==IT_WEAPON2)
			test_weapon=IT_WEAPON1;
		else
			test_weapon -= 1;
	}
	self.weapon=test_weapon; */


/*
	test_weapon = IT_WEAPON4;
	while((!W_CheckNoAmmo (test_weapon)||(!self.items&test_weapon)))
	{
		if(test_weapon==IT_WEAPON2)
			test_weapon=IT_WEAPON1;
		else
			test_weapon/=2;
	}
	self.weapon=test_weapon; */
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()player_sheep_baa;
void W_Attack (float rightclick)
{
	if (!W_CheckNoAmmo (self.weapon))
	{
		W_BestWeapon ();
		W_SetCurrentWeapon ();
		return;
	}
	
	if(self.attack_finished>time)
		return;
	
	//Firing whip, do notattempt regular attack
	if (self.playerclass==CLASS_ASSASSIN && rightclick && self.weapon != IT_WEAPON2)
		return;

	if(self.sheep_time>time)
	{
		player_sheep_baa();
		return;
	}

	if(self.viewentity!=self&&self.viewentity.classname!="chasecam")
		return;

	self.show_hostile = time + 1;	// wake monsters up
	self.last_attack=time;			//In attack state

	if(self.hull==HULL_PLAYER)
		self.act_state=ACT_ATTACK;
	else
		self.act_state=ACT_CROUCH_MOVE;
	
	if (self.weapon == IT_WEAPON1)
	{
		if (self.playerclass==CLASS_PALADIN)
			pal_gauntlet_fire(rightclick);
		else if (self.playerclass==CLASS_NECROMANCER)
			sickle_decide_attack(rightclick);
		else if (self.playerclass==CLASS_ASSASSIN)
		{
			Ass_Pdgr_Fire();
		}
		else if (self.playerclass==CLASS_CRUSADER)
			Cru_Wham_Fire(rightclick);
	}
	else if (self.weapon == IT_WEAPON2)
	{
		if (self.playerclass==CLASS_PALADIN)
			pal_vorpal_fire();
		else if(self.playerclass==CLASS_ASSASSIN)
		{
			crossbow_fire();
			//crossbow_charge_fire();
		}
		else if(self.playerclass==CLASS_CRUSADER)
		{
			if(self.th_weapon==icestaff_idle)
				Cru_Ice_Fire(rightclick);
		}
		else if(self.playerclass==CLASS_NECROMANCER)
			Nec_Mis_Attack();
	}
	else if (self.weapon == IT_WEAPON3)
	{
		if (self.playerclass==CLASS_PALADIN)
			pal_axe_fire();
		else if (self.playerclass==CLASS_ASSASSIN)
		{
			grenade_throw();
		}
		else if (self.playerclass==CLASS_CRUSADER)
			Cru_Met_Attack();
		else if(self.playerclass==CLASS_NECROMANCER)
			Nec_Bon_Attack();
	}
	else if (self.weapon == IT_WEAPON4)
	{
		if (self.playerclass==CLASS_PALADIN)
			pal_purifier_fire();
		else if(self.playerclass==CLASS_ASSASSIN)
		{
			ass_setstaff_fire();
		}
		else if (self.playerclass==CLASS_CRUSADER)
			Cru_Sun_Fire();
		else if(self.playerclass==CLASS_NECROMANCER)
			ravenstaff_fire();
	}
	else if (self.weapon == IT_WEAPON5)
	{
		if (self.playerclass==CLASS_PALADIN)
			pal_gauntlet_fire(rightclick);
		else if (self.playerclass==CLASS_NECROMANCER)
			sickle_decide_attack(rightclick);
		else if (self.playerclass==CLASS_ASSASSIN)
		{
			Ass_Pdgr_Fire();			
		}
		else if (self.playerclass==CLASS_CRUSADER)
			Cru_Wham_Fire(rightclick);
	}
	else if (self.weapon == IT_WEAPON6)
	{
		if (self.playerclass==CLASS_PALADIN)
			pal_gauntlet_fire(rightclick);
		else if (self.playerclass==CLASS_NECROMANCER)
			sickle_decide_attack(rightclick);
		else if (self.playerclass==CLASS_ASSASSIN)
		{
			Ass_Pdgr_Fire();			
		}
		else if (self.playerclass==CLASS_CRUSADER)
			Cru_Wham_Fire(rightclick);
	}
}


void W_DeselectWeapon (void)
{

	wp_deselect = 1;

	if (self.oldweapon == IT_WEAPON1)
	{
		if (self.playerclass==CLASS_PALADIN)
			gauntlet_deselect();
		else if (self.playerclass==CLASS_CRUSADER)
			warhammer_deselect();
		else if (self.playerclass==CLASS_ASSASSIN)
			punchdagger_deselect();
		else if (self.playerclass==CLASS_NECROMANCER)
			sickle_deselect();
		else
			W_SetCurrentAmmo();
	}
	else if (self.oldweapon == IT_WEAPON2)
	{
		if (self.playerclass==CLASS_PALADIN)
			vorpal_deselect();
		else if (self.playerclass==CLASS_CRUSADER)
			icestaff_deselect();
		else if (self.playerclass==CLASS_ASSASSIN)
			crossbow_deselect();
		else if (self.playerclass==CLASS_NECROMANCER)
		{
			if(self.weapon!=IT_WEAPON3)
				magicmis_deselect();
			else
				W_SetCurrentAmmo();
		}
		else
			W_SetCurrentAmmo();
	}
	else if (self.oldweapon == IT_WEAPON3)
	{
		if (self.playerclass==CLASS_PALADIN)
			axe_deselect();
		else if (self.playerclass==CLASS_CRUSADER)
			meteor_deselect();
		else if (self.playerclass==CLASS_ASSASSIN)
			grenade_deselect();
		else if (self.playerclass==CLASS_NECROMANCER)
		{
			if(self.weapon!=IT_WEAPON2)
				boneshard_deselect();
			else
				W_SetCurrentAmmo();
		}
		else
			W_SetCurrentAmmo();
	}
	else if (self.oldweapon == IT_WEAPON4)
	{
		if (self.playerclass==CLASS_PALADIN)
			purifier_deselect();
		else if (self.playerclass==CLASS_CRUSADER)
			sunstaff_deselect();
		else if (self.playerclass==CLASS_ASSASSIN)
			setstaff_deselect();
		else if (self.playerclass==CLASS_NECROMANCER)
			ravenstaff_deselect();
		else
			W_SetCurrentAmmo();
	}
	else if (self.oldweapon == IT_WEAPON5)
	{
		if (self.playerclass==CLASS_PALADIN)
			gauntlet_deselect();
		else if (self.playerclass==CLASS_CRUSADER)
			warhammer_deselect();
		else if (self.playerclass==CLASS_ASSASSIN)
			punchdagger_deselect();
		else if (self.playerclass==CLASS_NECROMANCER)
			sickle_deselect();
		else
			W_SetCurrentAmmo();
	}
	else if (self.oldweapon == IT_WEAPON6)
	{
		if (self.playerclass==CLASS_PALADIN)
			gauntlet_deselect();
		else if (self.playerclass==CLASS_CRUSADER)
			warhammer_deselect();
		else if (self.playerclass==CLASS_ASSASSIN)
			punchdagger_deselect();
		else if (self.playerclass==CLASS_NECROMANCER)
			sickle_deselect();
		else
			W_SetCurrentAmmo();
	}
	else
		W_SetCurrentAmmo();
}

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	if(self.sheep_time>time)
		return;

	if(self.viewentity!=self&&self.viewentity.classname!="chasecam")
		return;

	if(self.attack_finished>time)
		return;

float	it, am, fl;
	

	it = self.items;
	am = 0;
	
	if (self.impulse == 1)
	{
		fl = IT_WEAPON1;
	}
	else if (self.impulse == 2)
	{
		fl = IT_WEAPON2;
	}
	else if (self.impulse == 3)
	{
		fl = IT_WEAPON3;
		if (self.bluemana < 2)
			am = 1;
	}		
	else if (self.impulse == 4)
	{
		fl = IT_WEAPON4;
		if ((self.bluemana < 1) && (self.greenmana <1))
			am = 1;
	}
	else if (self.impulse == 5)
	{
		fl = IT_WEAPON5;
	}
	else if (self.impulse == 6)
	{
		fl = IT_WEAPON6;
	}

	self.impulse = 0;

	if (!(self.items & fl))
	{
		sprint (self, STR_NOCARRYWEAPON);
		return;
	}

	if(!W_CheckNoAmmo(fl))
	{
		sprint (self, STR_NOTENOUGHMANA);
		return;
	}

//
// set weapon, set ammo
//
	self.oldweapon=self.weapon;//for deselection animation
	self.weapon = fl;		
	W_SetCurrentWeapon ();
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
	//if(deathmatch||coop)
		//return;
	if(deathmatch)
		return;

	self.items(+)IT_WEAPON1|IT_WEAPON2|IT_WEAPON3|IT_WEAPON4|IT_WEAPON5|IT_WEAPON6|IT_WEAPON4_1|IT_WEAPON4_2;

	self.bluemana = self.max_mana;
	self.greenmana = self.max_mana;

	self.impulse = 0;

	if(self.attack_finished<time)
	{
		self.oldweapon = self.weapon;
		self.weapon = IT_WEAPON4;
		W_SetCurrentWeapon ();
	}
};

/*
the cycle weapon commands fixed by S.A.
============
CycleWeaponCommand
Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	float	fl;
	if(self.attack_finished>time)
		return;
	self.impulse = 0;
	self.items (+) IT_WEAPON1;
	fl = self.weapon;
	loop /*while (1)*/ {
		if (fl == IT_WEAPON1)
		{
			fl = IT_WEAPON2;
		}
		else if (fl == IT_WEAPON2)
		{
			fl = IT_WEAPON3;
		}
		else if (fl == IT_WEAPON3)
		{
			fl = IT_WEAPON4;
		}
		else if (fl == IT_WEAPON4)
		{
			fl = IT_WEAPON5;
		}
		else if (fl == IT_WEAPON5)
		{
			fl = IT_WEAPON6;
		}
		else if (fl == IT_WEAPON6)
		{
			fl = IT_WEAPON1;
		}
		else /* ouch !!?? */
		{
			return;
		}
		if (self.items & fl)
		{
			if (W_CheckNoAmmo(fl))
				break;
			if (self.playerclass == CLASS_PALADIN && fl == IT_WEAPON2)
				break;
		}
	}
	self.weapon = fl;
	W_SetCurrentWeapon ();
};

/*
============
CycleWeaponReverseCommand
Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	float	fl;
	if(self.attack_finished>time)
		return;
	self.impulse = 0;
	self.items (+) IT_WEAPON1;
	fl = self.weapon;
	loop /*while (1)*/ {
		if (fl == IT_WEAPON1)
		{
			fl = IT_WEAPON4;
		}
		else if (fl == IT_WEAPON2)
		{
			fl = IT_WEAPON1;
		}
		else if (fl == IT_WEAPON3)
		{
			fl = IT_WEAPON2;
		}
		else if (fl == IT_WEAPON4)
		{
			fl = IT_WEAPON3;
		}
		else if (fl == IT_WEAPON5)
		{
			fl = IT_WEAPON4;
		}
		else if (fl == IT_WEAPON6)
		{
			fl = IT_WEAPON5;
		}
		else /* ouch !!?? */
		{
			return;
		}
		if (self.items & fl)
		{
			if (W_CheckNoAmmo(fl))
				break;
			if (self.playerclass == CLASS_PALADIN && fl == IT_WEAPON2)
				break;
		}
	}
	self.weapon = fl;
	W_SetCurrentWeapon ();
};

/*
============
ServerflagsCommand

Just for development
============
*/
/*
void() ServerflagsCommand =
{
	serverflags = serverflags * 2 + 1;
};
*/

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
if (!(deathmatch))
{
	if (!(deathmatch))
	{
		if (world.model == "maps/demo1.bsp" || world.model == "keep1.bsp" || world.model == "maps/vil1.bsp" || world.spawnflags&WSF_WELCOMEMESSAGE)
		{
			if (self.welcomeshown <= 12)		// set endtime of welcome message here
			{
				if (time > self.welcomeshown)	// needed to set delay for welcome message
				{
				if (self.welcomeshown == 0)
					self.welcomeshown = time + .2;	// set delay for welcome message here
				else
					{
					self.welcomeshown = time + 1.9;
					centerprint(self, "Welcome to Hexen II: Shadows of Chaos@@Damage & abilities improve as you level@@@Default bindings (autoexec.cfg):@Altfire: right mouse@Stats: home@Options: end@Selection down: prev weapon@Selection up: next weapon@Select: fire");
					}
				}
			}
		}
	}
	ImpulseCommands ();
	if (self.playerclass==CLASS_ASSASSIN && self.button1 && self.weapon != IT_WEAPON2 && self.whiptime < time)
	{
		FireChainW();
	}
	if ((self.cameramode || self.flags2&FL2_MENUACTIVE) && self.weaponmodel && self.weaponmodel!="")
	{
		self.lastweapon=self.weaponmodel;
		self.weaponmodel="";
	}
	
	if (time < self.attack_finished)
		return;
	
//hijak keybindings for SoC menu system
	if (self.flags2&FL2_MENUACTIVE) {
		if (self.button0) {
			Menu_Choose();
			self.button0 = FALSE;
			self.attack_finished = time+0.25;	//prevent function running every frame button is held down
		}
		else if (self.button1)
			if (self.menu.impulse==MENU_STATS) {
				StatsMenu_Dump();
				self.button1 = FALSE;
				self.attack_finished = time+0.25;	//prevent function running every frame button is held down
			}
		return;
	}

// check for attack
	if (self.button0)
	{
		W_Attack (FALSE);
	}
	else if (self.button1)
	{
		W_Attack (TRUE);
	}
};

/*
========
	ClassChangeWeapon - Player is changing class so change weapon model to match. Called from C code
========
*/
void ClassChangeWeapon(void)
{
	self.drawflags(-)MLS_ABSLIGHT|DRF_TRANSLUCENT;

	if(self.sheep_time>time)
		return;

	self.weaponframe = 0;
	if (self.playerclass==CLASS_PALADIN)
	{
		if (self.weapon == IT_WEAPON1)
		{
			self.th_weapon=gauntlet_select;
			self.weaponmodel = GAUNT_TEXMOD;
		}
		else if (self.weapon == IT_WEAPON2)
		{
			self.th_weapon=vorpal_select;
			self.weaponmodel = "models/vorpal.mdl";
		}
		else if (self.weapon == IT_WEAPON3)
		{
			self.th_weapon=axe_select;
			self.weaponmodel = AXE_TEXMOD;
		}
		else if (self.weapon == IT_WEAPON4)
		{
			self.th_weapon=purifier_select;
			self.weaponmodel = "models/purifier.mdl";
		}
		else if (self.weapon == IT_WEAPON5)
		{
			self.th_weapon=gauntlet_select;
			self.weaponmodel = GAUNT_TEXMOD;
		}
		else if (self.weapon == IT_WEAPON6)
		{
			self.th_weapon=gauntlet_select;
			self.weaponmodel = GAUNT_TEXMOD;
		}
	}
	else if (self.playerclass==CLASS_CRUSADER)
	{
		if (self.weapon == IT_WEAPON1)
		{
			self.th_weapon=warhammer_select;
			self.weaponmodel = HAMMER_TEXMOD;
		}
		else if (self.weapon == IT_WEAPON2)
		{
			self.th_weapon=icestaff_select;
			self.weaponmodel = "models/icestaff.mdl";
		}
		else if (self.weapon == IT_WEAPON3)
		{
			self.th_weapon=meteor_select;
			self.weaponmodel = "models/meteor.mdl";
		}
		else if (self.weapon == IT_WEAPON4)
		{
			self.th_weapon=sunstaff_select;
			self.weaponmodel = "models/sunstaff.mdl";
		}
		else if (self.weapon == IT_WEAPON5)
		{
			self.th_weapon=warhammer_select;
			self.weaponmodel = HAMMER_TEXMOD;
		}
		else if (self.weapon == IT_WEAPON6)
		{
			self.th_weapon=warhammer_select;
			self.weaponmodel = HAMMER_TEXMOD;
		}
	}
	else if (self.playerclass==CLASS_NECROMANCER)
	{
		if (self.weapon == IT_WEAPON1)
		{
			self.th_weapon=sickle_select;
			self.weaponmodel = SICKLE_TEXMOD;
		}
		else if (self.weapon == IT_WEAPON2)
		{
			self.th_weapon=sickle_select;
			self.weaponmodel = "models/sickle.mdl";  // FIXME: still need these models
		}
		else if (self.weapon == IT_WEAPON3)
		{
			self.th_weapon=sickle_select;
			self.weaponmodel = "models/sickle.mdl";
		}
		else if (self.weapon == IT_WEAPON4)
		{
			self.th_weapon=ravenstaff_select;
			self.weaponmodel = "models/ravenstf.mdl";
		}
		else if (self.weapon == IT_WEAPON5)
		{
			self.th_weapon=sickle_select;
			self.weaponmodel = SICKLE_TEXMOD;
		}
		else if (self.weapon == IT_WEAPON6)
		{
			self.th_weapon=sickle_select;
			self.weaponmodel = SICKLE_TEXMOD;
		}
	}
	else if (self.playerclass==CLASS_ASSASSIN)
	{
		if (self.weapon == IT_WEAPON1)
		{
			self.th_weapon=punchdagger_select;
			self.weaponmodel = PDGR_TEXMOD;
		}
		else if (self.weapon == IT_WEAPON2)
		{
			self.th_weapon=crossbow_select;
			self.weaponmodel = "models/crossbow.mdl";
		}
		else if (self.weapon == IT_WEAPON3)
		{
			self.th_weapon=grenade_select;
			self.weaponmodel = "models/v_assgr.mdl";
		}
		else if (self.weapon == IT_WEAPON4)
		{
			self.th_weapon=setstaff_select;
			self.weaponmodel = "models/scarabst.mdl";
		}
		else if (self.weapon == IT_WEAPON5)
		{
			self.th_weapon=punchdagger_select;
			self.weaponmodel = PDGR_TEXMOD;
		}
		else if (self.weapon == IT_WEAPON6)
		{
			self.th_weapon=punchdagger_select;
			self.weaponmodel = PDGR_TEXMOD;
		}
	}
//FIXME: take off all timed effects, lighting tinting, drawflags,
//	power-ups, etc.  Reset max health, abilities, etc.
	SetModelAndThinks();
	self.act_state=ACT_STAND;
//	self.think=self.th_stand;
}


void W_SetCurrentWeapon (void) 
{
	if(self.attack_finished>time)
		return;

	if(self.sheep_time>time)
		return;

	self.button0=FALSE;
	//attck_cnt=0;

	if (self.oldweapon==self.weapon)		// Until we get multi skinned weapons
		return;

	self.attack_finished=time + 999;
	W_DeselectWeapon ();
}


/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/sickle.hc,v 1.3 2007-02-07 16:57:09 sezero Exp $
 */

/*
==============================================================================

Q:\art\models\weapons\sickle\final\sickle.hc

==============================================================================
*/

// For building the model
$cd Q:\art\models\weapons\sickle\final
$origin 0 0 0
$base BASE skin
$skin skin
$flags 0


//
$frame rootpose     

//
$frame 1swipe4      1swipe5      
$frame 1swipe6      1swipe7      1swipe10     
$frame 1swipe14     
$frame 1swipe15     1swipe16     1swipe17     

//  frame 10 - 
$frame 2swipe1      2swipe2      2swipe3            
$frame 2swipe6      2swipe7      2swipe8      2swipe9          
$frame 2swipe12     2swipe13     2swipe14     

// frame 20
$frame 3swipe1      3swipe5      
$frame 3swipe7      3swipe8      3swipe9      3swipe10     
$frame 3swipe11     3swipe12     3swipe13     3swipe14     

//
$frame select1      select2      select3      select4      select5      
$frame select6      select7      select8      select9      select10     

float SICKLE_LIGHTNING_RANGE = 450;
float SICKLE_LIGHTNING_DIV = 14; //doubling damage too early makes this overpowered
float SICKLE_LIGHTNING_DIV_TOME = 5;
float SICKLE_LIGHTNING_MAX = 7;
//float RAISE_DEAD_COST = 13;

string SICKLE_TEXMOD = "models/sickle.mdl"

void monster_spider_yellow_large(void);
void monster_spider_red_large(void);
void monster_scorpion_yellow (void);
void monster_scorpion_black (void);
void monster_werejaguar (void);
void monster_mummy(void);
void CorpseThink(void);
void sickle_ready(void);
void phase_init(void);

void minion_solid()
{
	float dist;
	dist = vlen(self.enemy.origin - self.controller.origin);
	if (dist > 80)
	{
		self.enemy.owner = world;	//enemy is the minion in question; owner was the player who summoned it
		remove(self);
		return;
	}
	self.think = minion_solid;
	self.nextthink = time + 0.1;
}

void minion_init()
{
	float level;
	
	//intmod = self.cnt;
	level = self.cnt + self.aflag;	//cnt is player level, aflag is monster class (0, grunt, henchman, leader, boss, final boss)
	self.cnt = 0;
	self.aflag = 0;
	
	phase_init();
	newmis = spawn();	//create entity that makes the summoned monster solid to the player only if the player is far enough away not to be blocked
	newmis.enemy = self;
	newmis.controller = self.controller;
	newmis.think = minion_solid;
	newmis.nextthink = time + 1;
	
	if (level > 11)
		monster_mummy();
	else if (level > 8)
		monster_death_knight();		//monster_werejaguar(); does not work! probably uses .enemy field in way that interferes w/ summoned monster logic
	else if (level > 5)
		monster_scorpion_black();
	else if (level > 3)
		monster_scorpion_yellow();
	else if (level > 2)
		monster_spider_yellow_large();
	else if (level > 1)
		monster_spider_red_small();
	else
		monster_spider_yellow_small();
	
	self.experience_value = 0; //no XP for summoned monsters
	self.th_die = chunk_death; //summoned monsters explode, don't respawn
	thinktime self : 0;
}

void minion_summon(entity body, float intmod, float level)
{
	vector newpos, newangles;
	entity newmis;
	
	newpos = body.origin;
	newangles = body.angles;
	
	//gib body
	body.think = chunk_death;	
	body.nextthink = 0.1;
	
	//ghost effect
	starteffect(CE_GHOST, body.origin,'0 0 30', 0.1);
	
	//spawn monster
	
	newmis = spawn ();
	newmis.origin = newpos + '0 0 7';
	newmis.angles = newangles;
	
	newmis.flags2 (+) FL_SUMMONED;
	newmis.flags2 (+) FL_ALIVE;
	newmis.lifetime = time + (intmod * 2);
	newmis.think = minion_init;
	newmis.nextthink = time + 0.05;
	newmis.controller = self;
	newmis.owner = self;
	newmis.preventrespawn = TRUE;// mark so summoned monster cannot respawn
	newmis.playercontrolled = TRUE;
	
	if(self.enemy!=world&&self.enemy.flags2&FL_ALIVE&&visible2ent(self.enemy,self))
	{
		newmis.enemy=newmis.goalentity=self.enemy;
	}
	else
	{
		newmis.enemy=newmis.goalentity=self; // follow player		
	}
	newmis.monster_awake=TRUE; //start awake
	newmis.team=self.team;
	
	//User count property to choose spawn type
	newmis.aflag = body.monsterclass;
	newmis.cnt = level;		//ws: changed from int to level for perfectly consistent level scaling results (since attribute raising is randomized)
	if (self.artifact_active&ART_TOMEOFPOWER)
		newmis.cnt *= 2;		//monster tier will be higher when tomed
}

void sickle_lightning_fire ()
{
	vector	source;
	vector	org;
	float damg;
	float intmod, wismod;
	float number_strikes;
	float lightning_div;
	float tome, litrange;
	
	tome = self.artifact_active&ART_TOMEOFPOWER;
	
	intmod = self.intelligence;
	wismod = self.wisdom;

	litrange = SICKLE_LIGHTNING_RANGE + intmod * 5;
	lightning_div = SICKLE_LIGHTNING_DIV_TOME;
	
	damg = 18 + wismod / 4;		//increased damage since its only a tomed attack now -ws
	
	number_strikes = 0;
	while (intmod / lightning_div >= 1)
	{
		number_strikes += 1;
		intmod -= lightning_div;
	}
	if (number_strikes > SICKLE_LIGHTNING_MAX)
	{
		number_strikes = SICKLE_LIGHTNING_MAX;
	}
	if (number_strikes < 1)
	{
		number_strikes = 1;
	}

	makevectors (self.v_angle);
	source = self.origin + self.proj_ofs;
	traceline (source, source + v_forward*litrange, FALSE, self);
	if (trace_fraction == 1.0)
	{
		traceline (source, source + v_forward*litrange - (v_up * 30), FALSE, self);  // 30 down
		if (trace_fraction == 1.0)
		{
			traceline (source, source + v_forward*litrange + v_up * 30, FALSE, self);  // 30 up
			if (trace_fraction == 1.0)
				return;
		}
	}

	org = trace_endpos + (v_forward * 4);

	self.enemy = trace_ent;
	if (trace_ent.takedamage)
	{
		CastLightning(number_strikes, damg);		
	}
	else
	{
		// hit wall
		if (vlen(self.origin - trace_endpos) > 96)	//dont hit as far as lightning would strike, only hit near the player
			return;
		
		sound (self, CHAN_WEAPON, "weapons/hitwall.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
		
		CreateWhiteFlash(trace_endpos - v_forward*8);
	}
}

void shockwave ()
{
	AdvanceFrame(0,9);
	
	self.drawflags = DRF_TRANSLUCENT|MLS_FULLBRIGHT;
	
	self.origin = self.owner.origin;
	
	if(self.lifetime<time)
		remove(self);
		
	self.think = shockwave;
	thinktime self : .05;
}


void sickle_fire (float altfire)
{
	vector	source;
	vector	org;
	float damg, damage_mod, damage_base;
	float chance,point_chance,drain_ok;
	float strmod, intmod, wismod;
	
	strmod = self.strength;
	intmod = self.intelligence;
	wismod = self.wisdom;
	
	if (altfire)
	{
		sound(self,CHAN_BODY,"skullwiz/gate.wav",1,ATTN_NORM);
		newmis = spawn();
		newmis.origin = self.origin;
		newmis.owner = self;
		newmis.lifetime = time + .8;
		setmodel(newmis, "models/proj_ringshock.mdl");
		newmis.think = shockwave;
		thinktime newmis : .1;
		
		float minions;
		entity risen;
		risen = findradius(self.origin, 360);
		while(risen)
		{
			if ((risen.flags & FL_MONSTER) && risen.health > 0 && risen.team != self.team)
				self.enemy = risen;
			
			if (visible(risen) && risen.takedamage && !risen.flags2&FL_ALIVE && risen.think == CorpseThink && !risen.playercontrolled && !risen.preventrespawn)
			{
				minion_summon(risen, intmod, self.level);
				CreateRedFlash(risen.origin + '0 0 8');
				
				minions+=1;
			}
			risen = risen.chain;
		}
		
		float drain = random(3,6)+minions+(rint(self.level*0.5));
		T_Damage (self, world, world, drain);
		SpawnPuff (self.origin + self.proj_ofs, '0 0 0', drain*2, self);
	}

	makevectors (self.v_angle);
	source = self.origin + self.proj_ofs;
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

	org = trace_endpos;
	
	if (trace_ent.takedamage)
	{
		// Necromancer stands a chance of vampirically stealing health points
		if(teamplay && trace_ent.team == self.team)
			drain_ok=FALSE;
		else
			drain_ok=TRUE;

		if  (drain_ok && (trace_ent.flags & FL_MONSTER || trace_ent.flags & FL_CLIENT) && (self.level >= 6))
		{
//			msg_entity=self;
//			WriteByte (MSG_ONE, SVC_SET_VIEW_TINT);
//			WriteByte (MSG_ONE, 168);

			chance = (self.level - 5) * .04;
			if (chance > .20)
				chance = .2;

			if (random() < chance)
			{
			//	point_chance = (self.level - 5) * 2;
			//	if (point_chance > 10)
			//		point_chance = 10;
			/* Pa3PyX -- This HAS TO change: One will be dead 3 times
			 * before stealing their 10 hit points at clvl 10 in 5 hits
			 * trying to hack away at a medusa or an archer lord. This
			 * has to be at least 20 to make any practical use of this
			 * level 6 ability, and at most that, since spiders can be
			 * leeched from fairly easily (but they will still caw at
			 * you at least twice before your hit actually drains).
			 * Given that you cannot leech from dead bodies.	*/
				point_chance = (self.level - 5) * 4;
				if (point_chance > 20)
					point_chance = 20;

				sound (self, CHAN_BODY, "weapons/drain.wav", 1, ATTN_NORM);

			//	self.health += point_chance;
			//	if (self.health>self.max_health)
			//		self.health = self.max_health;
			//	Pa3PyX: no longer cancel mystic urn effect
				if (self.health < self.max_health) {
					self.health += point_chance;
					if (self.health>self.max_health)
						self.health = self.max_health;
				}
			}
		}
		
		/*if (self.artifact_active & ART_TOMEOFPOWER)	//original tomed mode
		{
			damage_base = WEAPON1_PWR_BASE_DAMAGE;
			damage_mod = WEAPON1_PWR_ADD_DAMAGE;

			CreateWhiteFlash(org);

			if(trace_ent.mass<=10)
				inertia=1;
			else
				inertia=trace_ent.mass/10;

			if ((trace_ent.hull != HULL_BIG) && (inertia<1000) && (trace_ent.classname != "breakable_brush"))
			{
				if (trace_ent.mass < 1000)
				{
					dir =  trace_ent.origin - self.origin;
					trace_ent.velocity = dir * WEAPON1_PUSH*(1/inertia);
					if(trace_ent.movetype==MOVETYPE_FLY)
					{
						if(trace_ent.flags&FL_ONGROUND)
							trace_ent.velocity_z=200/inertia;
					}
					else
						trace_ent.velocity_z = 200/inertia;
					trace_ent.flags(-)FL_ONGROUND;
				}
			}
		}
		else
		{
			damage_base = WEAPON1_BASE_DAMAGE;
			damage_mod = WEAPON1_ADD_DAMAGE;
		}*/
		
		damage_base = WEAPON1_BASE_DAMAGE;	//12
		damage_mod = strmod;				//~12 to start
		damg = random(damage_mod + damage_base,damage_base);
		
		SpawnPuff (org + (v_forward*4), '0 0 0', damg,trace_ent);
		Knockback (trace_ent, self, self, 9.5, 0.25);	//dont want to use damg, because knockback already scales with strength
		T_Damage (trace_ent, self, self, damg);
		
		if (trace_ent.thingtype == THINGTYPE_FLESH)
		{
			self.weaponmodel = "models/sickleblood.mdl";
			SICKLE_TEXMOD = "models/sickleblood.mdl";
		}

		if (!MetalHitSound(trace_ent.thingtype))
			sound (self, CHAN_WEAPON, "weapons/slash.wav", 1, ATTN_NORM);
	}
	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "weapons/hitwall.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);

		org = trace_endpos - v_forward;
		
		if (altfire)
			CreateLittleWhiteFlash(org + '0 0 4');
		else
			CreateSpark (org + v_right*15 - '0 0 26');
	}
	
	if (altfire)
		self.attack_finished=time + 0.75;
}

void raisedead_fire (void)
{
	self.wfs = advanceweaponframe($2swipe1,$2swipe14);
	self.th_weapon=raisedead_fire;
	self.last_attack=time;

	if (self.weaponframe==$2swipe1)
		sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1, ATTN_NORM);
	else if (self.weaponframe == $2swipe3)
	{
		//bone_raise_dead();
		sickle_fire (TRUE);
	}

	if (self.wfs == WF_LAST_FRAME)
		sickle_ready();
}

void sickle_ready (void)
{
	self.th_weapon=sickle_ready;
	self.weaponframe = $rootpose;
	
	self.weaponmodel = SICKLE_TEXMOD;
}


void () sickle_c =
{
	self.th_weapon=sickle_c;
	self.wfs = advanceweaponframe($3swipe1,$3swipe14);

	if (self.weaponframe==$3swipe1)
		sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1, ATTN_NORM);
	else if (self.weaponframe == $3swipe7)
		sickle_fire(FALSE);
	if (self.wfs==WF_LAST_FRAME)
		sickle_ready();
};

void () sickle_b =
{
	self.th_weapon=sickle_b;
	self.wfs = advanceweaponframe($2swipe1,$2swipe14);

	if (self.weaponframe==$2swipe1)
		sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1, ATTN_NORM);
	else if (self.weaponframe == $2swipe3)
		sickle_fire(FALSE);
	else if (self.wfs == WF_LAST_FRAME)
		sickle_ready();
};

void () sickle_a =
{
	self.th_weapon=sickle_a;
	self.wfs = advanceweaponframe($1swipe4,$1swipe17);

	if (self.weaponframe==$1swipe4)
		sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1, ATTN_NORM);
	else if (self.weaponframe == $1swipe5)
		sickle_fire(FALSE);
	else if (self.wfs == WF_LAST_FRAME)
		sickle_ready();
};

void () sickle_lightning =
{
	self.th_weapon=sickle_lightning;
	self.wfs = advanceweaponframe($2swipe1,$2swipe14);

	if (self.weaponframe==$2swipe1)
		sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1, ATTN_NORM);
	else if (self.weaponframe == $2swipe3)
		sickle_lightning_fire();
	else if (self.wfs == WF_LAST_FRAME)
		sickle_ready();
};

void sickle_select (void)
{
	//selection sound?
	self.th_weapon=sickle_select;
	self.wfs = advanceweaponframe($select10,$select1);
	self.weaponmodel = SICKLE_TEXMOD;
	if(self.wfs==WF_CYCLE_STARTED)
		sound(self,CHAN_WEAPON,"weapons/unsheath.wav",1,ATTN_NORM);
	if (self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		sickle_ready();
	}
}

void sickle_deselect (void)
{
	self.th_weapon=sickle_deselect;
	self.wfs = advanceweaponframe($select1,$select10);
	if (self.wfs==WF_CYCLE_WRAPPED)
		W_SetCurrentAmmo();
}

void sickle_decide_attack (float rightclick)
{
	if (rightclick)
	{
		raisedead_fire ();
	}
	else
	{
		if (self.artifact_active & ART_TOMEOFPOWER)
			sickle_lightning ();
		else
		{
			if (self.attack_cnt < 1)
				sickle_a ();
			else
			{
				sickle_b ();
				self.attack_cnt = -1;
			}

			self.attack_cnt += 1;
		}
	}
	self.attack_finished = time + 0.5;
}


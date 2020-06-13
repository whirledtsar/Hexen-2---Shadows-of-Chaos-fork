/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/axe.hc,v 1.2 2007-02-07 16:56:55 sezero Exp $
 */

/*
==============================================================================

Q:\art\models\weapons\axe\final\axe.hc

==============================================================================
*/

// For building the model
$cd Q:\art\models\weapons\axe\final
$origin 10 -10 10
$base BASE skin
$skin skin
$flags 0

$frame AxeRoot1

$frame 1stAxe1      1stAxe2      1stAxe3      1stAxe4      1stAxe5
$frame 1stAxe6      1stAxe7      1stAxe8      
$frame 1stAxe11     1stAxe12     1stAxe14     
$frame 1stAxe15     1stAxe17     1stAxe18          
$frame 1stAxe21     1stAxe22     1stAxe23
$frame 1stAxe25     1stAxe27     

float AXE_THROW_COST		= 4;
float AXE_THROW_TOMECOST	= 3;
float AXE_MELEE_COST		= 2;

string AXE_TEXMOD		= "models/axe.mdl";

void() T_PhaseMissileTouch;

void axeblade_exp(void)
{
	sound (self, CHAN_WEAPON, "weapons/explode.wav", 1, ATTN_NORM);

	if (self.classname == "powerupaxeblade")
		CreateBlueExplosion (self.origin);
	else
		starteffect(CE_SM_EXPLOSION , self.origin);
}

void axeblade_hitwall(void)
{
	if (self.classname == "powerupaxeblade")
		CreateBSpark (self.origin - '0 0 30');
	else
		CreateSpark (self.origin - '0 0 30');
}

void axeblade_gone(void)
{
	sound (self, CHAN_VOICE, "misc/null.wav", 1, ATTN_NORM);
	sound (self, CHAN_WEAPON, "misc/null.wav", 1, ATTN_NORM);

	if (self.skin==0)
		CreateLittleWhiteFlash(self.origin);
	else
		CreateLittleBlueFlash(self.origin);

	remove(self.goalentity);
	remove(self);
}

void axeblade_run (void) [ ++ 0 .. 5]
{
//dvanceFrame(0,5);
	if (self.lifetime < time)
		axeblade_gone();
}


void axetail_run (void)
{
	if(!self.owner)
		remove(self);
	else
	{
		self.origin = self.owner.origin;
		self.velocity = self.owner.velocity;
		self.owner.angles = vectoangles(self.velocity);
		self.angles = self.owner.angles;
		self.origin = self.owner.origin;
	}
}


void launch_axtail (entity axeblade)
{
	local entity tail;

	tail = spawn ();
	tail.movetype = MOVETYPE_NOCLIP;
	tail.solid = SOLID_NOT;
	tail.classname = "ax_tail";
	setmodel (tail, "models/axtail.mdl");
	setsize (tail, '0 0 0', '0 0 0');		
	tail.drawflags (+)DRF_TRANSLUCENT;

	tail.owner = axeblade;
	tail.origin = tail.owner.origin;
	tail.velocity = tail.owner.velocity;
    tail.angles = tail.owner.angles;

	axeblade.goalentity = tail;
}

void launch_axe (vector dir_mod,vector angle_mod, float damg, float tome)
{
	entity missile;

	self.attack_finished = time + 0.4;

	missile = spawn ();

	CreateEntityNew(missile,ENT_AXE_BLADE,"models/axblade.mdl",SUB_Null);

	missile.owner = self;
	missile.netname = "axeblade";
		
	// set missile speed	
	makevectors (self.v_angle + dir_mod);
	missile.velocity = normalize(v_forward);
	missile.velocity = missile.velocity * 900;
	
	missile.touch = T_PhaseMissileTouch;
	missile.th_die = axeblade_exp;	//called by T_PhaseMissileTouch
	missile.blocked = axeblade_hitwall;

	// Point it in the proper direction
    missile.angles = vectoangles(missile.velocity);
	missile.angles += angle_mod;

	// set missile duration
	missile.counter = 2;  // Can hurt two things before disappearing
	missile.hoverz = 4;		// Maximum things (both wall and shootable) to hit before exploding
	missile.cnt = 0;		// Counts number of times it has hit walls
	missile.lifetime = time + 2;  // Or lives for 2 seconds and then dies when it hits anything

	setorigin (missile, self.origin + self.proj_ofs  + v_forward*10 + v_right * 1);

//sound (missile, CHAN_VOICE, "paladin/axblade.wav", 1, ATTN_NORM);

	if (tome)
	{
		missile.frags=TRUE;
		missile.classname = "powerupaxeblade";
		missile.skin = 1;
		missile.drawflags = (self.drawflags & MLS_MASKOUT)| MLS_POWERMODE;
	}
	else
		missile.classname = "axeblade";
	
	missile.dmg = damg;
	missile.sightsound = "paladin/axric1.wav";	//used by T_PhaseMissileTouch when reflecting
	
	thinktime missile : HX_FRAME_TIME;
	missile.think = axeblade_run;

	launch_axtail(missile);
}

void axe_melee (float damage_base,float damage_mod,float mode)	//using FireMelee didn't work because it checked whether to use mana after doing damage, so if its victim died it wouldnt recognize it as a valid target and use mana. also it was making the wrong hit sound.
{
	vector	source;
	vector	org;
	float damg;

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
		if (trace_ent.thingtype == THINGTYPE_FLESH)
		{
			AXE_TEXMOD = "models/axeblood.mdl";
			self.weaponmodel = "models/axeblood.mdl";
		}
		
		if (trace_ent.flags & FL_MONSTER || trace_ent.flags & FL_CLIENT)
			self.greenmana-=AXE_MELEE_COST*mode;	//mode 0 for no mana, mode 3 for tomed, mode 1 for normal
		
		damg = random(damage_mod+damage_base,damage_base);
		SpawnPuff (org, '0 0 0', damg,trace_ent);
		if (trace_ent.flags & FL_ONGROUND)
			Knockback (trace_ent, self, self, 12+mode, 0.2);
		else
			Knockback (trace_ent, self, self, 12+mode, -1);
		T_Damage (trace_ent, self, self, damg);
		
		if (!MetalHitSound(trace_ent.thingtype))
			sound (self, CHAN_WEAPON, "weapons/slash.wav", 1, ATTN_NORM);
	}
	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "weapons/hitwall.wav", 1, ATTN_NORM);
		CreateWhiteSmoke(trace_endpos - v_forward*8,'0 0 2',HX_FRAME_TIME);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
	
	if (mode > 1)	//tomed
		CreateWhiteFlash(trace_endpos - v_forward*6);
}

/*
================
axeblade_fire
================
*/
void(float rightclick, float tome) axeblade_fire =
{
	float damg;
	float strmod, dexmod;
	
	strmod = self.strength;
	dexmod = self.dexterity;
	
	if (rightclick)
	{
		if (tome && self.greenmana >= AXE_MELEE_COST*3)
			axe_melee (strmod*3, strmod*3.25, 3);
		else if (self.greenmana >= AXE_MELEE_COST)
			axe_melee (strmod*1.2, strmod*1.6, 1);
		else
			axe_melee (strmod*0.8, strmod*1.2, 0);
	}
	else
	{
		damg = 20 + random(dexmod*1.5, dexmod*2);	//dex starts at ~12, so ~45
		if (tome && self.greenmana >= AXE_THROW_COST + AXE_THROW_TOMECOST)
		{
			sound (self, CHAN_WEAPON, "paladin/axgenpr.wav", 1, ATTN_NORM);

			launch_axe('0 0 0','0 0 0', damg, tome);	// Middle

			launch_axe('0 5 0','0 0 0', damg, tome);    // Side
			launch_axe('0 -5 0','0 0 0', damg, tome);   // Side

			self.greenmana -= AXE_THROW_COST + AXE_THROW_TOMECOST;
		}
		else if (self.greenmana >= AXE_THROW_COST)	//regular throw
		{
			sound (self, CHAN_WEAPON, "paladin/axgen.wav", 1, ATTN_NORM);

			launch_axe('0 0 0','0 0 300', damg, tome);
			self.greenmana -= AXE_THROW_COST;
		}
		else if (self.greenmana >= AXE_MELEE_COST)	//not enough mana for throw, do altfire
			axe_melee (strmod*1.25, strmod*1.75, 1);
		else	//dry melee
			axe_melee (strmod*0.25, strmod*0.75, 0);
	}
	
};

void axe_ready (void)
{
	self.th_weapon=axe_ready;
	self.weaponframe = $AxeRoot1;
	
	self.weaponmodel = AXE_TEXMOD;
}

void axe_select (void)
{
	self.wfs = advanceweaponframe($1stAxe18,$1stAxe3);
	if (self.weaponframe == $1stAxe14)
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);

	self.weaponmodel = AXE_TEXMOD;
	self.th_weapon=axe_select;
	self.last_attack=time;

	if (self.wfs == WF_LAST_FRAME)
	{
		self.attack_finished = time - 1;
		axe_ready();
	}
}

void axe_deselect (void)
{
	self.wfs = advanceweaponframe($1stAxe18,$1stAxe3);
	self.th_weapon=axe_deselect;
	self.oldweapon = IT_WEAPON3;

	if (self.wfs == WF_LAST_FRAME)
		W_SetCurrentAmmo();
}

void axe_b ()	//altfire
{
	float tome;
	tome = self.artifact_active & ART_TOMEOFPOWER;
	
	self.wfs = advanceweaponframe($1stAxe1,$1stAxe25);
	self.th_weapon = axe_b;

	// These frames are used during selection animation
	if ((self.weaponframe >= $1stAxe2) && (self.weaponframe <= $1stAxe4))
		self.weaponframe +=1;
	else if ((self.weaponframe >= $1stAxe6) && (self.weaponframe <= $1stAxe7))
		self.weaponframe +=1;

	if (self.weaponframe == $1stAxe15)
	{
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);
		axeblade_fire(TRUE, tome);
	}

	if (self.wfs == WF_LAST_FRAME)
		axe_ready();
	
	self.attack_finished = time + .1;
}

void axe_a ()	//normal fire
{
	float tome;
	tome = self.artifact_active & ART_TOMEOFPOWER;
	
	self.wfs = advanceweaponframe($1stAxe1,$1stAxe25);
	self.th_weapon = axe_a;

	// These frames are used during selection animation
	if ((self.weaponframe >= $1stAxe2) && (self.weaponframe <= $1stAxe4))
		self.weaponframe +=1;
	else if ((self.weaponframe >= $1stAxe6) && (self.weaponframe <= $1stAxe7))
		self.weaponframe +=1;

	if (self.weaponframe == $1stAxe15)
	{
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);
		axeblade_fire(FALSE, tome);
	}

	if (self.wfs == WF_LAST_FRAME)
		axe_ready();
	
	if (tome)
  		self.attack_finished = time + .7;
	else
  		self.attack_finished = time + .35;
}

void pal_axe_fire()
{
	float rightclick;
	
	rightclick = self.button1;
	
	if (rightclick)
		axe_b();
	else
		axe_a();
}


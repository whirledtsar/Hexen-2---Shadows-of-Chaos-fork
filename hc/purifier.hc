/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/purifier.hc,v 1.3 2007-03-18 08:11:02 sezero Exp $
 */

/*
==============================================================================

Q:\art\models\weapons\purifier\final\purifier.hc

==============================================================================
*/

// For building the model
$cd Q:\art\models\weapons\purifier\final
$origin 0 0 0
$base BASE skin
$skin skin
$flags 0

//
$frame Rootpose     
//
$frame 1Lshot1      1Lshot2      1Lshot3      

//
$frame 1Rshot1      1Rshot2      1Rshot3      

//
$frame 2Lshot1      2Lshot2      2Lshot3      

//
$frame 2Rshot1      2Rshot2      2Rshot3      

//
$frame 3Rshot1      3Rshot2      3Rshot3      

//
$frame bigshot1     bigshot2     bigshot3     bigshot4     bigshot5     
$frame bigshot6     bigshot7     bigshot8     bigshot9     

//
$frame select1      select2      select3      select4      select5      
$frame select6      select7      select8      select9      select10     
$frame select11     select12          


//==================================================================

float PFLAME_COST = 5;

void purifier_ready (void);

void pshot_gone(void)
{
	float damg;

	if (other.health)
	{
		damg = 30 + random(30);
		T_Damage (other, self, self.owner, damg);
	}

	remove(self);
}

void pflame1_runup (void) [++ 0 .. 16 ]
{
	if (cycle_wrapped)
		if(self.cnt)
		{
			self.cnt-=1;
			particle2(self.origin+'0 0 17','0 0 25','0 0 25',168,7,5);
		}
		else
			remove(self);
}

void pflame2_runup (void) [++ 17 .. 33 ]
{
	if (cycle_wrapped)
		if(self.cnt)
		{
			self.cnt-=1;
			particle2(self.origin+'0 0 17','0 0 25','0 0 25',168,7,5);
		}
		else
			remove(self);
}

void pflame3_runup (void) [++ 34 .. 50 ]
{
	if (cycle_wrapped)
		if(self.cnt)
		{
			self.cnt-=1;
			particle2(self.origin+'0 0 17','0 0 25','0 0 25',168,7,5);
		}
		else
			remove(self);
}

void pflame_burn(void)
{
	float damg;

	if ((other.health) && (other != self.owner) && (self.pain_finished<time))
	{
		damg = self.dmg + random() * self.dmg;
		T_Damage (other, self, self.owner, damg);
		self.pain_finished = time + .05;
		if(self.t_width<time)
		{
			sound(self,CHAN_BODY,"crusader/sunhit.wav",1,ATTN_NORM);
			self.t_width=time+0.1;
		}
	}
}


void SpawnPFlame(void)
{
	entity new;
	float chance;

	traceline(self.origin,self.origin - '0 0 600',TRUE,self);

	if (trace_fraction==1)
		return;

	if(pointcontents(trace_endpos)==CONTENT_WATER)
	{
		remove(self);
		return;
	}

	new = spawn();

	CreateEntityNew(new,ENT_MUMMY_FIRE,"models/mumshot.mdl",SUB_Null);

	setorigin(new, trace_endpos);
	new.owner = self.owner;
	new.pain_finished = 0;
	new.drawflags=MLS_ABSLIGHT;
	new.abslight=0.5;
	new.angles = self.angles;
	new.dmg=6;
	
	chance = random();
	if (chance < .33)
		new.think = pflame1_runup;
	else if (chance < .66)
		new.think = pflame2_runup;
	else
		new.think = pflame3_runup;

	thinktime new : HX_FRAME_TIME;

	new.touch = pflame_burn;

	if(self.classname=="circfire")
	{
		new.angles = self.angles +'0 -90 0';
		new.scale=2.5;
		new.cnt=10;
		particle2(new.origin+'0 0 17','0 0 25','0 0 25',168,7,5);
	}
	else if (self.lifetime < time)
	{
		remove(self);
	}
	else
	{
		particle2(new.origin,'0 0 25','0 0 25',168,7,5);

	//	self.nextthink = time + .04;
		thinktime self : .04;

		self.think = SpawnPFlame;
	}
}

void launch_pflame ()
{
	vector dir;
	
	self.last_attack=time;

	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	setmodel (newmis,"models/mumshot.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	makevectors (self.angles);
	setorigin (newmis, self.origin);

	dir = v_forward;
	dir_z = 0;
	
	newmis.velocity = normalize(dir);
	newmis.velocity = newmis.velocity * 400;
	newmis.classname = "mumshot";
	newmis.angles = vectoangles(newmis.velocity);

	newmis.touch = pshot_gone;

	CreateRedFlash(self.origin + v_forward*-14 + v_right * 15 + v_up * 50);

	newmis.effects = EF_NODRAW;
	sound (self, CHAN_WEAPON, "mummy/mislfire.wav", 1, ATTN_NORM);

	newmis.lifetime = time + 2.5;

// set missile duration
//	newmis.nextthink = time + .04;
	thinktime newmis : .04;

	newmis.think = SpawnPFlame;

}

void pmissile_gone(void)
{
	sound (self, CHAN_VOICE, "misc/null.wav", 1, ATTN_NORM);
	sound (self, CHAN_WEAPON, "misc/null.wav", 1, ATTN_NORM);
	remove(self);
}

/*
============
pmissile_touch - missile1 hit something. Hurt it
============
*/
void pmissile_touch (void)
{
	float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		pmissile_gone();
		return;
	}

	damg = random(15,25);
	if (other.health)
		T_Damage (other, self, self.owner, damg );

	//sound (self, CHAN_BODY, "weapons/expsmall.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	CreateFireCircle(self.origin - (v_forward * 8));

	self.effects = EF_NODRAW;
	self.solid = SOLID_NOT;
	self.nextthink = time + .5;  // So explosion sound can finish out
	self.think = pmissile_gone;
}

/*
============
smokering_run - the life and death of a smoke ring FIXME: this should be done client side
============
*/
void   smokering_run(void)
{
	self.scale += 0.12;
	self.nextthink = time + HX_FRAME_TIME + random(HX_FRAME_TIME);
	self.think = smokering_run;

	if ((self.lifetime - time) < .30)
		self.skin = 4;
	else if ((self.lifetime - time) < .60)
		self.skin = 3;
	else if ((self.lifetime - time) < .90)
		self.skin = 2;
	else if ((self.lifetime - time) < 1.20)
		self.skin = 1;
	else
		self.skin = 0;
	
	if (self.lifetime < time)
		remove(self);
}

/*
============
pmissile2_touch - missile2 hit something. Hurt it bad
============
*/
void pmissile2_touch (void)
{
	float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		pmissile_gone();
		return;
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	damg = random(150,200);
	if (other.health)
		T_Damage (other, self, self.owner, damg );

	damg = random(120,160);
	T_RadiusDamage (self, self.owner, damg, other);

	sound (self, CHAN_BODY, "weapons/exphuge.wav", 1, ATTN_NORM);

	self.origin = self.origin - 8*normalize(self.velocity);
	self.effects = EF_NODRAW;
	self.solid = SOLID_NOT;

	CreateExplosion29(self.origin - (v_forward * 8));

	self.nextthink = time + .5;
	self.think = pmissile_gone;
}

/*
============
pmissile2_puff - create smoke ring behind missile
============
*/
void pmissile2_puff(void)
{
	entity smokering;
	// Not using it till we get the smoke animation in
	smokering = spawn ();
	smokering.owner = self;
	smokering.movetype = MOVETYPE_FLYMISSILE;
	smokering.solid = SOLID_BBOX;

	smokering.classname = "puffring";
		
	// set missile speed		
	smokering.angles = self.angles + '0 0 90';

	// set missile duration
	setmodel (smokering, "models/ring.mdl");
	setsize (smokering, '0 0 0', '0 0 0');		
	smokering.drawflags(+)DRF_TRANSLUCENT;
	smokering.origin = self.origin;
	smokering.velocity_z = 15;
	smokering.nextthink = time + .01;
	smokering.think = smokering_run;
	smokering.lifetime = time + 1.2;
	smokering.drawflags(+)SCALE_ORIGIN_CENTER;
	smokering.scale =1;
	smokering.owner = self;
	self.nextthink = time + .15;
	self.think = pmissile2_puff;

	if(time>self.lifetime - 1.7)	//Don't start tracking until it's been in the world 1/3 of a second
	{
		HomeThink();
		self.angles=vectoangles(self.velocity);
	}

	if (self.lifetime < time)	// Kill missile if it's time is up
		pmissile_gone();
		
}

/*
============
launch_pmissile2 - create and launch power up missile
============
*/
void launch_pmissile2 (void)
{
	local entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.frags=TRUE;

	missile.classname = "purimissile";
			
	// set missile speed	
	makevectors (self.v_angle);
	missile.velocity = normalize(v_forward);
    missile.velocity = missile.velocity * 1000;
	
	missile.touch = pmissile2_touch;
	missile.angles = vectoangles(missile.velocity);

	sound (self, CHAN_VOICE, "paladin/purfireb.wav", 1, ATTN_NORM);

	setmodel (missile, "models/drgnball.mdl");
	setsize (missile, '0 0 0', '0 0 0');		

//	setorigin (missile, self.origin + v_forward*10 + v_right * 1 + v_up * 40);
	setorigin (missile, self.origin + self.proj_ofs + v_forward*10);

	missile.effects=EF_BRIGHTLIGHT;
	missile.nextthink = time + .15;
	missile.think = pmissile2_puff;
	missile.lifetime = time + 2;
//Homing stuff-------------------
	missile.veer=FALSE;	//No random wandering
	missile.turn_time=3;//Lower the number, tighter the turn
	missile.speed=1000;	//Speed
	missile.ideal_yaw=TRUE;//Only track things in front
//End homing stuff-------------------
	self.greenmana -= 8;
	self.bluemana -= 8;

}

void purifier_flamefire (void)
{
	self.wfs = advanceweaponframe($bigshot1,$bigshot9);
	self.th_weapon=purifier_flamefire;
	if(self.weaponframe==$bigshot2)
	{
		self.punchangle_x= -4;
		launch_pflame();
		self.attack_finished = time + 0.65;
		
		self.greenmana -= PFLAME_COST;
		self.bluemana -= PFLAME_COST;
	}
	else if(self.wfs==WF_CYCLE_WRAPPED)
			purifier_ready();
}

/*
============
purifier_tomefire - firing animation when in power up mode
============
*/
void purifier_tomefire (void)
{
	self.wfs = advanceweaponframe($bigshot1,$bigshot9);
	self.th_weapon=purifier_tomefire;
	if(self.weaponframe==$bigshot2)
	{
		self.punchangle_x= -4;
		launch_pmissile2 ();
		self.attack_finished = time + 0.5;
	}
	else if(self.wfs==WF_CYCLE_WRAPPED)
			purifier_ready();
}

/*
============
launch_pmissile1 - create and launch normal missile
============
*/
void launch_pmissile1 (void)
{
	local entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;

	missile.classname = "purimissile";
		
// set missile speed	
	makevectors (self.v_angle);
	missile.velocity = normalize(v_forward);
    missile.velocity = missile.velocity * 1000;
	missile.touch = pmissile_touch;
	missile.angles = vectoangles(missile.velocity);

// set missile duration
    setmodel (missile, "models/purfir1.mdl");
	setsize (missile, '0 0 0', '0 0 0');		

	if ((self.cnt==1) || (self.cnt==3))
		setorigin (missile, self.origin + self.proj_ofs + v_forward*6 + v_right * 10 );
	else if ((self.cnt==0) || (self.cnt==2))
		setorigin (missile, self.origin +self.proj_ofs + v_forward*6 - v_right * 10);

	sound (self, CHAN_WEAPON, "paladin/purfire.wav", 1, ATTN_NORM);

	self.cnt += 1;

	if (self.cnt > 3)
		self.cnt =0;


	missile.drawflags=MLS_ABSLIGHT;
	missile.abslight=1;

	missile.nextthink = time + 2.5;
	missile.think = pmissile_gone;

	self.greenmana -= 1;
	self.bluemana -= 1;
}

/*
============
purifier_rapidfire? - different rapid fire animations
============
*/
void purifier_rapidfire2R (void)
{
	self.wfs = advanceweaponframe($2Rshot1,$2Rshot3);
	self.th_weapon=purifier_rapidfire2R;

	if (self.weaponframe == $2Rshot3)
		self.punchangle_x= random(-3);

	if (self.attack_finished <= time&&(self.button0 || self.button1))
		launch_pmissile1();

	if (self.wfs==WF_CYCLE_WRAPPED)
		purifier_ready();
}

void purifier_rapidfire2L (void)
{
	self.wfs = advanceweaponframe($2Lshot1,$2Lshot3);
	self.th_weapon=purifier_rapidfire2L;

	if (self.weaponframe == $1Lshot3)
		self.punchangle_x= random(-3);

	if (self.attack_finished <= time&&(self.button0 || self.button1))
		launch_pmissile1();

	if (self.wfs==WF_CYCLE_WRAPPED)
		purifier_ready();
}

void purifier_rapidfire1R (void)
{
	self.wfs = advanceweaponframe($1Rshot1,$1Rshot3);
	self.th_weapon=purifier_rapidfire1R;

	if (self.weaponframe == $1Rshot3)
		self.punchangle_x= random(-3);

	if (self.attack_finished <= time&&(self.button0 || self.button1))
		launch_pmissile1();

	if (self.wfs==WF_CYCLE_WRAPPED)
		purifier_ready();
}

void purifier_rapidfire1L (void)
{
	self.wfs = advanceweaponframe($1Lshot1,$1Lshot3);
	self.th_weapon=purifier_rapidfire1L;

	if (self.weaponframe == $1Lshot3)
		self.punchangle_x= random(-3);

	if (self.attack_finished <= time&&(self.button0 || self.button1))
		launch_pmissile1();

	if (self.wfs==WF_CYCLE_WRAPPED)
		purifier_ready();
}

/*
============
purifier_rapidfire - choose which rapid fire animation to use
============
*/
void purifier_rapidfire (void)
{
	
	if (self.counter ==0)
		purifier_rapidfire1L();
	else if (self.counter ==1)
		purifier_rapidfire1R();
	else if (self.counter ==2)
		purifier_rapidfire2L();
	else if (self.counter ==3)
		purifier_rapidfire2R();

	self.counter += 1;
	self.attack_finished = time + .14;

	if (self.counter > 3)
		self.counter =0;
}

/*
============
purifier_fire - shoot purifier.
============
*/

void pflame_run (void) [ ++ 0 .. 26]
{
//dvanceFrame(0,5);
	if (self.lifetime < time)
		pmissile_gone();
}

void flamestream_touch ()
{
	if(other.classname=="fball")
		return;
	self.effects(+)EF_MUZZLEFLASH;
	if(other.takedamage)
		T_Damage(other,self,self.owner,self.dmg);
	else
		T_RadiusDamage(self,self.owner,self.dmg*2,self.owner);	
	if(self.frame<24)
		self.frame=24;
}


void launch_fball ()
{
	entity missile;
	//float sndcount = 3;

	//sndcount = sndcount +1;
	
	self.attack_finished = time + 0.1;

	missile = spawn ();

	CreateEntityNew(missile,ENT_AXE_BLADE,"models/eidoflam.spr",SUB_Null);
	if(self.t_width<time)
		{
//			sound(self,CHAN_VOICE,"misc/fburn_bg.wav",1,ATTN_NONE);
			sound(self,CHAN_VOICE,"eidolon/flambrth.wav",1,ATTN_NONE);
			self.t_width=time+0.5;
		}
	
	missile.owner = self;
	missile.classname = "fball";
	missile.scale = 0.5;
		
	// set missile speed	
	makevectors (self.v_angle);
	missile.velocity = normalize(v_forward);
	missile.velocity = missile.velocity * 400;
	
	missile.touch = flamestream_touch;
	//missile.touch = pmissile2_puff;

	// Point it in the proper direction
    missile.angles = vectoangles(missile.velocity);
	//missile.angles += angle_mod;

	// set missile duration
	missile.counter = 4;  // Can hurt two things before disappearing
	missile.cnt = 0;		// Counts number of times it has hit walls
	missile.lifetime = time + .5;  // Or lives for 2 seconds and then dies when it hits anything
	setorigin (missile, self.origin + self.proj_ofs  + v_forward*10 + v_right * 1);

//sound (missile, CHAN_VOICE, "paladin/axblade.wav", 1, ATTN_NORM);

	/*if (tome)
	{
		missile.frags=TRUE;
		missile.classname = "powerupaxeblade";
		missile.skin = 1;
		missile.drawflags = (self.drawflags & MLS_MASKOUT)| MLS_POWERMODE;
	}*/
	//else
		//missile.classname = "axeblade";
	
	missile.dmg = 5;

	missile.lifetime = time + .5;
	thinktime missile : HX_FRAME_TIME;
	//missile.think = pmissile2_puff;
	missile.think = pflame_run;
	
	self.greenmana -= 1.5;
	self.bluemana -= 1.5;
	
	
	//missile.think = pmissile2_puff;

	//launch_axtail(missile);

}

void purifier_tomeflamer()
{
	self.wfs = advanceweaponframe($bigshot1,$bigshot9);
	//self.th_weapon=launch_fball;
	if(self.weaponframe==$bigshot1)
	{
		self.punchangle_x= -4;
		launch_fball();
		self.attack_finished = time + 0.1;
	}
	else if(self.wfs==WF_CYCLE_WRAPPED)
			purifier_ready();
}

void() pal_purifier_fire =
{
	if ((self.artifact_active & ART_TOMEOFPOWER) && self.button1 && self.greenmana >= PFLAME_COST && self.bluemana >= PFLAME_COST)
		purifier_tomeflamer();
	else if ((self.artifact_active & ART_TOMEOFPOWER) &&
		(self.greenmana >= 8) && (self.bluemana >= 8))
		purifier_tomefire();
	else if (self.button1 && self.greenmana >= PFLAME_COST && self.bluemana >= PFLAME_COST)
		purifier_flamefire();
	else if ((self.greenmana >= 1) && (self.bluemana >= 1))
		purifier_rapidfire();

	self.nextthink=time;
};


/*
============
purifier_ready - just sit there until fired
============
*/
void purifier_ready (void)
{
	self.weaponframe = $Rootpose;
	self.wfs = $Rootpose;
	self.th_weapon=purifier_ready;
}

/*
============
purifier_deselect - purifier was just unchosen. Remove from view
============
*/
void purifier_deselect (void)
{
	self.wfs = advanceweaponframe($Select12,$Select1);
	self.th_weapon=purifier_deselect;
	self.oldweapon = IT_WEAPON4;

	if (self.wfs == WF_LAST_FRAME)
		W_SetCurrentAmmo();
}

/*
============
purifier_select - purifier was just chosen. Bring into view
============
*/
void purifier_select (void)
{
	self.wfs = advanceweaponframe($select1,$select12);
	self.weaponmodel = "models/purifier.mdl";
	self.th_weapon=purifier_select;
	self.counter = 0;

	if (self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		purifier_ready();
	}
}


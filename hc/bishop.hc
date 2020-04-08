/*
==============================================================================

Dark Bishop

==============================================================================
*/

$cd id1/models/bishop
$origin 0 0 24
$base base
$skin badass3

void() dark_bishop_dodge1;
void() dark_bishop_warp1;

void()	dark_bishop_fire1	=[	0,	dark_bishop_fire2	] {};
void()	dark_bishop_fire2	=[	1,	dark_bishop_fire1	] {};

void()	dark_bishop_pdie1	=[	0,	dark_bishop_pdie2	] {sound (self, CHAN_AUTO, "bishop/tdam.wav", 1, ATTN_NORM);};
void()	dark_bishop_pdie2	=[	1,	dark_bishop_pdie3	] {};
void()	dark_bishop_pdie3	=[	2,	dark_bishop_pdie4	] {};
void()	dark_bishop_pdie4	=[	3,	dark_bishop_pdie5	] {};
void()	dark_bishop_pdie5	=[	4,	dark_bishop_pdie5	] {remove(self);};

void()	dark_bishop_dsprite9		=[	8,	dark_bishop_dsprite10	] {};
void()	dark_bishop_dsprite10	=[	9,	dark_bishop_dsprite11	] {};
void()	dark_bishop_dsprite11	=[	10,	dark_bishop_dsprite12	] {};
void()	dark_bishop_dsprite12	=[	11,	dark_bishop_dsprite12	] {remove(self);};


void()	dark_bishop_float1	=[	0,	dark_bishop_float2	] {ai_stand();};
void()	dark_bishop_float2	=[	1,	dark_bishop_float3	] {ai_stand();};
void()	dark_bishop_float3	=[	2,	dark_bishop_float4	] {ai_stand();};
void()	dark_bishop_float4	=[	3,	dark_bishop_float5	] {ai_stand();if (random() < 0.01)
{
	sound (self, CHAN_VOICE, "bishop/idle.wav", 1,  ATTN_IDLE); }else if (random () > 0.01 && random() < 0.02) sound (self, CHAN_VOICE, "bishop/idle2.wav", 1,  ATTN_IDLE);};
void()	dark_bishop_float5	=[	4,	dark_bishop_float6	] {ai_stand();};
void()	dark_bishop_float6	=[	5,	dark_bishop_float7	] {ai_stand();};
void()	dark_bishop_float7	=[	6,	dark_bishop_float8	] {ai_stand();};
void()	dark_bishop_float8	=[	7,	dark_bishop_float9	] {ai_stand();};
void()	dark_bishop_float9	=[	8,	dark_bishop_float10	] {ai_stand();};
void()	dark_bishop_float10	=[	9,	dark_bishop_float11	] {ai_stand();};
void()	dark_bishop_float11	=[	10,	dark_bishop_float1	] {ai_stand();};

void()	dark_bishop_walk1	=[	0,		dark_bishop_walk2	] {
if (random() < 0.02)
	sound (self, CHAN_VOICE, "bishop/idle2.wav", 1,  ATTN_IDLE);
ai_walk(3);};
void()	dark_bishop_walk2	=[	1,		dark_bishop_walk3	] {ai_walk(2);};
void()	dark_bishop_walk3	=[	2,		dark_bishop_walk4	] {ai_walk(3);};
void()	dark_bishop_walk4	=[	3,		dark_bishop_walk5	] {ai_walk(4);};
void()	dark_bishop_walk5	=[	4,		dark_bishop_walk6	] {ai_walk(3);};
void()	dark_bishop_walk6	=[	5,		dark_bishop_walk7	] {ai_walk(3);};
void()	dark_bishop_walk7	=[	6,		dark_bishop_walk8	] {ai_walk(3);};
void()	dark_bishop_walk8	=[	7,		dark_bishop_walk9	] {ai_walk(4);};
void()	dark_bishop_walk9	=[	8,		dark_bishop_walk10	] {ai_walk(3);};
void()	dark_bishop_walk10	=[	9,	dark_bishop_walk11	] {ai_walk(3);};
void()	dark_bishop_walk11	=[	10,	dark_bishop_walk1	] {ai_walk(2);};


void()	dark_bishop_run1	=[	0,		dark_bishop_run2	] {ai_run(4);};
void()	dark_bishop_run2	=[	1,		dark_bishop_run3	] {ai_run(4);};
void()	dark_bishop_run3	=[	2,		dark_bishop_run4	] {ai_run(3);};
void()	dark_bishop_run4	=[	3,		dark_bishop_run5	] {ai_run(4);};
void()	dark_bishop_run5	=[	4,		dark_bishop_run6	] {ai_run(4);if (random() < 0.05)
	sound (self, CHAN_VOICE, "bishop/idle2.wav", 1,  ATTN_IDLE);};
void()	dark_bishop_run6	=[	5,		dark_bishop_run7	] {ai_run(4);};
void()	dark_bishop_run7	=[	6,		dark_bishop_run8	] {ai_run(3);if (random() < 0.4) dark_bishop_warp1();};
void()	dark_bishop_run8	=[	7,		dark_bishop_run9	] {ai_run(4);};
void()	dark_bishop_run9	=[	8,		dark_bishop_run10	] {ai_run(3);if (random() < 0.03) dark_bishop_dodge1();};
void()	dark_bishop_run10	=[	9,		dark_bishop_run11	] {ai_run(4);};
void()	dark_bishop_run11	=[	10,		dark_bishop_run1	] {ai_run(4);};


/*
void bishop_blur ()
{
vector rollangle;
	makevectors(self.angles);
	rollangle=vectoangles(v_right);
	if (pointcontents(self.origin) != CONTENT_SOLID)
	{
		if(walkmove(rollangle_x,15-self.cnt/2,FALSE))
		{
			particle(self.origin-v_right*(20 - self.cnt/2), '0 0 70', 344, 10);
			self.drawflags(+)DRF_TRANSLUCENT;
			if(random()<0.2)
				CreateGreenSmoke(self.origin-v_right*(10-self.cnt/2),'0 0 8',HX_FRAME_TIME * 2);
		}
		else
		{
			self.cnt+=1;
			self.think=bishop_blur;
			thinktime self : 0.05;
		}
	}
}*/

void bishop_blur ()
{
	self.drawflags(+)DRF_TRANSLUCENT;
	self.origin = self.origin + v_right*19;
	if(random()<0.2)
		CreateGreenSmoke(self.origin-v_right*(10-self.cnt/2),'0 0 8',HX_FRAME_TIME * 2);
} 

void bishop_blur_left ()
{
	self.drawflags(+)DRF_TRANSLUCENT;
	self.origin = self.origin + -v_right*19;
	if(random()<0.2)
		CreateGreenSmoke(self.origin-v_right*(10-self.cnt/2),'0 0 8',HX_FRAME_TIME * 2);
} 

void()	dark_bishop_dodge1	=[	16,		dark_bishop_dodge2	] {
	sound (self, CHAN_AUTO, "bishop/blur.wav", 1,  ATTN_IDLE);};
void()	dark_bishop_dodge2	=[	17,		dark_bishop_dodge3	] {bishop_blur();};
void()	dark_bishop_dodge3	=[	16,		dark_bishop_dodge4	] {bishop_blur();};
void()	dark_bishop_dodge4	=[	17,		dark_bishop_dodge5	] {bishop_blur();};
void()	dark_bishop_dodge5	=[	16,		dark_bishop_dodge6	] {bishop_blur();};
void()	dark_bishop_dodge6	=[	17,		dark_bishop_run1	] {bishop_blur();self.drawflags(-)DRF_TRANSLUCENT;};

void()	dark_bishop_dodgel1	=[	16,		dark_bishop_dodgel2	] {
	sound (self, CHAN_AUTO, "bishop/blur.wav", 1,  ATTN_IDLE);};
void()	dark_bishop_dodgel2	=[	17,		dark_bishop_dodgel3	] {bishop_blur_left();};
void()	dark_bishop_dodgel3	=[	16,		dark_bishop_dodgel4	] {bishop_blur_left();};
void()	dark_bishop_dodgel4	=[	17,		dark_bishop_dodgel5	] {bishop_blur_left();};
void()	dark_bishop_dodgel5	=[	16,		dark_bishop_dodgel6	] {bishop_blur_left();};
void()	dark_bishop_dodgel6	=[	17,		dark_bishop_run1	] {bishop_blur_left();self.drawflags(-)DRF_TRANSLUCENT;};

void()	dark_bishop_warp1	=[	15,		dark_bishop_warp2	] {self.drawflags(+)DRF_TRANSLUCENT;
sound(self,CHAN_AUTO,"bishop/blur.wav",1,ATTN_NORM);
ai_charge(1);};
void()	dark_bishop_warp2	=[	16,		dark_bishop_warp3	] {ai_charge(19);CreateGreenSmoke(self.origin,'0 0 0',HX_FRAME_TIME);};
void()	dark_bishop_warp3	=[	17,		dark_bishop_warp4	] {ai_charge(19);};
void()	dark_bishop_warp4	=[	16,		dark_bishop_warp5	] {ai_charge(19);CreateGreenSmoke(self.origin,'0 0 0',HX_FRAME_TIME);};
void()	dark_bishop_warp5	=[	17,		dark_bishop_warp6	] {ai_charge(19);};
void()	dark_bishop_warp6	=[	16,		dark_bishop_warp7	] {ai_charge(19);CreateGreenSmoke(self.origin,'0 0 0',HX_FRAME_TIME);};
void()	dark_bishop_warp7	=[	17,		dark_bishop_run1	] {ai_charge(19);self.drawflags(-)DRF_TRANSLUCENT;};

/*

void()	dark_bishop_runatk1	=[	$runattack1,		dark_bishop_runatk2	]
{
if (random() > 0.5)
	sound (self, CHAN_WEAPON, "death_knight/sword2.wav", 1, ATTN_NORM);
else
	sound (self, CHAN_WEAPON, "death_knight/sword1.wav", 1, ATTN_NORM);
ai_charge(20);
};
void()	dark_bishop_runatk2	=[	$runattack2,	dark_bishop_runatk3	] {ai_charge_side();};
void()	dark_bishop_runatk3	=[	$runattack3,	dark_bishop_runatk4	] {ai_charge_side();};
void()	dark_bishop_runatk4	=[	$runattack4,	dark_bishop_runatk5	] {ai_charge_side();};
void()	dark_bishop_runatk5	=[	$runattack5,	dark_bishop_runatk6	] {ai_melee_side();};
void()	dark_bishop_runatk6	=[	$runattack6,	dark_bishop_runatk7	] {ai_melee_side();};
void()	dark_bishop_runatk7	=[	$runattack7,	dark_bishop_runatk8	] {ai_melee_side();};
void()	dark_bishop_runatk8	=[	$runattack8,	dark_bishop_runatk9	] {ai_melee_side();};
void()	dark_bishop_runatk9	=[	$runattack9,	dark_bishop_runatk10	] {ai_melee_side();};
void()	dark_bishop_runatk10	=[	$runattack10,	dark_bishop_runatk11	] {ai_charge_side();};
void()	dark_bishop_runatk11	=[	$runattack11,	dark_bishop_run1	] {ai_charge(10);};

*/
void(float offset, float seeking) FireHomingMissile;

void()	dark_bishop_atk1	=[	11,		dark_bishop_atk2	]
{
sound(self,CHAN_AUTO,"bishop/atk.wav",0.7,ATTN_NORM);
ai_charge(0);};
void()	dark_bishop_atk2	=[	12,		dark_bishop_atk3	] {ai_charge(0);};
void()	dark_bishop_atk3	=[	13,		dark_bishop_atk4	] {ai_charge(0);if (random() < 0.2) dark_bishop_dodgel1();};
void()	dark_bishop_atk4	=[	14,		dark_bishop_atk5	] {ai_charge(0);};
void()	dark_bishop_atk5	=[	15,		dark_bishop_atk6	] {ai_charge(3);};
void()	dark_bishop_atk6	=[	16,		dark_bishop_atk7	] {ai_charge(1);FireHomingMissile(0,TRUE);};
void()	dark_bishop_atk7	=[	17,		dark_bishop_atk8	] {ai_charge(3);};
void()	dark_bishop_atk8	=[	18,		dark_bishop_atk9	] {ai_charge(0);FireHomingMissile(0,TRUE);};
void()	dark_bishop_atk9	=[	16,		dark_bishop_atk10	] {ai_charge(1);};
void()	dark_bishop_atk10	=[	17,		dark_bishop_atk11	] {ai_charge(3);FireHomingMissile(0,TRUE);};
void()	dark_bishop_atk11	=[	18,		dark_bishop_atk12	] {ai_charge(0);};
void()	dark_bishop_atk12	=[	19,		dark_bishop_atk13] {ai_charge(1);FireHomingMissile(0,TRUE);};
void()	dark_bishop_atk13=[	20,		dark_bishop_atk14	] {ai_charge(0);if (random() < 0.25) dark_bishop_dodge1();};
void()	dark_bishop_atk14=[	21,		dark_bishop_atk15	] {ai_charge(0);};
void()	dark_bishop_atk15=[	22,		dark_bishop_atk16	] {ai_charge(0);};
void()	dark_bishop_atk16=[	23,		dark_bishop_atk17	] {ai_charge(0);};
void()	dark_bishop_atk17=[	24,		dark_bishop_run1	] {ai_charge(0);};

//void()	dark_bishop_atk9	=[	$attack9,		dark_bishop_atk10	] {};
//void()	dark_bishop_atk10	=[	$attack10,		dark_bishop_atk11	] {};
//void()	dark_bishop_atk11	=[	$attack11,		dark_bishop_run1	] {};

//===========================================================================

void()	dark_bishop_pain1	=[	25,	dark_bishop_pain2	] {};
void()	dark_bishop_pain2	=[	26,	dark_bishop_pain3	] {if (random() > 0.4) dark_bishop_dodgel1();};
void()	dark_bishop_pain3	=[	27,	dark_bishop_pain4	] {};
void()	dark_bishop_pain4	=[	28,	dark_bishop_pain5	] {};
void()	dark_bishop_pain5	=[	29,	dark_bishop_pain6	] {ai_pain(2);};
void()	dark_bishop_pain6	=[	30,	dark_bishop_pain7	] {if (random() > 0.4) dark_bishop_dodge1(); else dark_bishop_dodgel1();};
void()	dark_bishop_pain7	=[	31,	dark_bishop_pain8	] {};
void()	dark_bishop_pain8	=[	32,	dark_bishop_pain9	] {};
void()	dark_bishop_pain9	=[	33,	dark_bishop_pain10	] {};
void()	dark_bishop_pain10	=[	34,	dark_bishop_pain11	] {};
void()	dark_bishop_pain11	=[	35,	dark_bishop_run1	] {};

void(entity attacker, float damage)	dark_bishop_pain =
{
	if (self.pain_finished > time)
		return;

	sound (self, CHAN_VOICE, "bishop/pain.wav", 1, ATTN_NORM);
	ThrowGib ("models/blood.mdl", self.health);
	dark_bishop_pain1 ();
	self.pain_finished = time + 1;
	
};

/*
void() bishop_fx 
{
	newmis = spawn ();
	newmis.drawflags(+)DRF_TRANSLUCENT;
	newmis.owner = self;
	newmis.origin = self.origin + '0 0 33';
	setmodel (newmis, "models/grndth.spr");
	newmis.think = bishop_dsprite9;
	newmis.nextthink = time + 0.1;
	
}*/

//===========================================================================


void()	dark_bishop_die1	=[	36,	dark_bishop_die2	] {self.movetype = MOVETYPE_FLY;};
void()	dark_bishop_die2	=[	37,	dark_bishop_die3	] {/*setsize (self, '-17 -17 -9', '17 17 2');*/};
void()	dark_bishop_die3	=[	38,	dark_bishop_die4	] {};
void()	dark_bishop_die4	=[	39,	dark_bishop_die5	] {};
void()	dark_bishop_die5	=[	40,	dark_bishop_die6	] {};
void()	dark_bishop_die6	=[	41,	dark_bishop_die7	] {};
void()	dark_bishop_die7	=[	42,	dark_bishop_die8	] {};
void()	dark_bishop_die8	=[	43,	dark_bishop_die9	] {};
void()	dark_bishop_die9	=[	44,	dark_bishop_die10] {};
void()	dark_bishop_die10=[	45,	dark_bishop_die11] {};
void()	dark_bishop_die11=[	46,	dark_bishop_die12] {};
void()	dark_bishop_die12=[	47,	dark_bishop_die13] {};
void()	dark_bishop_die13=[	48,	dark_bishop_die14] {};
void()	dark_bishop_die14=[	49,	dark_bishop_die15] {ThrowGib ("models/fog.spr", self.health);};
void()	dark_bishop_die15=[	50,	dark_bishop_die15] {ThrowGib ("models/fog.spr", self.health);ThrowGib ("models/fog.spr", self.health);ThrowGib ("models/fog.spr", self.health);CreateGreenSmoke(self.origin,'0 0 0',HX_FRAME_TIME);chunk_death();sound (self, CHAN_VOICE, "death_knight/gib2.wav", 1, ATTN_NORM);ThrowGib ("models/blood.mdl", self.health);ThrowGib ("models/blood.mdl", self.health);};


void() dark_bishop_die =
{
// gib check not needed
	/*if (self.health < -30)
	{
		//sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NORM);
		chunk_death();
	}*/

// regular death
	sound (self, CHAN_VOICE, "bishop/death.wav", 1, ATTN_NORM);
	dark_bishop_die1 ();
	//if (self.frame == 87)
		
};

void() bmis_touch =
{
	setmodel (self, "models/grndie.spr");
	self.movetype = MOVETYPE_NONE;
	self.think = SUB_Remove;
	self.nextthink = time + 1.5;
	bishop_pdie1();
//float rand;
	//self.think = bishop_pdie1;
	if (other.classname == "worldspawn")
		sound (self, CHAN_AUTO, "bishop/tdam.wav", 1, ATTN_NORM);

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
		if (other.classname == "monster_bishop")
		{
			T_RadiusDamage (self, self.owner, 7, self);
			sound (self, CHAN_AUTO, "bishop/tdam.wav", 1, ATTN_NORM);
			remove(self);
		}
		else
		{
			spawn_touchpuff (6,other);
			T_Damage (other, self, self.owner, 7);
			//T_RadiusDamage (self, self.owner, 7, world);
			sound (self, CHAN_AUTO, "bishop/tdam.wav", 1, ATTN_NORM);
			remove(self);
		}
	}
};


void FireHomingMissile (float offset, float seeking)
{
	v_forward=self.v_angle;

	self.effects(+)EF_MUZZLEFLASH;
	newmis=spawn();
	newmis.angles = self.v_angle;
	//particle2(trace_endpos,'-30 -30 50','30 30 100',384,PARTICLETYPE_SPELL,80);
	//newmis.classname="magic missile";
	newmis.drawflags = MLS_FULLBRIGHT;
	newmis.owner=self;
	//newmis.drawflags(+)SCALE_ORIGIN_CENTER|MLS_FULLBRIGHT|MLS_CRYSTALGOLEM;//|DRF_TRANSLUCENT;
	newmis.movetype=MOVETYPE_FLYMISSILE;
	newmis.solid=SOLID_BBOX;

	newmis.touch=bmis_touch;

	newmis.speed=500;
	//newmis.velocity=normalize(v_forward)*newmis.speed + spread;
	newmis.velocity = normalize(self.enemy.origin - self.origin);
	newmis.velocity = newmis.velocity * 50;
	//newmis.movedir=normalize(newmis.velocity);
	newmis.avelocity_z=random(300,600);
	//newmis.avelocity_y=300;
	newmis.level=TRUE;

	setmodel(newmis,"models/bishop_proj.mdl");
	setsize(newmis,'0 0 0','0 0 0');

	newmis.scale=.8;
	setorigin(newmis,self.origin+self.proj_ofs+v_forward*8+v_right*7+'0 0 15');

	if(seeking)
	{		
		newmis.enemy=self.enemy;
		newmis.classname = "bishop star";
		newmis.turn_time=12;
		newmis.dmg=random(3,7);
		newmis.effects=EF_DIMLIGHT;
		newmis.frags=TRUE;
		newmis.veer=60;
		newmis.homerate=0.03;
		newmis.lifetime=time+5;
		newmis.th_die=chain_remove;
		newmis.think=HomeThink;
		newmis.hoverz=TRUE;
		thinktime newmis : 0.2;
	}
}

/*QUAKED monster_bishop (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_bishop =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	if (!self.flags2 & FL_SUMMONED && !self.flags2&FL2_RESPAWN)
		precache_bishop();
	
	//self.skin = 1;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "models/bishop.mdl");

	setsize (self, '-13 -13 -2', '13 13 45');
	if(!self.health)
		self.health = 200;
	
	self.thingtype=THINGTYPE_FLESH;
	
	self.netname="bishop";
	self.flags (+) FL_MONSTER;
	self.flags2 (+) FL_ALIVE;
	self.sightsound = "bishop/sight.wav";
	self.yaw_speed = 14;
	
	self.monsterclass = CLASS_LEADER;
	//self.hull=HULL_PLAYER;
	
	if(!self.experience_value)
		self.experience_value = 140;
	if(!self.mass)
		self.mass = 10;

	self.th_stand = dark_bishop_float1;
	self.th_walk = dark_bishop_walk1;
	self.th_run = dark_bishop_run1;
	self.th_melee = dark_bishop_atk1;
	self.th_missile = dark_bishop_atk1;
	self.th_pain = dark_bishop_pain;
	self.th_die = dark_bishop_die;
	self.th_init = monster_bishop;
	
	self.buff=2;
	flymonster_start ();
};
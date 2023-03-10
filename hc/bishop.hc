/*
==============================================================================

Dark Bishop

==============================================================================
*/

$cd id1/models/bishop
$origin 0 0 24
$base base
$skin badass3

float BISHOP_BLURSPEED = 15;

void() dark_bishop_dodge1;
void() dark_bishop_warp1;

void()	dark_bishop_fire1	=[	0,	dark_bishop_fire2	] {};
void()	dark_bishop_fire2	=[	1,	dark_bishop_fire1	] {};

void()	dark_bishop_pdie1	=[	0,	dark_bishop_pdie2	] {};
void()	dark_bishop_pdie2	=[	1,	dark_bishop_pdie3	] {};
void()	dark_bishop_pdie3	=[	2,	dark_bishop_pdie4	] {};
void()	dark_bishop_pdie4	=[	3,	dark_bishop_pdie5	] {};
void()	dark_bishop_pdie5	=[	4,	SUB_Remove	] {};

void()	dark_bishop_dsprite9		=[	8,	dark_bishop_dsprite10	] {};
void()	dark_bishop_dsprite10	=[	9,	dark_bishop_dsprite11	] {};
void()	dark_bishop_dsprite11	=[	10,	dark_bishop_dsprite12	] {};
void()	dark_bishop_dsprite12	=[	11,	dark_bishop_dsprite12	] {remove(self);};

void()	dark_bishop_float1	=[	0,	dark_bishop_float2	] {ai_stand();};
void()	dark_bishop_float2	=[	1,	dark_bishop_float3	] {ai_stand();};
void()	dark_bishop_float3	=[	2,	dark_bishop_float4	] {ai_stand();};
void()	dark_bishop_float4	=[	3,	dark_bishop_float5	] {ai_stand();if (random() < 0.01) {
	sound (self, CHAN_VOICE, "bishop/idle.wav", 1,  ATTN_IDLE); }
else if (random () > 0.01 && random() < 0.02)
	sound (self, CHAN_VOICE, "bishop/idle2.wav", 1,  ATTN_IDLE); };
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
void()	dark_bishop_run7	=[	6,		dark_bishop_run8	] {ai_run(3);if (random() < 0.4 && visible(self.enemy)) dark_bishop_warp1();};
void()	dark_bishop_run8	=[	7,		dark_bishop_run9	] {ai_run(4);};
void()	dark_bishop_run9	=[	8,		dark_bishop_run10	] {ai_run(3);if (random() < 0.03 && visible(self.enemy)) dark_bishop_dodge1();};
void()	dark_bishop_run10	=[	9,		dark_bishop_run11	] {ai_run(4);};
void()	dark_bishop_run11	=[	10,		dark_bishop_run1	] {ai_run(4);};

void bishop_blur ()
{
	self.drawflags(+)DRF_TRANSLUCENT;
	
	if (!walkmove (self.ideal_yaw + (90*self.lefty), BISHOP_BLURSPEED, FALSE)) {
		self.drawflags(-)DRF_TRANSLUCENT;
		self.th_pain = self.th_save;
		self.think = self.th_run;
	}
	
	if(random()<0.33)
		CreateGreenSmoke(self.origin-v_right*10,'0 0 5',HX_FRAME_TIME*2);
}

void()	dark_bishop_dodge1	=[	16,		dark_bishop_dodge2	] {
	self.lefty*=(-1);
	self.th_save = self.th_pain;
	self.th_pain = SUB_Null;
	sound (self, CHAN_AUTO, "bishop/blur.wav", 1,  ATTN_IDLE); };
void()	dark_bishop_dodge2	=[	17,		dark_bishop_dodge3	] {bishop_blur();};
void()	dark_bishop_dodge3	=[	16,		dark_bishop_dodge4	] {bishop_blur();};
void()	dark_bishop_dodge4	=[	17,		dark_bishop_dodge5	] {bishop_blur();};
void()	dark_bishop_dodge5	=[	16,		dark_bishop_dodge6	] {bishop_blur();};
void()	dark_bishop_dodge6	=[	17,		dark_bishop_run1	] {bishop_blur();
	self.drawflags(-)DRF_TRANSLUCENT; 
	self.th_pain = self.th_save; };

void()	dark_bishop_warp1	=[	15,		dark_bishop_warp2	] {self.drawflags(+)DRF_TRANSLUCENT;
sound(self,CHAN_AUTO,"bishop/blur.wav",1,ATTN_NORM);
ai_charge(1);};
void()	dark_bishop_warp2	=[	16,		dark_bishop_warp3	] {ai_charge(19);CreateGreenSmoke(self.origin,'0 0 0',HX_FRAME_TIME);};
void()	dark_bishop_warp3	=[	17,		dark_bishop_warp4	] {ai_charge(19);};
void()	dark_bishop_warp4	=[	16,		dark_bishop_warp5	] {ai_charge(19);CreateGreenSmoke(self.origin,'0 0 0',HX_FRAME_TIME);};
void()	dark_bishop_warp5	=[	17,		dark_bishop_warp6	] {ai_charge(19);};
void()	dark_bishop_warp6	=[	16,		dark_bishop_warp7	] {ai_charge(19);CreateGreenSmoke(self.origin,'0 0 0',HX_FRAME_TIME);};
void()	dark_bishop_warp7	=[	17,		dark_bishop_run1	] {ai_charge(19);self.drawflags(-)DRF_TRANSLUCENT;};

void(float total) InitBishopVolley;
void(entity newmis, vector dir) FireBishopMissile;

void()	dark_bishop_atk1	=[	11,		dark_bishop_atk2	] {
	sound(self,CHAN_AUTO,"bishop/atk.wav",0.7,ATTN_NORM);
	ai_face(); };
void()	dark_bishop_atk2	=[	12,		dark_bishop_atk3	] {ai_face(); };
void()	dark_bishop_atk3	=[	13,		dark_bishop_atk4	] {ai_face(); };
void()	dark_bishop_atk4	=[	14,		dark_bishop_atk5	] {ai_face(); };
void()	dark_bishop_atk5	=[	15,		dark_bishop_atk6	] {ai_face(); };
void()	dark_bishop_atk6	=[	19,		dark_bishop_atk7	] {ai_face(); };
void()	dark_bishop_atk7	=[	16,		dark_bishop_atk8	] {ai_face(); 
InitBishopVolley(5);
if (self.enemy)
	self.movedir = normalize((self.enemy.origin+self.enemy.proj_ofs) - (self.origin+self.proj_ofs));
else
	self.movedir = self.v_angle;
FireBishopMissile(self.path_current, self.movedir); };
void()	dark_bishop_atk8	=[	17,		dark_bishop_atk9	] {};
void()	dark_bishop_atk9	=[	18,		dark_bishop_atk10	] {};
void()	dark_bishop_atk10	=[	19,		dark_bishop_atk11	] {thinktime self : HX_FRAME_TIME*0.5; };
void()	dark_bishop_atk11	=[	16,		dark_bishop_atk12	] {FireBishopMissile(self.path_current.path_current, self.movedir); };
void()	dark_bishop_atk12	=[	17,		dark_bishop_atk13	] {};
void()	dark_bishop_atk13	=[	18,		dark_bishop_atk14	] {};
void()	dark_bishop_atk14	=[	19,		dark_bishop_atk15	] {thinktime self : HX_FRAME_TIME*0.5; };
void()	dark_bishop_atk15	=[	16,		dark_bishop_atk16	] {FireBishopMissile(self.path_current.path_current.path_current, self.movedir); };
void()	dark_bishop_atk16	=[	17,		dark_bishop_atk17	] {};
void()	dark_bishop_atk17	=[	18,		dark_bishop_atk18	] {};
void()	dark_bishop_atk18	=[	19,		dark_bishop_atk19	] {thinktime self : HX_FRAME_TIME*0.5; };
void()	dark_bishop_atk19	=[	16,		dark_bishop_atk20	] {FireBishopMissile(self.path_current.path_current.path_current.path_current, self.movedir); };
void()	dark_bishop_atk20	=[	17,		dark_bishop_atk21	] {};
void()	dark_bishop_atk21	=[	18,		dark_bishop_atk22	] {};
void()	dark_bishop_atk22	=[	19,		dark_bishop_atk23	] {thinktime self : HX_FRAME_TIME*0.5; };
void()	dark_bishop_atk23	=[	16,		dark_bishop_atk24	] {FireBishopMissile(self.path_current.path_current.path_current.path_current, self.movedir); };
void()	dark_bishop_atk24	=[	17,		dark_bishop_atk25	] {};
void()	dark_bishop_atk25	=[	18,		dark_bishop_atk26	] {};
void()	dark_bishop_atk26	=[	19,		dark_bishop_atk27	] {thinktime self : HX_FRAME_TIME*0.5; };
void()	dark_bishop_atk27	=[	16,		dark_bishop_atk28	] {FireBishopMissile(self.path_current.path_current.path_current.path_current.path_current, self.movedir); };
void()	dark_bishop_atk28	=[	17,		dark_bishop_atk29	] {};
void()	dark_bishop_atk29	=[	18,		dark_bishop_atk30	] {};
void()	dark_bishop_atk30	=[	19,		dark_bishop_atk31	] {thinktime self : HX_FRAME_TIME*0.5; };
void()	dark_bishop_atk31=[	20,		dark_bishop_atk32	] {SUB_AttackFinished(6); if (random() < 0.2) dark_bishop_dodge1();};
void()	dark_bishop_atk32=[	21,		dark_bishop_atk33	] {};
void()	dark_bishop_atk33=[	22,		dark_bishop_atk34	] {};
void()	dark_bishop_atk34=[	23,		dark_bishop_atk35	] {};
void()	dark_bishop_atk35=[	24,		dark_bishop_run1	] {};

//===========================================================================

void()	dark_bishop_pain1	=[	25,	dark_bishop_pain2	] {};
void()	dark_bishop_pain2	=[	26,	dark_bishop_pain3	] {if (random() > 0.5) dark_bishop_dodge1(); };
void()	dark_bishop_pain3	=[	27,	dark_bishop_pain4	] {ai_pain(1); };
void()	dark_bishop_pain4	=[	28,	dark_bishop_pain5	] {ai_pain(2); };
void()	dark_bishop_pain5	=[	29,	dark_bishop_pain6	] {ai_pain(4); };
void()	dark_bishop_pain6	=[	30,	dark_bishop_pain7	] {if (random() > 0.25) dark_bishop_dodge1(); };
void()	dark_bishop_pain7	=[	31,	dark_bishop_pain8	] {};
void()	dark_bishop_pain8	=[	32,	dark_bishop_pain9	] {};
void()	dark_bishop_pain9	=[	33,	dark_bishop_pain10	] {};
void()	dark_bishop_pain10	=[	34,	dark_bishop_pain11	] {};
void()	dark_bishop_pain11	=[	35,	dark_bishop_run1	] {};

void dark_bishop_blasted ()
{
	float result = AdvanceFrame(25, 35);
	
	if (self.blasted > 1) {
		ai_backfromenemy(self.blasted);
		self.blasted -= BLAST_DECEL;
	}
	
	if (result == AF_END)
		self.think = bishop_run1;
	else if (self.frame == 32) {
		if (random() > 0.25)
			dark_bishop_dodge1();
	}
	else
		self.think = bishop_blasted;
	thinktime self : HX_FRAME_TIME;
}

void(entity attacker, float damage)	dark_bishop_pain =
{
	if (self.pain_finished > time)
		return;

	sound (self, CHAN_VOICE, "bishop/pain.wav", 1, ATTN_NORM);
	ThrowGib ("models/blood.mdl", self.health);
	self.pain_finished = time + 1;
	dark_bishop_pain1();
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
void dark_bishop_fog ()
{	//CreateFog(self.finaldest);
	CreateGreySmoke(self.finaldest, randomv('-8 -8 1', '8 8 8'), HX_FRAME_TIME*4);
}

void()	dark_bishop_die1	=[	36,	dark_bishop_die2	] {self.movetype=MOVETYPE_NONE; };
void()	dark_bishop_die2	=[	37,	dark_bishop_die3	] {};
void()	dark_bishop_die3	=[	38,	dark_bishop_die4	] {};
void()	dark_bishop_die4	=[	39,	dark_bishop_die5	] {self.solid = SOLID_PHASE; };
void()	dark_bishop_die5	=[	40,	dark_bishop_die6	] {};
void()	dark_bishop_die6	=[	41,	dark_bishop_die7	] {self.finaldest = self.origin+'0 0 8'; dark_bishop_fog(); };
void()	dark_bishop_die7	=[	42,	dark_bishop_die8	] {self.finaldest = self.origin+'0 0 8'; self.finaldest_z += random(16); dark_bishop_fog(); };
void()	dark_bishop_die8	=[	43,	dark_bishop_die9	] {self.finaldest = self.origin+'0 0 8'; self.finaldest_z += random(8,24); dark_bishop_fog(); };
void()	dark_bishop_die9	=[	44,	dark_bishop_die10] {self.finaldest = self.origin+'0 0 8'; self.finaldest_z += random(16,32); dark_bishop_fog(); };
void()	dark_bishop_die10=[	45,	dark_bishop_die11] {self.finaldest = self.origin+'0 0 8'; self.finaldest_z += random(16,32); dark_bishop_fog(); };
void()	dark_bishop_die11=[	46,	dark_bishop_die12] {};
void()	dark_bishop_die12=[	47,	dark_bishop_die13] {};
void()	dark_bishop_die13=[	48,	dark_bishop_die14] {};
void()	dark_bishop_die14=[	49,	dark_bishop_die15] {};
void()	dark_bishop_die15=[	50,	dark_bishop_die15] {
	ThrowGib ("models/blood.mdl", self.health);
	ThrowGib ("models/blood.mdl", self.health);
	CreateGreenSmoke(self.origin,'0 0 0',HX_FRAME_TIME);
	chunk_death();
	sound (self, CHAN_VOICE, "death_knight/gib2.wav", 1, ATTN_NORM);
};


void() dark_bishop_die =
{
	sound (self, CHAN_VOICE, "bishop/death.wav", 1, ATTN_NORM);
	dark_bishop_die1 ();
};

void() bmis_touch =
{
	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing
	
	if (self.aflag) {	//if we are lead missile, try to make previous missile in chain the new lead
		entity next, newlead;
		next = self.path_current;
		newlead = world;
		while (next) {
			if (next.path_last == self) {
				newlead = next;
				next = world;	//end loop
			}
			else
				next = next.path_current;
		}
		if (newlead) {
			newlead.aflag = TRUE;
			newlead.path_last = world;
		}
		
		self.aflag = FALSE;
	}
	
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	sound (self, CHAN_AUTO, "bishop/tdam.wav", 1, ATTN_NORM);
	
	if (other.takedamage)
	{
		if (other.classname == "monster_bishop")
		{
			T_RadiusDamage (self, self.owner, self.dmg, other);
			remove(self);
		}
		else
		{
			spawn_touchpuff (6,other);
			T_Damage (other, self, self.owner, self.dmg);
			remove(self);
		}
		return;
	}
	
	setmodel (self, "models/grndie.spr");
	self.movetype = MOVETYPE_NONE;
	dark_bishop_pdie1();
};

void bmis_fly ()
{
	AdvanceFrame(0,4);
	thinktime self : 0.1;
	
	if (time > self.lifetime) {
		SpiralThink();
		return;
	}
	
	if (self.aflag) {
		HomeThink();
		vector newangles;
		newangles=vectoangles(self.velocity);
		self.angles_y=newangles_y;
		self.angles_x=newangles_x;
		return;
	}
	
	entity lead, last;
	last = self.path_last;
	lead = world;
	while (last) {			//find lead missile
		if (last.aflag) {
			lead = last;
			last = world;	//end loop
		}
		else if (!last.path_last) {		//no more missiles in chain past this one
			lead = last;
			lead.aflag = TRUE;
			last = world;	//end loop
		}
		else
			last = last.path_last;
	}
	if (!lead) {		//lead missile is gone, become new lead missile
		self.aflag = TRUE;
		HomeThink();
		return;
	}
	
	self.movedir = lead.movedir;		//follow direction of lead missile
	SpiralThink();
}

void FireBishopMissile (entity newmis, vector dir)
{
	if (!newmis)
		return;
	
	makevectors(self.angles);
	v_forward=self.v_angle;
	
	self.effects(+)EF_MUZZLEFLASH;
//identity
	//newmis=spawn();
	newmis.owner=self;
	newmis.classname = "bishop star";
//physics
	newmis.movetype=MOVETYPE_FLYMISSILE;
	newmis.solid=SOLID_BBOX;
//rendering
	newmis.drawflags(+)MLS_ABSLIGHT;
	newmis.effects(+)EF_DIMLIGHT;
	newmis.abslight=0.6;
	newmis.scale=0.5;
//appearance, size, origin
	setmodel(newmis,"models/bishop_proj.mdl");
	setsize(newmis,'0 0 0','0 0 0');
	setorigin(newmis,self.origin+self.proj_ofs+'0 0 20'+v_forward*20);
//impact
	newmis.touch=bmis_touch;
//velocity
	newmis.speed=250;
	newmis.velocity = dir * newmis.speed;
	newmis.movedir = normalize(newmis.velocity);
	newmis.angles = vectoangles(newmis.velocity);
	newmis.avelocity_z=500;
//behavior
	newmis.dmg=random(4,6);
//homing
	newmis.enemy=newmis.lockentity=self.enemy;
	newmis.homerate=0.075;
	newmis.hoverz=TRUE;
	newmis.lifetime=time+2.5;		//stop homing at this time
	newmis.turn_time=8;
	//newmis.th_die=SUB_Null;		//do this after lifetime expires
	newmis.veer=0;	//10
//spiraling
	newmis.anglespeed = 40;
//think
	newmis.think=bmis_fly;
	thinktime newmis : 0;
}

void InitBishopVolley (float total)
{
	float i;
	entity firstmis, lastmis;
	
	i = 0;
	firstmis = lastmis = world;
	//path_last = previous entity in chain
	//path_current = next entity in chain
	while (i < total) {		//create chain of missiles in order of spawning
		newmis = spawn();
		if (lastmis) {
			lastmis.path_current = newmis;
			newmis.path_last = lastmis;
		}
		else {
			self.path_current = newmis;		//remember head missile in chain for bishop
			newmis.aflag = TRUE;
		}
		lastmis = newmis;
		newmis.count = i+1;
		i++;
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
	if (!self.flags2&FL_SUMMONED && !self.flags2&FL2_RESPAWN)
		precache_bishop();
	
	//self.skin = 1;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "models/bishop.mdl");
	setsize (self, '-13 -13 -2', '13 13 45');
	
	if(!self.health)
		self.health = 200;
	self.max_health = self.health;
	
	self.thingtype=THINGTYPE_FLESH;
	
	self.netname="bishop";
	self.flags (+) FL_MONSTER|FL_FLY;
	self.flags2 (+) FL_ALIVE;
	if (!self.hoverz)
		self.hoverz = random(56,128);
	self.lefty = 1;	//-1 for left dodge, 1 for right dodge
	self.mintel = 8;
	self.monsterclass = CLASS_HENCHMAN;
	self.proj_ofs = '0 0 28';
	self.view_ofs = '0 0 40';
	self.sightsound = "bishop/sight.wav";
	self.yaw_speed = 14;
	
	if(!self.experience_value)
		self.experience_value = 140;
	self.init_exp_val = self.experience_value;
	if(!self.mass)
		self.mass = 11;		//not 10!

	self.th_stand = dark_bishop_float1;
	self.th_walk = dark_bishop_walk1;
	self.th_run = dark_bishop_run1;
	self.th_melee = dark_bishop_atk1;
	self.th_missile = dark_bishop_atk1;
	self.th_pain = dark_bishop_pain;
	self.th_die = dark_bishop_die;
	self.th_blasted = dark_bishop_blasted;
	self.th_init = monster_bishop;
	
	self.buff=2;
	flymonster_start ();
};

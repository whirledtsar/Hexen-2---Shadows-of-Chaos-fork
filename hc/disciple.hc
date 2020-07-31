/*
==============================================================================

Disciple

==============================================================================
*/

$cd id1/models/disciple
$origin 0 0 24
$base base
$skin badass3



void()	bishop_pdie1	=[	0,	bishop_pdie2	] {};
void()	bishop_pdie2	=[	1,	bishop_pdie3	] {};
void()	bishop_pdie3	=[	2,	bishop_pdie4	] {};
void()	bishop_pdie4	=[	3,	bishop_pdie5	] {};
void()	bishop_pdie5	=[	4,	bishop_pdie5	] {remove(self);};

void()	bishop_dsprite9		=[	8,	bishop_dsprite10	] {};
void()	bishop_dsprite10	=[	9,	bishop_dsprite11	] {};
void()	bishop_dsprite11	=[	10,	bishop_dsprite12	] {};
void()	bishop_dsprite12	=[	11,	bishop_dsprite12	] {remove(self);};

void()	bishop_float1	=[	0,	bishop_float2	] {ai_stand();};
void()	bishop_float2	=[	1,	bishop_float3	] {ai_stand();};
void()	bishop_float3	=[	2,	bishop_float4	] {ai_stand();};
void()	bishop_float4	=[	3,	bishop_float5	] {ai_stand();if (random() < 0.01)
{
	sound (self, CHAN_VOICE, "disciple/idle.wav", 1,  ATTN_IDLE); }else if (random () > 0.01 && random() < 0.02) sound (self, CHAN_VOICE, "disciple/idle2.wav", 1,  ATTN_IDLE);};
void()	bishop_float5	=[	4,	bishop_float6	] {ai_stand();};
void()	bishop_float6	=[	5,	bishop_float7	] {ai_stand();};
void()	bishop_float7	=[	6,	bishop_float8	] {ai_stand();};
void()	bishop_float8	=[	7,	bishop_float9	] {ai_stand();};
void()	bishop_float9	=[	8,	bishop_float10	] {ai_stand();};
void()	bishop_float10	=[	9,	bishop_float11	] {ai_stand();};
void()	bishop_float11	=[	10,	bishop_float1	] {ai_stand();};

void()	bishop_walk1	=[	0,		bishop_walk2	] {
if (random() < 0.02)
	sound (self, CHAN_VOICE, "disciple/idle2.wav", 1,  ATTN_IDLE);
ai_walk(3);};
void()	bishop_walk2	=[	1,		bishop_walk3	] {ai_walk(2);};
void()	bishop_walk3	=[	2,		bishop_walk4	] {ai_walk(3);};
void()	bishop_walk4	=[	3,		bishop_walk5	] {ai_walk(4);};
void()	bishop_walk5	=[	4,		bishop_walk6	] {ai_walk(3);};
void()	bishop_walk6	=[	5,		bishop_walk7	] {ai_walk(3);};
void()	bishop_walk7	=[	6,		bishop_walk8	] {ai_walk(3);};
void()	bishop_walk8	=[	7,		bishop_walk9	] {ai_walk(4);};
void()	bishop_walk9	=[	8,		bishop_walk10	] {ai_walk(3);};
void()	bishop_walk10	=[	9,	bishop_walk11	] {ai_walk(3);};
void()	bishop_walk11	=[	10,	bishop_walk1	] {ai_walk(2);};


void()	bishop_run1	=[	0,		bishop_run2	] {ai_run(4);};
void()	bishop_run2	=[	1,		bishop_run3	] {ai_run(4);};
void()	bishop_run3	=[	2,		bishop_run4	] {ai_run(3);};
void()	bishop_run4	=[	3,		bishop_run5	] {ai_run(4);};
void()	bishop_run5	=[	4,		bishop_run6	] {ai_run(4);if (random() < 0.05)
	sound (self, CHAN_VOICE, "disciple/idle2.wav", 1,  ATTN_IDLE);};
void()	bishop_run6	=[	5,		bishop_run7	] {ai_run(4);};
void()	bishop_run7	=[	6,		bishop_run8	] {ai_run(3);};
void()	bishop_run8	=[	7,		bishop_run9	] {ai_run(4);};
void()	bishop_run9	=[	8,		bishop_run10	] {ai_run(3);};
void()	bishop_run10	=[	9,		bishop_run11	] {ai_run(4);};
void()	bishop_run11	=[	10,		bishop_run1	] {ai_run(4);};

void(float offset) bishop_shot;

void()	bishop_atk1	=[	11,		bishop_atk2	]
{
	sound(self,CHAN_WEAPON,"disciple/atk.wav",0.7,ATTN_NORM);
	ai_face(); };
void()	bishop_atk2	=[	12,		bishop_atk3	] {ai_face(); };
void()	bishop_atk3	=[	13,		bishop_atk4	] {ai_face(); };
void()	bishop_atk4	=[	14,		bishop_atk5	] {ai_face(); };
void()	bishop_atk5	=[	15,		bishop_atk6	] {ai_charge(3);};
void()	bishop_atk6	=[	16,		bishop_atk7	] {ai_charge(1);self.drawflags(+)DRF_TRANSLUCENT;};
void()	bishop_atk7	=[	17,		bishop_atk8	] {ai_charge(1);};
void()	bishop_atk8	=[	18,		bishop_atk9	] {ai_charge(1);self.drawflags(-)DRF_TRANSLUCENT;};
void()	bishop_atk9	=[	16,		bishop_atk10	] {ai_charge(1);};
void()	bishop_atk10	=[	17,		bishop_atk11	] {ai_charge(3);self.drawflags(+)DRF_TRANSLUCENT;};
void()	bishop_atk11	=[	18,		bishop_atk12	] {ai_face(); };
void()	bishop_atk12	=[	19,		bishop_atk13] {ai_charge(1);bishop_shot(1);bishop_shot(0);bishop_shot(-1);self.drawflags(-)DRF_TRANSLUCENT;};
void()	bishop_atk13=[	20,		bishop_atk14	] {ai_face(); };
void()	bishop_atk14=[	21,		bishop_atk15	] {ai_face(); };
void()	bishop_atk15=[	22,		bishop_atk16	] {};
void()	bishop_atk16=[	23,		bishop_atk17	] {};
void()	bishop_atk17=[	24,		bishop_run1	] {SUB_AttackFinished(0.5); };

//===========================================================================

void()	bishop_pain1	=[	25,	bishop_pain2	] {};
void()	bishop_pain2	=[	26,	bishop_pain3	] {};
void()	bishop_pain3	=[	27,	bishop_pain4	] {ai_pain(1);};
void()	bishop_pain4	=[	28,	bishop_pain5	] {ai_pain(2);};
void()	bishop_pain5	=[	29,	bishop_pain6	] {ai_pain(4);};
void()	bishop_pain6	=[	30,	bishop_pain7	] {};
void()	bishop_pain7	=[	31,	bishop_pain8	] {};
void()	bishop_pain8	=[	32,	bishop_pain9	] {};
void()	bishop_pain9	=[	33,	bishop_pain10	] {};
void()	bishop_pain10	=[	34,	bishop_pain11	] {};
void()	bishop_pain11	=[	35,	bishop_run1	] {};

void(entity attacker, float damage)	bishop_pain =
{
	local float r;

	if (self.pain_finished > time)
		return;
	if (damage < self.health*0.2 && random()<0.66)
		return;
	
	self.drawflags(-)DRF_TRANSLUCENT;	//reset in case we enter pain state while translucent
	r = random();
	if (r > 0.5)
		sound (self, CHAN_VOICE, "disciple/pain.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "disciple/pain2.wav", 1, ATTN_NORM);
	ThrowGib ("models/blood.mdl", self.health);
	bishop_pain1 ();
	self.pain_finished = time + 1.5;
	
};

//===========================================================================
void() discip_fx =
{
	newmis = spawn ();
	newmis.drawflags(+)DRF_TRANSLUCENT;
	newmis.owner = self;
	newmis.origin = self.origin + '0 0 33';
	setmodel (newmis, "models/purplexp.spr");
	newmis.think = bishop_dsprite9;
	newmis.nextthink = time + 0.1;
}

void()	bishop_die1	=[	36,	bishop_die2	] {self.movetype = MOVETYPE_NONE; };
void()	bishop_die2	=[	37,	bishop_die3	] {};
void()	bishop_die3	=[	38,	bishop_die4	] {};
void()	bishop_die4	=[	39,	bishop_die5	] {};
void()	bishop_die5	=[	40,	bishop_die6	] {self.solid = SOLID_PHASE; };
void()	bishop_die6	=[	41,	bishop_die7	] {};
void()	bishop_die7	=[	42,	bishop_die8	] {};
void()	bishop_die8	=[	43,	bishop_die9	] {};
void()	bishop_die9	=[	44,	bishop_die10] {};
void()	bishop_die10=[	45,	bishop_die11] {};
void()	bishop_die11=[	46,	bishop_die12] {};
void()	bishop_die12=[	47,	bishop_die13] {};
void()	bishop_die13=[	48,	bishop_die14] {};
void()	bishop_die14=[	49,	bishop_die15] {};
void()	bishop_die15=[	50,	bishop_die15] {
	discip_fx();
	chunk_death();
	sound (self, CHAN_VOICE, "death_knight/gib2.wav", 1, ATTN_NORM);
	ThrowGib ("models/blood.mdl", self.health);
	ThrowGib ("models/blood.mdl", self.health);
};


void() bishop_die =
{
// gib check not needed
	sound (self, CHAN_VOICE, "disciple/death.wav", 1, ATTN_NORM);
	bishop_die1 ();
};


void() bspike_touch =
{	
	if (other.classname == "monster_disciple")
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	if (other.takedamage)
	{
		spawn_touchpuff (6,other);
		T_Damage (other, self, self.owner, 7);
		remove(self);
		return;
	}
	setmodel (self, "models/purpldie.spr");
	self.movetype = MOVETYPE_NONE;
	self.think = bishop_pdie1;
	thinktime self : 0;
};
/*
void(float offset) bishop_shot =
{
	local	vector	offang;
	local	vector	org, vec;
	
	offang = vectoangles (self.enemy.origin - (self.origin+self.proj_ofs));
	offang_y = offang_y + offset * 6;
	
	makevectors (offang);
	org = self.origin + self.proj_ofs + v_forward * 20;
	vec = v_forward;
	vec_z -= vec_z + (random() + 0.5)*0.1;
	
	newmis = spawn ();
	newmis.classname = "voidstar";
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	
	setmodel (newmis, "models/purplfire.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);
	
	newmis.velocity = vec*600;
	newmis.angles = vectoangles(vec);
	newmis.avelocity='-1500 600 0';
	
	newmis.effects=EF_DIMLIGHT;	
	newmis.scale = 1.3;
	
	newmis.touch = bspike_touch;
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
};
*/
void bishop_shot (float offset)
{
vector diff, org;
	makevectors (self.angles);
	org = self.origin+self.proj_ofs+(v_forward*20);
	
	diff = normalize((self.enemy.origin+self.enemy.proj_ofs + v_right*(offset*60)) - org);
	diff += aim_adjust(self.enemy);
	
	newmis = spawn ();
	newmis.classname = "voidstar";
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	
	newmis.effects = EF_DIMLIGHT;
	newmis.scale = 1.3;
	
	newmis.velocity = diff * 600;
	newmis.classname = "void";
	newmis.angles = vectoangles(newmis.velocity);
	
	setmodel (newmis, "models/purplfire.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org + (v_right*offset*20));
	
	newmis.touch = bspike_touch;
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
}

/*QUAKED monster_disciple (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_disciple =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	if (!self.flags2&FL_SUMMONED && !self.flags2&FL2_RESPAWN)
		precache_disciple();

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	//self.movetype = MOVETYPE_FLY;

	setmodel (self, "models/disciple.mdl");
	setsize (self, '-13 -13 -2', '13 13 45');
	
	if(!self.health)
		self.health = 160;
	self.max_health = self.health;
	if(!self.experience_value)
		self.experience_value = 140;
	self.init_exp_val = self.experience_value;
	if(!self.mass)
		self.mass = 15;
		
	self.netname="disciple";
	self.flags (+) FL_FLY;
	self.monsterclass = CLASS_HENCHMAN;
	self.proj_ofs = '0 0 40';
	self.thingtype=THINGTYPE_FLESH;
	self.yaw_speed = 16;

	self.th_stand = bishop_float1;
	self.th_walk = bishop_walk1;
	self.th_run = bishop_run1;
	self.th_melee = bishop_atk1;
	self.th_missile = bishop_atk1;
	self.th_pain = bishop_pain;
	self.th_die = bishop_die;
	self.th_init = monster_disciple;
	
	self.buff=2;
	flymonster_start();
};

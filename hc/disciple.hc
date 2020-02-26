/*
==============================================================================

Disciple

==============================================================================
*/

$cd id1/models/disciple
$origin 0 0 24
$base base
$skin badass3



void()	bishop_fire1	=[	0,	bishop_fire2	] {};
void()	bishop_fire2	=[	1,	bishop_fire1	] {};

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

/*

void()	bishop_runatk1	=[	$runattack1,		bishop_runatk2	]
{
if (random() > 0.5)
	sound (self, CHAN_WEAPON, "death_knight/sword2.wav", 1, ATTN_NORM);
else
	sound (self, CHAN_WEAPON, "death_knight/sword1.wav", 1, ATTN_NORM);
ai_charge(20);
};
void()	bishop_runatk2	=[	$runattack2,	bishop_runatk3	] {ai_charge_side();};
void()	bishop_runatk3	=[	$runattack3,	bishop_runatk4	] {ai_charge_side();};
void()	bishop_runatk4	=[	$runattack4,	bishop_runatk5	] {ai_charge_side();};
void()	bishop_runatk5	=[	$runattack5,	bishop_runatk6	] {ai_melee_side();};
void()	bishop_runatk6	=[	$runattack6,	bishop_runatk7	] {ai_melee_side();};
void()	bishop_runatk7	=[	$runattack7,	bishop_runatk8	] {ai_melee_side();};
void()	bishop_runatk8	=[	$runattack8,	bishop_runatk9	] {ai_melee_side();};
void()	bishop_runatk9	=[	$runattack9,	bishop_runatk10	] {ai_melee_side();};
void()	bishop_runatk10	=[	$runattack10,	bishop_runatk11	] {ai_charge_side();};
void()	bishop_runatk11	=[	$runattack11,	bishop_run1	] {ai_charge(10);};

*/
void(float offset) bishop_shot;

void()	bishop_atk1	=[	11,		bishop_atk2	]
{
sound(self,CHAN_WEAPON,"disciple/atk.wav",0.7,ATTN_NORM);
ai_charge(0);};
void()	bishop_atk2	=[	12,		bishop_atk3	] {ai_charge(0);};
void()	bishop_atk3	=[	13,		bishop_atk4	] {ai_charge(0);};
void()	bishop_atk4	=[	14,		bishop_atk5	] {ai_charge(0);};
void()	bishop_atk5	=[	15,		bishop_atk6	] {ai_charge(3);};
void()	bishop_atk6	=[	16,		bishop_atk7	] {ai_charge(1);self.drawflags(+)DRF_TRANSLUCENT;};
void()	bishop_atk7	=[	17,		bishop_atk8	] {ai_charge(1);};
void()	bishop_atk8	=[	18,		bishop_atk9	] {ai_charge(1);self.drawflags(-)DRF_TRANSLUCENT;};
void()	bishop_atk9	=[	16,		bishop_atk10	] {ai_charge(1);};
void()	bishop_atk10	=[	17,		bishop_atk11	] {ai_charge(3);self.drawflags(+)DRF_TRANSLUCENT;};
void()	bishop_atk11	=[	18,		bishop_atk12	] {ai_charge(0);};
void()	bishop_atk12	=[	19,		bishop_atk13] {ai_charge(1);bishop_shot(3);bishop_shot(0);bishop_shot(-3);self.drawflags(-)DRF_TRANSLUCENT;};
void()	bishop_atk13=[	20,		bishop_atk14	] {ai_charge(0);};
void()	bishop_atk14=[	21,		bishop_atk15	] {ai_charge(0);};
void()	bishop_atk15=[	22,		bishop_atk16	] {ai_charge(0);};
void()	bishop_atk16=[	23,		bishop_atk17	] {ai_charge(0);};
void()	bishop_atk17=[	24,		bishop_run1	] {ai_charge(0);};

//===========================================================================

void()	bishop_pain1	=[	25,	bishop_pain2	] {self.drawflags(-)DRF_TRANSLUCENT;};
void()	bishop_pain2	=[	26,	bishop_pain3	] {};
void()	bishop_pain3	=[	27,	bishop_pain4	] {};
void()	bishop_pain4	=[	28,	bishop_pain5	] {};
void()	bishop_pain5	=[	29,	bishop_pain6	] {ai_pain(2);};
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

	r = random();
	if (r > 0.5)
		sound (self, CHAN_VOICE, "disciple/pain.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "disciple/pain2.wav", 1, ATTN_NORM);
	ThrowGib ("models/blood.mdl", self.health);
	bishop_pain1 ();
	self.pain_finished = time + 1;
	
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

void()	bishop_die1	=[	36,	bishop_die2	] {};
void()	bishop_die2	=[	37,	bishop_die3	] {/*setsize (self, '-17 -17 -9', '17 17 2');*/};
void()	bishop_die3	=[	38,	bishop_die4	] {};
void()	bishop_die4	=[	39,	bishop_die5	] {};
void()	bishop_die5	=[	40,	bishop_die6	] {};
void()	bishop_die6	=[	41,	bishop_die7	] {};
void()	bishop_die7	=[	42,	bishop_die8	] {};
void()	bishop_die8	=[	43,	bishop_die9	] {};
void()	bishop_die9	=[	44,	bishop_die10] {};
void()	bishop_die10=[	45,	bishop_die11] {};
void()	bishop_die11=[	46,	bishop_die12] {};
void()	bishop_die12=[	47,	bishop_die13] {};
void()	bishop_die13=[	48,	bishop_die14] {};
void()	bishop_die14=[	49,	bishop_die15] {};
void()	bishop_die15=[	50,	bishop_die15] {ThrowGib ("models/bloodpool.mdl", self.health);discip_fx();chunk_death();sound (self, CHAN_VOICE, "death_knight/gib2.wav", 1, ATTN_NORM);ThrowGib ("models/blood.mdl", self.health);ThrowGib ("models/blood.mdl", self.health);};


void() bishop_die =
{
// gib check not needed

	sound (self, CHAN_VOICE, "disciple/death.wav", 1, ATTN_NORM);
	bishop_die1 ();
};


void() bspike_touch =
{
	setmodel (self, "models/purpldie.spr");
	self.think = bishop_pdie1;
	self.movetype = MOVETYPE_NONE;
	self.nextthink = time + 0.1;
//float rand;
	//self.think = bishop_pdie1;
	if (other.classname == "monster_disciple")
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
		spawn_touchpuff (6,other);
		T_Damage (other, self, self.owner, 7);
		remove(self);
	}
};

void(vector org, vector dir) launch_bspike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = bspike_touch;
	newmis.classname = "void";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	newmis.effects=EF_DIMLIGHT;
	//setmodel (newmis, "models/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	//setorigin (newmis, org);
	if (self.enemy.classname == "player" && self.enemy.hull == HULL_CROUCH)		//ws: now hes actually capable of hitting crouching players
		setorigin (newmis, org + '0 0 -20');
	else
		setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void(float offset) bishop_shot =
{
	local	vector	offang;
	local	vector	org, vec;
	
	offang = vectoangles (self.enemy.origin - self.origin);
	offang_y = offang_y + offset * 6;
	
	makevectors (offang);

	org = self.origin + '0 0 20' + self.mins + self.size*0.5 + v_forward * 20;

// set missile speed
	vec = normalize (v_forward);
	//vec = trace_ent.origin;
	
	vec_z = 0 - vec_z + (random() - 0.5)*0.1;
	
	
	launch_bspike (org, vec - '0 0 10');
	newmis.classname = "voidstar";
	//setmodel (newmis, "models/disciple_proj.mdl");
	setmodel (newmis, "models/purplfire.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	newmis.velocity = vec*600;
	//newmis.avelocity = '0 0 800';
	newmis.avelocity='-1500 600 0';
	newmis.think = bishop_fire1;
	newmis.nextthink = time + 0.1;
	newmis.scale = 1.3;
	//sound (self, CHAN_WEAPON, "hknight/attack1.wav", 1, ATTN_NORM);
};

/*QUAKED monster_disciple (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_disciple =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	if (!self.flags2 & FL_SUMMONED&&!self.flags2&FL2_RESPAWN)
		precache_disciple();

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	//self.movetype = MOVETYPE_FLY;

	setmodel (self, "models/disciple.mdl");

	setsize (self, '-13 -13 -2', '13 13 45');
	if(!self.health)
		self.health = 162;
	
	self.thingtype=THINGTYPE_FLESH;
	
	self.netname="disciple";
	self.flags (+) FL_MONSTER;
	self.flags2 (+) FL_ALIVE;
	self.flags (+) FL_FLY;
	self.yaw_speed = 14;
	
	self.monsterclass = CLASS_HENCHMAN;
	//self.hull=HULL_PLAYER;
	
	if(!self.experience_value)
		self.experience_value = 60;
	if(!self.mass)
		self.mass = 15;		//self.mass = 80;

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

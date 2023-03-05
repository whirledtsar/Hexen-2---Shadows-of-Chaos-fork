/*
==============================================================================

death_knight

==============================================================================
*/

$cd id1/models/death_knight
$origin 0 0 24
$base base
$skin badass3

void death_knight_raise()
{
float state;
	state = RewindFrame(89,69);
	
	self.think = self.th_raise;
	
	if (state==AF_BEGINNING) {
		sound (self, CHAN_VOICE, "death_knight/kdeath.wav", 1, ATTN_NORM);
	}
	if (state==AF_END) {
		self.th_init();
		monster_raisedebuff();
		if (self.enemy!=world)
			self.think=self.th_run;
		else
			self.think=self.th_stand;
	}
	
	thinktime self : HX_FRAME_TIME;
}

void()	death_knight_stand1	=[	0,	death_knight_stand2	] {ai_stand();};
void()	death_knight_stand2	=[	1,	death_knight_stand3	] {ai_stand();};
void()	death_knight_stand3	=[	2,	death_knight_stand4	] {ai_stand();};
void()	death_knight_stand4	=[	3,	death_knight_stand5	] {ai_stand();};
void()	death_knight_stand5	=[	4,	death_knight_stand6	] {ai_stand();};
void()	death_knight_stand6	=[	5,	death_knight_stand7	] {ai_stand();};
void()	death_knight_stand7	=[	6,	death_knight_stand8	] {ai_stand();};
void()	death_knight_stand8	=[	7,	death_knight_stand9	] {ai_stand();};
void()	death_knight_stand9	=[	8,	death_knight_stand10	] {ai_stand();};
void()	death_knight_stand10	=[	9,	death_knight_stand11	] {ai_stand();};
void()	death_knight_stand11	=[	10,	death_knight_stand1	] {ai_stand();};

void()	death_knight_walk1	=[	11,		death_knight_walk2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "death_knight/idle.wav", 1,  ATTN_IDLE);
ai_walk(3);};
void()	death_knight_walk2	=[	12,		death_knight_walk3	] {ai_walk(2);};
void()	death_knight_walk3	=[	13,		death_knight_walk4	] {ai_walk(3);};
void()	death_knight_walk4	=[	14,		death_knight_walk5	] {ai_walk(4);};
void()	death_knight_walk5	=[	15,		death_knight_walk6	] {ai_walk(3);};
void()	death_knight_walk6	=[	16,		death_knight_walk7	] {ai_walk(3);};
void()	death_knight_walk7	=[	17,		death_knight_walk8	] {ai_walk(3);};
void()	death_knight_walk8	=[	18,		death_knight_walk9	] {ai_walk(4);};
void()	death_knight_walk9	=[	19,		death_knight_walk10	] {ai_walk(3);};
void()	death_knight_walk10	=[	20,	death_knight_walk11	] {ai_walk(3);};
void()	death_knight_walk11	=[	21,	death_knight_walk12	] {ai_walk(2);};
void()	death_knight_walk12	=[	22,	death_knight_walk13	] {ai_walk(3);};
void()	death_knight_walk13	=[	23,	death_knight_walk14	] {ai_walk(4);};
void()	death_knight_walk14	=[	24,	death_knight_walk15	] {ai_walk(3);};
void()	death_knight_walk15	=[	25,	death_knight_walk16	] {ai_walk(3);};
void()	death_knight_walk16	=[	26,	death_knight_walk1	] {ai_walk(3);};

void()	death_knight_run1	=[	27,		death_knight_run2	] {ai_run(16);};
void()	death_knight_run2	=[	28,		death_knight_run3	] {ai_run(20);};
void()	death_knight_run3	=[	29,		death_knight_run4	] {ai_run(15);};
void()	death_knight_run4	=[	30,		death_knight_run5	] {ai_run(10);};
void()	death_knight_run5	=[	31,		death_knight_run6	] {ai_run(16);};
void()	death_knight_run6	=[	32,		death_knight_run7	] {ai_run(20);};
void()	death_knight_run7	=[	33,		death_knight_run8	] {ai_run(15);};
void()	death_knight_run8	=[	34,		death_knight_run9	] {ai_run(10);};
void()	death_knight_run9	=[	35,		death_knight_run10	] {ai_run(15);};
void()	death_knight_run10	=[	36,		death_knight_run11	] {ai_run(10);};
void()	death_knight_run11	=[	37,		death_knight_run12	] {ai_run(20);};
void()	death_knight_run12	=[	38,		death_knight_run13	] {ai_run(14);};
void()	death_knight_run13	=[	39,		death_knight_run14	] {ai_run(10);};
void()	death_knight_run14	=[	40,		death_knight_run1	] {ai_run(10);};

void death_knight_melee ()
{
	ai_melee();
	if (trace_ent.takedamage && self.check_ok) {
		sound(self,CHAN_AUTO,"weapons/met2flsh.wav",1,ATTN_NORM);
		self.check_ok = FALSE;
	}
}

void()	death_knight_atk1	=[	41,		death_knight_atk2	]
{
sound(self,CHAN_WEAPON,"weapons/vorpswng.wav",0.7,ATTN_NORM);
ai_charge(0);};
void()	death_knight_atk2	=[	42,		death_knight_atk3	] {ai_charge(5);};
void()	death_knight_atk3	=[	43,		death_knight_atk4	] {ai_charge(4);};
void()	death_knight_atk4	=[	44,		death_knight_atk5	] {ai_charge(0);};
void()	death_knight_atk5	=[	45,		death_knight_atk6	] {ai_charge(3);};
void()	death_knight_atk6	=[	46,		death_knight_atk7	] {ai_charge(5); self.check_ok=TRUE; death_knight_melee(); };
void()	death_knight_atk7	=[	47,		death_knight_atk8	] {ai_charge(5); death_knight_melee(); };
void()	death_knight_atk8	=[	48,		death_knight_atk9	] {ai_charge(3); death_knight_melee(); };
void()	death_knight_atk9	=[	49,		death_knight_atk10] {ai_charge(1);};
void()	death_knight_atk10=[	50,		death_knight_run1	] {ai_charge(5);};

//===========================================================================

void()	death_knight_pain1	=[	57,	death_knight_pain2	] {};
void()	death_knight_pain2	=[	58,	death_knight_pain3	] {ai_pain(1);};
void()	death_knight_pain3	=[	59,	death_knight_pain4	] {};
void()	death_knight_pain4	=[	60,	death_knight_pain5	] {};
void()	death_knight_pain5	=[	61,	death_knight_pain6	] {ai_pain(1);};
void()	death_knight_pain6	=[	62,	death_knight_pain7	] {ai_pain(1);};
void()	death_knight_pain7	=[	63,	death_knight_pain8	] {ai_pain(1);};
void()	death_knight_pain8	=[	64,	death_knight_pain9	] {ai_pain(1);};
void()	death_knight_pain9	=[	65,	death_knight_pain10	] {ai_pain(1);};
void()	death_knight_pain10	=[	66,	death_knight_pain11	] {};
void()	death_knight_pain11	=[	67,	death_knight_run1	] {};

void(entity attacker, float damage)	death_knight_pain =
{
	local float r;

	if (self.pain_finished > time)
		return;

	r = random();
	
	if (r<0.5)
		sound (self, CHAN_VOICE, "death_knight/khurt.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "death_knight/khurt2.wav", 1, ATTN_NORM);
	ThrowGib ("models/blood.mdl", self.health);
	ThrowGib ("models/blood.mdl", self.health);
	death_knight_pain1 ();
	self.pain_finished = time + 1;
};

//===========================================================================

void() death_knight_gibs =
{
	if (self.model != "models/footsoldiersplit.mdl")
	{
		ThrowGib ("models/footsoldierarm.mdl", self.health);
		ThrowGib ("models/footsoldierarm.mdl", self.health);
		ThrowGib ("models/footsoldieraxe.mdl", self.health);
	}
	
	ThrowGib ("models/footsoldierleg.mdl", self.health);
	ThrowGib ("models/footsoldierleg.mdl", self.health);
}

void death_knight_dying () [++ 69 .. 88]
{
	self.think = death_knight_dying;
	thinktime self : HX_FRAME_TIME;
	
	if (self.frame<86)
	{	//check for gib
		if (self.health < -30)
		{
			chunk_death();
			return;
		}
	}
	if (cycle_wrapped) {
		self.frame = 88;
		MakeSolidCorpse();
	}
}

void() death_knight_die =
{
// check for gib
	ThrowGib ("models/blood.mdl", self.health);
	ThrowGib ("models/blood.mdl", self.health);
	if (self.health < -30)
	{
		sound (self, CHAN_VOICE, "death_knight/gib2.wav", 1, ATTN_NORM);
		
		chunk_death();
		return;		//remove(self);
	}
	
	if (self.enemy.playerclass == CLASS_PALADIN && self.enemy.weapon == IT_WEAPON2 && random()<0.75)
	{
		setmodel (self, "models/footsoldiersplit.mdl");
		sound(self,CHAN_VOICE,"death_knight/kdeath2.wav",1,ATTN_NORM);
		ThrowGib ("models/footsoldierhalf.mdl", self.health);
		ThrowGib ("models/footsoldieraxe.mdl", self.health);
		self.headmodel = "";
		bloodspew_create (3, 60, '0 0 16');
	}
	else if (self.decap>0 && random()<0.5)	//ws: only sharp weapons will decapitate; see damage.hc
	{
		setmodel (self, "models/footsoldierdecap.mdl");
		sound(self,CHAN_VOICE,"player/decap.wav",1,ATTN_NORM);	//player/telefrag.wav
		ThrowGib ("models/footsoldierhd.mdl", self.health);
		self.headmodel = "";
		bloodspew_create (2, 25, self.view_ofs);
	}
	// regular death
	else
		sound (self, CHAN_VOICE, "death_knight/kdeath.wav", 1, ATTN_NORM);
	
	sound (self, CHAN_AUTO, "player/megagib.wav", 1, ATTN_NORM);
	
	setsize (self, '-13 -13 0', '13 13 12');
	death_knight_dying();
};

/*QUAKED monster_death_knight (1 0 0) (-16 -16 0) (16 16 56) Ambush
*/
void() monster_death_knight =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	if (!self.flags2&FL_SUMMONED && !self.flags2&FL2_RESPAWN)
		precache_knight();

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "models/footsoldier.mdl");
	//setsize (self, '-13 -13 -12', '13 13 44');
	setsize (self, '-13 -13 0', '13 13 56');
	
	if (!self.health)
		self.health = 62;
	self.max_health = self.health;
	
	self.thingtype=THINGTYPE_FLESH;
	
	self.mintel = 5;
	self.monsterclass = CLASS_GRUNT;
	self.netname="footsoldier";
	self.flags (+) FL_MONSTER;
	self.flags2 (+) FL_ALIVE;
	self.yaw_speed = 14;
	
	if(!self.experience_value)
		self.experience_value = 30;
	self.init_exp_val = self.experience_value;
	if(!self.mass)
		self.mass = 11;
		
	self.headmodel = "models/footsoldierhd.mdl";

	self.th_stand = death_knight_stand1;
	self.th_walk = death_knight_walk1;
	self.th_run = death_knight_run1;
	self.th_jump = monster_jump;	self.jumpframe = 59;	//pain4
	self.th_melee = death_knight_atk1;
	self.th_pain = death_knight_pain;
	self.th_die = death_knight_die;
	self.th_raise = death_knight_raise;
	self.th_init = monster_death_knight;
	
	self.buff=1;
	walkmonster_start ();
};

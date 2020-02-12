/*
==============================================================================

death_knight

==============================================================================
*/

$cd id1/models/death_knight
$origin 0 0 24
$base base
$skin badass3

/*

void() blood_fall1 =[ 0, blood_fall2] {bloodpool.scale = 0;};
void() blood_fall2 =[ 0, blood_fall3] {setmodel (bloodpool, "models/blood.mdl");bloodpool.scale = .3;};
void() blood_fall3 =[ 0, blood_fall4] {bloodpool.scale = 0.4;};
void() blood_fall4 =[ 0, blood_fall5] {bloodpool.scale = 0.5;};
void() blood_fall5 =[ 0, blood_fall6] {bloodpool.scale = 0.6;};
void() blood_fall6 =[ 0, blood_fall7] {bloodpool.scale = 0.7;};
void() blood_fall7 =[ 0, blood_fall8] {bloodpool.scale = 0.8;};
void() blood_fall8 =[ 0, blood_fall8] {bloodpool.scale = 1.0;bloodpool.think = SUB_Remove; bloodpool.nextthink = time + 15;};

void() blood_fx =
{	
	bloodpool = spawn ();
	bloodpool.owner = self;
	bloodpool.movetype = MOVETYPE_BOUNCE;
	bloodpool.origin = self.origin + '0 0 0';
	setsize (bloodpool, '0 5 1', '5 5 5');
	bloodpool.think = blood_fall1;
	bloodpool.nextthink = time + 0.01;
	
}

*/

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

/*

void()	death_knight_runatk1	=[	$runattack1,		death_knight_runatk2	]
{
if (random() > 0.5)
	sound (self, CHAN_WEAPON, "death_knight/sword2.wav", 1, ATTN_NORM);
else
	sound (self, CHAN_WEAPON, "death_knight/sword1.wav", 1, ATTN_NORM);
ai_charge(20);
};
void()	death_knight_runatk2	=[	$runattack2,	death_knight_runatk3	] {ai_charge_side();};
void()	death_knight_runatk3	=[	$runattack3,	death_knight_runatk4	] {ai_charge_side();};
void()	death_knight_runatk4	=[	$runattack4,	death_knight_runatk5	] {ai_charge_side();};
void()	death_knight_runatk5	=[	$runattack5,	death_knight_runatk6	] {ai_melee_side();};
void()	death_knight_runatk6	=[	$runattack6,	death_knight_runatk7	] {ai_melee_side();};
void()	death_knight_runatk7	=[	$runattack7,	death_knight_runatk8	] {ai_melee_side();};
void()	death_knight_runatk8	=[	$runattack8,	death_knight_runatk9	] {ai_melee_side();};
void()	death_knight_runatk9	=[	$runattack9,	death_knight_runatk10	] {ai_melee_side();};
void()	death_knight_runatk10	=[	$runattack10,	death_knight_runatk11	] {ai_charge_side();};
void()	death_knight_runatk11	=[	$runattack11,	death_knight_run1	] {ai_charge(10);};

*/

void()	death_knight_atk1	=[	41,		death_knight_atk2	]
{
sound(self,CHAN_WEAPON,"weapons/vorpswng.wav",0.7,ATTN_NORM);
ai_charge(0);};
void()	death_knight_atk2	=[	42,		death_knight_atk3	] {ai_charge(5);};
void()	death_knight_atk3	=[	43,		death_knight_atk4	] {ai_charge(4);};
void()	death_knight_atk4	=[	44,		death_knight_atk5	] {ai_charge(0);};
void()	death_knight_atk5	=[	45,		death_knight_atk6	] {ai_charge(3);};
void()	death_knight_atk6	=[	46,		death_knight_atk7	] {ai_charge(5); ai_melee();};
void()	death_knight_atk7	=[	47,		death_knight_atk8	] {ai_charge(5); ai_melee(); if (trace_ent.takedamage) sound(self,CHAN_AUTO,"weapons/met2flsh.wav",1,ATTN_NORM);};
void()	death_knight_atk8	=[	48,		death_knight_atk9	] {ai_charge(3);
ai_melee();};
void()	death_knight_atk9	=[	49,		death_knight_atk10] {ai_charge(1);};
void()	death_knight_atk10=[	50,		death_knight_run1	] {ai_charge(5);};

//void()	death_knight_atk9	=[	$attack9,		death_knight_atk10	] {};
//void()	death_knight_atk10	=[	$attack10,		death_knight_atk11	] {};
//void()	death_knight_atk11	=[	$attack11,		death_knight_run1	] {};

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
void()	death_knight_pain11	=[	67,	death_knight_pain12	] {};
void()	death_knight_pain12	=[	68,	death_knight_run1	] {};

void(entity attacker, float damage)	death_knight_pain =
{
	local float r;

	if (self.pain_finished > time)
		return;

	r = random();
	
	sound (self, CHAN_VOICE, "death_knight/khurt.wav", 1, ATTN_NORM);
	ThrowGib ("models/blood.mdl", self.health);
	ThrowGib ("models/blood.mdl", self.health);
	death_knight_pain1 ();
	self.pain_finished = time + 1;
	
};

//===========================================================================


void()	death_knight_die1	=[	69,	death_knight_die2	] {};
void()	death_knight_die2	=[	70,	death_knight_die3	] {/*setsize (self, '-17 -17 -9', '17 17 2');*/};
void()	death_knight_die3	=[	71,	death_knight_die4	] {};
void()	death_knight_die4	=[	72,	death_knight_die5	] {};
void()	death_knight_die5	=[	73,	death_knight_die6	] {};
void()	death_knight_die6	=[	74,	death_knight_die7	] {};
void()	death_knight_die7	=[	75,	death_knight_die8	] {};
void()	death_knight_die8	=[	76,	death_knight_die9	] {};
void()	death_knight_die9	=[	77,	death_knight_die10] {};
void()	death_knight_die10=[	78,	death_knight_die11] {};
void()	death_knight_die11=[	79,	death_knight_die12] {};
void()	death_knight_die12=[	80,	death_knight_die13] {};
void()	death_knight_die13=[	81,	death_knight_die14] {};
void()	death_knight_die14=[	82,	death_knight_die15] {};
void()	death_knight_die15=[	83,	death_knight_die16] {};
void()	death_knight_die16=[	84,	death_knight_die17] {};
void()	death_knight_die17=[	85,	death_knight_die18] {};
void()	death_knight_die18=[	86,	death_knight_die19] {};
void()	death_knight_die19=[	87,	death_knight_die20] {};
void()	death_knight_die20=[	88,	death_knight_die21] {MakeSolidCorpse();};
void()	death_knight_die21=[	89,	death_knight_die21] {};

void() death_knight_gibs =
{
	ThrowGib ("models/footsoldierarm.mdl", self.health);
	ThrowGib ("models/footsoldierleg.mdl", self.health);
	ThrowGib ("models/footsoldierarm.mdl", self.health);
	ThrowGib ("models/footsoldierleg.mdl", self.health);
	ThrowGib ("models/footsoldieraxe.mdl", self.health);
}

void() death_knight_die =
{
// check for gib
	if (self.health < -30)
	{
		sound (self, CHAN_VOICE, "death_knight/gib2.wav", 1, ATTN_NORM);
		ThrowGib ("models/blood.mdl", self.health);
		ThrowGib ("models/bloodpool.mdl", self.health);
		//ThrowGib ("models/flesh2.mdl", self.health);
		ThrowGib ("models/blood.mdl", self.health);
		ThrowGib ("models/blood.mdl", self.health);
		//ThrowGib (self.headmodel, self.health);
		chunk_death();
		return;
	}

// regular death
	sound (self, CHAN_VOICE, "death_knight/kdeath.wav", 1, ATTN_NORM);
	ThrowGib ("models/flesh2.mdl", self.health);
	if (self.enemy.playerclass == CLASS_PALADIN && self.enemy.weapon == IT_WEAPON2)
	{
		if (random(100) < 35)
		{
			setmodel (self, "models/footsoldiersplit.mdl");
			sound(self,CHAN_VOICE,"death_knight/kdeath2.wav",1,ATTN_NORM);
			//setsize (self, '-13 -13 -12', '13 13 35');
			//setsize (self, '-16 -16 0', '16 16 56');
			//setsize (self, '-13 -13 -6', '13 13 1');
			ThrowGib ("models/footsoldierhalf.mdl", self.health);
			ThrowGib ("models/blood.mdl", self.health);
			ThrowGib ("models/blood.mdl", self.health);
			ThrowGib ("models/footsoldieraxe.mdl", self.health);
			self.headmodel = "";
			//blood_fx();
		}
	}
	else if (self.decap>0 && random()<0.5)	//ws: only sharp weapons will decapitate; see damage.hc
	{
		setmodel (self, "models/footsoldierdecap.mdl");
		sound(self,CHAN_VOICE,"player/telefrag.wav",1,ATTN_NORM);
		//setsize (self, '-13 -13 -12', '13 13 35');
		//setsize (self, '-13 -13 -6', '13 13 1');
		//setsize (self, '-16 -16 0', '16 16 56');
		ThrowGib ("models/blood.mdl", self.health);
		ThrowGib ("models/blood.mdl", self.health);
		ThrowGib ("models/footsoldierhd.mdl", self.health);
		self.headmodel = "";
		//blood_fx();
	}
	//else
	setsize (self, '-13 -13 -6', '13 13 6');
	sound (self, CHAN_AUTO, "player/megagib.wav", 1, ATTN_NORM);
	ThrowGib ("models/blood.mdl", self.health);
	death_knight_die1 ();
	self.movetype = MOVETYPE_NONE;
	//if (self.frame == 87)
		
};

/*QUAKED monster_death_knight (1 0 0) (-16 -16 -24) (16 16 40) Ambush
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

	setsize (self, '-13 -13 -12', '13 13 44');
	self.health = 62;
	//self.scale = 0.9;
	
	self.thingtype=THINGTYPE_FLESH;
	
	self.netname="footsoldier";
	self.flags (+) FL_MONSTER;
	self.flags2 (+) FL_ALIVE;
	self.yaw_speed = 14;
	
	self.monsterclass = CLASS_GRUNT;
	//self.hull=HULL_PLAYER;
	
	if(!self.experience_value)
		self.experience_value = 12;
	if(!self.mass)
		self.mass = 10;
		
	self.headmodel = "models/footsoldierhd.mdl";

	self.th_stand = death_knight_stand1;
	self.th_walk = death_knight_walk1;
	self.th_run = death_knight_run1;
	self.th_jump = monster_jump;	self.jumpframe = 59;	//pain4
	self.th_melee = death_knight_atk1;
	self.th_pain = death_knight_pain;
	self.th_die = death_knight_die;
	
	walkmonster_start ();
};

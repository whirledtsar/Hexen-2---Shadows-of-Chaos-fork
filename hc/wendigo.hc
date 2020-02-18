/*
==============================================================================

wendigo

==============================================================================
*/

$cd id1/models/wendigo
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

void()	wendigo_stand1	=[	0,	wendigo_stand2	] {ai_stand();};
void()	wendigo_stand2	=[	1,	wendigo_stand3	] {ai_stand();};
void()	wendigo_stand3	=[	2,	wendigo_stand4	] {ai_stand();};
void()	wendigo_stand4	=[	3,	wendigo_stand5	] {ai_stand();};
void()	wendigo_stand5	=[	4,	wendigo_stand6	] {ai_stand();};
void()	wendigo_stand6	=[	5,	wendigo_stand7	] {ai_stand();};
void()	wendigo_stand7	=[	6,	wendigo_stand8	] {ai_stand();};
void()	wendigo_stand8	=[	7,	wendigo_stand9	] {ai_stand();};
void()	wendigo_stand9	=[	8,	wendigo_stand10	] {ai_stand();};
void()	wendigo_stand10	=[	9,	wendigo_stand11	] {ai_stand();};
void()	wendigo_stand11	=[	10,	wendigo_stand12	] {ai_stand();};
void()	wendigo_stand12	=[	11,	wendigo_stand13	] {ai_stand();};
void()	wendigo_stand13	=[	12,	wendigo_stand14	] {ai_stand();};
void()	wendigo_stand14	=[	13,	wendigo_stand15	] {ai_stand();};
void()	wendigo_stand15	=[	14,	wendigo_stand16	] {ai_stand();};
void()	wendigo_stand16	=[	15,	wendigo_stand17	] {ai_stand();};
void()	wendigo_stand17	=[	16,	wendigo_stand1	] {ai_stand();};

void()	wendigo_walk1	=[	17,		wendigo_walk2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "wendigo/idle.wav", 1,  ATTN_IDLE);
ai_walk(3);};
void()	wendigo_walk2	=[	18,		wendigo_walk3	] {ai_walk(2);};
void()	wendigo_walk3	=[	19,		wendigo_walk4	] {ai_walk(3);};
void()	wendigo_walk4	=[	20,		wendigo_walk5	] {ai_walk(4);};
void()	wendigo_walk5	=[	21,		wendigo_walk6	] {ai_walk(3);};
void()	wendigo_walk6	=[	22,		wendigo_walk7	] {ai_walk(3);};
void()	wendigo_walk7	=[	23,		wendigo_walk8	] {ai_walk(3);};
void()	wendigo_walk8	=[	24,		wendigo_walk9	] {ai_walk(4);};
void()	wendigo_walk9	=[	25,		wendigo_walk10	] {ai_walk(3);};
void()	wendigo_walk10	=[	26,	wendigo_walk11	] {ai_walk(3);};
void()	wendigo_walk11	=[	27,	wendigo_walk12	] {ai_walk(2);};
void()	wendigo_walk12	=[	28,	wendigo_walk11	] {ai_walk(3);};


void()	wendigo_run1	=[	17,		wendigo_run2	] {ai_run(4);};
void()	wendigo_run2	=[	18,		wendigo_run3	] {ai_run(8);
if (random() < 0.2)
	sound (self, CHAN_VOICE, "wendigo/idle.wav", 1,  ATTN_IDLE);};
void()	wendigo_run3	=[	19,		wendigo_run4	] {ai_run(3);};
void()	wendigo_run4	=[	20,		wendigo_run5	] {ai_run(8);};
void()	wendigo_run5	=[	21,		wendigo_run6	] {ai_run(4);};
void()	wendigo_run6	=[	22,		wendigo_run7	] {ai_run(8);};
void()	wendigo_run7	=[	23,		wendigo_run8	] {ai_run(3);};
void()	wendigo_run8	=[	24,		wendigo_run9	] {ai_run(8);};
void()	wendigo_run9	=[	25,		wendigo_run10	] {ai_run(3);};
void()	wendigo_run10	=[	26,		wendigo_run11	] {ai_run(8);};
void()	wendigo_run11	=[	27,		wendigo_run12	] {ai_run(8);};
void()	wendigo_run12	=[	28,		wendigo_run1	] {ai_run(2);};
//void()	wendigo_run13	=[	39,		wendigo_run14	] {ai_run(8);};
//void()	wendigo_run14	=[	40,		wendigo_run1	] {ai_run(8);};

/*

void()	wendigo_runatk1	=[	$runattack1,		wendigo_runatk2	]
{
if (random() > 0.5)
	sound (self, CHAN_WEAPON, "wendigo/sword2.wav", 1, ATTN_NORM);
else
	sound (self, CHAN_WEAPON, "wendigo/sword1.wav", 1, ATTN_NORM);
ai_charge(20);
};
void()	wendigo_runatk2	=[	$runattack2,	wendigo_runatk3	] {ai_charge_side();};
void()	wendigo_runatk3	=[	$runattack3,	wendigo_runatk4	] {ai_charge_side();};
void()	wendigo_runatk4	=[	$runattack4,	wendigo_runatk5	] {ai_charge_side();};
void()	wendigo_runatk5	=[	$runattack5,	wendigo_runatk6	] {ai_melee_side();};
void()	wendigo_runatk6	=[	$runattack6,	wendigo_runatk7	] {ai_melee_side();};
void()	wendigo_runatk7	=[	$runattack7,	wendigo_runatk8	] {ai_melee_side();};
void()	wendigo_runatk8	=[	$runattack8,	wendigo_runatk9	] {ai_melee_side();};
void()	wendigo_runatk9	=[	$runattack9,	wendigo_runatk10	] {ai_melee_side();};
void()	wendigo_runatk10	=[	$runattack10,	wendigo_runatk11	] {ai_charge_side();};
void()	wendigo_runatk11	=[	$runattack11,	wendigo_run1	] {ai_charge(10);};

*/

void()	wendigo_shatter1	=[	0,	wendigo_shatter2	] {self.solid = SOLID_NOT;};
void()	wendigo_shatter2	=[	1,	wendigo_shatter3	] {particle2(self.origin,'-10 -10 -10','10 10 10',145,14,5);
};
void()	wendigo_shatter3	=[	2,	wendigo_shatter4	] {particleexplosion(self.origin,14,25,50);};
void()	wendigo_shatter4	=[	3,	wendigo_shatter5	] {particleexplosion(self.origin,14,25,50);};
void()	wendigo_shatter5	=[	4,	wendigo_shatter6	] {particleexplosion(self.origin,14,25,50);};
void()	wendigo_shatter6	=[	5,	wendigo_shatter7	] {particleexplosion(self.origin,14,25,50);};
void()	wendigo_shatter7	=[	6,	wendigo_shatter8	] {};
void()	wendigo_shatter8	=[	7,	wendigo_shatter9	] {};
void()	wendigo_shatter9	=[	8,	wendigo_shatter10	] {};
void()	wendigo_shatter10	=[	9,	wendigo_shatter11	] {};
void()	wendigo_shatter11	=[	10,	wendigo_shatter12	] {};
void()	wendigo_shatter12	=[	11,	wendigo_shatter13	] {};
void()	wendigo_shatter13	=[	12,	wendigo_shatter14	] {};
void()	wendigo_shatter14	=[	13,	wendigo_shatter15	] {};
void()	wendigo_shatter15	=[	14,	wendigo_shatter16	] {};
void()	wendigo_shatter16	=[	15,	wendigo_shatter17	] {};
void()	wendigo_shatter17	=[	16,	wendigo_shatter18	] {};
void()	wendigo_shatter18	=[	17,	wendigo_shatter19	] {};
void()	wendigo_shatter19	=[	18,	wendigo_shatter20	] {};
void()	wendigo_shatter20	=[	19,	wendigo_shatter21	] {};
void()	wendigo_shatter21	=[	20,	wendigo_shatter22	] {};
void()	wendigo_shatter22	=[	21,	wendigo_shatter23	] {};
void()	wendigo_shatter23	=[	22,	wendigo_shatter23	] {remove(self);};



void(vector dir) FireIceSpike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	//local vector dir;
	//dir = aim (self, v_forward, 0);
	//makevectors(newmis.angles);
	
	//newmis.angles = self.angles;
	newmis.velocity= dir * 25;
	
	//newmis.velocity = newmis.velocity * 390;
	newmis.angles = vectoangles(newmis.velocity);
	
	newmis.touch = FreezeTouch;
	newmis.classname = "Icespike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 1;
	setmodel(newmis,"models/shardice.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, self.origin + '0 0 10');

	//newmis.speed = 700;
};

void icering()
{
	
	self.think = SUB_Remove;
	self.nextthink = 0.01;
	
	if(other.classname == "player")
	{
		T_RadiusDamage(self,self.owner,5,self.owner);
		FireIceSpike('0 25 0');
		FireIceSpike('50 0 0');
	}
	else
	{
		FireIceSpike('25 25 0');
		//FireIceSpike('50 0 0');
		FireIceSpike('-25 -25 0');
		FireIceSpike('-50 0 0');
		FireIceSpike('0 25 0');
		//FireIceSpike('0 50 0');
		FireIceSpike('25 -25 0');
		FireIceSpike('-25 -50 0');
	}
	
}


void shoot_iceball (float offset, vector offpos)
{
local entity snowball;
vector org,to_enemy;
//PARTICLE TRAIL
	makevectors(self.angles);
	self.effects(+)EF_MUZZLEFLASH;
	snowball=spawn();
	snowball.owner = self;
	snowball.solid=SOLID_BBOX;
	snowball.classname="iceball";
	snowball.movetype = MOVETYPE_BOUNCEMISSILE;
	snowball.dmg= 5;
	snowball.touch = icering;//yak_snowball_hit;
	snowball.th_die=shatter;
	snowball.deathtype="ice shatter";
	setmodel(snowball,"models/proj_wend.mdl");
	snowball.think=SUB_Remove;
	thinktime snowball : 6;

	snowball.drawflags=MLS_ABSLIGHT;
	snowball.abslight=0.5;
	setsize(snowball,'0 0 0','0 0 0');
	
	org=self.origin+self.proj_ofs+v_forward*64 - '0 0 5';
	snowball.speed=(400);
	to_enemy=normalize(self.enemy.origin+self.enemy.view_ofs-org);
	if(fov(self.enemy,self,45))
		snowball.velocity=to_enemy;
	else
	{
		snowball.velocity=v_forward;
		snowball.velocity_z=to_enemy_z;
	}
	snowball.velocity+=v_right*offset;
	if(self.enemy.velocity_x||self.enemy.velocity_y)
		snowball.velocity=snowball.velocity+v_right*(random(0.2) - 0.1);
	snowball.velocity=snowball.velocity*snowball.speed;
	snowball.avelocity_z=600;

	setorigin(snowball,org+offpos);
	
	
	//sound(self,CHAN_WEAPON,"wendigo/icehit.wav",1,ATTN_NORM);
}

/*
void() fire_icespike =
{
	makevectors (self.angles);
	do_shard('14 8 0'*self.scale,360 + random()*150, '0 0 0');
}*/

void()	wendigo_atk1	=[	35,		wendigo_atk2	] {};
void()	wendigo_atk2	=[	36,		wendigo_atk3	] {};
void()	wendigo_atk3	=[	37,		wendigo_atk4	] {};
void()	wendigo_atk4	=[	38,		wendigo_atk5	] {sound(self,CHAN_WEAPON,"wendigo/attack.wav",0.7,ATTN_NORM);};
void()	wendigo_atk5	=[	39,		wendigo_atk6	] {ai_charge(3);};
void()	wendigo_atk6	=[	40,		wendigo_atk7	] {ai_charge(5); ai_melee();};
void()	wendigo_atk7	=[	41,		wendigo_atk8	] {ai_charge(5); ai_melee();};
void()	wendigo_atk8	=[	42,		wendigo_atk9	] {ai_melee();shoot_iceball(0, '10 5 0');shoot_iceball(0, '-10 -5 0');};
void()	wendigo_atk9	=[	43,		wendigo_atk10] {ai_charge(1);};
void()	wendigo_atk10	=[	44,		wendigo_atk11	] {};
void()	wendigo_atk11	=[	45,		wendigo_atk12	] {};
void()	wendigo_atk12	=[	46,		wendigo_atk13	] {};
void()	wendigo_atk13	=[	47,		wendigo_run1	] {};

//void()	wendigo_atk9	=[	$attack9,		wendigo_atk10	] {};
//void()	wendigo_atk10	=[	$attack10,		wendigo_atk11	] {};
//void()	wendigo_atk11	=[	$attack11,		wendigo_run1	] {};

//===========================================================================

void()	wendigo_pain1	=[	78,	wendigo_pain2	] {ai_pain(0);};
void()	wendigo_pain2	=[	79,	wendigo_pain3	] {ai_pain(3);};
void()	wendigo_pain3	=[	80,	wendigo_pain4	] {};
void()	wendigo_pain4	=[	81,	wendigo_pain5	] {};
void()	wendigo_pain5	=[	82,	wendigo_pain6	] {ai_pain(2);};
void()	wendigo_pain6	=[	83,	wendigo_pain7	] {ai_pain(4);};
void()	wendigo_pain7	=[	84,	wendigo_run1	] {ai_pain(2);};

/*
void()	wendigo_pain8	=[	64,	wendigo_pain9	] {ai_painforward(5);};
void()	wendigo_pain9	=[	65,	wendigo_pain10	] {ai_painforward(5);};
void()	wendigo_pain10	=[	66,	wendigo_pain11	] {ai_painforward(0);};
void()	wendigo_pain11	=[	67,	wendigo_pain12	] {};
void()	wendigo_pain12	=[	68,	wendigo_run1	] {};

*/

void(entity attacker, float damage)	wendigo_pain =
{
	local float r;

	if (self.pain_finished > time)
		return;

	r = random();
	
	sound (self, CHAN_VOICE, "wendigo/idle.wav", 1, ATTN_NORM);
	wendigo_pain1 ();
	self.pain_finished = time + 1;
	
};

//===========================================================================


void()	wendigo_die1	=[	84,	wendigo_die2	] {};
void()	wendigo_die2	=[	85,	wendigo_die3	] {};
void()	wendigo_die3	=[	86,	wendigo_die4	] {};
void()	wendigo_die4	=[	87,	wendigo_die4	] {chunk_death();};
/*
void()	wendigo_die5	=[	88,	wendigo_die6	] {};
void()	wendigo_die6	=[	89,	wendigo_die7	] {};
void()	wendigo_die7	=[	90,	wendigo_die8	] {};
void()	wendigo_die8	=[	91,	wendigo_die9	] {};
void()	wendigo_die9	=[	92,	wendigo_die10] {};
void()	wendigo_die10=[	93,	wendigo_die11] {MakeSolidCorpse();};

*/
/*
void()	wendigo_die11=[	79,	wendigo_die12] {};
void()	wendigo_die12=[	80,	wendigo_die13] {};
void()	wendigo_die13=[	81,	wendigo_die14] {};
void()	wendigo_die14=[	82,	wendigo_die15] {};
void()	wendigo_die15=[	83,	wendigo_die16] {};
void()	wendigo_die16=[	84,	wendigo_die17] {};
void()	wendigo_die17=[	85,	wendigo_die18] {};
void()	wendigo_die18=[	86,	wendigo_die19] {};
void()	wendigo_die19=[	87,	wendigo_die20] {};
void()	wendigo_die20=[	88,	wendigo_die21] {MakeSolidCorpse();};
void()	wendigo_die21=[	89,	wendigo_die21] {};

*/
//entity new;

void() wendigo_die =
{
	/*ThrowGib ("models/shard.mdl", self.health);
	ThrowGib ("models/shard.mdl", self.health);
	ThrowGib ("models/shard.mdl", self.health);
	ThrowGib ("models/shard.mdl", self.health);*/
	//self.drawflags(+)DRF_TRANSLUCENT|MLS_CRYSTALGOLEM;
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/shardwend.mdl", self.health);
	ThrowGib ("models/bloodpool_ice.mdl", self.health);
	/*ThrowGib ("models/shardice.mdl", self.health);
	ThrowGib ("models/shardice.mdl", self.health);*/
	//ThrowGib ("models/shard.mdl", self.health);
	sound (self, CHAN_VOICE, "misc/icestatx.wav", 1, ATTN_NORM);
	//setmodel (self, "models/IceDeath.mdl");
	setmodel (self, "");
	//self.skin = 0;
	wendigo_shatter1();
	return;

};

/*QUAKED monster_wendigo (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_wendigo =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	if (!self.flags2 & FL_SUMMONED&&!self.flags2&FL2_RESPAWN)
	{
		precache_model ("models/wendigo.mdl");
		precache_model ("models/IceDeath.mdl");
		precache_model ("models/proj_wend.mdl");

		precache_sound ("wendigo/attack.wav");
		precache_sound ("wendigo/icehit.wav");
		precache_sound ("wendigo/idle.wav");
		precache_sound ("crusader/icewall.wav");
	}

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "models/wendigo.mdl");

	setsize (self, '-13 -13 -22', '13 13 35');
	self.health = 62;
	//self.scale = 0.9;
	
	self.thingtype=THINGTYPE_ICE;
	
	self.netname="wendigo";
	self.flags (+) FL_MONSTER;
	self.flags2 (+) FL_ALIVE;
	self.yaw_speed = 12;
	
	self.monsterclass = CLASS_GRUNT;
	//self.hull=HULL_PLAYER;
	
	if(!self.experience_value)
		self.experience_value = 20;
	if(!self.mass)
		self.mass = 10;

	self.th_stand = wendigo_stand1;
	self.th_walk = wendigo_walk1;
	self.th_run = wendigo_run1;
	self.th_melee = wendigo_atk1;
	self.th_missile = wendigo_atk1;
	self.th_pain = wendigo_pain;
	self.th_die = wendigo_die;
	
	walkmonster_start ();
};

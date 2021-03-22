/*
	=Roman Legionnaire=
	Code by Whirledtsar, based on Mummy code by Raven, model by Rogue Software from Dissolution Of Eternity
	
	Custom/edited functions used:
	weapons.hc:	void Knockback (entity victim, entity attacker, entity inflictor, float force, float zmod)
	fight.hc:	void ai_melee (void)
*/

float ROMAN_STAND = 0;
float ROMAN_RUN = 32;
float ROMAN_RUN_END = 42;
float ROMAN_WALK = 43;
float ROMAN_WALK_END = 55;
float ROMAN_SHOOT = 56;
float ROMAN_SHOOT_GO = 59;
float ROMAN_SHOOT_END = 64;
float ROMAN_STAB = 65;
float ROMAN_STAB_END = 75;
float ROMAN_STAB2 = 76;
float ROMAN_STAB2_GO = 85;
float ROMAN_STAB2_END = 91;
float ROMAN_PUSH = 92;
float ROMAN_PUSH_GO = 96;
float ROMAN_PUSH_END = 103;
float ROMAN_PAIN = 104;
float ROMAN_PAIN_END = 113;
float ROMAN_PAIN_SHORT = 114;
float ROMAN_PAIN_SHORT_END = 120;
float ROMAN_DEATH = 121;
float ROMAN_DEATH_END = 129;


void() roman_melee;
void() roman_run;
void() roman_stand;
void() roman_walk;
void() monster_roman_lord;

void precache_roman (void)
{
	//precache_mummy();
	precache_model2 ("models/mumshot.mdl");
	precache_sound2 ("mummy/mislfire.wav");
	precache_sound2 ("mummy/tap.wav");
	precache_sound2 ("mummy/fire.wav");
	
	precache_model("models/roman.mdl");
	precache_sound("weapons/knfhit.wav");
	precache_sound("roman/see.wav");
	precache_sound("roman/pain.wav");
	precache_sound("roman/die.wav");
	precache_sound("roman/die2.wav");
}

void roman_die (void)
{
	self.think = roman_die;
	thinktime self : HX_FRAME_TIME*2;
	
	AdvanceFrame(ROMAN_DEATH, ROMAN_DEATH_END);
	
	if (self.frame == ROMAN_DEATH) {
		if (self.strength)
			sound (self, CHAN_VOICE, "roman/die2.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "roman/die.wav", 1, ATTN_NORM);
		ThrowGib ("models/blood.mdl", self.health);
		ThrowGib ("models/blood.mdl", self.health);
	}
	if (self.frame == ROMAN_DEATH_END) {
		if (self.strength)
			self.skin = 3;	//close eyes
		else
			self.skin = 2;	//close eyes
		self.frame = ROMAN_DEATH_END;
		MakeSolidCorpse();
		return;
	}
	else if (self.frame < ROMAN_DEATH_END-2 && self.health <= (-50)) {
		stopSound(self,CHAN_VOICE);
		chunk_death();
	}
}

void roman_pain_long (void)
{
	AdvanceFrame(ROMAN_PAIN, ROMAN_PAIN_END);
	if (self.frame == ROMAN_PAIN_END) {
		self.pain_finished = time+random(0.3,1);
		self.think = roman_run;
		thinktime self : 0;
	}
	else
		thinktime self : HX_FRAME_TIME;
}

void roman_pain_short (void)
{
	AdvanceFrame(ROMAN_PAIN_SHORT, ROMAN_PAIN_SHORT_END);
	if (self.frame == ROMAN_PAIN_SHORT_END) {
		self.pain_finished = time+random(0.3,1);
		self.think = roman_run;
		thinktime self : 0;
	}
	else
		thinktime self : HX_FRAME_TIME;
}

void roman_pain(entity attacker, float damg)
{
	if (time < self.pain_finished)
		return;
	
	ThrowGib ("models/blood.mdl", self.health);
	
	/*if (self.strength)
		sound (self, CHAN_VOICE, "mummy/pain2.wav", 1, ATTN_NORM);
	else*/
		sound (self, CHAN_VOICE, "roman/pain.wav", 1, ATTN_NORM);
	
	if (self.strength)
		self.think = roman_pain_short;
	else
		self.think = roman_pain_long;
	
	thinktime self : 0;
}


void lordroman_missile (void)
{
	vector delta;
	
	self.think = lordroman_missile;
	thinktime self : HX_FRAME_TIME;
	
	delta = self.enemy.origin - self.origin;
	if (vlen(delta) < 70)  // Too close to shoot with a missile
		mummymelee();
	
	AdvanceFrame(ROMAN_STAB2,ROMAN_STAB2_END);
	
	if (self.frame == ROMAN_STAB2)
		sound (self, CHAN_WEAPON, "mummy/tap.wav", 1, ATTN_NORM);
	else if (self.frame == ROMAN_STAB2_GO)
		launch_mumshot(2.5);
	
	if (self.frame < ROMAN_STAB2_GO)
		thinktime self : HX_FRAME_TIME*1.25;
	
	if (self.frame == ROMAN_STAB2_END) {
		SUB_AttackFinished (1.5);
		roman_run();
	}
	else
		ai_face();
}

void roman_missile (void)
{
	float chance;
	vector delta;

	thinktime self : HX_FRAME_TIME;
	self.think = roman_missile;

	delta = self.enemy.origin - self.origin;
	if (vlen(delta) < 70)  // Too close to shoot with a missile
		roman_melee();

	AdvanceFrame(ROMAN_SHOOT,ROMAN_SHOOT_END);

	if (self.frame == ROMAN_SHOOT_GO)
	{
		sound (self, CHAN_WEAPON, "mummy/fire.wav", 1, ATTN_NORM);
		self.effects (+) EF_MUZZLEFLASH;
		makevectors(self.angles);
		Create_Missile(self,self.origin + v_forward*14 + v_right * 5 + v_up * 35, 
			self.enemy.origin+self.enemy.view_ofs,"models/akarrow.mdl","green_arrow",0,1000,mummissile_touch);
	}
	
	if (self.frame == ROMAN_SHOOT_END) {
		if (enemy_range < RANGE_NEAR)
			chance = 0.80;
		else if (enemy_range < RANGE_MID)
			chance = 0.70;
		else if (enemy_range < RANGE_FAR)
			chance = 0.40;
		
		if (random() < chance)  // Repeat as necessary
			self.frame = ROMAN_SHOOT;
		else {
			SUB_AttackFinished (1);
			roman_run();
		}
	}
	else
		ai_face();
}

void roman_missile_choice (void)
{
	float chance;

	// He's more likely to use his flame attack when enemy is farther away
	if (enemy_range < RANGE_NEAR)
		chance = 0.40;	//0.6
	else if (enemy_range < RANGE_MID)
		chance = 0.60;	//0.8
	else if (enemy_range < RANGE_FAR)
		chance = 0.80;	//0.9

	if (random() < chance) 
		lordroman_missile();
	else
		roman_missile();
}

void roman_push_dmg()
{
vector	org1,org2;
float dist;

	if (!self.enemy)
		return;
		
	org1=self.origin+self.proj_ofs;
	org2=self.enemy.origin;
	
	if(vlen(org2-org1)>80)
	{
		org2=(self.enemy.absmin+self.enemy.absmax)*0.5;
		if(vlen(org2-org1)>80)
		return;
	}

	traceline(org1,org2,FALSE,self);
	if(trace_ent!=self.enemy)
	{
		org2=(self.enemy.absmin+self.enemy.absmax)*0.5;
		traceline(org1,org2,FALSE,self);
	}
		
	if(!trace_ent.takedamage)
		return;
	
	MetalHitSound (trace_ent.thingtype);
	T_Damage (trace_ent, self, self, random(6,12));
	if (fov(trace_ent, self, 120))
		Knockback (trace_ent, self, self, 26, 0.75);
}

void roman_push(void)
{
	self.nextthink = time + HX_FRAME_TIME;
	self.think = roman_push;
	
	AdvanceFrame(ROMAN_PUSH,ROMAN_PUSH_END);
	
	if (self.frame<98)
		ai_charge(2);
	
	if (self.frame==ROMAN_PUSH_GO)
		roman_push_dmg();
	else if (self.frame==ROMAN_PUSH_END) {
		SUB_AttackFinished(1);
		roman_run();
	}
}

void roman_stab(void)
{
	vector delta;

	AdvanceFrame(ROMAN_STAB,ROMAN_STAB_END);
	
	if (self.frame<=ROMAN_STAB+1)		//slight delay
		self.nextthink = time + HX_FRAME_TIME*2;
	else
		self.nextthink = time + HX_FRAME_TIME;
	self.think = roman_stab;
	
	switch (self.frame)	//set melee range
	{
		case 69:
			self.t_length = 70;
			break;
		case 70:
			self.t_length = 85;
			break;
		case 71:
			self.t_length = 90;
			break;
	}
	
	if (self.frame >= 69 && self.frame <= 71)
	{
		ai_melee();
		delta = self.enemy.origin - (self.origin+self.proj_ofs);
		if (vlen(delta)<=self.t_length && !self.aflag) {
			if (trace_ent.thingtype==THINGTYPE_FLESH)
				sound (self, CHAN_WEAPON, "weapons/knfhit.wav", 0.5, ATTN_NORM);
			else
				sound (self, CHAN_WEAPON, "weapons/met2stn.wav", 1, ATTN_NORM);
			self.aflag = TRUE;
		}
		trace_ent = world;
	}
	
	if (self.frame == ROMAN_STAB_END)
	{
		if (!EnemyIsValid(self.enemy))
			roman_run();
		
		self.aflag = FALSE;
		self.t_length = 0;
		delta = self.enemy.origin - self.origin;
		if (vlen(delta) > 80) {
			SUB_AttackFinished(1);
			roman_run();
		}
	}
	else
		ai_charge(2);
}

void roman_melee (void)
{
	vector delta;
	delta = self.enemy.origin - self.origin;
	if (vlen(delta) < 90 && random()<0.9) {
		if (time < self.attack_finished+0.5) {	//dont repeat push in quick succession
			if (self.oldweapon) {
				self.oldweapon = FALSE;
				roman_stab();
				return;
			}
		}
		self.oldweapon = TRUE;
		roman_push();
		return;
	}
	
	self.oldweapon = FALSE;
	roman_stab();
}

void roman_run(void)
{
	thinktime self : HX_FRAME_TIME;
	self.think = roman_run;

	if ((random() < .10) && (self.frame == ROMAN_RUN))
	{
		/*if (self.strength)
			sound (self, CHAN_VOICE, "mummy/moan2.wav", 1, ATTN_NORM);
		else*/
			sound (self, CHAN_VOICE, "roman/see.wav", 1, ATTN_NORM);
	}
	
	AdvanceFrame(ROMAN_RUN,ROMAN_RUN_END);

	ai_run(5);
}


void roman_walk(void)
{
	thinktime self : HX_FRAME_TIME;
	self.think = roman_walk;
	
	if ((random() < .10) && (self.frame == ROMAN_WALK))
	{
		/*if (self.strength)
			sound (self, CHAN_VOICE, "mummy/moan2.wav", 1, ATTN_NORM);
		else*/
			sound (self, CHAN_VOICE, "roman/see.wav", 1, ATTN_NORM);
	}

	AdvanceFrame(ROMAN_WALK,ROMAN_WALK_END);

	ai_walk(2.5);
}

void roman_stand(void)
{
	thinktime self : HX_FRAME_TIME;
	self.think = roman_stand;

	self.frame = ROMAN_STAND;

	if (random() < .5)
		ai_stand();
}

/*QUAKED monster_roman (1 0.3 0) (-16 -16 0) (16 16 56) AMBUSH 

-------------------------FIELDS-------------------------
health : 150
experience : 500
--------------------------------------------------------
*/
void monster_roman (void)
{
	if(deathmatch)
	{
		remove(self);
		return;
	}

	if(!self.flags2&FL_SUMMONED && !self.flags2&FL2_RESPAWN)
		precache_roman();
	
	setmodel(self, "models/roman.mdl");
	setsize(self, '-16 -16 0', '16 16 56');
	self.hull = HULL_PLAYER;
	
	if (!self.experience_value)
		self.experience_value = 200;
	if (!self.health)
		self.health = 200;
	self.init_exp_val = self.experience_value;
	self.max_health = self.health;
	self.monsterclass = CLASS_GRUNT;
	self.thingtype = THINGTYPE_FLESH;
	
	self.mass = 8;
	self.movetype = MOVETYPE_STEP;
	self.solid = SOLID_SLIDEBOX;
	
	self.buff=2;
	self.flags (+) FL_MONSTER;
	self.mintel = 3;
	self.yaw_speed = 10;
	self.sightsound = "roman/see.wav";
	
	self.th_stand = roman_stand;
	self.th_walk = roman_walk;
	self.th_run = roman_run;
	self.th_melee = roman_melee;
	self.th_missile = roman_missile;
	self.th_pain = roman_pain;
	self.th_die = roman_die;
	self.th_jump = monster_jump;	self.jumpframe = ROMAN_PAIN_SHORT;
	self.th_init = monster_roman;
	
	if (self.classname=="monster_roman_lord") {
		self.skin = 1;
		self.monsterclass = CLASS_HENCHMAN;
		self.strength = TRUE;
		self.th_missile = roman_missile_choice;
		self.th_init = monster_roman_lord;
	}
	
	walkmonster_start();
}

/*QUAKED monster_roman_lord (1 0.3 0) (-16 -16 0) (16 16 50) AMBUSH
-------------------------FIELDS-------------------------
health : 500
experience : 300
--------------------------------------------------------
*/
void monster_roman_lord (void)
{
	if(deathmatch)
	{
		remove(self);
		return;
	}

	if(!self.flags2&FL_SUMMONED&&!self.flags2&FL2_RESPAWN)
		precache_roman();
	
	if (!self.health)
		self.health = 400;
	if (!self.experience_value)
		self.experience_value = 300;
	
	monster_roman();
}


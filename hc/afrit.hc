/*
==============================================================================

Afrit

==============================================================================
*/

$cd id1/models/afrit
$origin 0 0 24
$base base
$skin badass3

float AFRIT_COCOON = 2;
float AFRIT_DORMANT = 16;

float AFRIT_DODGESPEED = 6;
float AFRIT_STAGE_CHARGE = 1;
float AFRIT_STAGE_SLIDE = 2;

void() AfritCheckDodge;
void() afrit_wake1;
void(entity attacker, float damage)	afrit_pain;

void afrit_raise()
{
float state;
	state = RewindFrame(13,0);
	
	self.think = self.th_raise;
	
	if (state==AF_BEGINNING) {
		sound (self, CHAN_VOICE, "afrit/death.wav", 1, ATTN_NORM);
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

void() AfritEffects
{
entity new;
string model;

	if (self.count == 0) {
		model="models/burn.spr";
		self.count=1;
	}
	else if (self.count == 1) {
		model="models/burn1.spr";
		self.count=2;
	}
	else {
		model="models/burn2.spr";
		self.count=0;
	}
	
	new = spawn_temp();
	new.origin = (self.absmin+self.absmax)*0.5;
	new.origin_z = new.origin_z + 6;
	setmodel (new, model);
	setsize (new, '0 0 0', '0 0 0');
	new.drawflags(+)DRF_TRANSLUCENT;
	new.movetype = MOVETYPE_FLY;
	new.velocity_x = (random(-5,5));
	new.velocity_y = (random(-5,5));
	new.velocity_z = (random(10,27));
	
	new.think = SUB_Remove;
	thinktime new : 0.09;
}

void() ABallTouch
{
	sound(self,CHAN_AUTO,"afrit/afrithit.wav",1,ATTN_NORM);
	if(other.classname=="monster_afrit")
	{
		remove(self);
		return;
	}
	else if(other.takedamage)
		T_Damage(other,self,self.owner,self.dmg);

	//T_RadiusDamage(self,self.owner,self.dmg / 2,other);
	starteffect(CE_SM_EXPLOSION,self.origin-self.movedir*8,0.05);
	remove(self);
}

void(vector offset) AfritFire =
{
entity missile;
vector vec;

	missile = spawn ();
	missile.owner = self;
	missile.speed=400;
	missile.dmg = 3;

	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.health = 10;

	setmodel (missile, "models/fireball2.mdl");
	setsize (missile, '0 0 0', '0 0 0');		

// set missile speed	

	makevectors (self.angles);
	vec = self.origin + self.view_ofs + v_factor(offset);
	setorigin (missile, vec);

	vec = self.enemy.origin - missile.origin + self.enemy.view_ofs;
	vec = normalize(vec);

	missile.velocity = (vec+aim_adjust(self.enemy))*missile.speed;
	missile.angles = vectoangles('0 0 0'-missile.velocity);
	
	missile.touch = ABallTouch;

	missile.think = fireball_1;
	missile.nextthink = time + HX_FRAME_TIME;
	missile.drawflags(+)MLS_FULLBRIGHT|MLS_FIREFLICKER;
	sound(self,CHAN_WEAPON,"afrit/atk.wav",0.7,ATTN_NORM);
};

void afrit_dormant () [++ 78 .. 101]
{
	if (self.enemy) {
		self.think = self.th_run;
		self.th_run();
		return;
	}
	else
		self.think = afrit_dormant;
	thinktime self : HX_FRAME_TIME;
	//no idle sound intentionally
	if (self.frame==91)
		CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);
}

void()	afrit_sit1	=[	78,		afrit_sit2	] {
if (random() < 0.02)
	sound (self, CHAN_VOICE, "afrit/idle.wav", 1,  ATTN_IDLE);
ai_stand();};
void()	afrit_sit2	=[	79,		afrit_sit3	] {ai_stand();};
void()	afrit_sit3	=[	80,		afrit_sit4	] {ai_stand();};
void()	afrit_sit4	=[	81,		afrit_sit5	] {ai_stand();};
void()	afrit_sit5	=[	82,		afrit_sit6	] {ai_stand();};
void()	afrit_sit6	=[	83,		afrit_sit7	] {ai_stand();};
void()	afrit_sit7	=[	84,		afrit_sit8	] {ai_stand();};
void()	afrit_sit8	=[	85,		afrit_sit9	] {ai_stand();};
void()	afrit_sit9	=[	86,		afrit_sit10	] {ai_stand();};
void()	afrit_sit10	=[	87,		afrit_sit11	] {ai_stand();};
void()	afrit_sit11	=[	88,		afrit_sit12	] {ai_stand();};
void()	afrit_sit12	=[	89,		afrit_sit13	] {ai_stand();};
void()	afrit_sit13	=[	90,		afrit_sit14	] {ai_stand();};
void()	afrit_sit14	=[	91,		afrit_sit15	] {ai_stand();};
void()	afrit_sit15	=[	92,		afrit_sit16	] {ai_stand();CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);};
void()	afrit_sit16	=[	93,		afrit_sit17	] {ai_stand();};
void()	afrit_sit17	=[	94,		afrit_sit18	] {ai_stand();};
void()	afrit_sit18	=[	95,		afrit_sit19	] {ai_stand();};
void()	afrit_sit19	=[	96,		afrit_sit20	] {ai_stand();};
void()	afrit_sit20	=[	97,		afrit_sit21	] {ai_stand();};
void()	afrit_sit21	=[	98,		afrit_sit22	] {ai_stand();};
void()	afrit_sit22	=[	99,		afrit_sit23	] {ai_stand();};
void()	afrit_sit23	=[	100,		afrit_sit24	] {ai_stand();};
void()	afrit_sit24	=[	101,		afrit_sit1	] {ai_stand();};

void()	afrit_hover1	=[	35,		afrit_hover2	] {
if (random() < 0.02)
	sound (self, CHAN_VOICE, "afrit/idle.wav", 1,  ATTN_IDLE);
ai_stand();}; //3);};
void()	afrit_hover2	=[	36,		afrit_hover3	] {ai_stand();AfritEffects();}; //2);};
void()	afrit_hover3	=[	37,		afrit_hover4	] {ai_stand();}; //3);};
void()	afrit_hover4	=[	38,		afrit_hover5	] {ai_stand();particle4(self.origin + '0 0 18',random(5,10),254, PARTICLETYPE_FIRE,10);CreateWhiteSmoke(self.origin + '0 0 16','0 0 18',HX_FRAME_TIME * 2);}; //4);};
void()	afrit_hover5	=[	39,		afrit_hover6	] {ai_stand();AfritEffects();}; //3);};
void()	afrit_hover6	=[	40,		afrit_hover7	] {ai_stand();}; //3);};
void()	afrit_hover7	=[	41,		afrit_hover8	] {ai_stand();AfritEffects();}; //3);};
void()	afrit_hover8	=[	42,		afrit_hover9	] {ai_stand();}; //4);};
void()	afrit_hover9	=[	43,		afrit_hover10	] {ai_stand();AfritEffects();}; //3);};
void()	afrit_hover10	=[	44,		afrit_hover11	] {ai_stand();}; //3);};
void()	afrit_hover11	=[	45,		afrit_hover12	] {ai_stand();AfritEffects();if (random() < 0.4) CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);}; //2);};
void()	afrit_hover12	=[	46,		afrit_hover13	] {ai_stand();}; //3);};
void()	afrit_hover13	=[	47,		afrit_hover14	] {ai_stand();AfritEffects();sound (self, CHAN_AUTO, "afrit/hover.wav", 1, ATTN_IDLE);}; //4);};
void()	afrit_hover14	=[	48,		afrit_hover15	] {ai_stand();}; //3);};
void()	afrit_hover15	=[	49,		afrit_hover16	] {ai_stand();AfritEffects();}; //3);};
void()	afrit_hover16	=[	50,		afrit_hover17	] {ai_stand();}; //2);};
void()	afrit_hover17	=[	51,		afrit_hover18	] {ai_stand();AfritEffects();}; //3);};
void()	afrit_hover18	=[	52,		afrit_hover19	] {ai_stand();}; //3);};
void()	afrit_hover19	=[	53,		afrit_hover20	] {ai_stand();AfritEffects();particle4(self.origin + '0 0 18',random(5,10),254, PARTICLETYPE_FIRE,10);CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);}; //2);};
void()	afrit_hover20	=[	54,		afrit_hover1	] {ai_stand();}; //3);};

//AFRIT DODGE

void afrit_slide (void)	//self.lefty = 1 for right, -1 for left
{
	if (!walkmove (self.ideal_yaw + (90*self.lefty), AFRIT_DODGESPEED + self.weaponframe_cnt, FALSE))
		if (self.attack_state != AS_FERRY)
			self.think=self.th_run;
	
	self.weaponframe_cnt*=1.75;
	if(random()<0.1) {
		CreateWhiteSmoke(self.origin-v_right*(10),'0 0 8',HX_FRAME_TIME * 2); }
}

void()	afrit_dodge1	=[	16,		afrit_dodge2	] {afrit_slide();};
void()	afrit_dodge2	=[	17,		afrit_dodge3	] {afrit_slide();};
void()	afrit_dodge3	=[	16,		afrit_dodge4	] {afrit_slide();AfritEffects();};
void()	afrit_dodge4	=[	17,		afrit_dodge5	] {afrit_slide();};
void()	afrit_dodge5	=[	16,		afrit_dodge6	] {afrit_slide();};
void()	afrit_dodge6	=[	17,		afrit_dodge7	] {afrit_slide();};
void()	afrit_dodge7	=[	16,		afrit_fly1	] {afrit_slide(); AfritEffects();};

void()	afrit_glide1	=[	35,		afrit_glide2	] {
if (random() < 0.02)
	sound (self, CHAN_VOICE, "afrit/idle.wav", 1,  ATTN_IDLE);
ai_walk(3);};
void()	afrit_glide2	=[	36,		afrit_glide3	] {ai_walk(3); if (self.th_stand == afrit_sit1) self.th_stand = afrit_hover1;};
void()	afrit_glide3	=[	37,		afrit_glide4	] {ai_walk(3);self.drawflags(+)MLS_FULLBRIGHT;};
void()	afrit_glide4	=[	38,		afrit_glide5	] {ai_walk(4);};
void()	afrit_glide5	=[	39,		afrit_glide6	] {ai_walk(3);particle4(self.origin + '0 0 18',random(5,10),254, PARTICLETYPE_FIRE,10);CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);};
void()	afrit_glide6	=[	40,		afrit_glide7	] {ai_walk(3);};
void()	afrit_glide7	=[	41,		afrit_glide8	] {ai_walk(3);AfritEffects();};
void()	afrit_glide8	=[	42,		afrit_glide9	] {ai_walk(4);};
void()	afrit_glide9	=[	43,		afrit_glide10	] {ai_walk(3);};
void()	afrit_glide10	=[	44,		afrit_glide11	] {ai_walk(3);AfritEffects();};
void()	afrit_glide11	=[	45,		afrit_glide12	] {ai_walk(3);CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);};
void()	afrit_glide12	=[	46,		afrit_glide13	] {ai_walk(3);};
void()	afrit_glide13	=[	47,		afrit_glide14	] {ai_walk(3);AfritEffects();sound (self, CHAN_AUTO, "afrit/hover.wav", 1, ATTN_IDLE);};
void()	afrit_glide14	=[	48,		afrit_glide15	] {ai_walk(4);};
void()	afrit_glide15	=[	49,		afrit_glide16	] {ai_walk(4);};
void()	afrit_glide16	=[	50,		afrit_glide17	] {ai_walk(3);AfritEffects();};
void()	afrit_glide17	=[	51,		afrit_glide18	] {ai_walk(3);};
void()	afrit_glide18	=[	52,		afrit_glide19	] {ai_walk(3);particle4(self.origin + '0 0 18',random(5,10),254, PARTICLETYPE_FIRE,10);CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);};
void()	afrit_glide19	=[	53,		afrit_glide20	] {ai_walk(3);AfritEffects();};
void()	afrit_glide20	=[	54,		afrit_glide1	] {ai_walk(3);};

void() afrit_run =
{
	if (self.spawnflags & AFRIT_COCOON) {
		self.spawnflags (-) AFRIT_COCOON;
		self.th_pain = afrit_pain;
		self.th_stand = afrit_hover1;
		self.th_run = afrit_fly1;
		self.think = afrit_wake1;
	}
	else
		self.think = afrit_fly1;
	
	thinktime self : 0;
};

void()	afrit_fly1	=[	35,		afrit_fly2	] {
if (random() < 0.02)
	sound (self, CHAN_VOICE, "afrit/idle.wav", 1,  ATTN_IDLE);
AfritCheckDodge();
ai_run(3);};
void()	afrit_fly2	=[	36,		afrit_fly3	] {AfritCheckDodge(); ai_run(3); if (self.th_stand == afrit_sit1) self.th_stand = afrit_hover1;};
void()	afrit_fly3	=[	37,		afrit_fly4	] {AfritCheckDodge(); ai_run(3); self.drawflags(+)MLS_FULLBRIGHT;};
void()	afrit_fly4	=[	38,		afrit_fly5	] {AfritCheckDodge(); ai_run(4);};
void()	afrit_fly5	=[	39,		afrit_fly6	] {AfritCheckDodge(); ai_run(3); particle4(self.origin + '0 0 18',random(5,10),254, PARTICLETYPE_FIRE,10);CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);};
void()	afrit_fly6	=[	40,		afrit_fly7	] {AfritCheckDodge(); ai_run(3);};
void()	afrit_fly7	=[	41,		afrit_fly8	] {AfritCheckDodge(); ai_run(3); AfritEffects();};
void()	afrit_fly8	=[	42,		afrit_fly9	] {AfritCheckDodge(); ai_run(4);};
void()	afrit_fly9	=[	43,		afrit_fly10	] {AfritCheckDodge(); ai_run(3);};
void()	afrit_fly10	=[	44,		afrit_fly11	] {AfritCheckDodge(); ai_run(3); AfritEffects();};
void()	afrit_fly11	=[	45,		afrit_fly12	] {AfritCheckDodge(); ai_run(3); CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);};
void()	afrit_fly12	=[	46,		afrit_fly13	] {AfritCheckDodge(); ai_run(3);};
void()	afrit_fly13	=[	47,		afrit_fly14	] {AfritCheckDodge(); ai_run(3); AfritEffects(); sound (self, CHAN_AUTO, "afrit/hover.wav", 1, ATTN_NORM);};
void()	afrit_fly14	=[	48,		afrit_fly15	] {AfritCheckDodge(); ai_run(4);};
void()	afrit_fly15	=[	49,		afrit_fly16	] {AfritCheckDodge(); ai_run(4);};
void()	afrit_fly16	=[	50,		afrit_fly17	] {AfritCheckDodge(); ai_run(3); AfritEffects();};
void()	afrit_fly17	=[	51,		afrit_fly18	] {AfritCheckDodge(); ai_run(3);};
void()	afrit_fly18	=[	52,		afrit_fly19	] {AfritCheckDodge(); ai_run(3); particle4(self.origin + '0 0 18',random(5,10),254, PARTICLETYPE_FIRE,10);CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);};
void()	afrit_fly19	=[	53,		afrit_fly20	] {AfritCheckDodge(); ai_run(3); AfritEffects();};
void()	afrit_fly20	=[	54,		afrit_fly1	] {AfritCheckDodge(); ai_run(3);};

void afrit_charge ()
{
	ai_face();
	if (self.monster_stage != AFRIT_STAGE_CHARGE)
		return;
	
	self.weaponframe_cnt+=0.5;
	ai_charge(self.weaponframe_cnt);
}

void afrit_atk_slide ()
{
	ai_face();
	if (self.monster_stage != AFRIT_STAGE_SLIDE)
		return;
	
	afrit_slide();
}

void()	afrit_atk1	=[	14,		afrit_atk2	] {
	self.weaponframe_cnt = 0.25;
	self.attack_state = AS_FERRY;
	if (random() < (0.3+(skill*0.1)) )
		self.monster_stage = AFRIT_STAGE_SLIDE;
	else
		self.monster_stage = AFRIT_STAGE_CHARGE;
};
void()	afrit_atk2	=[	15,		afrit_atk3	] {ai_face(); };
void()	afrit_atk3	=[	16,		afrit_atk4	] {afrit_charge(); };
void()	afrit_atk4	=[	17,		afrit_atk5	] {afrit_charge(); AfritEffects();};
void()	afrit_atk5	=[	18,		afrit_atk6	] {afrit_charge(); };
void()	afrit_atk6	=[	19,		afrit_atk7	] {afrit_charge(); };
void()	afrit_atk7	=[	20,		afrit_atk8	] {afrit_charge(); };
void()	afrit_atk8	=[	21,		afrit_atk9	] {afrit_charge(); AfritEffects();};
void()	afrit_atk9	=[	22,		afrit_atk10	] {afrit_charge(); afrit_atk_slide(); };
void()	afrit_atk10	=[	23,		afrit_atk11	] {afrit_atk_slide(); };
void()	afrit_atk11	=[	24,		afrit_atk12	] {afrit_atk_slide();  AfritFire(0); particle4(self.origin + '0 0 18',random(5,10),254, PARTICLETYPE_FIRE,10); CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);};
void()	afrit_atk12	=[	25,		afrit_atk13] {afrit_atk_slide(); AfritEffects();};
void()	afrit_atk13=[	26,		afrit_atk14	] {afrit_atk_slide(); };
void()	afrit_atk14=[	27,		afrit_atk15	] {afrit_atk_slide(); AfritFire(0);};
void()	afrit_atk15=[	28,		afrit_atk16	] {afrit_atk_slide(); };
void()	afrit_atk16=[	29,		afrit_atk17	] {afrit_atk_slide(); AfritEffects();};
void()	afrit_atk17=[	30,		afrit_atk18	] {afrit_atk_slide(); AfritFire(0);CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);};
void()	afrit_atk18=[	31,		afrit_atk19	] {ai_face(); };
void()	afrit_atk19=[	32,		afrit_atk20	] {ai_face(); AfritCheckDodge();};
void()	afrit_atk20=[	33,		afrit_atk21	] {AfritCheckDodge();};
void()	afrit_atk21=[	34,		afrit_fly1	] {AfritEffects(); AfritCheckDodge();};


//===========================================================================

void()	afrit_pain1	=[	62,	afrit_pain2	] {if (random() < 0.1) afrit_dodge1();};
void()	afrit_pain2	=[	63,	afrit_pain3	] {};
void()	afrit_pain3	=[	64,	afrit_pain4	] {};
void()	afrit_pain4	=[	65,	afrit_pain5	] {};
void()	afrit_pain5	=[	66,	afrit_pain6	] {ai_pain(2);};
void()	afrit_pain6	=[	67,	afrit_pain7	] {ai_pain(2);};
void()	afrit_pain7	=[	68,	afrit_pain8	] {AfritEffects();};
void()	afrit_pain8	=[	69,	afrit_pain9	] {};
void()	afrit_pain9	=[	70,	afrit_pain10	] {AfritCheckDodge();};
void()	afrit_pain10	=[	71,	afrit_pain11	] {};
void()	afrit_pain11	=[	72,	afrit_pain12	] {AfritEffects();};
void()	afrit_pain12	=[	73,	afrit_pain13	] {};
void()	afrit_pain13	=[	74,	afrit_pain14	] {};
void()	afrit_pain14	=[	75,	afrit_fly1	] {AfritCheckDodge();};

void()	afrit_wake1	=[	54,	afrit_wake2	] {};
void()	afrit_wake2	=[	55,	afrit_wake3	] {};
void()	afrit_wake3	=[	56,	afrit_wake4	] {};
void()	afrit_wake4	=[	57,	afrit_wake5	] {};
void()	afrit_wake5	=[	58,	afrit_wake6	] {};
void()	afrit_wake6	=[	59,	afrit_wake7	] {self.drawflags(+)MLS_FULLBRIGHT;};
void()	afrit_wake7	=[	60,	afrit_wake8	] {AfritEffects();};
void()	afrit_wake8	=[	61,	afrit_wake9	] {};
void()	afrit_wake9	=[	62,	afrit_wake10	] {};
void()	afrit_wake10	=[	63,	afrit_wake11	] {};
void()	afrit_wake11	=[	64,	afrit_wake12	] {AfritEffects();};
void()	afrit_wake12	=[	65,	afrit_wake13	] {};
void()	afrit_wake13	=[	66,	afrit_wake14	] {};
void()	afrit_wake14	=[	67,	afrit_wake15	] {AfritEffects();};
void()	afrit_wake15	=[	68,	afrit_wake16	] {};
void()	afrit_wake16	=[	69,	afrit_wake17	] {};
void()	afrit_wake17	=[	70,	afrit_wake18	] {AfritEffects();};
void()	afrit_wake18	=[	71,	afrit_wake19	] {};
void()	afrit_wake19	=[	72,	afrit_wake20	] {};
void()	afrit_wake20	=[	73,	afrit_wake21	] {};
void()	afrit_wake21	=[	74,	afrit_wake22	] {AfritEffects();};
void()	afrit_wake22	=[	75,	afrit_fly1	] {};


void(entity attacker, float damage)	afrit_pain =
{
	//local float r;

	if (self.pain_finished > time)
		return;
	if (random() > 0.5)
		sound (self, CHAN_VOICE, "afrit/pain.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "afrit/pain2.wav", 1, ATTN_NORM);
	ThrowGib ("models/blood.mdl", self.health);
	afrit_pain1 ();
	self.pain_finished = time + 1;
	self.counter = 0;	//can dodge immediately
};

//===========================================================================

void()	afrit_die1	=[	0,	afrit_die2	] {self.drawflags(-)MLS_FULLBRIGHT;};
void()	afrit_die2	=[	1,	afrit_die3	] {AfritEffects();CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);};
void()	afrit_die3	=[	2,	afrit_die4	] {particle4(self.origin + '0 0 18',random(5,10),254, PARTICLETYPE_FIRE,10);};
void()	afrit_die4	=[	3,	afrit_die5	] {};
void()	afrit_die5	=[	4,	afrit_die6	] {AfritEffects();CreateWhiteSmoke(self.origin + '0 0 16','0 0 8',HX_FRAME_TIME * 2);};
void()	afrit_die6	=[	5,	afrit_die7	] {};
void()	afrit_die7	=[	6,	afrit_die8	] {};
void()	afrit_die8	=[	7,	afrit_die9	] {};
void()	afrit_die9	=[	8,	afrit_die10] {};
void()	afrit_die10=[	9,	afrit_die11] {};
void()	afrit_die11=[	10,	afrit_die12] {};
void()	afrit_die12=[	11,	afrit_die13] {};
void()	afrit_die13=[	12,	afrit_die14] {};
void()	afrit_die14=[	13,	afrit_die14] {MakeSolidCorpse();};

void AfritCheckDodge ()
{
	if (self.enemy==world || self.counter>time || random()<0.05)
		return;
	
	entity enemy_proj;
	float dodge, direction;
	dodge=FALSE;
	enemy_proj = look_projectiles();
	
	if (IsEnemyOwned(enemy_proj))	//IsEnemyOwned is in ai.hc
		dodge=TRUE;
	else if (range(self.enemy)==RANGE_MELEE && self.enemy.last_attack>time-1)
		dodge=TRUE;
		
	if (!dodge)
		return;
	
	self.counter = time+1.5;	//won't dodge immediately after already dodging
	self.weaponframe_cnt = 0.5;		//counter for speed acceleration
	
	if (enemy_proj)
	{
		direction = check_heading_left_or_right(enemy_proj);	//1=left, -1=right, 0 for neither
		if (direction<0)
			self.lefty=1;		//dprint("Afrit sees projectile to its right\n");
		else if (direction>0)
			self.lefty=(-1);	//dprint("Afrit sees projectile to its left\n");
		else if (random()<0.5)	//strafe randomly if projectile is heading straight at it
			self.lefty=1;
		else
			self.lefty=(-1);
	}
	else if (random()<0.5)
		self.lefty=1;		//afrit_dodge1();
	else
		self.lefty=(-1);	//afrit_dodgel1();
	
	afrit_dodge1();
}

void() afrit_gibs =
{
	ThrowGib ("models/afritwing.mdl", self.health);
	ThrowGib ("models/afritwing.mdl", self.health);
}

void() afrit_die =
{
	local float r;
//gib check
	if (self.health < -25)
	{
		//sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NORM);
		ThrowGib ("models/blood.mdl", self.health);
		//ThrowGib ("models/flesh2.mdl", self.health);
		//ThrowGib (self.headmodel, self.health);
		ThrowGib ("models/blood.mdl", self.health);
		chunk_death();
		return;
	}

// regular death
	//afrit_fx();
	r = random();
	if (r > 0.5)
		sound (self, CHAN_VOICE, "afrit/death2.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "afrit/death.wav", 1, ATTN_NORM);
	afrit_die1 ();
};

/*QUAKED monster_afrit (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_afrit =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	if (!self.flags2&FL_SUMMONED && !self.flags2&FL2_RESPAWN)
		precache_afrit();
		
	if (self.flags2&FL_SUMMONED || self.flags2&FL2_RESPAWN)
		self.spawnflags(-)AFRIT_COCOON;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "models/afrit.mdl");
	setsize (self, '-16 -16 0', '16 16 36');
	
	if(!self.health)
		self.health = 75;
	self.max_health = self.health;
	
	self.thingtype=THINGTYPE_FLESH;
	
	self.flags (+) FL_MONSTER;
	self.flags (+) FL_FLY;
	self.flags2 (+) FL_ALIVE;
	self.counter = 0;	//counter for dodging
	self.sightsound = "afrit/sight.wav";
	self.yaw_speed = 14;
	
	self.monsterclass = CLASS_GRUNT;
	//self.hull=HULL_PLAYER;
	
	if(!self.experience_value)
		self.experience_value = 40;
	self.init_exp_val = self.experience_value;
	if(!self.mass)
		self.mass = 6;
	
	self.headmodel = "models/h_imp.mdl";
	
	self.th_walk = afrit_glide1;
	self.th_run = afrit_run;	//afrit_fly1;
	self.th_melee = afrit_atk1;
	self.th_missile = afrit_atk1;
	self.th_pain = afrit_pain;
	self.th_die = afrit_die;
	self.th_init = monster_afrit;
	self.th_raise = afrit_raise;
	
	if (self.spawnflags&AFRIT_COCOON) {
		if (self.spawnflags&AFRIT_DORMANT) {
			self.th_stand = afrit_dormant;
			self.th_pain = SUB_Null;
		}
		else
			self.th_stand = afrit_sit1;
	}
	else
		self.th_stand = afrit_hover1;
	
	flymonster_start ();
};

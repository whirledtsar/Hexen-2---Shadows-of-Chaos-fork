void() check_stand;

vector undying_mins = '-16 -16 -6';
vector undying_maxs = '16 16 56';

void UnsetFromFloor()
{	//called when they rise from fake death or real death (via resurrection). otherwise they get stuck in ground & cant move
	setorigin (self, self.origin + '0 0 2');
	self.movetype = MOVETYPE_TOSS;
	self.flags (-) FL_ONGROUND;
	self.velocity = '0 0 -100';
}

void undying_raise()
{
float state;
	state = RewindFrame(130,90);
	
	self.think = self.th_raise;
	
	if (state==AF_BEGINNING) {
		sound (self, CHAN_VOICE, "undying/udeath.wav", 1, ATTN_NORM);
	}
	if (state==AF_END) {
		self.th_init();
		monster_raisedebuff();
		UnsetFromFloor();
		if (self.enemy!=world)
			self.think=self.th_run;
		else
			self.think=self.th_stand;
	}
	
	thinktime self : HX_FRAME_TIME;
}

float undying_headless ()
{
	if (self.model == "models/ZombiePal_nohd.mdl")
		return TRUE;
		
	return FALSE;
}

void undying_standup(void) [++ 131 .. 182]
{
	thinktime self : HX_FRAME_TIME;
	
	if (self.frame == 132)
	{
		if (random(100) < 80 && !undying_headless())
			sound (self, CHAN_VOICE, "undying/usight.wav", 1, ATTN_NORM);
	}
		
	if (self.frame == 140)
	{
		local entity amstuck, stuckent;
		
		amstuck = findradius(self.origin, 60);
		
		while (amstuck)
		{
			if (amstuck.health)
			{
				stuckent = amstuck;
			}
			amstuck = amstuck.chain;
		}
		
		if (stuckent)
		{
			if (stuckent.think == CorpseThink)
				T_Damage(stuckent,self,self,50);
			else
			{
				check_stand();
				return;
			}
		}
	}
	
	if (self.frame == 141)
	{
		setsize (self, undying_mins, undying_maxs);
		self.solid = SOLID_SLIDEBOX;
		self.takedamage = DAMAGE_YES;
		self.th_pain = self.th_save;
		UnsetFromFloor();
	}
	
	if (self.frame >= 181)
	{
		if (EnemyIsValid(self.enemy))
			self.think = self.th_run;
		else
			self.think = self.th_stand;
	}
}

void() check_stand
{
	thinktime self : 2;
	self.frame = 131;	//rise1
	self.think = undying_standup;
}

void undying_debug(void) [++ 0 .. 182]
{
	thinktime self : HX_FRAME_TIME;
	
	centerprint(find(world, classname, "player"), ftos(self.frame));
	
	if (self.frame >= 181)
		self.think = self.th_stand;
}

void undying_painfall(void) [++ 90 .. 130]
{
	if (self.frame == 130)
		thinktime self : random(3.75,4.5-(skill*0.5));
	else
		thinktime self : HX_FRAME_TIME;
	
	if (self.frame<=91) {
		self.counter = TRUE;	//dont get back up again
		self.movetype = MOVETYPE_STEP;	//dont get pushed around
		self.takedamage = DAMAGE_NO;
		self.th_save = self.th_pain;
		self.th_pain = SUB_Null;
	}
	
	if (self.frame == 92)
	{
		if (random(100) < 80 && !undying_headless())
		{
			bloodspew_create (2, 25, self.view_ofs);
			ThrowGib(self.headmodel, self.health);
			self.headmodel = "";
			setmodel(self, "models/ZombiePal_nohd.mdl");
			setsize (self, '-23 -13 -6', '23 13 6');
			sound(self,CHAN_VOICE,"undying/udecap.wav",1,ATTN_NORM);
		}
		else
			sound(self,CHAN_VOICE,"undying/udeath.wav",1,ATTN_NORM);
	}
	
	if (self.frame == 121)	//death33
	{
		self.solid = SOLID_NOT;
		setsize (self, '-23 -13 -6', '23 13 6');
		setorigin (self, self.origin+'0 0 2');
	}
	else if (self.frame == 119)	//death31
		setsize (self, '-16 -16 -6', '16 16 25');
	else if (self.frame == 104)	//death16
		setsize (self, '-16 -16 -6', '16 16 35');
	else if (self.frame == 100)	//death12
		setsize (self, '-16 -16 -6', '16 16 45');
		
	if (self.frame >= 130)
		self.think = undying_standup;
}

void undying_pain(void) [++ 90 .. 99]
{
	if (self.health < 40 && !self.counter)
		undying_painfall();
	else if (self.pain_finished>time)
		self.th_run();
	
	ThrowGib ("models/blood.mdl", self.health);
	if (random() < 0.3)
		return;
	
	ai_pain(2);
	self.pain_finished=time+1;
	
	if (self.frame == 91 && !undying_headless())
		sound(self,CHAN_VOICE,"undying/upain.wav",1,ATTN_NORM);
	
	if(self.frame >= 99)
		self.think = self.th_run;
	
	thinktime self : HX_FRAME_TIME;
}

void undying_attack(void) [++ 65 .. 88]
{
	thinktime self : HX_FRAME_TIME;	// Make him move a little slower so his run will look faster
	
	ai_charge(1); 
	
	/*if (self.target)	ws: what the fuck is this?
		self.target = "";*/
	
	if (self.frame==65)		//reset sword hit sound check
		self.check_ok=TRUE;
	else if (self.frame == 74)
	{
		sound(self,CHAN_WEAPON,"undying/uattack.wav",1,ATTN_NORM);
		ai_charge_side();
	}
	
	if (self.frame >= 73 && self.frame <= 80)	//(self.frame >= 77 && self.frame <= 80)
		ai_charge(1); 
	if (self.frame >= 74 && self.frame <= 76)	//(self.frame >= 77 && self.frame <= 79)
	{
		ai_melee();
		if (trace_ent.takedamage && vlen(self.enemy.origin-self.origin)<self.t_length && self.check_ok)
		{	//ai_melee should make the vlen check here unnecessary, but it is necessary
			sound(self,CHAN_ITEM,"undying/uhit.wav",1,ATTN_NORM);
			self.check_ok = FALSE;	//only play hit sound once per animation
			trace_ent = world;
		}
	}
		
	if(self.frame >= 88)
		self.think = self.th_run;
}

void undying_leap(void) [++ 65 .. 88]
{
	thinktime self : HX_FRAME_TIME;	// Make him move a little slower so his run will look faster
	
	ai_charge(1); 
		
	//if (self.frame == 67)
	//{
		self.velocity += '0 0 220' + v_forward*130;
	//}
	
	if (self.frame >= 76 && self.frame <= 80)
	{
		ai_charge(1);
		ai_melee();
	}
		
	if (self.frame == 74)// && self.frame <=75)
		ai_charge_side();
		
	if(cycle_wrapped)
		self.think = self.th_run;
}

/*-----------------------------------------
	undying_run - run towards the enemy
  -----------------------------------------*/

void()	undying_run1	=[	50,		undying_run2	] {
	ai_run(self.speed*2);
	sound (self, CHAN_BODY, "mummy/crawl.wav", 1, ATTN_NORM);
};
void()	undying_run2	=[	51,		undying_run3	] {ai_run(self.speed*2);};
void()	undying_run3	=[	52,		undying_run4	] {ai_run(self.speed*2);};
void()	undying_run4	=[	53,		undying_run5	] {ai_run(self.speed*2);};
void()	undying_run5	=[	54,		undying_run6	] {ai_run(self.speed*2);};
void()	undying_run6	=[	55,		undying_run7	] {ai_run(self.speed*2);};
void()	undying_run7	=[	56,		undying_run8	] {ai_run(self.speed*2);};
void()	undying_run8	=[	57,		undying_run9	] {ai_run(self.speed*2);};
void()	undying_run9	=[	58,		undying_run10	] {ai_run(self.speed*2);};
void()	undying_run10	=[	59,		undying_run11	] {ai_run(self.speed*2);};
void()	undying_run11	=[	60,		undying_run12	] {ai_run(self.speed*2);};
void()	undying_run12	=[	61,		undying_run13	] {ai_run(self.speed*2);};
void()	undying_run13	=[	62,		undying_run14	] {ai_run(self.speed*2);};
void()	undying_run14	=[	63,		undying_run1	] {ai_run(self.speed*2);};

void() undying_gibs =
{
	ThrowGib ("models/ZombiePal_arm.mdl", self.health);
	ThrowGib ("models/ZombiePal_leg.mdl", self.health);
	//ThrowGib ("models/ZombiePal_hd.mdl", self.health);
	remove(self);
}

void undying_dying(void) [++ 90 .. 130]
{
	thinktime self : HX_FRAME_TIME;
	
	setsize (self, '-23 -13 -6', '23 13 6');
	self.th_pain = SUB_Null;
	
	if (self.frame == 91)
	{
		starteffect(CE_GHOST, self.origin,'0 0 10', 0.1);
		if (random(100) < 80 && !undying_headless())
		{
			bloodspew_create (2, 25, self.view_ofs);
			ThrowGib(self.headmodel, self.health);
			self.headmodel = "";
			setmodel(self, "models/ZombiePal_nohd.mdl");
			setsize (self, '-23 -13 -6', '23 13 6');
			sound(self,CHAN_VOICE,"undying/udecap.wav",1,ATTN_NORM);
		}
		else
			sound(self,CHAN_VOICE,"undying/udeath.wav",1,ATTN_NORM);
	}
	
	if (cycle_wrapped)
	{
		self.frame = 130;
		MakeSolidCorpse();
	}
	
	if (self.health < -25)
		chunk_death();
}

/*-----------------------------------------
	undying_walk - walking his beat
  -----------------------------------------*/
void undying_walk(void) [++ 22 .. 50]
{
	thinktime self : HX_FRAME_TIME + .01;	// Make him move a little slower so his run will look faster
	
	if (self.frame==22)
		sound (self, CHAN_BODY, "mummy/crawl.wav", 1, ATTN_NORM);
	
	if (self.frame >= 22 && self.frame <= 31)
		ai_walk(self.speed*1.4);
	else
		ai_walk(self.speed);
	
	if(cycle_wrapped)
		self.think = self.th_walk;
}

/*-----------------------------------------
	undying_stand - standing and waiting
  -----------------------------------------*/
void undying_stand(void) [++ 0 .. 21]
{
	ai_stand();
	
	if(cycle_wrapped)
		self.think = self.th_stand;
}

/*QUAKED monster_undying (1 0.3 0) (-16 -16 -6) (16 16 56) AMBUSH
Zombified Paladin monster
-------------------------FIELDS-------------------------
Health : 85
Experience Pts: 50
--------------------------------------------------------
*/
void monster_undying ()
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	if (!self.flags2&FL_SUMMONED&&!self.flags2&FL2_RESPAWN)
		precache_undying();

	if(!self.experience_value)
		self.experience_value = 40;
	self.init_exp_val = self.experience_value;
	if(!self.health)
		self.health = 85;
	self.max_health = self.health;

	self.th_stand = undying_stand;
	self.th_walk = undying_walk;
	self.th_run = undying_run1;
	self.th_melee = undying_attack;
	//self.th_missile = undying_leap;
	self.th_pain = undying_pain;
	self.th_die = undying_dying;
	self.th_init = monster_undying;
	self.th_raise = undying_raise;
	
	self.decap = 0;
	self.headmodel = "models/ZombiePal_hd.mdl";
	self.sightsound = "undying/usight.wav";
	
	if(!self.speed)
		self.speed=1.3;
	
	if (!undying_headless())
		setmodel(self, "models/ZombiePal.mdl");
	
	self.netname="undying";
	self.flags (+) FL_MONSTER;
	self.flags2 (+) FL_ALIVE;
	self.mass = 11;		//ws: increased. 10 seems to be the magic number for when they take impact damage from player running into them
	self.yaw_speed = 4;
	self.thingtype=THINGTYPE_FLESH;
	self.t_length = 80;		//custom melee range for ai_melee. default is 60
	//self.view_ofs = '0 0 40';
	
	//self.hull=HULL_PLAYER;
	self.hull = 2;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_TOSS;
	setsize (self, undying_mins, undying_maxs);
	
	UnsetFromFloor();
	walkmonster_start();
}

void() check_stand;

vector undying_mins = '-16 -16 -6';
vector undying_maxs = '16 16 56';

void undying_standup(void) [++ 131 .. 182]
{
	thinktime self : HX_FRAME_TIME;
	
	if (self.frame == 132)
	{
		setorigin(self, self.origin + '0 0 1');
		if (random(100) < 80 && self.model != "models/ZombiePal_nohd.mdl")
			sound (self, CHAN_WEAPON, "undying/usight.wav", 1, ATTN_NORM);
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
		//centerprint(find(world, classname, "player"), "not stuck");
	}
	
	if (self.frame == 141)
	{
		setorigin(self, self.origin + '0 0 3');
		//self.flags(-)FL_ONGROUND;
		setsize (self, undying_mins, undying_maxs);
		self.solid = SOLID_SLIDEBOX;
	}
	
	if (self.frame >= 181)
		self.think = self.th_run;
}

void() check_stand
{
	thinktime self : 2;
	self.frame = 131;
	setorigin(self, self.origin + '0 0 1');
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
		thinktime self : 4;
	else
		thinktime self : HX_FRAME_TIME;
	
	
		
	if (self.frame == 92)
	{

		if (random(100) < 80)
		{
			ThrowGib(self.headmodel, self.health);
			self.headmodel = "";
			setmodel(self, "models/ZombiePal_nohd.mdl");
			sound(self,CHAN_VOICE,"undying/udecap.wav",1,ATTN_NORM);
			setsize (self, '-23 -13 -6', '23 13 6');
		}
		else
			sound(self,CHAN_VOICE,"undying/udeath.wav",1,ATTN_NORM);
			
	}
	
	if (self.frame == 110)
	{
		self.solid = SOLID_NOT;
		setsize (self, '-23 -13 -6', '23 13 6');
	}
	
	//if (self.frame >= 131)
	//	MakeSolidCorpse();
		//self.think = CorpseThink;
	self.cnt++;
		
	if (self.frame >= 130)
		self.think = undying_standup;
	
}

void undying_pain(void) [++ 90 .. 99]
{
	if (self.health < 40 && !self.cnt)
		undying_painfall();
	thinktime self : HX_FRAME_TIME;
	
	if (self.frame == 91)
	{
		ThrowGib ("models/blood.mdl", self.health);
	
		if (random(100) < 30)
			return;
	}
	
	ai_pain(2); 
	
	if (self.frame == 91 && self.model != "models/ZombiePal_nohd.mdl")
		sound(self,CHAN_VOICE,"undying/upain.wav",1,ATTN_NORM);
	
	if(self.frame >= 99)
		self.think = self.th_run;
	

}


void undying_attack(void) [++ 65 .. 88]
{
	thinktime self : HX_FRAME_TIME;	// Make him move a little slower so his run will look faster
	
	ai_charge(1); 
	
	if (self.target)
		self.target = "";
	
	if (self.frame >= 76 && self.frame <= 80)
		ai_charge(1); 
	if (self.frame >= 77 && self.frame <= 79)	
		ai_melee();

	if (self.frame == 74)// && self.frame <=75)
	{
		sound(self,CHAN_WEAPON,"undying/uattack.wav",1,ATTN_NORM);
		ai_charge_side();
	}
	
		
	if(self.frame >= 88)
		self.think = self.th_run;

}

void undying_leap(void) [++ 65 .. 88]
{
	thinktime self : HX_FRAME_TIME;	// Make him move a little slower so his run will look faster
	
	ai_charge(1); 
	
	if (self.target)
		self.target = "";
		
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

void()	undying_run1	=[	50,		undying_run2	] {ai_run(self.speed*2); 
	if (self.solid != SOLID_SLIDEBOX)
	{
		setorigin(self, self.origin + '0 0 3');
		setsize (self, undying_mins, undying_maxs);
		self.solid = SOLID_SLIDEBOX;
	}
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
	ThrowGib ("models/ZombiePal_hd.mdl", self.health);
	remove(self);
}


void undying_dying(void) [++ 90 .. 130]
{
	thinktime self : HX_FRAME_TIME;
	
	setsize (self, '-23 -13 -6', '23 13 6');
	
	if (self.frame == 91)
	{
		starteffect(CE_GHOST, self.origin,'0 0 10', 0.1);
		if (random(100) < 80)
		{
			ThrowGib(self.headmodel, self.health);
			self.headmodel = "";
			setmodel(self, "models/ZombiePal_nohd.mdl");
			sound(self,CHAN_VOICE,"undying/udecap.wav",1,ATTN_NORM);
			setsize (self, '-23 -13 -6', '23 13 6');
		}
		else
			sound(self,CHAN_VOICE,"undying/udeath.wav",1,ATTN_NORM);
	}
	
	if (cycle_wrapped)
	{
		self.frame = 130;
		MakeSolidCorpse();
	}
		//self.think = CorpseThink;
	
	if (self.health < -25)
		chunk_death();
		
	
		
}

/*-----------------------------------------
	undying_walk - walking his beat
  -----------------------------------------*/
void undying_walk(void) [++ 22 .. 50]
{
	thinktime self : HX_FRAME_TIME + .01;	// Make him move a little slower so his run will look faster
	
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

/*QUAKED monster_archer_lord (1 0.3 0) (-16 -16 0) (16 16 50) AMBUSH STUCK JUMP x DORMANT NO_DROP FROZEN
Zombified Paladin monster
-------------------------FIELDS-------------------------
Health : 325
Experience Pts: 200
Favorite Cities: Madrid & Las Vegas
Favorite Flower: Orchid
What people don't know about me: I cry at sad movies
What people say when they see me: Don't shoot!! Don't shoot!!
--------------------------------------------------------
*/
void monster_undying ()
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	/*if(!self.th_init)
	{
		self.th_init=monster_undying;
		self.init_org=self.origin;
	}*/
	if (!self.flags2 & FL_SUMMONED&&!self.flags2&FL2_RESPAWN)
	{
		precache_undying();
	}

	if(!self.experience_value)
		self.experience_value = 100;
	if(!self.health)
		self.health = 85;

	//CreateEntityNew(self,ENT_ARCHER,"models/archer.mdl",archer_die);

	self.th_stand = undying_stand;
	self.th_walk = undying_walk;
	self.th_run = undying_run1;
	self.th_melee = undying_attack;
	//self.th_missile = undying_leap;
	self.th_pain = undying_pain;
	self.th_die = undying_dying;
	self.decap = 0;
	self.headmodel = "models/ZombiePal_hd.mdl";
	//if(!self.spawnflags&ARCHER_STUCK)
	//	self.mintel = 7;
	
	if(!self.speed)
		self.speed=1.3;
		
	setmodel(self, "models/ZombiePal.mdl");

	self.monsterclass = CLASS_GRUNT;

	self.thingtype=THINGTYPE_FLESH;
	
	self.mass = 10;
	
	self.netname="undying";
	self.flags (+) FL_MONSTER;
	self.flags2 (+) FL_ALIVE;
	self.yaw_speed = 4;
	//self.view_ofs = '0 0 40';
	
	//self.hull=HULL_PLAYER;
	self.hull = 2;
	self.solid = SOLID_SLIDEBOX;
	setsize (self, undying_mins, undying_maxs);
	

	self.init_exp_val = self.experience_value;
	
	walkmonster_start();
}
void() monster_afrit;
void() monster_bishop;
void() monster_archer;
void() monster_archer_lord;
void() monster_death_knight;
void() monster_disciple;
void() monster_fallen_angel;
void() monster_fallen_angel_lord;
void() monster_imp_fire;
void() monster_imp_ice;
void() monster_mummy;
void() monster_mummy_lord;
void() monster_scorpion_black;
void() monster_scorpion_yellow;
void() monster_spider_red_large;
void() monster_spider_red_small;
void() monster_spider_yellow_large;
void() monster_spider_yellow_small;
void() monster_skull_wizard;
void() monster_skull_wizard_lord;
void() monster_werejaguar;
void() monster_werepanther;
void() monster_undying;
void(vector org, entity death_owner) spawn_tdeath;

void() precache_afrit;
void() precache_bishop;
void() precache_disciple;
void() precache_fangel;
void() precache_knight;
void() precache_mummy;
void() precache_scorpion;
void() precache_werejaguar;
void() precache_undying;

void spawnspot_activate (void)
{
	self.deadflag=FALSE;//it's that simple!
}

float monster_spawn_precache (void)
{
float have_monsters;
	if (self.spawnflags & AFRIT)
	{
		precache_afrit();
		have_monsters=TRUE;
	}
	if (self.spawnflags & ARCHER)
	{
		precache_archer();
		have_monsters=TRUE;
	}
/*	if (self.spawnflags & DISCIPLE)
	{
		if (self.spawnflags & SPAWN_SUPER)
			precache_bishop();
		else
			precache_disciple();
		have_monsters=TRUE;
	}
*/
	if (self.spawnflags & FANGEL)
	{
		precache_fangel();
		have_monsters=TRUE;
	}
	if (self.spawnflags & IMP)
	{
		precache_model ("models/imp.mdl");
		precache_model ("models/h_imp.mdl");//empty for now
		precache_sound ("imp/up.wav");
		precache_sound ("imp/die.wav");
		precache_sound ("imp/swoop.wav");
		precache_sound ("imp/fly.wav");
		precache_model ("models/shardice.mdl");
		precache_model ("models/fireball.mdl");
		precache_sound ("imp/swoophit.wav");
		precache_sound ("imp/fireball.wav");
		precache_sound ("imp/shard.wav");
		precache_sound("hydra/turn-s.wav");
		have_monsters=TRUE;
	}
	if (self.spawnflags & KNIGHT)
	{
		precache_knight();
		have_monsters=TRUE;
	}
/*	if (self.spawnflags & MUMMY)
	{
		precache_mummy();
		have_monsters=TRUE;
	}
*/
	if (self.spawnflags & SCORPION)
	{
		precache_scorpion();
		have_monsters=TRUE;
	}
	if (self.spawnflags & WIZARD)
	{
		precache_model("models/skullwiz.mdl");
		precache_model("models/skulbook.mdl");
		precache_model("models/skulhead.mdl");
		precache_model("models/skulshot.mdl");
		precache_sound("skullwiz/death.wav");
		precache_sound("skullwiz/blinkspk.wav");
		precache_sound("skullwiz/growl.wav");
		precache_sound("skullwiz/scream.wav");
		precache_sound("skullwiz/pain.wav");
		precache_sound("skullwiz/gate.wav");
		precache_sound("skullwiz/blinkin.wav");
		precache_sound("skullwiz/blinkout.wav");
		precache_sound("skullwiz/push.wav");
		precache_sound("skullwiz/firemisl.wav");
		precache_spider();
		have_monsters=TRUE;
	}
	if (self.spawnflags & WEREBEAST)
	{
		precache_werejaguar();
		have_monsters=TRUE;
	}
	if (self.spawnflags & UNDYING)
	{
		precache_undying();
		have_monsters=TRUE;
	}
	if(self.spawnflags & SPIDER)
	{
		precache_spider();
		have_monsters=TRUE;
	}
	return have_monsters;
}

float check_monsterspawn_ok (void)
{
vector org;

	if(self.spawnername)
	{
	entity findspot;
	float foundspot,founddead;

//FIXME: have it chain them at spawning and do a self.controller=self.controller.chain;
		findspot=find(self.controller,netname,self.netname);
		while(!foundspot)
		{
			//Warning!  If you forget to put spawnspots and you give the spawner
			//a spawnername string, it will go into an infinite loop and the Universe
			//will cease to exist!
			if(findspot.spawnername==self.spawnername)
			{
			if(findspot.aflag==self.level+1)
				if(findspot.deadflag)
				{
					founddead=TRUE;
					self.level=findspot.aflag;
				}
				else
					foundspot=TRUE;
//			Oops!  doesn't automatically loop
			if(findspot==self.controller)
//			if(findspot==world)
				if(self.level==0)
					if(founddead)//found some, but they're not active yet
						return FALSE;
					else
					{
						remove(self);
						return FALSE;
					}
				else
					self.level=0;
			}
			if(!foundspot)
				findspot=find(findspot,netname,self.netname);
		}
		self.level=findspot.aflag;
		self.controller=findspot;
		org=findspot.origin;
	}
	else
		org=self.origin;

	if(self.controller.spawnflags&ONDEATH&&(self.controller.goalentity.flags2&FL_ALIVE))
		return FALSE;

	tracearea(org,org,self.mins,self.maxs,FALSE,self);
	newmis = spawn();
	if(trace_fraction<1)
		if(trace_ent.flags2&FL_ALIVE)
		{
			remove(newmis);
			return FALSE;
		}
		else
			spawn_tdeath(trace_ent.origin,newmis);

	newmis.angles = self.controller.angles;		//ws: changed from self to controller so monsters inherit spot's angles
	newmis.flags2+=FL_SUMMONED;
//	newmis.spawnflags=NO_DROP;

	float foundthink,rnd;

	while(!foundthink)
	{
		//rnd=rint(random(1,5));
		rnd=rint(random(1,24));	//ws: increased to 24 to cover every possible spawnflag, therefore allowing more monster flags
		rnd=byte_me(rnd);
		if(self.controller.spawnflags&rnd)
		{
			if (rnd==ONDEATH || rnd==QUIET || rnd==TRIGGERONLY || rnd==SPAWN_SUPER)	//ws: we only want to find the monster spawnflags
				foundthink=FALSE;
			else
				foundthink=TRUE;
		}
	}

/*	if (rnd==DISCIPLE)
	{
		if (self.controller.spawnflags&SPAWN_SUPER)
		{
			newmis.classname = "monster_bishop";
			newmis.think = monster_bishop;
		}
		else
		{
			newmis.classname = "monster_disciple";
			newmis.think = monster_disciple;
		}
	}
	else if (rnd==MUMMY)
	{
		if (self.controller.spawnflags&SPAWN_SUPER)
		{
			newmis.classname = "monster_mummy_lord";
			newmis.think = monster_mummy_lord;
		}
		else
		{
			newmis.classname = "monster_mummy";
			newmis.think = monster_mummy;
		}
	}
	else */if (rnd==KNIGHT)
	{
		newmis.classname = "monster_death_knight";
		newmis.think = monster_death_knight;
	}
	else if (rnd==IMP)
	{
		/*if (self.controller.spawnflags&SPAWN_SUPER)
		{
			newmis.classname = "monster_imp_ice";
			newmis.think = monster_imp_ice;
		}
		else
		{
			newmis.classname = "monster_imp_fire";
			newmis.think = monster_imp_fire;
		}*/
		if(self.controller.spawnflags&SPAWN_SUPER || random()<0.5)	//need to maintain original random behavior used in PoP
		{
			newmis.classname = "monster_imp_ice";
			newmis.think = monster_imp_ice;
		}
		else
		{
			newmis.classname = "monster_imp_fire";
			newmis.think = monster_imp_fire;
		}
	}
	else if (rnd==ARCHER)
	{
		if (self.controller.spawnflags&SPAWN_SUPER)
		{
			newmis.classname = "monster_archer_lord";
			newmis.think = monster_archer_lord;
		}
		else
		{
			newmis.classname = "monster_archer";
			newmis.think = monster_archer;
		}
	}
	else if (rnd==WIZARD)
	{
		if (self.controller.spawnflags&SPAWN_SUPER)
		{
			newmis.classname = "monster_skull_wizard_lord";
			newmis.think = monster_skull_wizard_lord;
		}
		else
		{
			newmis.classname = "monster_skull_wizard";
			newmis.think = monster_skull_wizard;
		}
	}
	else if (rnd==SCORPION)
	{
		if (self.controller.spawnflags&SPAWN_SUPER)
		{
			newmis.classname = "monster_scorpion_black";
			newmis.think = monster_scorpion_black;
		}
		else
		{
			newmis.classname = "monster_scorpion_yellow";
			newmis.think = monster_scorpion_yellow;
		}
	}
	/*else if (rnd==BISHOP)
	{
		newmis.classname = "monster_bishop";
		newmis.think = monster_bishop;
	}*/
	else if (rnd==AFRIT)
	{
		newmis.classname = "monster_afrit";
		newmis.think = monster_afrit;
	}
	else if (rnd==UNDYING)
	{
		newmis.classname = "monster_undying";
		newmis.think = monster_undying;
	}
	else if (rnd==WEREBEAST)
	{
		if (self.controller.spawnflags&SPAWN_SUPER)
		{
			newmis.classname = "monster_werepanther";
			newmis.think = monster_werejaguar;
		}
		else
		{
			newmis.classname = "monster_werejaguar";
			newmis.think = monster_werejaguar;
		}
	}
	else if (rnd==FANGEL)
	{
		if (self.controller.spawnflags&SPAWN_SUPER)
		{
			newmis.classname = "monster_fallen_angel_lord";
			newmis.think = monster_fallen_angel_lord;
		}
		else
		{
			newmis.classname = "monster_fallen_angel";
			newmis.think = monster_fallen_angel;
		}
	}
	else//it must be a spider, baby!
	{
		rnd=rint(random(1,4));
		if(rnd==4)
		{
			newmis.classname = "monster_spider_yellow_large";
			newmis.think = monster_spider_yellow_large;
		}
		else if(rnd==3)
		{
			newmis.classname = "monster_spider_yellow_small";
			newmis.think = monster_spider_yellow_small;
		}
		else if(rnd==2)
		{
			newmis.classname = "monster_spider_red_large";
			newmis.think = monster_spider_red_large;
		}
		else
		{
			newmis.classname = "monster_spider_red_small";
			newmis.think = monster_spider_red_small;
		}
	}

	self.controller.goalentity=newmis;
	setorigin(newmis,org);
	if(!self.controller.spawnflags&QUIET)
		spawn_tfog(org);
	newmis.nextthink = time;
	return TRUE;
}

void monsterspawn_active (void)
{
	self.think=monsterspawn_active;
	if(check_monsterspawn_ok())
	{
		self.controller.frags+=1;
		if(self.controller!=self)
			self.frags+=1;
		if(self.controller!=self)
		{
			self.controller.deadflag=TRUE;
			self.controller.think=self.controller.use;
			self.controller.nextthink=time+self.controller.wait;
		}
		if(self.controller.frags>=self.controller.cnt)
			remove(self.controller);
		if(self.frags>=self.cnt)
			remove(self);
		if(self.spawnflags&TRIGGERONLY)
			self.nextthink=-1;
		else
			self.nextthink=time+self.wait;
	}
	else if(self.spawnflags&TRIGGERONLY)//Don't keep trying
		self.nextthink=-1;
	else
		self.nextthink=time+0.1;
}

/*QUAKED func_monsterspawner (1 .8 0) (-16 -16 0) (16 16 56) IMP ARCHER WIZARD SCORPION SPIDER ONDEATH QUIET TRIGGERONLY 
If something is blocking the spawnspot, this will telefrag it as long as it's not a living entity (flags2&FL_ALIVE)

You can set up as many spots as you want for it to spawn at and it will cycle
between these.  Make them classname func_monsterspawn_spot and
their spawnername has to match this entity's spawnername.
You can control the order in which they are used by setting thier
aflag (1, 2, 3, etc- there is NO ZERO, that's for you designers!)
You should give the spawner an aflag too if you want it's origin
included in the cycle of spawning, but if there are no spawn spots (just a spawner), no aflag is needed anywhere.

WARNING!!!  If you forget to put spawnspots and you give the spawner a spawnername, it will go into an infinite loop and the Universe will cease to exist!

If you only want monsters to spawn at the monster spawner origin, then don't worry about aflags or the spawnername, it will know... It's that cool.

The Monsters will be spawned at the origin of the spawner (and/or spawnspots), so if you want them not to stick in the ground, put this above the ground some- maybe 24?  Make sure there's enough room around it for the monsters.

ONDEATH = only spawn the new monster after the last has died, defaults to FALSE (doesn't wait)
TRIGGERONLY = Will only spawn a monster when it's been used by a trigger.  The default is continous spawning.
wait = time to wait after spawning a monster until the next monster is spawned, defaults to 0.5 seconds. If there are multiple spawn spots, this will be the time between cycles (default 0.5)
cnt = number of monsters, max to spawn, defaults to 17 (no reason, just like that number!)	If there are multiple spots, this should be the total off ALL the spots, including the spawner itself.
aflag = order in the spawning cycle
spawnername = spawnspots to look for- be sure to make spawnspots!
targetname = not needed unless you plan to activate this with a trigger

There will be a test on this on Thursday.  Interns are NOT exempt.
*/
void func_monsterspawner (void)
{
	if(!self.cnt)
		self.cnt=17;

	if(!self.wait)
		self.wait=0.5;

	self.netname="monsterspawn_spot";
	if(self.spawnername)
		self.controller=world;//misleading name, this is the last spawnspot
	else
		self.controller=self;

	self.level=0;//Spawn cycle counter
	//setmodel(self,self.model);
	setsize(self,'-16 -16 0','16 16 56');
	setorigin(self,self.origin);

	if(!monster_spawn_precache()&&!self.spawnername)
	{
//		dprint("You don't have any monsters assigned to me, and I have no spawnername!\n");
		remove(self);
	}

	if(self.targetname)
		self.use=monsterspawn_active;
	else
	{
		self.think=monsterspawn_active;
		self.nextthink=time+3;//wait while map starts
	}
}

/*QUAKED func_monsterspawn_spot (1 .3 0) (-16 -16 0) (16 16 56) IMP ARCHER WIZARD SCORPION SPIDER ONDEATH QUIET
All this does is mark where to spawn monsters for a spawn spot.

You can set any monster type for each spawnspot.

Just make the spawnername of this entity equal to the spawnername of the spawner and the spawner will cycle through all it's spawnspots in the world.

If you don't set the aflag, the spawn spot will NOT be used.

Note that if you set a trigger to activate this spawnspot, you can have it turn on and be included in the spawner's cycle, but you still always have to set the aflag.

aflag = order in the spawning cycle, you MUST set this, or it's useless.
cnt = number of monsters this spot will spawn, defaults to 17.
spawnername = this HAS to match the spawner's spawnername!
wait = how long the minimum interval should be between monster spawns for THIS spot.
targetname = used if you want this to wait to be activated by a seperate trigger before being included in the spawning cycle.
*/
void func_monsterspawn_spot (void)
{

	if(!self.aflag)
	{
//		dprint("Ooo!  You didn't include me in the spawn cycle!  FIXME!\n");
		remove(self);
	}
	if(!self.cnt)
		self.cnt=17;
	self.netname="monsterspawn_spot";

	if(!monster_spawn_precache())
	{
//		dprint("You didn't give me any monsters to spawn!!!\n");
		remove(self);
	}

	//setmodel(self,self.model);
	setsize(self,'-16 -16 0','16 16 56');
	setorigin(self,self.origin);
	if(self.targetname)
		self.deadflag=TRUE;
	else
		self.use=spawnspot_activate;
}

/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/portals/monsters.hc,v 1.2 2007-02-07 16:59:34 sezero Exp $
 */
/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */

// name =[framenum,	nexttime, nextthink] {code}
// expands to:
// name ()
// {
//		self.frame=framenum;
//		self.nextthink = time + nexttime;
//		self.think = nextthink
//		<code>
// };

void() impmonster_start;
void() init_hydra;
void() monster_dormant;
void() monster_spawn;

void monster_unfreeze ()
{
	if(random()<0.2)
		sound(self,CHAN_AUTO,"misc/drip.wav",1,ATTN_NORM);

	if(self.skin==GLOBAL_SKIN_ICE&&self.think!=monster_unfreeze)
	{
		sound(self,CHAN_BODY,"crusader/frozen.wav",1,ATTN_NORM);
		self.think=monster_unfreeze;
		thinktime self : 0.1;
	}
	else if(self.colormap<149)
	{
		if(self.skin==GLOBAL_SKIN_ICE)
		{
			self.skin=self.oldskin;
			self.colormap=144;
			self.abslight=0.5;
		}
		else
		{
			self.colormap+=1;
			self.abslight+=0.05;
		}
		self.think=monster_unfreeze;
		thinktime self : 0.1;
	}
	else
	{
		self.abslight=0;
		self.colormap=0;
		self.frozen=0;
		self.drawflags(-)DRF_TRANSLUCENT|MLS_ABSLIGHT;
		self.thingtype=THINGTYPE_FLESH;//old thingtype?
		self.touch=self.oldtouch;//oldtouch?
		self.movetype=self.oldmovetype;
		thinktime self : 0.1;
		self.think = FoundTarget;
	}
}

void monster_start_frozen ()
{
	self.frozen=50;
	if(self.skin<10)
		self.oldskin=self.skin;
	else
		self.skin=0;
	self.colormap=0;
	self.abslight=0.5;
	self.skin=GLOBAL_SKIN_ICE;
	self.thingtype=THINGTYPE_ICE;
	self.oldmovetype=self.movetype;
	self.movetype=MOVETYPE_TOSS;
//    loser.flags(-)FL_FLY;
//    loser.flags(-)FL_SWIM;
	if(self.flags&FL_ONGROUND)
		self.last_onground=time;
    self.flags(-)FL_ONGROUND;
	self.oldtouch=self.touch;
	self.touch=obj_push;
	self.drawflags(+)DRF_TRANSLUCENT|MLS_ABSLIGHT;
	self.think=SUB_Null;
	self.nextthink=-1;
}

/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/
void() monster_use =
{
	if (self.enemy)
		return;
	if (self.health <= 0)
		return;
	if (!self.flags2&FL_ALIVE)
		return;
	if (activator.items & IT_INVISIBILITY)
		return;
	if (activator.flags & FL_NOTARGET)
		return;
	if (activator.classname != "player")
		return;
	
	if(self.frozen&&!self.monster_awake)
	{
		self.enemy=activator;
		monster_unfreeze();
		return;
	}

	if(self.classname=="monster_mezzoman"&&!visible(activator)&&!self.monster_awake)
	{
		self.enemy=activator;
		mezzo_choose_roll(activator);
		return;
	}
// delay reaction so if the monster is teleported, its sound is still
// heard
	else
	{
		self.enemy = activator;
		thinktime self : 0.1;
		self.think = FoundTarget;
	}
};

/*
================
monster_death_use

When a mosnter dies, it fires all of its targets with the current
enemy as activator.
================
*/
void monster_respawn_go ()
{
	self.frags=FALSE;
	sound (self, CHAN_AUTO, "weapons/expsmall.wav", 1, ATTN_NORM);
	starteffect(CE_FLOOR_EXPLOSION , self.origin+'0 0 64');
	self.think=self.th_init;
	thinktime self : 0.1;
}

void monster_respawn_init ()
{
	self.frags=TRUE;
	spawn_tdeath(self.origin,self);
	self.think=monster_respawn_go;
	thinktime self : 0.5;
}

void(float force_respawn) monster_death_use =
{
// fall to ground
	if((!deathmatch&&skill>=4)||force_respawn)
	{
		if(self.th_init!=SUB_Null||force_respawn)
		{
			if((self.monsterclass<CLASS_BOSS&&!self.flags2&FL_SUMMONED)||force_respawn)
			{
				entity newmonster;
				newmonster=spawn();
				if(self.classname=="monster_mezzoman")
				{
					if(self.model=="models/snowleopard.mdl")
					{
						if(self.strength>=3)
							newmonster.classname="monster_weretiger";
						else
							newmonster.classname="monster_weresnowleopard";
					}
					else if(self.strength)
						newmonster.classname="monster_werepanther";
					else
						newmonster.classname="monster_werejaguar";
				}
				else if(self.netname=="monster_archer_ice")
					newmonster.classname=self.netname;
				else
					newmonster.classname=self.classname;
				
				if(self.classname=="monster_pentacles")
					newmonster.target=self.target;
				else if(self.model=="models/sheep.mdl"&&world.target=="sheep")
				{
					newmonster.target=self.target;
					newmonster.targetname=self.targetname;
				}
				newmonster.spawnflags=self.spawnflags;
				setorigin(newmonster,self.init_org);
				newmonster.init_org=self.init_org;
				newmonster.th_init=self.th_init;
				newmonster.flags2(+)FL2_RESPAWN;
				if(self.skin>=100)
					newmonster.skin=self.oldskin;
				else
					newmonster.skin=self.skin;
				setsize(newmonster,self.mins,self.maxs);
				newmonster.think=monster_respawn_init;
				thinktime newmonster : 5+random(10);
			}
		}
	}
	self.flags(-)FL_FLY;
	self.flags(-)FL_SWIM;

	if (!self.target)
		return;

	activator = self.enemy;
	SUB_UseTargets ();
};


//============================================================================

void() walkmonster_start_go =
{
	sdprint("Summon monster start GO", FALSE);
	
	if(!self.touch)
		self.touch=obj_push;

	if (self.playercontrolled)
		self.spawnflags(+)NO_DROP;

	if(!self.spawnflags&NO_DROP)
	{
		self.origin_z = self.origin_z + 1;	// raise off floor a bit
		droptofloor();
		if (!walkmove(0,0, FALSE))
		{
			if(self.flags2&FL_SUMMONED)
			{
				sdprint("Summon monster removed", FALSE);
				remove(self);
				return; /* THOMAS: return  was missing here */
			}
			else
			{
				dprint ("walkmonster in wall at: ");
				dprint (vtos(self.origin));
				dprint ("\n");
			}
		}
		if(self.model=="model/spider.mdl"||self.model=="model/scorpion.mdl")
			pitch_roll_for_slope('0 0 0',self);
	}

	if(!self.ideal_yaw)
	{
//		dprint("no preset ideal yaw\n");
		self.ideal_yaw = self.angles * '0 1 0';
	}
	
	if (!self.yaw_speed)
		self.yaw_speed = 20;

	if(self.view_ofs=='0 0 0')
		self.view_ofs = '0 0 25';

	if(self.proj_ofs=='0 0 0')
		self.proj_ofs = '0 0 25';

	if(!self.use)
		self.use = monster_use;

	if(!self.flags&FL_MONSTER)
		self.flags(+)FL_MONSTER;
	
	if(self.flags&FL_MONSTER&&self.classname=="player_sheep")
		self.flags(-)FL_MONSTER;

	if (self.target)
	{
		sdprint("Summon monster start GO - Has a target", FALSE);					
		self.goalentity = self.pathentity = find(world, targetname, self.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		if (!self.pathentity)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		if (self.pathentity.classname == "path_corner")
			if(self.spawnflags&SF_FROZEN)
				monster_start_frozen();
			else
				self.th_walk ();
		else
		{
			if(self.goalentity.health>0&&self.goalentity.flags2&FL_ALIVE)
			{
				self.enemy=self.goalentity;
				self.th_run();
			}
			else
			{
				self.pausetime = 99999999;
				if(self.spawnflags&SF_FROZEN)
					monster_start_frozen();
				else
					self.th_stand ();
			}
		}
	}
	else
	{
		sdprint("Summon monster start GO - no target found. Standing", FALSE);
			self.pausetime = 99999999;
			if(self.spawnflags&SF_FROZEN)
				monster_start_frozen();
			else
				self.th_stand ();
	}

// spread think times so they don't all happen at same time
	self.nextthink+=random(0.5);
};

void walkmonster_start ()
{
// delay drop to floor to make sure all doors have been spawned
// spread think times so they don't all happen at same time
	if(self.puzzle_id)
		MonsterPrecachePuzzlePiece();
	
	self.init_org = self.origin;
	
	if (self.spawnflags&SPAWNIN) {
		monster_dormant();
		return;
	}
	
	self.takedamage=DAMAGE_YES;
	self.flags2(+)FL_ALIVE;

	if(self.scale<=0)
		self.scale=1;

	self.nextthink+=random(0.5);
	self.think = walkmonster_start_go;
	if (!self.playercontrolled)
		total_monsters = total_monsters + 1;
}




void() flymonster_start_go =
{
	self.takedamage = DAMAGE_YES;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;

	if(self.view_ofs=='0 0 0')
		self.view_ofs = '0 0 24';
	if(self.proj_ofs=='0 0 0')
		self.proj_ofs = '0 0 24';

	self.use = monster_use;

	self.flags(+)FL_FLY;
	self.flags(+)FL_MONSTER;

	if(!self.touch)
		self.touch=obj_push;

	if (!walkmove(0,0, FALSE))
	{
		dprint ("flymonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}

	if (self.target)
	{
		self.goalentity = self.pathentity = find(world, targetname, self.target);
		if (!self.pathentity)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror

		if (self.pathentity.classname == "path_corner")
			self.th_walk ();
		else
		{
			self.pausetime = 99999999;
			self.th_stand ();
		}
	}
	else
	{

		self.pausetime = 99999999;
		self.th_stand ();
	}
};

void() flymonster_start =
{
	self.init_org = self.origin;
	
	if (self.spawnflags&SPAWNIN) {
		monster_dormant();
		return;
	}
	
// spread think times so they don't all happen at same time
	self.takedamage=DAMAGE_YES;
	self.flags2(+)FL_ALIVE;
	self.nextthink+=random(0.5);
	self.think = flymonster_start_go;
	if (!self.playercontrolled)
		total_monsters = total_monsters + 1;
};
/*
void() swimmonster_start_go =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	if(!self.touch)
		self.touch=obj_push;

	self.takedamage = DAMAGE_YES;
	total_monsters = total_monsters + 1;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;

	if(self.view_ofs=='0 0 0');
		self.view_ofs = '0 0 10';
	if(self.proj_ofs=='0 0 0');
		self.proj_ofs = '0 0 10';

	self.use = monster_use;
	
	self.flags(+)FL_SWIM;
	self.flags(+)FL_MONSTER;

	if (self.target)
	{
		self.goalentity = self.pathentity = find(world, targetname, self.target);
		if (!self.pathentity)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		self.th_walk ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

// spread think times so they don't all happen at same time
	self.nextthink+=random(0.5);
};

void() swimmonster_start =
{
// spread think times so they don't all happen at same time
	self.takedamage=DAMAGE_YES;
	self.flags2(+)FL_ALIVE;
	self.nextthink+=random(0.5);
	self.think = swimmonster_start_go;
	total_monsters = total_monsters + 1;
};
*/

void ApplyMonsterBuffEffect(entity monst)
{
	if (monst.bufftype & BUFFTYPE_LEADER)
		self.effects(+)EF_DIMLIGHT;
	
	if (monst.bufftype & BUFFTYPE_SPECTRE)
		self.drawflags(+)DRF_TRANSLUCENT;
	if (monst.bufftype & BUFFTYPE_GHOST)
		self.drawflags(+)MLS_ABSLIGHT;
}

void RemoveMonsterBuffEffect(entity monst)
{
	if (monst.bufftype & BUFFTYPE_LEADER)
		self.effects(-)EF_DIMLIGHT;
	
	if (monst.bufftype & BUFFTYPE_SPECTRE)
		self.drawflags(-)DRF_TRANSLUCENT;
	if (monst.bufftype & BUFFTYPE_GHOST)
		self.drawflags(-)MLS_ABSLIGHT;
}

//Make monster larger and stronger
void ApplyLargeMonster(entity monst)
{
	entity oself;
	float sizescale, bonusscale;
	float oldheight, newheight;
	vector newmins, newmaxs, newoffs1, newoffs2;

	oself = self; //swap self for scope
	self = monst;
		
	sizescale = random(1.25, 1.75);
	self.scale = self.scale * sizescale;
	
	//save for restoring size after teleports and other efects
	self.tempscale = self.scale;
	
	bonusscale = sizescale * 1.25; //bonus scale is 25% higher than size increase
	
	newmins = self.mins * sizescale;
	newmaxs = self.maxs * sizescale;

	oldheight = fabs(self.mins_y) + self.maxs_y;
	newheight = fabs(newmins_y) + newmaxs_y;
	
	newoffs1 = self.view_ofs * sizescale;
	newoffs2 = self.proj_ofs * sizescale;
	
	/*
	dprintv("Mins: %s - ", self.mins);
	dprintv("%s | Maxs: ", newmins);
	dprintv("%s - ", self.maxs);
	dprintv("%s | View Ofs: ", newmaxs);
	dprintv("%s - ", self.view_ofs);
	dprintv("%s | Proj Ofs: ", newoffs1);
	dprintv("%s - ", self.proj_ofs);
	dprintv("%s \n", newoffs2);
	*/
	
	if (self.movetype == MOVETYPE_FLY)
		self.drawflags(+)SCALE_ORIGIN_CENTER;
	else
		self.drawflags(+)SCALE_ORIGIN_BOTTOM;
	
	setsize (monst, newmins, newmaxs);
	self.view_ofs = newoffs1;
	self.proj_ofs = newoffs2;
	
	self.speed *= sizescale;
	
	self.max_health *= bonusscale;
	self.health *= bonusscale;
	self.experience_value *= bonusscale;
	
	//no less than henchman	
	if (self.monsterclass < CLASS_HENCHMAN)
		self.monsterclass = CLASS_HENCHMAN;
	
	self = oself; //restore scope
}

void ApplyLeaderMonster(entity monst)
{
	entity oself;
	
	oself = self;
	self = monst;
	
	self.health *= 1.75;
	self.experience_value *= 2;
	
	self.effects(+)EF_DIMLIGHT;
	
	if (self.movetype == MOVETYPE_FLY)
		self.drawflags(+)SCALE_ORIGIN_CENTER;
	else
		self.drawflags(+)SCALE_ORIGIN_BOTTOM;
	self.scale *= 1.25;
	
	//spawn helpers
	cube_of_force(self);
	if (random() < 0.25)
	{
		cube_of_force(self);		
	}
	
	if (self.monsterclass < CLASS_LEADER)
		self.monsterclass = CLASS_LEADER;

	
	self = oself;
}

//make monster invisible and fast
void ApplySpectreMonster(entity monst)
{
	entity oself;
	
	oself = self;
	self = monst;

	self.drawflags(+)DRF_TRANSLUCENT;
	self.drawflags(+)MLS_ABSLIGHT;	//ws - translucent monsters were too difficult to see without abslight
	
	self.speed *= 1.75;
	self.experience_value *= 1.5;
	/*
	//ghost (even stronger) 25% of the time
	if (random(4) < 1)
	{
		self.health *= 1.2;
		self.speed *= 1.2;
		self.experience_value *= 1.33;
		
		self.drawflags(+)MLS_ABSLIGHT;
		
		self.bufftype(+)BUFFTYPE_GHOST;
	}
	*/
	self = oself; //restore scope
}

//Game of Tomes monster buffing system
float BUFF_RANDMIN_MIN = 0;
float BUFF_RANDMIN_MAX = 40;
float BUFF_RANDMAX = 100;
float BUFF_LARGE_CHANCE = 12;
float BUFF_LEADER_CHANCE = 2; //3
float BUFF_SPECTRE_CHANCE = 6;
void ApplyMonsterBuff(entity monst, float canBeLeader)
{
	if (!monst.buff || !CheckCfgParm(PARM_BUFF))
		return;
	
	float randmin, randval;
	
	monst.bufftype = BUFFTYPE_NORMAL;
	
	//no buff for player summoned monsters
	if (monst.playercontrolled)
		return;
	
	//respawn monsters have higher chance of becoming special.
	//  by increasing the min, the total spread reduces leaving the special monsters intact;
	randmin = monst.killerlevel * 2;
	
	//clamp value
	if (randmin < BUFF_RANDMIN_MIN)
		randmin = BUFF_RANDMIN_MIN;
	if (randmin > BUFF_RANDMIN_MAX)
		randmin = BUFF_RANDMIN_MAX;
	
	randval = random(randmin, BUFF_RANDMAX);
	if (randval > BUFF_RANDMAX - BUFF_LARGE_CHANCE)
	{	dprint ("large monster\n");
		ApplyLargeMonster(monst);
		monst.bufftype (+) BUFFTYPE_LARGE;
	}
	
	//make second check. There is a small chance that a monster can be a large leader!
	if (canBeLeader>1)
	{
		randval = random(randmin / 2, BUFF_RANDMAX);
		if (randval > BUFF_RANDMAX - BUFF_LEADER_CHANCE)
		{	dprint ("leader monster\n");
			ApplyLeaderMonster(monst);
			monst.bufftype (+) BUFFTYPE_LEADER;
			
			return; //cannot be a spectre leader, ditch here
		}	
	}
	
	randval = random(randmin, BUFF_RANDMAX);
	if (randval > BUFF_RANDMAX - BUFF_SPECTRE_CHANCE)
	{
		ApplySpectreMonster(monst);
		monst.bufftype (+) BUFFTYPE_SPECTRE;
	}
}

//monster spawning system originated by bloodshot12; modified & generalized for use by any monster by whirledtsar

void() imp_hover;

void() monster_spawn =
{
	if (self.spawndelay) {
		self.think = monster_spawn;
		thinktime self : self.spawndelay;
		self.spawndelay = 0;
		return;
	}
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.takedamage = DAMAGE_YES;
	self.effects(-)EF_NODRAW;
	self.use = monster_use;
	setmodel (self, self.init_model);
	setsize (self, self.orgnl_mins, self.orgnl_maxs);
	spawn_tdeath(self.origin, self);
	if (!self.spawnflags&SPAWNQUIET)
		GenerateTeleportEffect(self.origin, 0);	//spawn_tfog(self.origin);
	
	CheckMonsterBuff();
	
	SUB_AttackFinished(1);	//dont attack immediately
	
	if (self.model=="models/imp.mdl") {
		self.movetype = MOVETYPE_FLY;
		impmonster_start();
	}
	else if (self.classname=="monster_hydra")
		init_hydra();
	else if (self.flags&FL_FLY)
		flymonster_start();
	else
		walkmonster_start();
}

void() monster_dormant =
{
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	self.takedamage = DAMAGE_NO;
	self.effects(+)EF_NODRAW;
	self.init_model = self.model;	//use pre-existing fields to save values for when its spawned; init_model is otherwise only used by clients afaik
	self.orgnl_mins = self.mins;
	self.orgnl_maxs = self.maxs;
	self.spawnflags (-) SPAWNIN;
	self.flags2 (+) FL2_SPAWNED;
	self.use = monster_spawn;
	setmodel (self, "");
	setsize (self, '0 0 0', '0 0 0');
}

void monster_jump ()	//ws: generic think function for monsters in the air due to disc of repulsion or trigger_monsterjump
{
	MonsterCheckContents();
	if (self.flags&FL_ONGROUND || self.velocity=='0 0 0')
	{
		sound(self,CHAN_AUTO,"player/land.wav",0.75,ATTN_NORM);	//fx/thngland
		if (self.enemy)
			self.think=self.th_run;
		else
			self.think=self.th_stand;
		
		thinktime self : 0;
	}
	else if (self.health<=0) {
		self.think = self.th_die;
		thinktime self : 0;
	}
	else {
		self.frame = self.jumpframe;
		self.think = monster_jump;
		thinktime self : 0.01;
	}
}

void monster_raisedebuff()
{	//called by risen monsters after initializing their default values but before entering their think states
	self.buff = 0;		//dont turn into a buffed monster variant
	self.health *= 0.75;
	self.experience_value *= 0.75;
}

void monster_raisecheck ()
{
entity stuck, stuckent;
	stuck = findradius(self.origin, 64);
	while (stuck)
	{
		if (stuck.health && (stuck.solid!=SOLID_PHASE && stuck.solid!=SOLID_NOT))
			stuckent = stuck;
		stuck = stuck.chain;
	}
	if (stuckent)
		thinktime self : 0.1;
	else
	{
		self.think = self.th_raise;
		thinktime self : 0;
	}
}

void monster_raiseinit(entity corpse)
{
	if (!corpse.th_raise || !corpse.th_init)
		return;
	
entity new;		//create new entity to avoid inheriting anything weird from corpse
	new = spawn();
	setsize (new, corpse.mins, corpse.maxs);
	setmodel(new, corpse.model);
	setorigin(new, corpse.origin);
	
	new.frame = corpse.frame;
	new.scale = corpse.scale;
	new.drawflags = corpse.drawflags;
	new.skin = corpse.skin;
	new.flags2 (+) FL2_RESPAWN;		//dont precache
	new.enemy = corpse.enemy;
	new.classname = corpse.classname;
	new.th_init = corpse.th_init;
	new.th_raise = corpse.th_raise;
	new.think = monster_raisecheck;
	thinktime new : 0;
	
	remove(corpse);
}

void CheckMonsterBuff ()
{
	/*ws: monsters are spawned before player, so they cant check client's config flags immediately (as they arent initialized).
	instead, use ai_run, ai_walk, & ai_stand to check once player is ready (indicated by global var client_ready, set in client.hc). */
	if (!self.state && client_ready) {
		self.state = TRUE;	//dont check again
		if (CheckCfgParm(PARM_BUFF) && self.buff)
			ApplyMonsterBuff(self, self.buff);
	}
	
	return;
}

void minionfx ()
{
	if (!self.playercontrolled)
		return;
	if (deathmatch)
		return;
	if (random()<0.75)
		return;
	
	vector area, spot;
	area = randomv('-16 -16 0', '16 16 0');
	spot = self.origin;
	if (self.model=="models/scorpion.mdl")
		spot += self.view_ofs+'0 0 4';	//account for huge scorpion hitbox
	else
		spot_z += self.maxs_z;
	
	particle2(spot,area,area+randomv('0 0 0', '0 0 24'),COLOR_YELLOW_MID,PARTICLETYPE_STATIC,random(1, 3));
}

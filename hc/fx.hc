/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/fx.hc,v 1.2 2007-02-07 16:57:04 sezero Exp $
 */

float WHITE_PUFF	= 0;
float RED_PUFF		= 1;
float GREEN_PUFF	= 2;
float GREY_PUFF		= 3;


void CreateTeleporterBodyEffect (vector org,vector vel,float framelength)
{
	starteffect(CE_TELEPORTERBODY, org,vel,framelength);
}


void CreateTeleporterSmokeEffect (vector org,vector vel,float framelength)
{
	starteffect(CE_TELEPORTERPUFFS, org,vel,framelength);
}

// ============= SMOKE ================================

void CreateWhiteSmoke (vector org,vector vel,float framelength)
{
	starteffect(CE_WHITE_SMOKE, org,vel,framelength);
}

void CreateRedSmoke (vector org,vector vel,float framelength)
{
	starteffect(CE_RED_SMOKE, org,vel, framelength);
}

void CreateGreySmoke (vector org,vector vel,float framelength)
{
	starteffect(CE_GREY_SMOKE, org,vel, framelength);
}

void CreateGreenSmoke (vector org,vector vel,float framelength)
{
	starteffect(CE_GREEN_SMOKE, org,vel, framelength);
}

void CreateRedCloud (vector org,vector vel,float framelength)
{
	starteffect(CE_REDCLOUD, org,vel, framelength);
}

// ============= FLASHES ================================

void CreateLittleWhiteFlash (vector spot)
{
	starteffect(CE_SM_WHITE_FLASH,spot);
}

void CreateLittleBlueFlash (vector spot)
{
	starteffect(CE_SM_BLUE_FLASH,spot);
}

void CreateBlueFlash (vector spot) 
{
	starteffect(CE_BLUE_FLASH,spot);
}

void CreateWhiteFlash (vector spot) 
{
	starteffect(CE_WHITE_FLASH, spot);
}

void CreateYRFlash (vector spot)
{
	starteffect(CE_YELLOWRED_FLASH,spot);
}

// ============= EXPLOSIONS =============================

void CreateBlueExplosion (vector spot)
{
	starteffect(CE_BLUE_EXPLOSION,spot);
}

void CreateExplosion29 (vector spot)
{
	starteffect(CE_BG_CIRCLE_EXP,spot);
}

void CreateFireCircle (vector spot)
{
	starteffect(CE_SM_CIRCLE_EXP,spot);
}

// ============= SPARKS =============================

void CreateRedSpark (vector spot) 
{
	starteffect(CE_REDSPARK,spot);
}

void CreateGreenSpark (vector spot) 
{
	starteffect(CE_GREENSPARK,spot);
}

void CreateBSpark (vector spot) 
{
	starteffect(CE_BLUESPARK,spot);
}

void CreateSpark (vector spot)
{
	starteffect(CE_YELLOWSPARK,spot);
}

//FIXME:This should be a temp entity
void splash_run (void)
{
	float result;

	result = AdvanceFrame(0,5);

	self.nextthink = time + HX_FRAME_TIME;
	self.think = splash_run;

	if (result == AF_END)
	{
		self.think = SUB_Remove;
	}
}

void CreateWaterSplash (vector spot, vector vel)
{
	entity newent;

	newent = spawn();
  	setmodel (newent, "models/wsplash.spr");

	setorigin (newent, spot);
	if (vel)
		newent.movetype = MOVETYPE_TOSS;
	else
		newent.movetype = MOVETYPE_NOCLIP;
	newent.gravity = 0.1;
	newent.solid = SOLID_NOT;
	newent.velocity = vel;
	newent.nextthink = time + 0.05;
	newent.think = splash_run;
}

void CreateSludgeSplash (vector spot, vector vel)
{
	entity newent;

	newent = spawn();
  	setmodel (newent, "models/slsplash.spr");
	
	setorigin (newent, spot);
	if (vel)
		newent.movetype = MOVETYPE_TOSS;
	else
		newent.movetype = MOVETYPE_NOCLIP;
	newent.gravity = 0.1;
	newent.solid = SOLID_NOT;
	newent.velocity = vel;
	newent.nextthink = time + HX_FRAME_TIME*7;
	newent.think = SUB_Remove;
}

void CreateWaterSplashBig (vector org)
{
	float i, max;
	float neg;
	
	neg = 1;
	if (self.flags&FL_CLIENT)
		max = 6;
	else
		max = 4;
	
	for (i=0; i<=max-((coop||deathmatch||teamplay)*3); i++) {		//create fewer splashes in netgames for speed purposes
		if (random()<0.5)
			neg *= (-1);
		vector dir;
		dir_x = random(60,120) * neg;
		if (random()<0.5)
			neg *= (-1);
		dir_y = random(60,120) * neg;
		dir_z = random(20, 40);
		CreateWaterSplash(org, dir);
	}
}

void CreateSludgeSplashBig (vector org)
{
	float i, max;
	float neg;
	
	neg = 1;
	if (self.flags&FL_CLIENT)
		max = 6;
	else
		max = 4;
	
	for (i=0; i<=max-((coop||deathmatch||teamplay)*3); i++) {		//create fewer splashes in netgames for speed purposes
		if (random()<0.5)
			neg *= (-1);
		vector dir;
		dir_x = random(60,120) * neg;
		if (random()<0.5)
			neg *= (-1);
		dir_y = random(60,120) * neg;
		dir_z = random(20, 40);
		CreateSludgeSplash(org, dir);
	}
}

float AshColor()
{
	return 2+rint(random(4));
}

/*
================
SpawnPuff
================
*/
void  SpawnPuff (vector org, vector vel, float damage,entity victim)
{
	float part_color;
	float rad;

	if(victim.frozen>0)
		part_color = 406+random(8);				// Ice particles
	else if (victim.thingtype==THINGTYPE_FLESH && victim.classname!="mummy" && victim.netname != "spider")
		part_color = 256 + 8 * 16 + random(9);				//Blood red
	else if ((victim.thingtype==THINGTYPE_GREYSTONE) || (victim.thingtype==THINGTYPE_BROWNSTONE))
		part_color = 256 + 20 + random(8);			// Gray
	else if (victim.thingtype==THINGTYPE_METAL)	
		part_color = 256 + (8 * 15);			// Sparks
	else if (victim.thingtype==THINGTYPE_WOOD)	
		part_color = 256 + (5 * 16) + random(8);			// Wood chunks
	else if (victim.thingtype==THINGTYPE_ICE)	
		part_color = 406+random(8);				// Ice particles
	else if (victim.thingtype==THINGTYPE_ASH)	// Blackened ash
		part_color = AshColor();
	else if (victim.netname == "spider")	
		part_color = 256 + 183 + random(8);		// Spider's have green blood
	else
		part_color = 256 + (3 * 16) + 4;		// Dust Brown

	rad=vlen(vel);
	if(!rad)
		rad=random(10,20);
	particle4(org,rad,part_color,PARTICLETYPE_FASTGRAV,2 * damage);
}

/*-----------------------------------------
	redblast - the red flash sprite
  -----------------------------------------*/
void(vector spot) CreateRedFlash =
{
	starteffect(CE_RED_FLASH,spot);
};

void() DeathBubblesSpawn;

void GenerateTeleportSound (entity center)
{
string telesnd;
float r;
	r=rint(random(4))+1;
	if(r==1)
		telesnd="misc/teleprt1.wav";
	else if(r==2)
		telesnd="misc/teleprt2.wav";
	else if(r==3)
		telesnd="misc/teleprt3.wav";
	else if(r==4)
		telesnd="misc/teleprt4.wav";
	else
		telesnd="misc/teleprt5.wav";
	sound(center,CHAN_AUTO,telesnd,1,ATTN_NORM);
}

void GenerateTeleportEffect(vector spot1,float teleskin)
{
	entity sound_ent;

	if (self.attack_finished > time)
		return;

	sound_ent = spawn();
	setorigin(sound_ent,spot1);
	GenerateTeleportSound(sound_ent);
	sound_ent.think = SUB_Remove;
	thinktime sound_ent : 2;

	CreateTeleporterBodyEffect (spot1,'0 0 0',teleskin);  // 3rd parameter is the skin

	CreateTeleporterSmokeEffect (spot1,'0 0 0',HX_FRAME_TIME);
	CreateTeleporterSmokeEffect (spot1 + '0 0 64','0 0 0',HX_FRAME_TIME);

//	GenerateTeleportSound(newent);
//	if (self.scale < 0.11)
//	{
//		particle4(self.origin + '0 0 40',random(5,10),20,PARTICLETYPE_FASTGRAV,random(20,30));
//		particle4(self.origin + '0 0 40',random(5,10),250,PARTICLETYPE_FASTGRAV,random(20,30));
//		remove(self);
//	}

}

void smoke_generator_use(void)
{
	self.use = smoke_generator_use;
	self.nextthink = time + HX_FRAME_TIME;
	if (!self.wait)
		self.wait = 2;	
	self.owner = other;

	if (self.lifespan)
		self.lifetime = time + self.lifespan;

}

void smoke_generator_run(void)
{
	if (self.thingtype == WHITE_PUFF)
		CreateWhiteSmoke(self.origin, '0 0 8', HX_FRAME_TIME *3);
	else if (self.thingtype == RED_PUFF)
		CreateRedSmoke(self.origin, '0 0 8', HX_FRAME_TIME *3);
	else if (self.thingtype == GREEN_PUFF)
		CreateRedSmoke(self.origin, '0 0 8', HX_FRAME_TIME *3);
	else if (self.thingtype == GREY_PUFF)
		CreateGreySmoke(self.origin, '0 0 8', HX_FRAME_TIME *3);

	self.nextthink = time + random(self.wait);
	self.think = smoke_generator_run;

	if ((self.lifespan) && (self.lifetime < time))
		remove(self);
}

/*QUAKED fx_smoke_generator (0 1 1) (-8 -8 -8) (8 8 8)
Generates smoke puffs
-------------------------FIELDS-------------------------
wait - how often it should generate smoke (default 2)
thingtype - type of smoke to generate
 0 - white puff       (fire place)
 1 - red              (lava)
 2 - green            (slime)
 3 - grey             (oil)

lifespan - fill this in and it will only puff for this long
--------------------------------------------------------
*/
void() fx_smoke_generator =
{
	setmodel(self, "models/null.spr");

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;

	setsize (self,'0 0 0' , '0 0 0');

	self.th_die = SUB_Remove;

	if (!self.targetname)	//	Not targeted by anything so puff away
		self.nextthink = time + HX_FRAME_TIME;

	self.use = smoke_generator_use;

	if (!self.wait)
		self.wait = 2;


	self.think = smoke_generator_run;
};

void (vector org, float effect) fx_light = 
{
	local entity newent;

	newent = spawn();
  	setmodel (newent, "models/null.spr");
	setorigin (newent, org + '0 0 24');
	newent.movetype = MOVETYPE_NOCLIP;
	newent.solid = SOLID_NOT;
	newent.velocity = '0 0 0';
	newent.nextthink = time + 0.5;
	newent.think = SUB_Remove;

	newent.effects = effect (+) EF_NODRAW;

	setsize (newent, '0 0 0', '0 0 0');
};

/*
void () friction_change_touch =
{
	if (other == self.owner)
		return;

	if (other.classname == "player")
		other.friction=self.friction;

};
*/
/*QUAK-ED fx_friction_change (0 1 1) ?

Set the friction within this area.

-------------------------FIELDS-------------------------
'friction' :  this is how quickly the player will slow down after he ceases indicating movement (lets go of arrow keys).

             1       : normal friction
             >0 & <1 : slippery
             >1      : high friction
--------------------------------------------------------
*/
/*
void() fx_friction_change =
{
	self.movetype = MOVETYPE_NONE;
	self.owner = self;
	self.solid = SOLID_TRIGGER;
	setorigin (self, self.origin);
	setmodel (self, self.model);
	self.modelindex = 0;
	self.model = "";

	setsize (self, self.mins , self.maxs);

	self.touch = friction_change_touch;
};
*/

void() explosion_done =
{
	self.effects=EF_DIMLIGHT;
};

void() explosion_use =
{
/*
	if (self.spawnflags & FLASH)
	{
		self.effects=EF_BRIGHTLIGHT;
		self.think=p_explosion_done;
		self.nextthink= time + 1;
	}
*/
	sound (self, CHAN_BODY, self.noise1, 1, ATTN_NORM);

	particleexplosion(self.origin,self.color,self.exploderadius,self.counter);

};

/*QUAK-ED fx_particle_explosion (0 1 1) ( -5 -5 -5) (5 5 5) FLASH
 Gives off a spray of particles like an explosion.
-------------------------FIELDS-------------------------
 FLASH will cause a brief flash of light.

 "color" is the color of the explosion. Particle colors dim as they move away from the center point.

 color values :
   31 - white
   47 - light blue
   63 - purple
   79 - light green
   85 - light brown
  101 - red  (default)
  117 - light blue
  133 - yellow
  149 - green
  238 - red to orange
  242 - purple to red
  246 - green to purple
  250 - blue - green
  254 - yellow to blue

 "exploderadius" is the distance the particles travel before disappearing. 1 - 10  (default 5)

 "soundtype" the type of sound made during explosion
  0 - no sound
  1 - rocket explosion   (default)
  2 - grenade shoot

  "counter" the number of particles to create
  1 - 1024
  512 (default)

--------------------------------------------------------
*/
/*
void() fx_particle_explosion =
{
	self.effects=0;
	self.use=explosion_use;

	self.movetype = MOVETYPE_NOCLIP;
	self.owner = self;
	self.solid = SOLID_NOT;
	setorigin (self, self.origin);
	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);

	// Explosion color
	if ((!self.color) || (self.color>254))
		self.color=101;

	// Explosion sound is what type????
	if (self.soundtype>2)
		self.soundtype=0;
	else if (!self.soundtype)
		self.soundtype=1;

	if (self.soundtype==0)
		self.noise1 = ("misc/null.wav");
	else if (self.soundtype==1)
		self.noise1 = ("weapons/explode.wav");
	else if (self.soundtype==2)
		self.noise1 = ("weapons/grenade.wav");

	self.exploderadius = 10 - self.exploderadius;  // This is backwards in builtin function

	// Explosion radius
	if ((self.exploderadius<1) || (self.exploderadius>10))
		self.exploderadius=5;

	// Particle count
	if ((self.counter<1) || (self.counter>1024))
		self.counter=512;

};
*/

/*QUAKED misc_fountain (0 1 0.8) (0 0 0) (32 32 32) 
New item for QuakeEd

-------------------------FIELDS-------------------------
angles    0 0 0  the direction it should move the particles
movedir   1 1 1  the force it should move them
color     256    the color
cnt       2      the number of particles each time
--------------------------------------------------------

*/
void() do_fountain
{
	starteffect(CE_FOUNTAIN, self.origin, self.angles,self.movedir,self.color,self.cnt);
	if (self.soundtype)
		ambientsound (self.origin, "ambience/water1.wav", 0.5, ATTN_IDLE);
}

void misc_fountain(void)
{
	if (self.soundtype)
		precache_sound ("ambience/water1.wav");
	
	if (self.targetname)
	{
		self.use = do_fountain;
		return;
	}
	self.think = do_fountain;
	thinktime self : HX_FRAME_TIME;
}

/*
	~fx_leaves~
Brush entity that spawns leaves within its bounds in the direction of its angle, with random variance determined by its veer. Don't killtarget to remove, just use.

angle (0): Angle to spawn
speed (125): Speed of leaves
veer (45): Maximum offset from angle (1-360)
wait (1): Spawns per second. Because each spawner has a limit of 18 active leaves, low values (<0.33) will have erratic results.
*/

string leaves[3] = {"models/leafchk1.mdl", "models/leafchk2.mdl", "models/leafchk3.mdl"};

void() fx_leaves_remove;

entity leaves_findent ()
{
	if (!self.cameramode.state)
		return self.cameramode;
	if (!self.catapulter.state)
		return self.catapulter;
	if (!self.chain.state)
		return self.chain;
	if (!self.check_chain.state)
		return self.check_chain;
	if (!self.controller.state)
		return self.controller;
	if (!self.dmg_inflictor.state)
		return self.dmg_inflictor;
	if (!self.enemy.state)
		return self.enemy;
	if (!self.goalentity.state)
		return self.goalentity;
	if (!self.groundentity.state)
		return self.groundentity;
	if (!self.lockentity.state)
		return self.lockentity;
	if (!self.movechain.state)
		return self.movechain;
	if (!self.oldenemy.state)
		return self.oldenemy;
	if (!self.pathentity.state)
		return self.pathentity;
	if (!self.path_current.state)
		return self.path_current;
	if (!self.path_last.state)
		return self.path_last;
	if (!self.shield.state)
		return self.shield;
	if (!self.trigger_field.state)
		return self.trigger_field;
	if (!self.viewentity.state)
		return self.viewentity;
	
	return world;
}

void leaf_reset ()
{
	//self.model = "";
	setmodel(self, "models/null.spr");
	setsize (self, VEC_ORIGIN, VEC_ORIGIN);
	
	self.count = self.frags = 0;
	self.effects = EF_NODRAW;
	self.state = FALSE;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	
	self.think = SUB_Null;
	thinktime self : 99999999;
}

void leaf_remove ()
{	//try not to disappear when player could see
	self.think = leaf_remove;
	thinktime self : 0.5;
	
	++self.count;
	if (self.count >= 5)
		leaf_reset();	//remove(self);
	
	if (!checkclient)
		leaf_reset();	//remove(self);
}

void leaf_rise ()
{
	thinktime self : HX_FRAME_TIME*0.5;
	
	setorigin(self, self.origin+'0 0 1');
	if (pointcontents(self.origin-self.proj_ofs)==CONTENT_EMPTY) {
		self.think = leaf_remove;
		thinktime self : random(1,2);
	}
}

void leaf_fly ()
{
thinktime self : HX_FRAME_TIME;
	if (self.check_ok < time && (self.angles_x > (90+15) || self.angles_x < (90-15)))	{
		self.avelocity_x*=(-1);		//rotate in opposite direction so it doesnt just spin 360
		self.check_ok = time+0.1;	//slight delay so it doesnt immediately reverse again
	}
	if (pointcontents(self.origin) == CONTENT_WATER || pointcontents(self.origin) == CONTENT_SLIME) {	//float on water
		self.movetype = MOVETYPE_NONE;
		self.velocity = '0 0 0';
		self.angles_x = 90;
		self.think = leaf_rise;
		thinktime self : 0;
	}
	else if (pointcontents(self.origin) == CONTENT_LAVA) {
		CreateGreySmoke(self.origin, '0 0 4', HX_FRAME_TIME);
		leaf_reset();	//remove(self);
	}
}

void leaf_blow ()
{
	++self.frags;
	self.flags (-) FL_ONGROUND;
	self.gravity = 0.01;
	self.movetype = MOVETYPE_TOSS;
	self.speed *= 0.7;
	setorigin(self, self.origin+'0 0 1');
	self.movedir_y += 30*crandom();
	self.movedir_z = random(0.5,2);	//blow slightly upwards
	makevectors(self.movedir);
	self.velocity = v_forward * self.speed;
	
	self.think = leaf_fly;
	thinktime self : 0;
}

void leaf_touch ()
{
	if (pointcontents(self.origin) == CONTENT_SKY)
		leaf_reset();	//remove(self);
	if (other.thingtype==THINGTYPE_LEAVES || other.thingtype==THINGTYPE_WOOD_LEAF)
		return;
	
	if (other && other.solid!=SOLID_BSP)
		leaf_reset();	//remove(self);
	
	setorigin(self, self.origin+self.proj_ofs);
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.angles_x = 90;
	
	if (self.frags<=2 && random()<0.75)
		self.think = leaf_blow;
	else
		self.think = leaf_remove;
	thinktime self : random(1,3);
}

void leaf_init (entity new)
{
float type;
vector dir, org;
	type = rint(random(0,2));
	setmodel (new, leaves[type]);
	setsize (new, VEC_ORIGIN, VEC_ORIGIN);
	org_x = random(self.absmin_x, self.absmax_x);
	org_y = random(self.absmin_y, self.absmax_y);
	org_z = random(self.absmin_z, self.absmax_z);
	setorigin(new, org);
	new.avelocity_x = 25+(self.speed*0.25);
	new.avelocity_y = (self.speed*0.25);
	new.effects = 0;	//remove EF_NODRAW
	new.flags(-)FL_ONGROUND;
	new.frags = 0;	//how many times its been blown
	new.gravity = 0.05;
	new.movetype = MOVETYPE_TOSS;
	new.owner = self.owner;
	new.scale = random(0.7, 1);
	new.speed = self.speed;
	new.state = TRUE;
	new.solid = SOLID_PHASE;
	new.touch = leaf_touch;
	new.think = leaf_fly;
	thinktime new : HX_FRAME_TIME;
	
	dir = self.angles;
	dir_y += self.veer*crandom();
	makevectors(dir);
	new.velocity = v_forward * (self.speed*random(0.9,1.1));
	new.velocity_z = v_forward_z + random(0,10);
	new.angles = new.movedir = vectoangles(new.velocity);
	new.angles_x = 90;	//because of how leaf models are oriented
	if (type==0) {
		new.angles_y += 90;
		new.proj_ofs = '0 0 2';
	}
	else {
		new.angles_y += 180;
		new.proj_ofs = '0 0 5';
	}
}

void leaves_generate ()
{
entity leaf;
	
	if (self.aflag)		//remove self if we have linked tree and it has been destroyed
		if (!self.owner || self.owner.health<=0)
			fx_leaves_remove();
	
	leaf = leaves_findent();	//spawn();
	if (leaf)	//create leaf using first empty entity space from our list
		leaf_init(leaf);
	
	thinktime self : self.wait*random(0.8,1.2);
}

void fx_leaves_init ()
{	//find nearby foliage to link with (remove self if theyre removed)
entity found;
	if (self.target!="") {
		found = world;
		do
		{
			found = find(found, targetname, self.killtarget);
			if (found) {
				self.aflag = TRUE;
				self.owner = found;
				found = world;	//end loop
			}
		}
		while(found!=world);
	}
	else {
		found = findradius((self.absmin+self.absmax)*0.5, 192);
		while (found!=world)
		{
			//if (found.classname=="obj_tree2" || found.classname=="tree2top") {
			if (found.thingtype==THINGTYPE_LEAVES || found.thingtype==THINGTYPE_WOOD_LEAF) {
				self.aflag = TRUE;
				self.owner = found;
				found = world;
			}
			else
				found = found.chain;
		}
	}
	
	//spawn 18 possible entities to create leaves with
	self.cameramode = spawn();
	self.catapulter = spawn();
	self.chain = spawn();
	self.check_chain = spawn();
	self.controller = spawn();
	self.dmg_inflictor = spawn();
	self.enemy = spawn();
	self.goalentity = spawn();
	self.groundentity = spawn();
	self.lockentity = spawn();
	self.movechain = spawn();
	self.oldenemy = spawn();
	self.pathentity = spawn();
	self.path_current = spawn();
	self.path_last = spawn();
	self.shield = spawn();
	self.trigger_field = spawn();
	self.viewentity = spawn();
	
	self.think = leaves_generate;
	thinktime self : 0;
}

void fx_leaves_remove ()
{
	if (self.cameramode)
		remove(self.cameramode);
	if (self.catapulter)
		remove(self.catapulter);
	if (self.chain)
		remove(self.chain);
	if (self.check_chain)
		remove(self.check_chain);
	if (self.controller)
		remove(self.controller);
	if (self.dmg_inflictor)
		remove(self.dmg_inflictor);
	if (self.enemy)
		remove(self.enemy);
	if (self.goalentity)
		remove(self.goalentity);
	if (self.groundentity)
		remove(self.groundentity);
	if (self.lockentity)
		remove(self.lockentity);
	if (self.movechain)
		remove(self.movechain);
	if (self.oldenemy)
		remove(self.oldenemy);
	if (self.pathentity)
		remove(self.pathentity);
	if (self.path_current)
		remove(self.path_current);
	if (self.path_last)
		remove(self.path_last);
	if (self.shield)
		remove(self.shield);
	if (self.trigger_field)
		remove(self.trigger_field);
	if (self.viewentity)
		remove(self.viewentity);
	remove(self);
}

void fx_leaves ()
{
	setmodel(self, self.model);       // set size and link into world
	self.model		= "";
	self.modelindex = 0;
	setsize (self, self.mins, self.maxs);
	
	self.use = fx_leaves_remove;
	self.think = fx_leaves_init;
	thinktime self : 0.1;
	
	if (!self.wait)
		self.wait = 1;
	if (!self.speed)
		self.speed = 125;
	if (self.veer<=0 || self.veer>360)
		self.veer = 45;
}

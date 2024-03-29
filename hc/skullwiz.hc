/*
 * h2/skullwiz.hc
 */

//
$frame skdeth1      skdeth2      skdeth3      skdeth4      skdeth5      
$frame skdeth6      skdeth7      skdeth8      skdeth9      skdeth10     
$frame skdeth11     skdeth12     skdeth13     skdeth14     skdeth15     

//
$frame skgate1      skgate2      skgate3      skgate4      skgate5      
$frame skgate6      skgate7      skgate8      skgate9      skgate10     
$frame skgate11     skgate12     skgate13     skgate14     skgate15     
$frame skgate16     skgate17     skgate18     skgate19     skgate20     
$frame skgate21     skgate22     skgate23     skgate24     skgate25     
$frame skgate26     skgate27     skgate28     skgate29     skgate30     

// Frame 46 - 57
$frame skpain1      skpain2      skpain3      skpain4      skpain5      
$frame skpain6      skpain7      skpain8      skpain9      skpain10     
$frame skpain11     skpain12     

// Frame 58 - 69
$frame skredi1      skredi2      skredi3      skredi4      skredi5      
$frame skredi6      skredi7      skredi8      skredi9      skredi10     
$frame skredi11     skredi12     

//
//$frame skspel1      skspel2      skspel3      skspel4      skspel5      
//$frame skspel6      skspel7      skspel8      skspel9      skspel10     
//$frame skspel11     skspel12     skspel13     skspel14     skspel15     
//$frame skspel16     skspel17     skspel18     skspel19     skspel20     
//$frame skspel21     skspel22     skspel23     skspel24     skspel25     
//$frame skspel26     skspel27     skspel28     skspel29     skspel30     
//$frame skspel31     

// Frame 70 - 84
$frame skspel2      skspel4            
$frame skspel6      skspel8      skspel10     
$frame skspel12     skspel14     
$frame skspel16     skspel18     skspel20     
$frame skspel22     skspel24          
$frame skspel26     skspel28     skspel30     


//
//$frame sktele1      sktele2      sktele3      sktele4      sktele5      
//$frame sktele6      sktele7      sktele8      sktele9      sktele10     
//$frame sktele11     sktele12     sktele13     sktele14     sktele15     
//$frame sktele16     sktele17     sktele18     sktele19     sktele20     
//$frame sktele21     sktele22     sktele23     sktele24     sktele25     
//$frame sktele26     sktele27     sktele28     sktele29     sktele30     
//$frame sktele31     

$frame sktele2      sktele4            
$frame sktele6      sktele8      sktele10     
$frame sktele12     sktele14          
$frame sktele16     sktele18     sktele20     
$frame sktele22     sktele24          
$frame sktele26     sktele28     sktele30     
//
$frame sktran1      sktran2      sktran3      sktran4      sktran5      
$frame sktran6      sktran7      

//
$frame skwait1      skwait2      skwait10     skwait11     skwait12     
$frame skwait13     skwait14     skwait15     skwait16     skwait17     
$frame skwait18     skwait19     skwait20     skwait21     skwait22     
$frame skwait23     skwait24     skwait25     skwait26     
  

//
$frame skwalk1      skwalk2      skwalk3      skwalk4      skwalk5      
$frame skwalk6      skwalk7      skwalk8      skwalk9      skwalk10     
$frame skwalk11     skwalk12     skwalk13     skwalk14     skwalk15     
$frame skwalk16     skwalk17     skwalk18     skwalk19     skwalk20     
$frame skwalk21     skwalk22     skwalk23     skwalk24     


void skullwiz_walk(void);
void skullwiz_run(void);
void skullwiz_melee(void);
void skullwiz_blink(void);
void skullwiz_push (void);
void skullwiz_missile_init (void);

void monster_raiseinit (entity corpse);

float SKULLBOOK  =0;
float SKULLHEAD  =1;


entity skullwiz_findcorpse ()
{
entity corpse;
	corpse = findradius(self.origin, 288);
	while(corpse)
	{
		if (corpse.th_raise && corpse.th_init && corpse.think == CorpseThink && !corpse.preventrespawn) {
			if (corpse.classname!="monster_undying" && corpse.decap)
				return world;	//dont revive decapitated corpses besides undying
			
			return corpse;
		}
		corpse = corpse.chain;
	}
	return world;
}

void skullwiz_raise(void)
{
entity risen;
	risen = skullwiz_findcorpse();
	if (risen==world)
		return;
	
	risen.enemy = self.enemy;
	risen.controller = self;
	monster_raiseinit(risen);
}

void skullwiz_raiseinit (void) [++ $skgate1..$skgate30]
{
	self.think = skullwiz_raiseinit;
	
	if (self.frame == $skgate2) {
		entity ring;
		ring = spawn();
		setorigin (ring, self.origin);
		ring.owner = self;
		ring.lifetime = time + .8;
		setmodel(ring, "models/proj_ringshock.mdl");
		ring.think = shockwave;
		thinktime ring : .1;
		
		sound (ring, CHAN_BODY, "skullwiz/gate.wav", 1, ATTN_NORM);
	}

	if (self.frame >= $skgate10 && self.frame <= $skgate23) {
		skullwiz_raise();
	}

	if (cycle_wrapped) {
		self.raiseTime=time+4;		//dont raise corpses again until this timer is up
		skullwiz_run();
	}
}

float() SkullFacingIdeal =
{
	local	float	delta;
	
	delta = anglemod(self.angles_y - self.ideal_yaw);
	if (delta > 25 && delta < 335)
		return FALSE;
	return TRUE;
};

float check_defense_blink ()
{
vector spot1,spot2,dangerous_dir;
float dot;
	if(!self.enemy)
		return FALSE;

	if(!visible(self.enemy))
		return FALSE;

	if(self.enemy.last_attack<time - 0.5)
		return FALSE;
	
	if (self.teleportTime > time)	//dont teleport immediately after teleporting in
		return FALSE;

	spot1=self.enemy.origin+self.enemy.proj_ofs;
	spot2=(self.absmin+self.absmax)*0.5;
	dangerous_dir=normalize(spot2-spot1);

	if(self.enemy.classname=="player")
		makevectors(self.enemy.v_angle);
	else
		makevectors(self.enemy.angles);

	dot=dangerous_dir*v_forward;
	if(dot>0.8)
		return TRUE;
	else
		return FALSE;
}

void skullwiz_gibinit()
{
	if (!self.flags&FL_ONGROUND  && !self.groundentity) {
		self.think = skullwiz_gibinit;
		thinktime self : HX_FRAME_TIME;
		return;
	}
	
	self.solid = SOLID_PHASE;
	self.movetype = MOVETYPE_NONE;
	setsize(self, self.mins, self.maxs);
	
	self.health = 15;
	self.takedamage = DAMAGE_YES;
	self.th_die = chunk_death;
	
	if (CheckCfgParm(PARM_FADE)) {
		self.think=init_corpseblink;
		thinktime self : random(30,20);
	}
	else {
		self.think = SUB_Null;
		thinktime self : 99999;
	}
}

void skullwiz_throw(float part)
{
	entity new;
	new = spawn();

	if (part==SKULLBOOK) {
		setmodel (new, "models/skulbook.mdl");
		new.thingtype = THINGTYPE_CLOTH;
	}
	else {
		setmodel (new, "models/skulhead.mdl");
		new.thingtype = THINGTYPE_BONE;
	}

	do {
		new.origin_x = random(10,10);
		new.origin_y = random(10,10);
		new.origin_z = 40;
		setorigin(new,self.origin + new.origin);
	} while (pointcontents(new.origin)==CONTENT_SOLID);
	
	setsize (new, '-5 -5 0', '5 5 2');		//setsize (new, '0 0 0', '0 0 0');
	float dir = randomsign();
	new.velocity_z = random(100,150);
	new.velocity_x = random(100,150)*dir;
	new.velocity_y = random(100,150)*dir;

	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity_y = random(400,600);
	if (part!=SKULLBOOK) {	//book looks bad not flat
		new.avelocity_x = random(400,600);
		new.avelocity_z = random(400,600);
	}
	new.flags(-)FL_ONGROUND;

	new.think=skullwiz_gibinit;
	new.nextthink = time + HX_FRAME_TIME * 15;
}

void()skullwiz_spiderinit;
void spider_spawn (float spawn_side)
{
	newmis = spawn ();
	newmis.cnt=spawn_side;			// Shows which side to appear on
	newmis.flags2=FL_SUMMONED;
	newmis.nextthink = time + .01;
	newmis.think = skullwiz_spiderinit;
	newmis.origin = self.origin;
	newmis.controller = self;
	newmis.owner = self;		//ws: temporary - let spider phase thru dead wizards
	newmis.preventrespawn = TRUE;

	newmis.angles = self.angles;
}


void skullwiz_die (void) [++ $skdeth1.. $skdeth15]
{
	entity newent,holdent;

	thinktime self : HX_FRAME_TIME * 1.5;
	self.scale = 1;

	if (self.frame == $skdeth1)
	{
		self.solid = SOLID_NOT;
		CreateWhiteSmoke(self.origin + '0 0 20', '0  0 12', HX_FRAME_TIME *10);
		CreateWhiteSmoke(self.origin + '0 0 20', '0  8  8', HX_FRAME_TIME *10);
		CreateWhiteSmoke(self.origin + '0 0 20', '0 -8  8', HX_FRAME_TIME *10);
		ThrowGib ("models/blood.mdl", self.health);
		ThrowGib ("models/blood.mdl", self.health);

		if (self.classname == "monster_skull_wizard")  
			sound (self, CHAN_VOICE, "skullwiz/death.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "skullwiz/death2.wav", 1, ATTN_NORM);
	}

	if (self.frame == $skdeth6)
		skullwiz_throw(SKULLBOOK);

	if (self.frame == $skdeth7)
	{
		setorigin(self,self.origin + '0 0 10');   // Throw robe
		self.flags(-)FL_ONGROUND;
		self.velocity_z = random(100,150);
		self.velocity_x = random(100,150);
		self.velocity_y = random(100,150);

		self.avelocity_x = random(400,600);
		self.avelocity_y = random(400,600);
		self.avelocity_z = random(400,600);
		self.mass = 99999;
	}

	if (self.frame == $skdeth8)
	{
		skullwiz_throw(SKULLHEAD);
	}

	if (self.frame == $skdeth15)
	{
		if (self.classname == "monster_skull_wizard_lord")  
		{
			newent = spawn();
			setorigin(newent,self.origin + '0 0 16');
			newent.lifespan = random(10,15);
			newent.lifetime = time + newent.lifespan;
			newent.thingtype = GREY_PUFF;
			newent.wait = 1.5;

			holdent = self;
			self = newent;
			fx_smoke_generator();
			self = holdent;
		}
		
		spider_spawn(0);
		if (random() < .5)
			spider_spawn(1);

		if (self.classname == "monster_skull_wizard_lord")  // Another two for the wizard lord
		{
			spider_spawn(0);
//			if (random() < .5)
//				spider_spawn(1);
		}

		MakeSolidCorpse();
	}
}

void spider_grow(void)
{
	thinktime self : HX_FRAME_TIME;
	self.think = spider_grow;

	self.scale += 0.03;

	if (self.scale>= 0.50)
		walkmonster_start();
}

void skullwiz_spiderinit(void)
{
vector spot;
	
	//self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.drawflags = SCALE_ORIGIN_BOTTOM;
	
	// Small spiders
	setsize(self, '-7 -7 0', '7 7 10');
	self.hull=HULL_CROUCH;
	self.orgnl_mins = self.mins;
	self.orgnl_maxs = self.maxs;
	
	if (self.controller.flags2&FL_ALIVE)
	{
		if (self.cnt)			// On one side
			spot = FindSpawnSpot(60, 140, -45, self.controller);
		else					// On the other side
			spot = FindSpawnSpot(60, 140, 45, self.controller);
		
		if (spot==VEC_ORIGIN)	//couldnt find suitable spawn spot
		{
			self.effects(+)EF_NODRAW;
			++self.counter;
			if (self.counter>20) {
				remove(self);
				return;
			}
			thinktime self : 0.1;
			return;
		}
		self.effects(-)EF_NODRAW;
 	}
	else	// Skull Wiz is dead, spawn at his location
	{
		if (!CanSpawnAtSpot(self.origin, self.mins*1.25, self.maxs*1.25, self.controller))
		{
			self.effects(+)EF_NODRAW;
			spot = FindSpawnSpot(10, 40, 360, self.controller);
			if (spot!=VEC_ORIGIN)
				self.origin = spot;
			++self.counter;
			if (self.counter>20) {
				remove(self);
				return;
			}
			thinktime self : 0.1;
			return;
		}
		self.effects(-)EF_NODRAW;
		spot = self.origin;
	}
	
	self.solid = SOLID_SLIDEBOX;
	setmodel(self, "models/spider.mdl");
	setsize(self, '-7 -7 0', '7 7 10');
	setorigin(self,spot + '0 0 4');
	droptofloor();
	
	self.flags2=FL_SUMMONED;
	self.yaw_speed = 10;
	self.mass = 0.5;
	self.speed = 5;
	
	self.lifetime = time + 30;
	
	self.skin = 1;
	self.health = self.max_health = 10 + ((skill>2)*15);	//extra health on nightmare
	self.init_exp_val = self.experience_value = SpiderExp[1]*0.5;
	
	self.drawflags = SCALE_ORIGIN_BOTTOM;
	self.scale = 0.1;
	self.spawnflags (+) JUMP|NO_DROP;
	
	self.monster_awake = TRUE;
	self.thingtype = THINGTYPE_FLESH;
	self.spiderType = 1;
	self.spiderGoPause = 35;
	self.mintel = 10;
	self.netname = "spider";
	self.classname = "monster_spider_yellow_small";
	
	self.th_stand = SpiderStand;
	self.th_walk = SpiderWalk;
	self.th_run = SpiderRun;
	self.th_die = SpiderDie;
	self.th_melee = SpiderMeleeBegin;
	self.th_missile = SpiderJumpBegin;
	self.th_pain = SpiderPain;
	
	self.flags (+) FL_MONSTER;
	
	self.owner = self.controller;
	newmis = spawn();		//create entity that checks if spider is out of controller's range and make them solid if so
	newmis.enemy = self;
	newmis.controller = self.controller;
	newmis.think = minion_solid;
	thinktime newmis : HX_FRAME_TIME;
	
	//CreateWhiteSmoke (self.origin+'0 0 3','0 0 8');
	
	spider_grow();
}

void skullwiz_summoninit (void) [++ $skgate1..$skgate30]
{
	thinktime self : HX_FRAME_TIME*0.5;	//ws: speed up animation
	if (self.frame == $skgate2)
		sound (self, CHAN_VOICE, "skullwiz/gatespk.wav", 1, ATTN_NORM);
	
	if (self.frame == $skgate21)   // Gate in the creatures
	{
		spider_spawn(0);

		if (random() < 0.15 || coop || self.bufftype & BUFFTYPE_LEADER)   // 15% chance he'll do another
		{
			spider_spawn(1);
		}
		
		sound (self, CHAN_AUTO, "skullwiz/gate.wav", 1, ATTN_NORM);
	}

	if (cycle_wrapped) {
		self.summonTime = time+1;	//dont immediately summon another spider
		skullwiz_run();
	}
}

/*-----------------------------------------
	skullwiz_transition - transition from 
  -----------------------------------------*/
void skullwiz_transition (void) [++ $sktran1.. $sktran7]
{
	if (self.frame == $sktran1)
		self.attack_finished = time + random(0.5,3.5);

	if (cycle_wrapped)
		skullwiz_run();
}

/*-----------------------------------------
	skullwiz_pain - flinch in pain
  -----------------------------------------*/
void skullwiz_pain_anim () [++ $skpain1 .. $skpain12]
{
	if (self.frame == $skpain2)
	{
		ThrowGib ("models/blood.mdl", self.health);
		ThrowGib ("models/blood.mdl", self.health);
		if (self.classname == "monster_skull_wizard")
			sound (self, CHAN_BODY, "skullwiz/pain.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_BODY, "skullwiz/pain2.wav", 1, ATTN_NORM);
	}
	//ws: frame advance is handled automatically by the function, so the following skipped most frames (including the frame with pain sound)
	//if (self.frame < $skpain11)
		//self.frame += 1;

	if (self.frame>=$skpain12)
	{
		self.pain_finished = time + 3;

		if (random() < .30)
			skullwiz_blink();
		else
			skullwiz_run();
	}
}

void skullwiz_pain (entity attacker, float damg)
{
	if (self.pain_finished > time||random(self.health*0.75)>damg)	//ws: pain chance increased slightly
		return;

	skullwiz_pain_anim();
}


void SkullMissileTouch (void)
{
	float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	if (self.owner.classname == "monster_skull_wizard")
		damg = random(5,13);
	else
		damg = random(10,18);

	if (other.health)
		T_Damage (other, self, self.owner, damg );

	self.origin = self.origin - 8*normalize(self.velocity);
	sound (self, CHAN_WEAPON, "weapons/explode.wav", 1, ATTN_NORM);

    BecomeExplosion (FALSE);
}

void SkullMissile_Twist2(void)
{
	vector holdangle;
	
	self.think = SkullMissile_Twist2;
	thinktime self : .2;

	holdangle = self.angles;
	if (!self.cnt)
	{
		holdangle_x = 0 - holdangle_x + 10;
		self.cnt = 1;
	}
	else
	{
		holdangle_x = 0 - holdangle_x - 10;
		self.cnt = 0;
	}

		
	makevectors (holdangle);
	self.velocity = normalize (v_forward);
	self.velocity = self.velocity * 600;

	if (self.lifetime < time )
		remove(self);

	if (self.scream_time < time)
	{
		sound (self, CHAN_BODY, "skullwiz/scream2.wav", 1, ATTN_NORM);
		self.scream_time = time + random(.50,1);
	}
	
	if (self.owner.bufftype & BUFFTYPE_LEADER)
		HomeThink();
}

void SkullMissile_Twist(void)
{
	self.think = SkullMissile_Twist;
	thinktime self : .2;

	if (self.lifetime < time )
		remove(self);

	if (self.scream_time < time)
	{
		sound (self, CHAN_BODY, "skullwiz/scream.wav", 1, ATTN_NORM);
		self.scream_time = time + random(.50,1);
	}
	
	if (self.owner.bufftype & BUFFTYPE_LEADER)
		HomeThink();
}

/*-----------------------------------------
	launch_skullshot - launch the missile
  -----------------------------------------*/
void launch_skullshot ()
{
	local vector diff;

	self.last_attack=time;
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
//	newmis.drawflags = MLS_FIREFLICKER;

	setmodel (newmis, "models/skulshot.mdl");
	newmis.hull=HULL_POINT;
	newmis.takedamage=DAMAGE_YES;
	newmis.health=1;
	newmis.dmg=10;
	newmis.th_die=MultiExplode;
	setsize (newmis, '-7 -7 -10', '7 7 10');		
	makevectors (self.angles);
	setorigin (newmis, self.origin + v_forward*20 - v_right * 16 + v_up * 45);

// set missile speed	
	diff = (self.enemy.origin + self.enemy.view_ofs) - newmis.origin ;
	newmis.velocity = normalize(diff+aim_adjust(self.enemy));
	newmis.velocity = newmis.velocity * 600;
	newmis.classname = "skullmissile";
	newmis.angles = vectoangles(newmis.velocity);
	

	newmis.scale=1.7;
	newmis.touch = SkullMissileTouch;

// set missile duration
	thinktime newmis : .10;
	newmis.lifetime = time + 2.5;
	newmis.scream_time = time + random(.5,1);

	self.cnt = 0;
	if (self.classname == "monster_skull_wizard_lord")
	{
		sound (newmis, CHAN_BODY, "skullwiz/scream2.wav", 1, ATTN_NORM);
		newmis.skin = 1;
		newmis.think = SkullMissile_Twist2;
	}
	else
	{
		sound (newmis, CHAN_BODY, "skullwiz/scream.wav", 1, ATTN_NORM);
		newmis.think = SkullMissile_Twist;
		newmis.scale = .90;
	}
	
	if (self.bufftype & BUFFTYPE_LEADER)
	{
		newmis.veer=0;				//slight veering, random course modifications
		newmis.turn_time = 0.5;
		newmis.hoverz=FALSE;
		newmis.ideal_yaw=TRUE;
		newmis.speed=500;
	}
}

/*-----------------------------------------
	skullwiz_missile - throw missile
  -----------------------------------------*/
void skullwiz_missile (void) [++ $skspel2..$skspel30]
{
	vector delta,spot1,spot2;

	delta = self.enemy.origin - self.origin;
//f (vlen(delta) < 50)  // Too close to shoot with a missile
//skullwiz_melee();

	if (self.frame == $skspel20)
	{
		ai_face();

		makevectors(self.angles);	
		// see if any entities are in the way of the shot
		spot1 = self.origin + v_right * 10 + v_up * 36;
		spot2 = self.enemy.origin + self.enemy.view_ofs;

		traceline (spot1, spot2, FALSE, self);
		if (trace_ent == self.enemy)
		{
			if (SkullFacingIdeal())
			{
				sound (self, CHAN_WEAPON, "skullwiz/firemisl.wav", 1, ATTN_NORM);
				launch_skullshot();
			}
			else
				self.frame-=1;
		}
	}

	if (cycle_wrapped)
	{
		// Attack again or walk a little
		if (random() < .5)		// Shoot again
			skullwiz_missile();			
		else if(self.skin&&random()<skill/10+0.2)
			skullwiz_blink();
		else
			skullwiz_transition();
	}
//	else
//		ai_face();

}

/*-----------------------------------------
	skullwiz_missile_init - ready to throw missile
  -----------------------------------------*/
void skullwiz_missile_init (void) [++ $skredi1..$skredi12]
{
	if (self.classname=="monster_skull_wizard_lord" && skullwiz_findcorpse()!=world)
		skullwiz_raiseinit();
	else if (self.classname=="monster_skull_wizard_lord" && vlen(self.enemy.origin-self.origin)<300 && random()<0.4 && time>self.summonTime)
		skullwiz_summoninit();
	
	self.frame += 2;

	if (cycle_wrapped)
	   skullwiz_missile();
}

void skullwiz_blinkin(void) 
{
	float max_scale;

	thinktime self : HX_FRAME_TIME;
	self.think = skullwiz_blinkin;

	self.scale += 0.10;
	ai_face();

	if (self.classname == "monster_skull_wizard")
		max_scale = 1;
	else
		max_scale = 1.20;
	
	if (self.bufftype & BUFFTYPE_LARGE)
		max_scale = self.tempscale;

	if (self.scale >= max_scale)
	{
		self.scale=max_scale;
		self.th_pain=skullwiz_pain;
		self.takedamage = DAMAGE_YES;
		
		//reset scale type to normal
		self.drawflags (-) SCALE_TYPE_MASKOUT;
		self.drawflags (-) SCALE_TYPE_XYONLY;
		self.drawflags (+) SCALE_ORIGIN_BOTTOM;
		
		//restore monster effects
		ApplyMonsterBuffEffect(self);
		
		self.teleportTime = time+1;		//ws: dont teleport again immediately, give player a little time to retaliate
		self.raiseTime = time+0.5;		//also dont immediately revive corpses
		self.summonTime = time+0.5;		//and dont summon spiders either
		
		skullwiz_run();
	}
}

void skullwiz_blinkin1 (void) 
{
	thinktime self : HX_FRAME_TIME;
	self.think = skullwiz_blinkin;

	setmodel(self, "models/skullwiz.mdl");
	self.frame = $skwalk1;
}

void skullwiz_ininit (void)
{
vector spot1,spot2,newangle,enemy_dir;
float loop_cnt,forward,dot;

	if (self.enemy != world)
	{
		if (!self.enemy.flags2 & FL_ALIVE)
		{
			self.enemy = world;
			self.goalentity = world;
		}
	}

	trace_fraction =0;
	loop_cnt = 0;
	do
	{
		if(self.enemy)
		{
			makevectors(self.enemy.angles);
			enemy_dir=self.enemy.velocity;
			enemy_dir_z=0;
			enemy_dir=normalize(enemy_dir);
			dot=enemy_dir*v_forward;
			enemy_dir_y=self.enemy.angles_y+360;
			if(dot>0.5)
				newangle_y=enemy_dir_y+random(-45,45);
			else
				newangle_y=enemy_dir_y+random(45,315);
		}
		else
		{
			newangle = self.angles;
			newangle_y = random(360);
		}

   		makevectors (newangle);
		if (self.enemy)
			spot1 = self.enemy.origin;
		else
			spot1 = self.origin;
		
		forward = random(120,200);
		spot2 = spot1 + (v_forward * forward);
		
		if (CanSpawnAtSpot(spot2, self.orgnl_mins*1.25, self.orgnl_maxs*1.25, self))
		{
			self.solid = SOLID_SLIDEBOX;
			setsize (self, self.orgnl_mins, self.orgnl_maxs);
			
			setorigin(self,spot2);
			if (walkmove(self.angles_y, .05, TRUE))		// You have to move it a little bit to make it solid
				trace_fraction = 1;   // So it will end loop
			else
			{
				trace_fraction = 0;   // So it will loop
				self.solid = SOLID_NOT;		//ws: Unset solid to prevent player from getting stuck
			}
		}
		else
			trace_fraction = 0;
		
		loop_cnt += 1;

		if (loop_cnt > 500)   // No endless loops
		{
			self.nextthink = time + 2;
			return;
		}

	} while (trace_fraction != 1);
	
	sound (self, CHAN_VOICE, "skullwiz/blinkin.wav", 1, ATTN_NORM);
	CreateRedFlash(self.origin + '0 0 40');
	
	setmodel(self, "models/skullwiz.mdl");
	self.frame = $skwalk1;
	setsize (self, self.orgnl_mins, self.orgnl_maxs);
	self.hull = HULL_PLAYER;
	
	self.think=skullwiz_blinkin;
	self.nextthink = time;
}

/*-----------------------------------------
	skullwiz_blinkout - blink out
  -----------------------------------------*/
void skullwiz_blinkout(void) 
{
	thinktime self : HX_FRAME_TIME;
	self.think = skullwiz_blinkout;

	self.scale -= 0.10;

	if ((self.scale > 0.19) && (self.scale < 0.29))
	{
		sound (self, CHAN_BODY, "skullwiz/blinkout.wav", 1, ATTN_NORM);
		CreateRedFlash(self.origin + '0 0 40');
	}

	if (self.scale < 0.10)
	{
		setmodel(self,string_null);
		thinktime self : random(0.5,3);		// Reappear when
		self.think = skullwiz_ininit;
	}
}

/*-----------------------------------------
	skullwiz_blink - assume stance to blink out
  -----------------------------------------*/
void skullwiz_blink(void) [++ $sktele2..$sktele30]
{

	if (self.frame == $sktele2)
	{
		if (self.classname == "monster_skull_wizard")
			sound (self, CHAN_VOICE, "skullwiz/blinkspk.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "skullwiz/blnkspk2.wav", 1, ATTN_NORM);
	}

	if(self.aflag)
	{
		if(self.frame+2<=$sktele30)
			self.frame+=2;
		thinktime self : 0.005;
	}

	if (self.frame == $sktele30)
	{
		self.aflag=FALSE;
		self.takedamage = DAMAGE_NO;  // So t_damage won't force him into another state 
		self.scale = 1;
		if (self.bufftype & BUFFTYPE_LARGE)
			self.scale = self.tempscale;
		
		//temporarily remove monster effects
		// Must happen before teleport in order to not break the SCALE_TYPE_MASKOUT effect
		RemoveMonsterBuffEffect(self);

		//self.drawflags = (self.drawflags & SCALE_TYPE_MASKOUT) | SCALE_TYPE_XYONLY;
		//replacing explicite flags with adding/removing Teleport related flags
		self.drawflags (+) SCALE_TYPE_MASKOUT;
		self.drawflags (+) SCALE_TYPE_XYONLY;
		self.drawflags (-) SCALE_ORIGIN_BOTTOM;		
		
		self.solid = SOLID_NOT;
		self.th_pain=SUB_Null;
		skullwiz_blinkout();	
	}
}

/*-----------------------------------------
	skullwiz_push - push the enemy away
  -----------------------------------------*/
void skullwiz_push ()
{
	local vector	delta;
	local float 	ldmg;

	if (self.enemy.classname != "player")
		return;

	delta = self.enemy.origin - self.origin;
//if (vlen(delta) > 80)
//		return;

	self.last_attack=time;
	ldmg = random(10);

	T_Damage (self.enemy, self, self, ldmg);
	sound (self, CHAN_VOICE, "skullwiz/push.wav", 1, ATTN_NORM);

	if (self.enemy.flags & FL_ONGROUND)
		self.enemy.flags(-)FL_ONGROUND;

	if (self.classname == "monster_skull_wizard")
	{
		self.enemy.velocity = delta * 10;
		self.enemy.velocity_z = 100;
	}
	else
	{
		self.enemy.velocity = delta * 10;
		self.enemy.velocity_z = 200;
	}
}

/*-----------------------------------------
	skullwiz_melee - push enemy away so you can throw a missile
  -----------------------------------------*/
void skullwiz_melee (void) [++ $skspel2..$skspel30]
{
	vector	delta;
	
	if (self.frame == $skspel20)   // Push enemy away
	{
		skullwiz_push();
		float r = random();
		if (r < 0.5)
			skullwiz_missile_init();
		else if (self.classname == "monster_skull_wizard_lord" && r < 0.6)	//0.1 chance of summoning
			skullwiz_summoninit();
	}

	if (cycle_wrapped)
	{
		delta = self.enemy.origin - self.origin;
		if (vlen(delta) > 80)
			skullwiz_run();
	}
	else
		ai_charge(1.3);

}
/*-----------------------------------------
	skullwiz_run - run towards the enemy
  -----------------------------------------*/
void skullwiz_run (void) [++ $skwalk1..$skwalk24]
{
	vector delta;

	if(check_defense_blink()&&(self.health<50||self.classname=="monster_skull_wizard_lord"))
	{
		self.solid = SOLID_NOT;
		self.aflag=TRUE;
		self.think=skullwiz_blink;
		thinktime self : 0;
		return;
	}

	if ((random(1)<.10) && (self.frame == $skwalk1))
	{
		if (self.classname == "monster_skull_wizard")
			sound (self, CHAN_VOICE, "skullwiz/growl.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "skullwiz/growl2.wav", 1, ATTN_NORM);
	}
	
	if (self.classname=="monster_skull_wizard_lord" && time>self.raiseTime)
	{	//ws: lord wizards can revive dead bodies
		if (skullwiz_findcorpse()!=world)
			skullwiz_raiseinit();
	}

	delta = self.enemy.origin - self.origin;
	if (vlen(delta) < 80)		// Too close so don't ignore enemy
		self.attack_finished = time - 1; 

	if (self.frame == $skwalk1)  // Decide if he should BLINK away
	{
		if (self.classname == "monster_skull_wizard")
		{
			if (random() < .20 && self.teleportTime < time)
				skullwiz_blink();
		}
		else	// Skull Wizard BLINKS more often
		{
			if ( (random() < .30 && self.teleportTime < time) ||self.search_time<time + 1)
				skullwiz_blink();
		}
	}
	else
	{
		if (self.attack_finished > time)
			movetogoal(1.3);
		else 	
			ai_run(1.5);
	}
}

/*-----------------------------------------
	skullwiz_walk - walking his beat
  -----------------------------------------*/
void skullwiz_walk (void) [++ $skwalk1..$skwalk24]
{
	if ((random(1)<.05) && (self.frame == $skwalk1))
	{
		if (self.classname == "monster_skull_wizard")
			sound (self, CHAN_VOICE, "skullwiz/growl.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "skullwiz/growl2.wav", 1, ATTN_NORM);
	}

	ai_walk(1.3);
}

/*-----------------------------------------
	skullwiz_stand - standing and waiting
  -----------------------------------------*/
void skullwiz_stand (void) //[++ $skwait1..$skwait26]
{	//ws: vanilla idle anim is choppy, so changed
	if (self.lefty) {
		if (RewindFrame (124, 111) == AF_END)
			self.lefty = FALSE;
	}
	else {
		if (AdvanceFrame (111, 124) == AF_END)
			self.lefty = TRUE;
	}
	
	self.think = skullwiz_stand;
	thinktime self : HX_FRAME_TIME+random(0,HX_FRAME_TIME);
	
	if (random() < .5)
		ai_stand();
}


void skullwizard_init(void)
{
	if(!self.flags2&FL_SUMMONED&&!self.flags2&FL2_RESPAWN)
	{
		precache_model("models/skullwiz.mdl");
		precache_model("models/skulbook.mdl");
		precache_model("models/skulhead.mdl");
		precache_model("models/skulshot.mdl");

		if (self.classname == "monster_skull_wizard")
		{
			precache_sound("skullwiz/death.wav");
			precache_sound("skullwiz/blinkspk.wav");
			precache_sound("skullwiz/growl.wav");
			precache_sound("skullwiz/scream.wav");
			precache_sound("skullwiz/pain.wav");
		}	
		else
		{
			precache_sound("skullwiz/death2.wav");
			precache_sound("skullwiz/blnkspk2.wav");
			precache_sound("skullwiz/growl2.wav");
			precache_sound("skullwiz/scream2.wav");
			precache_sound("skullwiz/gatespk.wav");
			precache_sound("skullwiz/pain2.wav");
		}	

		precache_sound("skullwiz/gate.wav");
		precache_sound("skullwiz/blinkin.wav");
		precache_sound("skullwiz/blinkout.wav");
		precache_sound("skullwiz/push.wav");
		precache_sound("skullwiz/firemisl.wav");

		precache_spider();
	}

	setmodel(self, "models/skullwiz.mdl");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.mass = 4;
	self.mintel = 5;
	self.thingtype=THINGTYPE_FLESH;

	self.th_stand = skullwiz_stand;
	self.th_walk = skullwiz_walk;
	self.th_run = skullwiz_run;
	self.th_melee = skullwiz_melee;
	self.th_missile = skullwiz_missile_init;
	self.th_pain = skullwiz_pain;
	self.th_die = skullwiz_die;

	setsize(self, '-24 -24 0', '24 24 64');
	self.orgnl_mins = self.mins;
	self.orgnl_maxs = self.maxs;
	self.hull = HULL_PLAYER;

	self.flags(+)FL_MONSTER;
	self.yaw_speed = 10;
}

/*QUAKED monster_skull_wizard (1 0.3 0) (-24 -24 0) (24 24 64) AMBUSH
A skull wizard
-------------------------FIELDS-------------------------
none
--------------------------------------------------------
*/
void monster_skull_wizard (void)
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	skullwizard_init();
	
	if (!self.health)
		self.health = 150;
	if (!self.experience_value)
		self.experience_value = 100;
	self.max_health=self.health;
	self.init_exp_val = self.experience_value;
	self.monsterclass = CLASS_GRUNT;
	self.th_init = monster_skull_wizard;
	
	self.buff=2;
	walkmonster_start();
}

/*QUAKED monster_skull_wizard_lord (1 0.3 0) (-24 -24 0) (24 24 64) AMBUSH
A skull wizard lord
-------------------------FIELDS-------------------------
none
--------------------------------------------------------
*/
void monster_skull_wizard_lord (void)
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	skullwizard_init();
	
	if(!self.health)
		self.health = 550;				//vanilla: 650
	self.max_health=self.health;
	if (!self.experience_value)
		self.experience_value = 300;	//vanilla: 325
	self.init_exp_val = self.experience_value;
	self.monsterclass = CLASS_LEADER;
	self.skin = 1;
	self.scale = 1.20;
	self.th_init = monster_skull_wizard_lord;
	
	self.buff=1;
	walkmonster_start();
}


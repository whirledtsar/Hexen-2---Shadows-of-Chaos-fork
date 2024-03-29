/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/light.hc,v 1.2 2007-02-07 16:57:07 sezero Exp $
 */
/*
==========================================================
LIGHT.HC
MG

Lights can be toggled/faded, shot out, etc.
==========================================================
*/

float START_LOW		= 1;
float LIGHT_SOUND	= 4;		//ws: force torches to emit ambient sound
//float FL2_ONFIRE	= 4194304;	//ws: tracks whether light is toggleable

void() light_stopsound;
void() light_startsound;
void(entity light) light_changesound;

void initialize_lightstyle (void)
{
	if(self.spawnflags&START_LOW)
		if(self.lightvalue1<self.lightvalue2)
			lightstylestatic(self.style, self.lightvalue1);
		else
			lightstylestatic(self.style, self.lightvalue2);
	else
		if(self.lightvalue1<self.lightvalue2)
			lightstylestatic(self.style, self.lightvalue2);
		else
			lightstylestatic(self.style, self.lightvalue1);
}

void fadelight()
{
	self.frags+=self.cnt;
	self.light_lev+=self.frags;
	lightstylestatic(self.style, self.light_lev);
	self.count+=1;
	//dprint(ftos(self.light_lev));
	//dprint("\n");
	if(self.count/20>=self.fadespeed)
	{
		//dprint("light timed out\n");
		remove(self);
	}
	else if((self.cnt<0&&self.light_lev<=self.level)||(self.cnt>0&&self.light_lev>=self.level))
	{
		//dprint("light fade done\n");
		lightstylestatic(self.style, self.level);
		remove(self);
	}
	else
	{
		self.nextthink=time+0.05;
		self.think=fadelight;
	}
}

void lightstyle_change_think()
{
	//dprint("initializing light change\n");
	self.speed=self.lightvalue2 - self.lightvalue1;
	self.light_lev=lightstylevalue(self.style);
	if(self.light_lev==self.lightvalue1)
		self.level = self.lightvalue2;
	else if(self.light_lev==self.lightvalue2)
		self.level = self.lightvalue1;
	else if(self.speed>0)
		if(self.light_lev<self.lightvalue1+self.speed*0.5)
			self.level=self.lightvalue2;
		else
			self.level=self.lightvalue1;
	else if(self.speed<0)
		if(self.light_lev<self.lightvalue2-self.speed*0.5)
			self.level=self.lightvalue1;
		else
			self.level=self.lightvalue2;

	self.cnt=(self.level-self.light_lev)/self.fadespeed/20;
	self.think = fadelight;
	self.nextthink = time;
	/*dprint("light style # ");
	dprint(ftos(self.style));
	dprint(":\n");
	dprint("value1: ");
	dprint(ftos(self.lightvalue1));
	dprint("\n");
	dprint("value2: ");
	dprint(ftos(self.lightvalue2));
	dprint("\n");
	dprint("difference: ");
	dprint(ftos(self.speed));
	dprint("\n");
	dprint("fadespeed: ");
	dprint(ftos(self.fadespeed));
	dprint("\n");
	dprint("current light level: ");
	dprint(ftos(self.light_lev));
	dprint("\n");
	dprint("target light level: ");
	dprint(ftos(self.level));
	dprint("\n");
	dprint("luminosity interval: ");
	dprint(ftos(self.cnt));
	dprint("\n");*/
}

void lightstyle_change (entity light_targ)
{
//dprint("spawning light changer\n");
	light_changesound(light_targ);
	
	newmis=spawn();
	newmis.lightvalue1=light_targ.lightvalue1;
	newmis.lightvalue2=light_targ.lightvalue2;
	newmis.fadespeed=light_targ.fadespeed;
	newmis.style=self.style;
	newmis.think=lightstyle_change_think;
	newmis.nextthink=time;
}

void torch_death ()
{
	light_stopsound();
	lightstylestatic(self.style,0);
	chunk_death();
}

void torch_think (void)
{
float lightstate;
	lightstate=lightstylevalue(self.style);
	if(!lightstate)			//Use "off" frames
	{
		if(self.mdl)
			setmodel(self,self.mdl);
		self.drawflags(-)MLS_ABSLIGHT;
	}
	else
	{
		if(self.weaponmodel)
			setmodel(self,self.weaponmodel);
		self.drawflags(+)MLS_ABSLIGHT;
	}
	if(time>self.fadespeed)
		self.nextthink=-1;
	else
		self.nextthink=time+0.05;
	self.think=torch_think;
}

void torch_use (void)
{
	self.fadespeed=time+other.fadespeed+1;
	light_changesound(self);
	
	torch_think();
}

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_LOW
Non-displayed fading light.
Default light value is 300
Default style is 0
----------------------------------
If triggered, will toggle between lightvalue1 and lightvalue2
.lightvalue1 (default 0) 
.lightvalue2 (default 11, equivalent to 300 brightness)
Two values the light will fade-toggle between, 0 is black, 25 is brightest, 11 is equivalent to a value of 300.
.fadespeed (default 1) = How many seconds it will take to complete the desired lighting change
The light will start on at a default of the higher light value unless you turn on the startlow flag.
START_LOW = will make the light start at the lower of the lightvalues you specify (default uses brighter)

NOTE: IF YOU DON'T PLAN ON USING THE DEFAULTS, ALL LIGHTS IN THE BANK OF LIGHTS NEED THIS INFO
*/
void light()
{
	if (self.targetname == "")
	{
		remove(self);
	}
	else
	{
		if(!self.lightvalue2)
			self.lightvalue2=11;
		if(!self.fadespeed)
			self.fadespeed = 1;
		initialize_lightstyle();
	}
}

void light_sound ()
{
	if (self.owner == world) {
		remove(self);
		return;
	}
	
	sound(self, CHAN_ITEM, self.noise, self.height, self.lip);
	self.think = light_sound;
	thinktime self : self.t_length;
}

void light_startsound ()
{
	if (!self.noise || !self.t_length || !self.flags2 & FL2_ONFIRE)
		return;
	
	entity sound;
	sound = spawn();
	self.enemy = sound;
	setorigin (sound, self.origin);
	sound.owner = self;
	sound.solid = SOLID_NOT;
	sound.noise = self.noise;
	sound.height = self.height;
	sound.lip = self.lip;
	sound.t_length = self.t_length;
	sound.think = light_sound;
	thinktime sound : 0;
	
	return;
}

void light_stopsound ()
{
	if (self.flags2 & FL2_ONFIRE && self.enemy!=world) {
		sound(self.enemy, CHAN_ITEM, "misc/null.wav", 1, 1);
		self.enemy.think = SUB_Null;
		remove(self.enemy);
	}
	return;
}

void light_changesound (entity light)
{
	if (!light.spawnflags & LIGHT_SOUND)
		return;
	entity oself;
	oself = self;
	self = light;
	if (light.spawnflags & START_LOW)
		light_startsound();
	else
		light_stopsound();
	self = oself;
}

void() FireAmbient =
{
	//t_length: exact length of wav file for toggleable looping purposes
	//height: volume
	//lip: attenuation
	if (!self.spawnflags & LIGHT_SOUND)
		return;
	
	if (self.soundtype == 1) {
		self.noise = "misc/fburn_bg.wav";
		if (!self.height)
			self.height = 0.5;
		self.t_length = 2.43;
	}
	else if (self.soundtype == 2) {
		self.noise = "misc/fburn_md.wav";
		if (!self.height)
			self.height = 0.75;
		self.t_length = 2.787;
	}
	else if (self.soundtype == 3) {
		self.noise = "misc/fburn_sm.wav";
		if (!self.height)
			self.height = 1;
		if (!self.lip)
			self.lip = ATTN_NORM*0.75;
		self.t_length = 1.812;
	}
	else if (self.soundtype == 4)
		return;
	else {
		self.noise = "raven/flame1.wav";
		if (!self.height)
			self.height = 0.5;
		self.t_length = 3.39;
	}
	precache_sound (self.noise);
	precache_sound ("misc/null.wav");
	
	if (self.lip <=0)
		self.lip = ATTN_STATIC;
	else if (self.lip > ATTN_STATIC)
		self.lip = ATTN_STATIC;
	
	if (self.health>=1 || SUB_IsTargeted(self)) {
		self.flags2 = FL2_ONFIRE;	//flag that indicates this entity has a togglable sound
		if (!self.spawnflags&START_LOW)
			light_startsound();
	}
	else
		ambientsound (self.origin, self.noise, self.height, self.lip);
};

/*QUAK-ED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20) START_LOW
Short wall torch
Default light value is 200
Default style is 0
----------------------------------
If triggered, will toggle between lightvalue1 and lightvalue2
.lightvalue1 (default 0) 
.lightvalue2 (default 11, equivalent to 300 brightness)
Two values the light will fade-toggle between, 0 is black, 25 is brightest, 11 is equivalent to a value of 300.
.fadespeed (default 1) = How many seconds it will take to complete the desired lighting change
The light will start on at a default of the higher light value unless you turn on the startlow flag.
START_LOW = will make the light start at the lower of the lightvalues you specify (default uses brighter)

NOTE: IF YOU DON'T PLAN ON USING THE DEFAULTS, ALL LIGHTS IN THE BANK OF LIGHTS NEED THIS INFO
*/
void() light_torch_small_walltorch =
{
	precache_model ("models/flame.mdl");
	self.spawnflags (+) LIGHT_SOUND;
	FireAmbient ();
	if(self.targetname)
		self.use=torch_use;
	self.mdl = "models/null.spr";
	self.weaponmodel = "models/flame.mdl";

	self.abslight = .75;

	if(self.style>=32)
	{
		if(!self.lightvalue2)
			self.lightvalue2=11;
		if(!self.fadespeed)
			self.fadespeed = 1;
		initialize_lightstyle();
		self.think = torch_think;
		self.nextthink = time+1;
	}
	else
	{
		self.drawflags(+)MLS_ABSLIGHT;
		setmodel(self,self.weaponmodel);
		makestatic (self);
	}
};

/*QUAKED light_flame_large_yellow (0 1 0) (-10 -10 -12) (12 12 18) START_LOW
Large yellow flame
----------------------------------
If triggered, will toggle between lightvalue1 and lightvalue2
.lightvalue1 (default 0) 
.lightvalue2 (default 11, equivalent to 300 brightness)
Two values the light will fade-toggle between, 0 is black, 25 is brightest, 11 is equivalent to a value of 300.
.fadespeed (default 1) = How many seconds it will take to complete the desired lighting change
The light will start on at a default of the higher light value unless you turn on the startlow flag.
START_LOW = will make the light start at the lower of the lightvalues you specify (default uses brighter)

NOTE: IF YOU DON'T PLAN ON USING THE DEFAULTS, ALL LIGHTS IN THE BANK OF LIGHTS NEED THIS INFO
*/
void() light_flame_large_yellow =
{
	precache_model ("models/flame1.mdl");
	self.spawnflags (+) LIGHT_SOUND;
	FireAmbient ();
	if(self.targetname)
		self.use=torch_use;

	self.abslight = .75;

	self.mdl = "models/null.spr";
	self.weaponmodel = "models/flame1.mdl";
	if(self.style>=32)
	{
		if(!self.lightvalue2)
			self.lightvalue2=11;
		if(!self.fadespeed)
			self.fadespeed = 1;
		initialize_lightstyle();
		self.think = torch_think;
		self.nextthink = time+1;
	}
	else
	{
		self.drawflags(+)MLS_ABSLIGHT;
		setmodel(self,self.weaponmodel);
		makestatic (self);
	}
};

/*QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) START_LOW
Small yellow flame ball
----------------------------------
If triggered, will toggle between lightvalue1 and lightvalue2
.lightvalue1 (default 0) 
.lightvalue2 (default 11, equivalent to 300 brightness)
Two values the light will fade-toggle between, 0 is black, 25 is brightest, 11 is equivalent to a value of 300.
.fadespeed (default 1) = How many seconds it will take to complete the desired lighting change
The light will start on at a default of the higher light value unless you turn on the startlow flag.
START_LOW = will make the light start at the lower of the lightvalues you specify (default uses brighter)

NOTE: IF YOU DON'T PLAN ON USING THE DEFAULTS, ALL LIGHTS IN THE BANK OF LIGHTS NEED THIS INFO
*/
void() light_flame_small_yellow =
{
	precache_model ("models/flame2.mdl");
	self.spawnflags (+) LIGHT_SOUND;
	FireAmbient ();
	if(self.targetname)
		self.use=torch_use;

	self.abslight = .75;

	self.mdl = "models/null.spr";
	self.weaponmodel = "models/flame2.mdl";
	if(self.style>=32)
	{
		if(!self.lightvalue2)
			self.lightvalue2=11;
		if(!self.fadespeed)
			self.fadespeed = 1;
		initialize_lightstyle();
		self.think = torch_think;
		self.nextthink = time+1;
	}
	else
	{
		self.drawflags(+)MLS_ABSLIGHT;
		setmodel(self,self.weaponmodel);
		makestatic (self);
	}
};

/*QUAK-ED light_flame_small_white (0 1 0) (-10 -10 -40) (10 10 40) START_LOW
Small white flame ball
----------------------------------
If triggered, will toggle between lightvalue1 and lightvalue2
.lightvalue1 (default 0) 
.lightvalue2 (default 11, equivalent to 300 brightness)
Two values the light will fade-toggle between, 0 is black, 25 is brightest, 11 is equivalent to a value of 300.
.fadespeed (default 1) = How many seconds it will take to complete the desired lighting change
The light will start on at a default of the higher light value unless you turn on the startlow flag.
START_LOW = will make the light start at the lower of the lightvalues you specify (default uses brighter)

NOTE: IF YOU DON'T PLAN ON USING THE DEFAULTS, ALL LIGHTS IN THE BANK OF LIGHTS NEED THIS INFO
*/
/*
void() light_flame_small_white =
{
	precache_model ("models/flame2.mdl");
	self.spawnflags (+) LIGHT_SOUND;
	FireAmbient ();
	if(self.targetname)
		self.use=torch_use;

	self.abslight = .75;

	self.mdl = "models/null.spr";
	self.weaponmodel = "models/flame2.mdl";
	if(self.style>=32)
	{
		if(!self.lightvalue2)
			self.lightvalue2=11;
		if(!self.fadespeed)
			self.fadespeed = 1;
		initialize_lightstyle();
		self.think = torch_think;
		self.nextthink = time+1;
	}
	else
	{
		self.drawflags(+)MLS_ABSLIGHT;
		setmodel(self,self.weaponmodel);
		makestatic (self);
	}
};
*/

/*QUAKED light_gem (0 1 0) (-8 -8 -8) (8 8 8) START_LOW
A gem that displays light.
Default light value is 300
Default style is 0
----------------------------------
If triggered, will toggle between lightvalue1 and lightvalue2
.lightvalue1 (default 0) 
.lightvalue2 (default 11, equivalent to 300 brightness)
Two values the light will fade-toggle between, 0 is black, 25 is brightest, 11 is equivalent to a value of 300.
.fadespeed (default 1) = How many seconds it will take to complete the desired lighting change
The light will start on at a default of the higher light value unless you turn on the startlow flag.
START_LOW = will make the light start at the lower of the lightvalues you specify (default uses brighter)

NOTE: IF YOU DON'T PLAN ON USING THE DEFAULTS, ALL LIGHTS IN THE BANK OF LIGHTS NEED THIS INFO
*/
void() light_gem =
{
	precache_model ("models/gemlight.mdl");
	if(self.targetname)
		self.use=torch_use;
	self.mdl = "models/null.spr";
	self.weaponmodel = "models/gemlight.mdl";

	self.abslight = .75;

	if(self.style>=32)
	{
		if(!self.lightvalue2)
			self.lightvalue2=11;
		if(!self.fadespeed)
			self.fadespeed = 1;
		initialize_lightstyle();
		self.think = torch_think;
		self.nextthink = time+1;
	}
	else
	{
		self.drawflags(+)MLS_ABSLIGHT;
		setmodel(self,self.weaponmodel);
		makestatic (self);
	}
};

/*QUAKED light_newfire (0 1 0) (-10 -10 -13) (10 10 41) START_LOW HURT
Large yellow flame
----------------------------------
If triggered, will toggle between lightvalue1 and lightvalue2
.lightvalue1 (default 0) 
.lightvalue2 (default 11, equivalent to 300 brightness)
Two values the light will fade-toggle between, 0 is black, 25 is brightest, 11 is equivalent to a value of 300.
.fadespeed (default 1) = How many seconds it will take to complete the desired lighting change
The light will start on at a default of the higher light value unless you turn on the startlow flag.
START_LOW = will make the light start at the lower of the lightvalues you specify (default uses brighter)
HURT = Will hurt things that touch it.
.dmg = how much to hurt people who touch fire - damage/20th of a second.  Default = .2;

NOTE: IF YOU DON'T PLAN ON USING THE DEFAULTS, ALL LIGHTS IN THE BANK OF LIGHTS NEED THIS INFO
*/
void() light_newfire =
{
	precache_model ("models/newfire.mdl");
	/*precache_model4 ("models/newfire.mdl");	PoP stuff
	if(self.spawnflags&2)
		spawn_burnfield(self.origin);
	else
		self.dmg=0;*/
	self.spawnflags (+) LIGHT_SOUND;
	if (!self.soundtype)
		self.soundtype = 1;
	FireAmbient ();
	if(self.spawnflags&4)
		self.drawflags = self.drawflags|SCALE_ORIGIN_BOTTOM;
	if(self.targetname)
		self.use=torch_use;

//	self.abslight = .75;

	self.mdl = "models/null.spr";
	self.weaponmodel = "models/newfire.mdl";
	if(self.style>=32)
	{
		if(!self.lightvalue2)
			self.lightvalue2=11;
		if(!self.fadespeed)
			self.fadespeed = 1;
		initialize_lightstyle();
		self.think = torch_think;
		self.nextthink = time+1;
	}
	else
	{
		self.drawflags(+)DRF_TRANSLUCENT|MLS_FIREFLICKER;
//		self.drawflags(+)MLS_ABSLIGHT;
		setmodel(self,self.weaponmodel);
		if(deathmatch||teamplay)
			makestatic (self);
		else
		{
			self.solid=SOLID_NOT;
			self.movetype=MOVETYPE_NONE;
		}
	}
};

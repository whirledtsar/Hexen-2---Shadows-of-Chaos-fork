/*
 * misc_model.qc requires math.qc
 *
 * Author: Joshua Skelton joshua.skelton@gmail.com
 * Edited by: Inky 20201219 Minor changes for a better integration with my own code
 * Edited by whirledtsar in 2021 to add toggle, breakable, and solid options
 */

// Forward declarations
void() misc_model_think;
void() misc_model_toggle;

float MODEL_TRANSLUCENT = 1;
float MODEL_SOLID = 2;
float MODEL_BREAKABLE = 4;
float MODEL_STARTOFF = 8;
float MODEL_TRIGGERBREAK = 16;
float MODEL_SCALETOP = 32;
float MODEL_SCALECENTER = 64;
float MODEL_SCALEZONLY = 128;
float MODEL_PUSHABLE = 262144;
float MODEL_SCALEXYONLY = 524288;

/*QUAKED custom_model (0 0.5 0.8) (-8 -8 -8) (8 8 8)
{
	model ({"path" : mdl, "skin" : skin, "frame": frame});
}
An entity for displaying models. A frame range can be given to animate the
model.

model:   The model to display. Can be of type mdl, bsp, or spr.
frame:   The frame to display (static models).
button0: Can be used to offset the animation.
button1: The starting frame of the animation.
button2: The last frame of the animation.
speed:   How long the animation frames last; default 0.05
wait:	 Delay before beginning animation
*/
void() misc_model = {
	if (!self.model || self.model=="")
		objerror("misc_model: No model");
	
	precache_model(self.model);
	setmodel(self, self.model);
	if (!self.orgnl_mins)
		self.orgnl_mins = '-8 -8 0';
	if (!self.orgnl_maxs)
		self.orgnl_maxs = '8 8 8';
	self.mins = self.orgnl_mins;
	self.maxs = self.orgnl_maxs;
	setsize(self, self.orgnl_mins, self.orgnl_maxs);
	
	if (self.spawnflags&MODEL_TRIGGERBREAK)
		self.spawnflags(+)MODEL_BREAKABLE;
	
	if (self.spawnflags&MODEL_BREAKABLE || self.spawnflags&MODEL_PUSHABLE)
		self.spawnflags(+)MODEL_SOLID;
	
	if (self.spawnflags&MODEL_SOLID) {
		if (!self.health)
			self.health = 1;		//necessary for player to walk on top without sliding
		
		if (self.spawnflags&MODEL_PUSHABLE) {
			self.solid = SOLID_SLIDEBOX;
			self.movetype = MOVETYPE_PUSHPULL;
			self.flags(+)FL_PUSH;
			self.touch = obj_push;
			if (!self.mass)
				self.mass = 5;
		}
		else
			self.solid = SOLID_BBOX;
	}

	if(self.abslight)
		self.drawflags(+)MLS_ABSLIGHT;
	
	if (self.spawnflags&MODEL_TRANSLUCENT)
		self.drawflags(+)DRF_TRANSLUCENT;
	
	if (self.spawnflags&MODEL_SCALETOP)
		self.drawflags(+)SCALE_ORIGIN_TOP;
	else if (!self.spawnflags&MODEL_SCALECENTER)
		self.drawflags(+)SCALE_ORIGIN_BOTTOM;
	
	if (self.spawnflags&MODEL_SCALEXYONLY)
		self.drawflags(+)SCALE_TYPE_XYONLY;
	else if (self.spawnflags&MODEL_SCALEZONLY)
		self.drawflags(+)SCALE_TYPE_ZONLY;
	
	self.mdl = self.model;
	self.takedamage = TRUE;		//not really, but necessary for damage/impact particles
	self.aflag = TRUE;			//model is on or off
	
	if (self.spawnflags&MODEL_BREAKABLE) {
		if (self.gibmdl1)
			precache_model(self.gibmdl1);
		if (self.gibmdl2)
			precache_model(self.gibmdl2);
		if (self.gibmdl3)
			precache_model(self.gibmdl3);
		self.max_health = self.health;
		self.th_die = chunk_death;
	}
	
	self.use = misc_model_toggle;
	
	if (self.spawnflags&MODEL_STARTOFF) {
		self.solid = SOLID_NOT;
		setmodel(self,"models/null.spr");
		self.effects(+)EF_NODRAW;
		self.aflag = FALSE;
		self.takedamage = FALSE;
		self.think = SUB_Null;
		self.nextthink = time + 99999;
	}
	else if (self.spawnflags&MODEL_TRIGGERBREAK)
		self.use = self.th_die;
	
	if (!self.frame) self.frame = self.button1;

	// Only animate if given a frame range
	if (!self.button2) return;
	if (self.button0) self.frame = self.button0;
	if (!self.speed) self.speed = 0.05; // Default animation speed
	
	self.check_ok = TRUE;	//indicates that this model is animated
	
	if (self.aflag) {
		self.nextthink = time + self.wait;
		self.think = misc_model_think;
	}
};

/*
 * misc_model_think
 *
 * Handles animation for misc_model entity.
 */
void() misc_model_think = {
	self.nextthink = time + fabs(self.speed);
	self.frame = self.frame + sign(self.speed);
	self.frame = wrap(self.frame, self.button1, self.button2);
};

void misc_model_checkblocking ()
{
	if (!self.controller) {
		remove(self);
		return;
	}
	
	entity checker;
	entity blocking;
	checker = self;
	self = self.controller;
	blocking = self.owner;
	
	self.owner = world;		//temporary so tracearea works
	tracearea (self.origin, self.origin+('0 0 1'*self.maxs_z), self.orgnl_mins, self.orgnl_maxs, FALSE, self);
	
	if (trace_ent==blocking) {	//entity is still within our hitbox, try again next frame
		self.owner = blocking;
		
		self = checker;
		self.think = misc_model_checkblocking;
		thinktime self : HX_FRAME_TIME;
		return;
	}
	
	self.owner = world;		//model will now be solid to them
	self = checker;
	remove(self);
}

void misc_model_toggle ()
{
	if (!self.aflag)
	{
		if (self.spawnflags&MODEL_SOLID) {
			tracearea (self.origin, self.origin+('0 0 1'*self.maxs_z), self.orgnl_mins*1.25, self.orgnl_maxs*1.25, FALSE, self);
			if (trace_ent && trace_ent.flags2&FL_ALIVE && (trace_ent.flags&FL_CLIENT || trace_ent.flags&FL_MONSTER)) {
				self.owner = trace_ent;	//makes model nonsolid to the entity inside out hitbox
				
				entity checker;
				checker = spawn();
				checker.controller = self;
				checker.think = misc_model_checkblocking;
				thinktime checker : HX_FRAME_TIME;
			}
			
			if (self.spawnflags&MODEL_PUSHABLE)
				self.solid = SOLID_SLIDEBOX;
			else
				self.solid = SOLID_BBOX;
		}
		setmodel(self, self.mdl);
		setsize(self, self.orgnl_mins, self.orgnl_maxs);
		setorigin(self, self.origin);
		self.effects(-)EF_NODRAW;
		self.aflag = TRUE;
		self.takedamage = TRUE;
		if (self.spawnflags&MODEL_TRIGGERBREAK)
			self.use = self.th_die;
		if (self.check_ok)	//if animated model
		{
			if (self.button0)
				self.frame = self.button0;
			else
				self.frame = self.button1;
			self.nextthink = time + self.wait;
			self.think = misc_model_think;
		}
	}
	else
	{
		self.solid = SOLID_NOT;
		setmodel(self,"models/null.spr");
		self.effects(+)EF_NODRAW;
		self.aflag = FALSE;
		self.takedamage = FALSE;
		self.think = SUB_Null;
		self.nextthink = time + 99999;
		self.use = misc_model_toggle;
	}
}

void custom_model ()
{ 
	self.classname = "misc_model";
	misc_model();
}

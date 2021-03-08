/*
 * misc_model.qc requires math.qc
 *
 * Author: Joshua Skelton joshua.skelton@gmail.com
 * Edited by: Inky 20201219 Minor changes for a better integration with my own code
 * Edited by whirledtsar in 2021 to add toggle functionality and solid bounding box
 */

// Forward declarations
void() misc_model_think;
void() misc_model_toggle;

float MODEL_NONSOLID = 2;
float MODEL_BREAKABLE = 4;
float MODEL_STARTOFF = 8;
float MODEL_TRIGGERBREAK = 16;

/*QUAKED custom_model (0 0.5 0.8) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
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
void() custom_model = {
    precache_model(self.model);
    setmodel(self, self.model);
	self.mins = self.orgnl_mins;
	self.maxs = self.orgnl_maxs;
	setsize(self, self.orgnl_mins, self.orgnl_maxs);
	
	if (!self.spawnflags&MODEL_NONSOLID)
		self.solid = SOLID_BBOX;
	
	if (self.spawnflags&MODEL_TRIGGERBREAK)
		self.spawnflags(+)MODEL_BREAKABLE;
	
	if (self.spawnflags&MODEL_BREAKABLE) {
		self.max_health = self.health;
		self.th_die = chunk_death;
	}

	if(self.abslight)
		self.drawflags(+)MLS_ABSLIGHT;
	
	self.mdl = self.model;
	self.takedamage = TRUE;		//not really, but necessary for damage/impact particles
	
	if (self.spawnflags&MODEL_STARTOFF) {
		self.solid = SOLID_NOT;
		setmodel(self,"models/null.spr");
		self.effects(+)EF_NODRAW;
		self.aflag = FALSE;
		self.use = misc_model_toggle;
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

void misc_model_toggle ()
{
	if (!self.aflag)
	{
		if (!self.spawnflags&MODEL_NONSOLID)
			self.solid = SOLID_BBOX;
		setmodel(self, self.mdl);
		setsize(self, self.orgnl_mins, self.orgnl_maxs);
		setorigin(self, self.origin);
		self.effects(-)EF_NODRAW;
		self.aflag = TRUE;
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
		self.think = SUB_Null;
		self.nextthink = time + 99999;
		self.use = misc_model_toggle;
	}
}

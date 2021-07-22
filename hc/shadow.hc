
/********************
misc_shadowcontroller

Controls switchable shadows on any bmodel entity (except doors).
Target entity must have set _switchableshadow set to 1, and either _shadow, _shadowself/_selfshadow, or _shadowworldonly also set to 1.
speed: Controls the time in seconds it takes to fade in/out. Default is 0.5, and setting it to -1 disables fading.
speed2: Same as 'speed' but for the fade out animation. If unset it's the same value as 'speed'.
spawnflag 1: target shadow starts as disabled
*********************/

string(float num) lightstyle_fade_lookup;

float SHADOWCONTROLLER_STARTOFF = 1;

void() shadow_fade_out =
{
	if (self.count < 0)
		self.count = 0;
	if (self.count > 12)
		self.count = 12;

	//dprint(ftos(self.count));dprint("\n");

	lightstyle(self.switchshadstyle, lightstyle_fade_lookup(self.count));
	self.count = self.count + self.dmg;
	if (self.count > 12) {
		self.think = SUB_Null;
		if (!self.enemy)
			remove(self);
		return;
	}

	self.think = shadow_fade_out;
	self.nextthink = time + self.delay;
};

void() shadow_fade_in =
{
	if (self.count < 0)
		self.count = 0;
	if (self.count > 12)
		self.count = 12;

	//dprint(ftos(self.count));dprint("\n");

	lightstyle(self.switchshadstyle, lightstyle_fade_lookup(self.count));
	self.count = self.count - self.dmg;
	if (self.count < 0) {
		self.think = SUB_Null;
		if (!self.enemy)
			remove(self);
		return;
	}

	self.think = shadow_fade_in;
	self.nextthink = time + self.delay;
};

void(float speed) misc_shadowcontroller_setsteps = {
	// self.delay -> time between steps
	// self.dmg -> step size
	if(speed >= 0.24) {
		self.delay = (speed/12);
		self.dmg = 1;
	}
	else if(speed >= 0.12) {
		self.delay = (speed/6);
		self.dmg = 2;
	}
	else if(speed >= 0.06) {
		self.delay = (speed/3);
		self.dmg = 4;
	}
	else if(speed >= 0.04) {
		self.delay = (speed/2);
		self.dmg = 6;
	}
	else {
		self.delay = 0;
		self.dmg = 12;
	}
}

void() misc_shadowcontroller_use = {

	if(self.shadowoff) {
		dprint("Fade in:\n");

		misc_shadowcontroller_setsteps(self.speed);

		shadow_fade_in();

		self.shadowoff = 0;
	}
	else {
		dprint("Fade out:\n");

		misc_shadowcontroller_setsteps(self.speed2);

		shadow_fade_out();

		self.shadowoff = 1;
	}
}

void() misc_shadowcontroller ={
	entity t1;

	// doesn't search for a target if switchshadstyle is already set
	// used for built-in shadow controllers
	if(!self.switchshadstyle) {
		t1 = find(world, targetname, self.target);

		// we need to find only the first target entity with switchable shadows set, since shadow lightstyles are bound by targetname
		while(t1 != world && !t1.switchshadstyle) {
			t1 = find(t1, targetname, self.target);
		}

		if(t1 == world) {
			dprint("*misc_shadowcontroller* _switchableshadow not set in target ");dprint(self.target);dprint("\n");
			return;
		}
		
		self.enemy = t1;
		self.switchshadstyle = t1.switchshadstyle;
		if (!self.speed && t1.switchshadspeed)
			self.speed = t1.switchshadspeed;
		if (!self.speed2 && t1.switchshadspeed2)
			self.speed2 = t1.switchshadspeed2;
	}

	if(!self.speed) self.speed = 0.5;
	if(!self.speed2) self.speed2 = self.speed;

	if(self.spawnflags & SHADOWCONTROLLER_STARTOFF) {
		lightstyle(self.switchshadstyle, "m");

		self.shadowoff = 1;
		self.count = 12;

		misc_shadowcontroller_setsteps(self.speed2);
	}
	else {
		lightstyle(self.switchshadstyle, "a");
		self.shadowoff = 0;
		self.count = 0;
		misc_shadowcontroller_setsteps(self.speed);
	}

	self.use = misc_shadowcontroller_use;
}

/*==========
lightstyle_fade_lookup
==========*/
string(float num) lightstyle_fade_lookup =
{
	switch (num)
	{
		case 0:
			return "a";
			break;
		case 1:
			return "b";
			break;
		case 2:
			return "c";
			break;
		case 3:
			return "d";
			break;
		case 4:
			return "e";
			break;
		case 5:
			return "f";
			break;
		case 6:
			return "g";
			break;
		case 7:
			return "h";
			break;
		case 8:
			return "i";
			break;
		case 9:
			return "j";
			break;
		case 10:
			return "k";
			break;
		case 11:
			return "l";
			break;
		case 12:
			return "m";
			break;
		default:
			error("count out of range\n");
			break;
	}
};

void spawn_shadowcontroller()
{
entity shadow, oldself;
	shadow = spawn();

	self.shadowcontroller = shadow;

	shadow.classname = "misc_shadowcontroller";
	shadow.switchshadstyle = self.switchshadstyle;
	if (!self.switchshadspeed) {
		if (self.classname=="door" && self.spawnflags&DOOR_NORMAL)
			shadow.speed = vlen(self.pos2 - self.pos1) / self.speed;
		else if (self.classname=="plat")
			shadow.speed = vlen(self.pos2 - self.pos1) / self.speed;
		else if (self.classname=="breakable_brush")
			shadow.speed = 0.25;
	}
	
	if ((self.classname=="door" || self.classname=="door_rotating") && self.spawnflags&DOOR_START_OPEN)
		shadow.spawnflags = 1;
	else if (self.classname=="plat" && self.targetname && self.targetname!="")
		shadow.spawnflags = 1;
	else
		shadow.spawnflags = 0;
	
	shadow.enemy = self;

	oldself = self;

	self = shadow;
	misc_shadowcontroller();

	self = oldself;
}

/*****************
func_shadow
An invisible bmodel that only casts a shadow.
******************/

void() func_shadow =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.effects = EF_NODRAW;
	
	self.modelindex = 0;
	self.model = "";
	
	// creates a shadow controller entity for the door if it has switchable shadows
	if(self.switchshadstyle) {
		//spawn_shadowcontroller();
	}
};

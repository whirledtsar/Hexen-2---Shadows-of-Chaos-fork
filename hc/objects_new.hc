float MIST_STARTOFF = 2;

float IS_SKELETON = 2;

float PORTAL_CLOSED = 2;

float WATER_OFF = 2;
float WATER_TRANS = 4;
float WATER_FULLBR = 8;
float WATER_SCALEZ = 16;
float WATER_SCALEXY = 32;
float WATER_TOPORIGIN = 64;
float WATER_SILENT = 128;

.float modeltype;

void	star_sparkle1 () [++ 0 .. 19] {}

void()	portal_spin1	=[	0,	portal_spin2	] {thinktime self : 0.1;};	//ws: halved because 20 fps is too fast for the animation
void()	portal_spin2	=[	1,	portal_spin3	] {thinktime self : 0.1;};
void()	portal_spin3	=[	2,	portal_spin4	] {thinktime self : 0.1;};
void()	portal_spin4	=[	3,	portal_spin5	] {thinktime self : 0.1;};
void()	portal_spin5	=[	4,	portal_spin6	] {thinktime self : 0.1;};
void()	portal_spin6	=[	5,	portal_spin7	] {thinktime self : 0.1;};
void()	portal_spin7	=[	6,	portal_spin8	] {thinktime self : 0.1;};
void()	portal_spin8	=[	7,	portal_spin9	] {thinktime self : 0.1;};
void()	portal_spin9	=[	8,	portal_spin1	] {thinktime self : 0.1;};

void()	portal_anim1	=[	26,	portal_anim2	] {};
void()	portal_anim2	=[	27,	portal_anim3	] {};
void()	portal_anim3	=[	28,	portal_anim4	] {};
void()	portal_anim4	=[	29,	portal_anim5	] {};
void()	portal_anim5	=[	30,	portal_anim6	] {};
void()	portal_anim6	=[	31,	portal_anim7	] {};
void()	portal_anim7	=[	32,	portal_anim8	] {};
void()	portal_anim8	=[	33,	portal_anim9	] {};
void()	portal_anim9	=[	34,	portal_anim10	] {};
void()	portal_anim10	=[	35,	portal_anim11	] {};
void()	portal_anim11	=[	36,	portal_anim12	] {};
void()	portal_anim12	=[	37,	portal_anim13	] {};
void()	portal_anim13	=[	38,	portal_anim14	] {};
void()	portal_anim14	=[	39,	portal_anim15	] {};
void()	portal_anim15	=[	40,	portal_anim16	] {};
void()	portal_anim16	=[	41,	portal_anim17	] {};
void()	portal_anim17	=[	42,	portal_anim18	] {};
void()	portal_anim18	=[	43,	portal_anim19	] {};
void()	portal_anim19	=[	44,	portal_anim20	] {};
void()	portal_anim20	=[	45,	portal_anim21	] {};
void()	portal_anim21	=[	46,	portal_anim22	] {};
void()	portal_anim22	=[	47,	portal_anim23	] {};
void()	portal_anim23	=[	48,	portal_anim24	] {};
void()	portal_anim24	=[	49,	portal_anim1	] {};

void()	portal_close1	=[	25,	portal_close2	] {};
void()	portal_close2	=[	24,	portal_close3	] {};
void()	portal_close3	=[	23,	portal_close4	] {};
void()	portal_close4	=[	22,	portal_close5	] {};
void()	portal_close5	=[	21,	portal_close6	] {};
void()	portal_close6	=[	20,	portal_close7	] {};
void()	portal_close7	=[	19,	portal_close8	] {};
void()	portal_close8	=[	18,	portal_close9	] {};
void()	portal_close9	=[	17,	portal_close10	] {};
void()	portal_close10	=[	16,	portal_close11	] {};
void()	portal_close11	=[	15,	portal_close12	] {};
void()	portal_close12	=[	14,	portal_close13	] {};
void()	portal_close13	=[	13,	portal_close14	] {};
void()	portal_close14	=[	12,	portal_close15	] {};
void()	portal_close15	=[	11,	portal_close16	] {};
void()	portal_close16	=[	10,	portal_close17	] {};
void()	portal_close17	=[	9,	portal_close18	] {};
void()	portal_close18	=[	8,	portal_close19	] {};
void()	portal_close19	=[	7,	portal_close20	] {};
void()	portal_close20	=[	6,	portal_close21	] {};
void()	portal_close21	=[	5,	portal_close22	] {};
void()	portal_close22	=[	4,	portal_close23	] {};
void()	portal_close23	=[	3,	portal_close24	] {};
void()	portal_close24	=[	2,	portal_close25	] {};
void()	portal_close25	=[	1,	portal_close26	] {};
void()	portal_close26	=[	0,	portal_close27	] {};
void()	portal_close27	=[	50,	portal_close27	] {};

void()	portal_open1	=[	0,	portal_open2	] {};
void()	portal_open2	=[	1,	portal_open3	] {};
void()	portal_open3	=[	2,	portal_open4	] {};
void()	portal_open4	=[	3,	portal_open5	] {};
void()	portal_open5	=[	4,	portal_open6	] {};
void()	portal_open6	=[	5,	portal_open7	] {};
void()	portal_open7	=[	6,	portal_open8	] {};
void()	portal_open8	=[	7,	portal_open9	] {};
void()	portal_open9	=[	8,	portal_open10	] {};
void()	portal_open10	=[	9,	portal_open11	] {};
void()	portal_open11	=[	10,	portal_open12	] {};
void()	portal_open12	=[	11,	portal_open13	] {};
void()	portal_open13	=[	12,	portal_open14	] {};
void()	portal_open14	=[	13,	portal_open15	] {};
void()	portal_open15	=[	14,	portal_open16	] {};
void()	portal_open16	=[	15,	portal_open17	] {};
void()	portal_open17	=[	16,	portal_open18	] {};
void()	portal_open18	=[	17,	portal_open19	] {};
void()	portal_open19	=[	18,	portal_open20	] {};
void()	portal_open20	=[	19,	portal_open21	] {};
void()	portal_open21	=[	20,	portal_open22	] {};
void()	portal_open22	=[	21,	portal_open23	] {};
void()	portal_open23	=[	22,	portal_open24	] {};
void()	portal_open24	=[	23,	portal_open25	] {};
void()	portal_open25	=[	24,	portal_anim1	] {};

void water_fall () [++ 41 .. 66]
{
	if (time > self.attack_finished && !self.spawnflags&WATER_SILENT) {
		sound (self, CHAN_ITEM, "fx/wfall.wav", 1, ATTN_NORM);
		self.attack_finished = time + 4.591;
	}
	self.think = water_fall;
	thinktime self : self.wait;
}

void water_start () [++ 0 .. 25]
{
	if (self.frame <= 1) {
		self.think = water_start;
		setmodel(self, self.mdl);
	}
	else if (self.frame==3 && !self.spawnflags&WATER_SILENT)
		sound (self, CHAN_ITEM, "fx/wfstart.wav", 1, ATTN_NORM);
	else if (self.frame == 25)
		self.think = water_fall;
	
	thinktime self : self.wait;
}

void water_stop () [++ 26 .. 40]
{
	self.think = water_stop;
	if (self.frame==26 && !self.spawnflags&WATER_SILENT)
		sound (self, CHAN_ITEM, "fx/wfend.wav", 1, ATTN_NORM);
	if (self.frame >= 40) {
		self.think = SUB_Null;
		self.nextthink = -1;
	}
	
	thinktime self : self.wait;
}

void()	corpse_swing1	=[	0,	corpse_swing2	] {
	self.th_save = self.th_pain;
	self.th_pain = SUB_Null;
};
void()	corpse_swing2	=[	1,	corpse_swing3	] {};
void()	corpse_swing3	=[	2,	corpse_swing4	] {};
void()	corpse_swing4	=[	3,	corpse_swing5	] {};
void()	corpse_swing5	=[	4,	corpse_swing6	] {};
void()	corpse_swing6	=[	5,	corpse_swing7	] {};
void()	corpse_swing7	=[	6,	corpse_swing8	] {};
void()	corpse_swing8	=[	7,	corpse_swing9	] {};
void()	corpse_swing9	=[	8,	corpse_swing10	] {};
void()	corpse_swing10	=[	9,	corpse_swing11	] {};
void()	corpse_swing11	=[	10,	corpse_swing12	] {};
void()	corpse_swing12	=[	11,	corpse_swing13	] {};
void()	corpse_swing13	=[	12,	corpse_swing14	] {};
void()	corpse_swing14	=[	13,	corpse_idle1	] {
	self.th_pain = self.th_save;
};

void() corpse_idle1	=[	13,	corpse_idle1	] {};

void() object_start =
{
	self.takedamage=DAMAGE_YES;
	self.flags2(+)FL_ALIVE;
	
	if (self.scale)
		ScaleBoundingBox (self.scale, self, 0);
	
	if (self.th_die)
		self.use = self.th_die;
	
	if (self.th_stand)
		self.th_stand ();
};

void() obj_hang_corpse =
{
	self.solid = SOLID_BBOX;
	if (self.spawnflags & IS_SKELETON)
	{
		precache_model ("models/hangskel.mdl");
		setmodel (self, "models/hangskel.mdl");
		self.thingtype=THINGTYPE_BONE;
		self.th_pain = SUB_Null;
	}
	else
	{
		precache_model ("models/hangass.mdl");
		setmodel (self, "models/hangass.mdl");
		self.thingtype=THINGTYPE_FLESH;
		self.th_pain = corpse_swing1;
		self.th_stand = corpse_idle1;
	}

	setsize (self, '-13 -13 -7', '13 13 25');
	self.health = 45;
	
	self.th_die = chunk_death;
	
	self.netname="hanged";
	
	object_start();
};

void() obj_skeleton_body =
{
	precache_model ("models/skeleton1.mdl");
	//precache_sound ("fx/bonebrk.wav");

	self.solid = SOLID_BBOX;

	setmodel (self, "models/skeleton1.mdl");
	self.thingtype=THINGTYPE_BONE;

	setsize (self, '-29 -29 0', '29 29 8');
	self.health = 30;
	
	self.th_die = chunk_death;
	self.netname="skeleton";
	
	self.flags (+) FL_FLY;
	
	object_start();
};

void() misc_portal =
{
	precache_model ("models/port.spr");
	self.solid = SOLID_NOT;
	self.takedamage=DAMAGE_YES;

	setmodel (self, "models/port.spr");
	self.th_stand = portal_spin1;
	self.th_stand();
	
	self.netname="portal";
};

void() misc_portal_big =
{
	//precache_model ("models/portal.mdl");
	precache_model ("models/telefx.spr");
	self.solid = SOLID_NOT;
	self.takedamage=DAMAGE_YES;

	setmodel (self, "models/telefx.spr");
	if (self.spawnflags & PORTAL_CLOSED)
		self.th_stand = portal_close26;
	else
		self.th_stand = portal_anim1;
	if (self.targetname)
		if (self.spawnflags & PORTAL_CLOSED)
			self.use = portal_open1;
	else
		self.use = portal_close1;
	self.flags (+) FL_FLY;
	self.th_stand();
	
	self.netname="portalbig";
};

void() misc_starwall =
{
	precache_model ("models/magicb.spr");
	setmodel (self, "models/magicb.spr");
	
	self.th_stand = star_sparkle1;
	self.netname="magic barrier";
	self.flags (+) FL_FLY;
	self.th_stand();
	if (self.targetname)
		self.use = SUB_Remove;
};

void() misc_waterfall =
{
	precache_sound ("fx/wfstart.wav");
	precache_sound ("fx/wfall.wav");
	precache_sound ("fx/wfend.wav");
	
	if (self.modeltype == 1)
		self.mdl = "models/waterfall2.mdl";
	else
		self.mdl = "models/waterfall.mdl";
	
	precache_model(self.mdl);
	setmodel (self, self.mdl);
	
	setsize (self, '-32 -32 -184', '32 32 128');
	
	self.netname="waterfall";
	self.flags (+) FL_FLY;
	if (!self.wait)
		self.wait = HX_FRAME_TIME;
	
	if (self.spawnflags & WATER_TRANS)
		self.drawflags (+) DRF_TRANSLUCENT;
	else if (self.spawnflags & WATER_FULLBR || self.abslight) {
		//self.drawflags (+) MLS_FULLBRIGHT;
		self.drawflags (+) MLS_ABSLIGHT;
		if (!self.abslight)
			self.abslight = 1.0;
	}
	
	if (self.spawnflags & WATER_TOPORIGIN)
		self.drawflags (+) SCALE_ORIGIN_TOP;
	if (self.spawnflags & WATER_SCALEXY) {
		self.drawflags (+) SCALE_TYPE_XYONLY;
		self.mins_x *= self.scale;
		self.mins_y *= self.scale;
		self.maxs_x *= self.scale;
		self.maxs_y *= self.scale;
		setsize (self, self.mins, self.maxs);
	}
	else if (self.spawnflags & WATER_SCALEZ) {
		self.drawflags (+) SCALE_TYPE_ZONLY;
		self.mins_z *= self.scale;
		if (!self.spawnflags & WATER_TOPORIGIN)
			self.maxs_z *= self.scale;
		setsize (self, self.mins, self.maxs);
	}
	else {	//scaled from center
		self.mins *= self.scale;
		self.maxs *= self.scale;
		setsize (self, self.mins, self.maxs);
	}
	
	if (self.targetname)
	{
		if (self.spawnflags & WATER_OFF)
			self.use = water_start;
		else	
			self.use = water_stop;
	}
	
	if (self.spawnflags & WATER_OFF)
	{
		setmodel (self, "");
		self.th_stand = SUB_Null;
	}
	else
		self.th_stand = water_fall;
	
	self.th_stand ();
}

string fog_sprites[3] = {"models/fog.spr", "models/fog2.spr", "models/fog3.spr"};

void CreateFog (vector org)
{
entity new;
float type;
	type = random(-0.5,2.5);
	if (type>2)
		type=2;
	else if (type<0)
		type=0;
	else
		type = rint(type);
	
	new = spawn();
	setorigin (new, org);
	setmodel (new, fog_sprites[type]);
	setsize (new, '0 0 0', '0 0 0');
	
	new.movetype = MOVETYPE_FLY;
	new.solid = SOLID_NOT;
	new.drawflags(+)DRF_TRANSLUCENT;
	new.frame=rint(random(0,4));
	new.think = SUB_Remove;
	thinktime new : random(1.5,3.5);
	
	new.velocity_x = random(-30,30);
	new.velocity_y = random(-30,30);
	new.velocity_z = random(-6,8);
}

void mist_spawn ()
{
vector org;
	makevectors(self.angles);
	org = (self.absmin+self.absmax)*0.5;
	if (random()<0.5)
		self.lefty*=(-1);
	org += (self.lefty * v_forward*random(self.t_width));
	if (random()<0.5)
		self.lefty*=(-1);
	org += (self.lefty * v_right*random(self.t_width));
	CreateFog(org);
	
	self.think = mist_spawn;
	thinktime self : random(self.wait,self.wait*2);
}

void fog_loop () [++ 0 .. 4]
{
	self.think = fog_loop;
	thinktime self : 0.15;
}

void() misc_mist
{
	float type;
	type = random(-0.5,2.5);
	if (type>2)
		type=2;
	else if (type<0)
		type=0;
	else
		type = rint(type);
	precache_model(fog_sprites[type]);
	setmodel (self, fog_sprites[type]);
	
	self.drawflags (+) DRF_TRANSLUCENT;
	
	self.netname="fog";
	self.flags (+) FL_FLY;
	self.think = fog_loop;
	thinktime self : 0.1;
	if (self.targetname)
		self.use = SUB_Remove;
};

void() misc_mistgen
{
	if (!self.t_width)		//spawning area
		self.t_width=30;
	if (!self.wait)
		self.wait=0.25;		//min delay between fog spawns
	self.lefty = 1;
	
	self.th_stand = mist_spawn;
	self.netname = "fog generator";
	
	if (self.targetname)
	{
		if (self.spawnflags & MIST_STARTOFF)
			self.use = mist_spawn;
		else
		{
			self.use = SUB_Remove;
			self.th_stand();
		}
	}
	else
		self.th_stand();
};

void() obj_treecluster
{
	self.solid = SOLID_NOT;
	precache_model ("models/trees.mdl");
	setmodel (self, "models/trees.mdl");
	if (self.targetname)
		self.use = SUB_Remove;
}

void() obj_treelarge
{
	self.solid = SOLID_NOT;
	precache_model ("models/treebig.mdl");
	setmodel (self, "models/treebig.mdl");
	if (self.targetname)
		self.use = SUB_Remove;
}

void fire_large_loop ()
{
	if (time<self.counter && self.flags2&FL2_ONFIRE) {
		sound (self, CHAN_ITEM, self.noise, self.height, self.lip);
		self.counter = time+self.t_length;
	}
	CreateWhiteSmoke(self.origin + '0 0 112','0 0 8',HX_FRAME_TIME * 2);
	
	thinktime self : 0.5+random(0.5);
}

void() light_fire_large
{
	precache_model ("models/flamelrg.spr");
	setmodel (self, "models/flamelrg.spr");
	self.drawflags(+)DRF_TRANSLUCENT;
	
	if (self.soundtype == 0) {
		self.noise = "misc/fburn_bg.wav";
		if (!self.height)
			self.height = 0.75;
		self.t_length = 2.43;
	}
	else if (self.soundtype == 1) {
		self.noise = "raven/flame1.wav";
		if (!self.height)
			self.height = 0.25;
		self.t_length = 3.39;
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
			self.lip = ATTN_NORM;
		self.t_length = 1.812;
	}
	else if (self.soundtype == 4)
		self.noise = "";
	
	if (self.noise&&self.noise!="")
		precache_sound(self.noise);
	
	if (!self.lip || self.lip <=0 || self.lip > ATTN_STATIC)
		self.lip = ATTN_STATIC;
	
	self.think = fire_large_loop;
	thinktime self : HX_FRAME_TIME;
	
	if (self.targetname) {
		self.flags2 (+) FL2_ONFIRE;
		self.use = SUB_Remove;
	}
	else
		ambientsound(self.origin, self.noise, self.height, self.lip);
}

/*void() misc_stream =
{
	precache_model ("models/Stream1.mdl");
	precache_model ("models/Stream2.mdl");
	setmodel (self, "models/Stream1.mdl");
	
	if (self.spawnflags & ANGLED_STREAM)
		setmodel (self, "models/Stream2.mdl");
	
	self.th_stand = water_fall1;
	self.netname="river stream";
	self.flags (+) FL_FLY;
	self.th_stand();
	
	if (self.targetname)
	{
		//if (self.spawnflags & WATER_OFF)
		//{
		if (self.th_stand == water_fall1)
			self.th_stand = water_idle1;
			self.use = water_start1;
		//}
	}
	
};

*/

void() obj_mummy =
{
	self.solid = SOLID_NOT;		//use invisible breakable for collision instead of bounding box, because bounding boxes won't rotate to match his rectangular shape
	precache_model ("models/misc_mum.mdl");
	setmodel (self, "models/misc_mum.mdl");
	/*
	self.solid = SOLID_BBOX;
	setsize (self, '-10 -40 0', '10 40 12');
	self.takedamage = DAMAGE_YES;
	self.thingtype = THINGTYPE_BONE;
	self.th_die = chunk_death;
	if (!self.health)
		self.health = 50;
	if (self.targetname)
		self.use = SUB_Remove;
	
	if (!(self.angles_y == 0) && !(self.angles_y == 180)) // Facing north/south
	{
		self.orgnl_mins = self.mins;
		self.orgnl_maxs = self.maxs;
		
		self.mins_x = self.orgnl_mins_y;
		self.mins_y = self.orgnl_mins_x;
		
		self.maxs_x = self.orgnl_maxs_y;
		self.maxs_y = self.orgnl_maxs_x;
	}
	setsize (self, self.mins, self.maxs);
	*/
}
/*
void() obj_statue_armor =
{
	precache_model("models/statue_armor");
	CreateEntityNew(self, ENT_STATUE_ARMOR, "models/statue_armor", SUB_Null);
	self.touch	= obj_push;
	self.flags	(+) FL_PUSH;
}*/

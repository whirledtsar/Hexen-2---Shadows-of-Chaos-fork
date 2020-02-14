
float IS_SKELETON = 2;

float PORTAL_CLOSED = 2;

float WATER_OFF = 2;

float WATER_TRANS = 4;

float WATER_FULLBR = 8;

.float modeltype;

void()	fog_loop1	=[	0,	fog_loop2	] {};
void()	fog_loop2	=[	0,	fog_loop3	] {};
void()	fog_loop3	=[	1,	fog_loop4	] {};
void()	fog_loop4	=[	1,	fog_loop5	] {};
void()	fog_loop5	=[	2,	fog_loop6	] {};
void()	fog_loop6	=[	2,	fog_loop7	] {};
void()	fog_loop7	=[	3,	fog_loop8	] {};
void()	fog_loop8	=[	3,	fog_loop9	] {};
void()	fog_loop9	=[	4,	fog_loop10	] {};
void()	fog_loop10	=[	4,	fog_loop1	] {};

void()	fire_burn1	=[	0,	fire_burn2	] {sound (self, CHAN_ITEM, "misc/fburn_sm.wav", 1, ATTN_NORM);};
void()	fire_burn2	=[	1,	fire_burn3	] {};
void()	fire_burn3	=[	2,	fire_burn4	] {};
void()	fire_burn4	=[	3,	fire_burn5	] {};
void()	fire_burn5	=[	4,	fire_burn6	] {};
void()	fire_burn6	=[	5,	fire_burn7	] {};
void()	fire_burn7	=[	6,	fire_burn8	] {};
void()	fire_burn8	=[	7,	fire_burn9	] {};
void()	fire_burn9	=[	8,	fire_burn10	] {};
void()	fire_burn10	=[	9,	fire_burn11	] {};
void()	fire_burn11	=[	10,	fire_burn12	] {};
void()	fire_burn12	=[	11,	fire_burn13	] {};
void()	fire_burn13	=[	12,	fire_burn14	] {};
void()	fire_burn14	=[	13,	fire_burn1	] {CreateWhiteSmoke(self.origin + '0 0 56','0 0 8',HX_FRAME_TIME * 2);};


void()	star_sparkle1	=[	0,	star_sparkle2	] {};
void()	star_sparkle2	=[	1,	star_sparkle3	] {};
void()	star_sparkle3	=[	2,	star_sparkle4	] {};
void()	star_sparkle4	=[	3,	star_sparkle5	] {};
void()	star_sparkle5	=[	4,	star_sparkle6	] {};
void()	star_sparkle6	=[	5,	star_sparkle7	] {};
void()	star_sparkle7	=[	6,	star_sparkle8	] {};
void()	star_sparkle8	=[	7,	star_sparkle9	] {};
void()	star_sparkle9	=[	8,	star_sparkle10	] {};
void()	star_sparkle10	=[	9,	star_sparkle11	] {};
void()	star_sparkle11	=[	10,	star_sparkle12	] {};
void()	star_sparkle12	=[	11,	star_sparkle13	] {};
void()	star_sparkle13	=[	12,	star_sparkle14	] {};
void()	star_sparkle14	=[	13,	star_sparkle15	] {};
void()	star_sparkle15	=[	14,	star_sparkle16	] {};
void()	star_sparkle16	=[	15,	star_sparkle17	] {};
void()	star_sparkle17	=[	16,	star_sparkle18	] {};
void()	star_sparkle18	=[	17,	star_sparkle19	] {};
void()	star_sparkle19	=[	18,	star_sparkle20	] {};
void()	star_sparkle20	=[	19,	star_sparkle1	] {};

void()	portal_spin1	=[	0,	portal_spin2	] {thinktime self : 0.1;};	//ws: halved because 20 fps is too fast for the animation
void()	portal_spin2	=[	1,	portal_spin3	] {thinktime self : 0.1;};
void()	portal_spin3	=[	2,	portal_spin4	] {thinktime self : 0.1;};
void()	portal_spin4	=[	3,	portal_spin5	] {thinktime self : 0.1;};
void()	portal_spin5	=[	4,	portal_spin6	] {thinktime self : 0.1;};
void()	portal_spin6	=[	5,	portal_spin7	] {thinktime self : 0.1;};
void()	portal_spin7	=[	6,	portal_spin8	] {thinktime self : 0.1;};
void()	portal_spin8	=[	7,	portal_spin9	] {thinktime self : 0.1;};
void()	portal_spin9	=[	8,	portal_spin1	] {thinktime self : 0.1;};
/*
void()	portal_spin10	=[	9,	portal_spin11	] {};
void()	portal_spin11	=[	10,	portal_spin12	] {};
void()	portal_spin12	=[	11,	portal_spin13	] {};
void()	portal_spin13	=[	12,	portal_spin14	] {};
void()	portal_spin14	=[	13,	portal_spin15	] {};
void()	portal_spin15	=[	14,	portal_spin16	] {};
void()	portal_spin16	=[	15,	portal_spin17	] {};
void()	portal_spin17	=[	16,	portal_spin18	] {};
void()	portal_spin18	=[	17,	portal_spin19	] {};
void()	portal_spin19	=[	18,	portal_spin20	] {};
void()	portal_spin20	=[	19,	portal_spin21	] {};
void()	portal_spin21	=[	20,	portal_spin22	] {};
void()	portal_spin22	=[	21,	portal_spin1	] {};
*/

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

void()	water_start1	=[	1,	water_start2	] {if (self.modeltype == 1) setmodel (self, "models/waterfall2.mdl"); else setmodel (self, "models/waterfall.mdl");};
void()	water_start2	=[	2,	water_start3	] {};
void()	water_start3	=[	3,	water_start4	] {sound (self, CHAN_ITEM, "fx/wfstart.wav", 1, ATTN_NORM);};
void()	water_start4	=[	4,	water_start5	] {};
void()	water_start5	=[	5,	water_start6	] {};
void()	water_start6	=[	6,	water_start7	] {};
void()	water_start7	=[	7,	water_start8	] {};
void()	water_start8	=[	8,	water_start9	] {};
void()	water_start9	=[	9,	water_start10	] {};
void()	water_start10	=[	10,	water_start11	] {};
void()	water_start11	=[	11,	water_start12	] {};
void()	water_start12	=[	12,	water_start13	] {};
void()	water_start13	=[	13,	water_start14	] {};
void()	water_start14	=[	14,	water_start15	] {};
void()	water_start15	=[	15,	water_start16	] {};
void()	water_start16	=[	16,	water_start17	] {};
void()	water_start17	=[	17,	water_start18	] {};
void()	water_start18	=[	18,	water_start19	] {};
void()	water_start19	=[	19,	water_start20	] {};
void()	water_start20	=[	20,	water_start21	] {};
void()	water_start21	=[	21,	water_start22	] {};
void()	water_start22	=[	22,	water_start23	] {};
void()	water_start23	=[	23,	water_start24	] {};
void()	water_start24	=[	24,	water_start25	] {};
void()	water_start25	=[	25,	water_start26	] {};
void()	water_start26	=[	26,	water_fall1	] {};

void() water_idle1	=[	0,	water_idle1	] {};


void()	water_stop1	=[	27,	water_stop2	] {};
void()	water_stop2	=[	28,	water_stop3	] {sound (self, CHAN_ITEM, "fx/wfend.wav", 1, ATTN_NORM);};
void()	water_stop3	=[	29,	water_stop4	] {};
void()	water_stop4	=[	30,	water_stop5	] {};
void()	water_stop5	=[	31,	water_stop6	] {};
void()	water_stop6	=[	32,	water_stop7	] {};
void()	water_stop7	=[	33,	water_stop8	] {};
void()	water_stop8	=[	34,	water_stop9	] {};
void()	water_stop9	=[	35,	water_stop10	] {};
void()	water_stop10	=[	36,	water_stop11	] {};
void()	water_stop11	=[	37,	water_stop12	] {};
void()	water_stop12	=[	38,	water_stop13	] {};
void()	water_stop13	=[	39,	water_stop14	] {};
void()	water_stop14	=[	40,	water_stop15	] {};
void()	water_stop15	=[	41,	water_stop16	] {};
void()	water_stop16	=[	41,	water_stop16	] {};

void()	water_fall1	=[	42,	water_fall2	] {};
void()	water_fall2	=[	43,	water_fall3	] {};
void()	water_fall3	=[	44,	water_fall4	] {};
void()	water_fall4	=[	45,	water_fall5	] {};
void()	water_fall5	=[	46,	water_fall6	] {};
void()	water_fall6	=[	47,	water_fall7	] {};
void()	water_fall7	=[	48,	water_fall8	] {};
void()	water_fall8	=[	49,	water_fall9	] {};
void()	water_fall9	=[	50,	water_fall10	] {};
void()	water_fall10	=[	51,	water_fall11	] {};
void()	water_fall11	=[	52,	water_fall12	] {};
void()	water_fall12	=[	53,	water_fall13	] {};
void()	water_fall13	=[	54,	water_fall14	] {};
void()	water_fall14	=[	55,	water_fall15	] {};
void()	water_fall15	=[	56,	water_fall16	] {};
void()	water_fall16	=[	57,	water_fall17	] {};
void()	water_fall17	=[	58,	water_fall18	] {};
void()	water_fall18	=[	59,	water_fall19	] {};
void()	water_fall19	=[	60,	water_fall20	] {};
void()	water_fall20	=[	61,	water_fall21	] {};
void()	water_fall21	=[	62,	water_fall22	] {};
void()	water_fall22	=[	63,	water_fall23	] {};
void()	water_fall23	=[	64,	water_fall24	] {};
void()	water_fall24	=[	65,	water_fall25	] {};
void()	water_fall25	=[	66,	water_fall26	] {};
void()	water_fall26	=[	67,	water_fall1	] {};

void()	corpse_swing1	=[	0,	corpse_swing2	] {};
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
void()	corpse_swing14	=[	13,	corpse_idle1	] {};

void() corpse_idle1	=[	13,	corpse_idle1	] {};

void()	corpse_die1	=[	0,	corpse_die2	] {chunk_death();};

void()	corpse_die2	=[	0,	corpse_die2	] {SUB_Remove;};


void() object_start =
{
// delay drop to floor to make sure all doors have been spawned
// spread think times so they don't all happen at same time
	self.takedamage=DAMAGE_YES;
	self.flags2(+)FL_ALIVE;

	if(self.scale<=0)
		self.scale=1;
	self.th_stand ();
};

void() obj_hang_corpse =
{
	precache_model ("models/hangass.mdl");
	precache_model ("models/hangskel.mdl");
	
	//precache_sound ("death_knight/sword1.wav");
	//precache_sound ("fx/bonebrk.wav");

	self.solid = SOLID_BBOX;

	if (self.spawnflags & IS_SKELETON)
	{
		setmodel (self, "models/hangskel.mdl");
		self.thingtype=THINGTYPE_BONE;
	}
	else
	{
		setmodel (self, "models/hangass.mdl");
		self.thingtype=THINGTYPE_FLESH;
	}

	setsize (self, '-13 -13 -7', '13 13 25');
	self.health = 45;
	
	self.th_stand = corpse_idle1;
	self.th_die = corpse_die1;
	self.th_pain = corpse_swing1;
	self.netname="hanged";
	
	self.flags (+) FL_MONSTER | FL_FLY;
	
	object_start();
};

void() obj_skeleton_body =
{
	precache_model ("models/skeleton1.mdl");
	
	//precache_sound ("death_knight/sword1.wav");
	//precache_sound ("fx/bonebrk.wav");

	self.solid = SOLID_BBOX;

	setmodel (self, "models/skeleton1.mdl");
	self.thingtype=THINGTYPE_BONE;

	setsize (self, '-29 -29 0', '29 29 8');
	self.health = 45;
	
	self.th_stand = corpse_idle1;
	self.th_die = corpse_die1;
	//self.th_pain = corpse_swing1;
	self.netname="skeleton";
	
	self.flags (+) FL_MONSTER | FL_FLY;
	
	object_start();
};

void() misc_portal =
{
	precache_model ("models/port.spr");
	self.solid = SOLID_NOT;
	self.takedamage=DAMAGE_YES;

	setmodel (self, "models/port.spr");
	self.th_stand = portal_spin1;
	//self.flags (+) FL_MONSTER | FL_FLY;
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
	//setmodel (self, "models/hangass.mdl");
	if (self.spawnflags & PORTAL_CLOSED)
		self.th_stand = portal_close26;
	else
		self.th_stand = portal_anim1;
	//self.th_stand = corpse_swing1;
	//self.th_die = corpse_die1;
	if (self.targetname)
		if (self.spawnflags & PORTAL_CLOSED)
			self.use = portal_open1;
	else
		self.use = portal_close1;
	self.flags (+) FL_MONSTER | FL_FLY;
	self.th_stand();
	
	self.netname="portalbig";
};

void() misc_starwall =
{
	precache_model ("models/magicb.spr");
	setmodel (self, "models/magicb.spr");
	
	self.th_stand = star_sparkle1;
	self.netname="magic barrier";
	self.flags (+) FL_MONSTER | FL_FLY;
	self.th_stand();
	if (self.targetname)
		self.use = SUB_Remove;
	
};

void() misc_waterfall =
{
	precache_model ("models/waterfall.mdl");
	precache_model ("models/waterfall2.mdl");
	precache_sound ("fx/wfstart.wav");
	precache_sound ("fx/wfall.wav");
	precache_sound ("fx/wfend.wav");
	
	if (self.modeltype == 1)
		setmodel (self, "models/waterfall2.mdl");
	else
		setmodel (self, "models/waterfall.mdl");
		
	if (self.spawnflags & WATER_OFF)
	{
		setmodel (self, "");
		self.th_stand = water_stop15;
	}	
	else
		self.th_stand = water_fall1;
	//self.think();
	self.netname="waterfall";
	self.flags (+) FL_MONSTER | FL_FLY;
	//self.th_stand();
	
	if (self.spawnflags & WATER_TRANS)
		self.drawflags (+) DRF_TRANSLUCENT;
	else if (self.spawnflags & WATER_FULLBR)
		self.drawflags (+) MLS_FULLBRIGHT;
	
	setsize (self, '-73 -73 -150', '73 73 120');
	
	if (self.targetname)
	{
		if (self.spawnflags & WATER_OFF)
			self.use = water_start1;
		else	
			self.use = water_stop1;
	}
	
	self.th_stand ();
	//else if (self.targetname && watcount == 1)
	//{
		//watcount = 0;
		//self.use = water_start1;
	//}
}
	
void fog_float ()
{
	self.frame=self.weaponframe_cnt;
	if (self.lifetime<time || self.velocity=='0 0 0')
		remove(self);
	else
		thinktime self : HX_FRAME_TIME;
}

void fog_spawn ()
{
entity new;
vector org;
	makevectors(self.angles);
	org = (self.absmin+self.absmax)*0.5 + normalize(v_forward)*random(self.t_width) + normalize(v_right)*random(self.t_width);
	new = spawn();
	setorigin (new, org);
	setmodel (new, "models/fog.spr");
	setsize (new, '0 0 0', '0 0 0');
	
	new.movetype = MOVETYPE_FLY;
	new.solid = SOLID_NOT;
	new.drawflags(+)DRF_TRANSLUCENT;
	new.scale=0.2;
	new.weaponframe_cnt=rint(random(0,4));
	new.lifetime = time+self.lifespan+random(self.lifespan);
	new.think = fog_float;
	thinktime new : 0;
	
	new.velocity_x = (random(-self.t_length,self.t_length));
	new.velocity_y = (random(-self.t_length,self.t_length));
	new.velocity_z = (random(-self.height,self.height));
	
	self.think = fog_spawn;
	thinktime self : random(self.wait,self.wait*2);
}

void() misc_mist
{
	precache_model ("models/fog.spr");
	setmodel (self, "models/fog.spr");
	
	self.drawflags (+) DRF_TRANSLUCENT;
	
	self.th_stand = fog_loop1;
	self.netname="fog";
	self.flags (+) FL_MONSTER | FL_FLY;
	self.th_stand();
	if (self.targetname)
		self.use = SUB_Remove;
};

void() misc_mistgen
{
	precache_model ("models/fog.spr");
	
	if (!self.t_length)		//speed
		self.t_length=30;
	if (!self.t_width)		//spawning area
		self.t_width=30;
	if (!self.height)		//z speed
		self.height=6;
	if (!self.lifespan)		//fog lifetime
		self.lifespan=2;
	if (!self.wait)
		self.wait=0.5;		//min delay between fog spawns
	self.th_stand = fog_spawn;
	self.netname="fog generator";
	if (self.targetname)
	{
		if (self.spawnflags & 2)
			self.use = fog_spawn;
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

void() light_fire_large
{
	self.solid = SOLID_NOT;
	precache_model ("models/flammd.spr");
	setmodel (self, "models/flammd.spr");
	self.think = fire_burn1;
	if (self.targetname)
		self.use = SUB_Remove;
	self.think();
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
	self.flags (+) FL_MONSTER | FL_FLY;
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
	/*setsize (self, '-10 -40 0', '10 40 12');
	self.thingtype = THINGTYPE_BONE;
	self.th_die = chunk_death;
	if (!self.health)
		self.health = 50;*/
	self.th_stand = SUB_Null;
	if (self.targetname)
		self.use = SUB_Remove;
}
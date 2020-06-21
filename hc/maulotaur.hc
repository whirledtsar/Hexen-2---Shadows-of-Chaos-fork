$frame idle1 idle2 idle3 idle4 idle5 idle6 idle7 idle8 idle9 idle10 idle11 idle12 idle13 idle14 idle15 idle16 idle17 idle18 idle19

$frame maulsw1 maulsw2 maulsw3 maulsw4 maulsw5 maulsw6 maulsw7 maulsw8 maulsw9 maulsw10 maulsw11 maulsw12 maulsw13 maulsw14 maulsw15 maulsw16 maulsw17 maulsw18

$frame maulat1 maulat2 maulat3 maulat4 maulat5 maulat6 maulat7 maulat8 maulat9 maulat10 maulat11 maulat12 maulat13 maulat14 maulat15 maulat16 maulat17 maulat18 maulat19 maulat20 maulat21 maulat22 maulat23 maulat24 maulat25 maulat26 maulat27 maulat28 maulat29 maulat30 maulat31 maulat32

$frame maulrn1 maulrn2 maulrn3 maulrn4 maulrn5 maulrn6 maulrn7 maulrn8 maulrn9 maulrn10 maulrn11 maulrn12 maulrn13 maulrn14 maulrn15 maulrn16 maulrn17 maulrn18

$frame maulpn1 maulpn2 maulpn3 maulpn4 maulpn5 maulpn6 maulpn7 maulpn8 maulpn9 maulpn10 maulpn11

$frame mauldt1 mauldt2 mauldt3 mauldt4 mauldt5 mauldt6 mauldt7 mauldt8 mauldt9 mauldt10 mauldt11 mauldt12 mauldt13 mauldt14 mauldt15 mauldt16 mauldt17 mauldt18 mauldt19 mauldt20 mauldt21 mauldt22 mauldt23 mauldt24 mauldt25 mauldt26 mauldt27 mauldt28 mauldt29

void(entity victim, float damg, float force, float zmod, float gore_vel) maul_hit;
void() maul_run;
void() maul_swing;
void() maul_smash;
void(string sound) maul_voice;

float MAUL_HIT_FORCE = 30;
float MAUL_CHG_FORCE = 50;
float MAUL_QUAKE_RANGE = 360;

float MAUL_EYESCLOSED = 1;	//skin

void precache_maulotaur()
{
	precache_model("models/maultaur.mdl");
	precache_model("models/drgnball.mdl");
	precache_model("models/mumshot.mdl");
	
	precache_sound("golem/slide.wav");
	precache_sound("maul/act.wav");
	precache_sound("maul/fall.wav");
	precache_sound("maul/die.wav");
	precache_sound("maul/fballhit.wav");
	precache_sound("maul/pain.wav");
	precache_sound("maul/see.wav");
	precache_sound("mummy/tap.wav");	//hammer hits ground
	precache_sound("pest/snort.wav");	//idle sound
	precache_sound("yakman/hoof.wav");
	precache_sound("weapons/expsmall.wav");	//fireball hit
	precache_sound("weapons/fbfire.wav");	//fire fireballs
	precache_sound("weapons/vorpblst.wav");	//charge hit
	precache_sound("weapons/vorpswng.wav");	//swing hammer
}

void maul_chargehit (entity victim)
{
	if (victim.safe_time>time)
		return;
	
	sound (self, CHAN_WEAPON, "weapons/vorpblst.wav", 1, self.lip);	//if (victim.thingtype == THINGTYPE_FLESH)
	
	if (!victim.takedamage || victim == world)
		return;
	
	victim.safe_time = time+0.75;
	if (victim.health - self.dmg*1.5 <= 0)
		victim.deathtype = "maul_charge";
	
	maul_hit (victim, self.dmg*1.5, MAUL_CHG_FORCE*self.scale, 0.5, random(-200,200));
}

void maul_chargemelee ()
{
vector	org1,org2,orgsave;
	
	makevectors(self.angles);
	org1=self.origin+self.proj_ofs;
	org2=orgsave=(org1+self.proj_ofs)+(v_forward*self.level);
	
	traceline(org1,org2,FALSE,self);
	
	if (trace_fraction == 1)
	{
		org2=orgsave+(v_up*30);
		traceline(org1,org2,FALSE,self);
		if (trace_fraction == 1)
		{
			org2=orgsave-(v_up*30);
			traceline(org1,org2,FALSE,self);
			if (trace_fraction == 1)
			{
				org2=orgsave+(v_right*30);
				traceline(org1,org2,FALSE,self);
				if (trace_fraction == 1)
				{
					org2=orgsave-(v_right*30);
					traceline(org1,org2,FALSE,self);
				}
			}
		}
	}
	
	if(trace_fraction == 1)
		return;
	
	maul_chargehit (trace_ent);
	dprint ("Mauloatur charge hit from maul_chargemelee\n");
}

/*void maul_chargetouch ()
{
	if (!other.takedamage)
		return;
	if (!fov(other, self, 60) )	{dprint ("Mauloatur: victim not in fov\n");
		return; }
	if (other.safe_time>time)
		return;
	
	maul_chargehit(other);
	dprint ("Mauloatur charge hit from maul_chargetouch\n");
}*/

void maul_chargedone () [++ $maulat12 .. $maulat19]
{
	if (cycle_wrapped)
	{
		self.think = maul_run;
		thinktime self : 0;
	}
}

void maul_charging ()
{
	self.frame = $maulat12;
	maul_chargemelee();
	if (self.scale>1 && random()<0.25+(skill*0.1))	//lord version tracks player while charging; tracks better in higher skills
		ai_face();
	
	particle(self.origin, '0 0 30', 344, 2);
	if(random()<0.2)
		CreateWhiteSmoke(self.origin,'0 0 8'*self.scale,HX_FRAME_TIME * 2);
	
	if (!walkmove (self.angles_y, 30*self.scale, TRUE) || time > self.counter)
	{
		if (trace_ent != world) {	dprint ("Mauloatur charge hit from maul_charging\n");
			maul_chargehit (trace_ent);
		}
		self.pain_finished = time;	//done charging, can enter pain state like normal
		//self.touch = obj_push;
		self.think = maul_chargedone;
		thinktime self : 0;
	}
	else
		thinktime self : HX_FRAME_TIME;
}
	
void maul_charge () [++ $maulat1 .. $maulat12]
{
	ai_charge(8*self.scale);
	
	if (cycle_wrapped)
	{
		//self.touch = maul_chargetouch;	//ended up being unnecessary
		sound (self, CHAN_BODY, "golem/slide.wav", 1, self.lip);
		self.counter = time+1.5;	//stop charging after this time
		self.pain_finished = time+100;	//dont go into pain while charging
		self.think = maul_charging;
		thinktime self : 0;
	}
}

void maul_die () [++ $mauldt1 .. $mauldt29]
{
	if (cycle_wrapped) {
		self.frame = $mauldt29;
		self.skin = MAUL_EYESCLOSED;	
		MakeSolidCorpse();
		return;
	}
	else if (self.health <= (-50*self.scale))
		chunk_death();
	
	if (self.frame == $mauldt1) {
		stopSound(self,CHAN_WEAPON);
		stopSound(self,CHAN_BODY);
		sound (self, CHAN_VOICE, "maul/die.wav", 1, self.lip-0.25);
		//self.takedamage = DAMAGE_NO;	//dont gib during fall animation
	}
	else if (self.frame == $mauldt27 && self.flags&FL_ONGROUND)
		sound (self, CHAN_BODY, "maul/fall.wav", 1, self.lip);
	
	if (self.frame <= $mauldt22) {
		ThrowGib ("models/blood.mdl", self.health);
	}
}

void maul_fballtouch ()
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	if (pointcontents(self.origin) == CONTENT_WATER || pointcontents(self.origin) == CONTENT_SLIME)
		FireFizzle();
	
	if (other.health && other.netname != self.owner.netname) {	//dont hurt fellow maulobros
		other.deathtype = "maul_fire";
		spawn_touchpuff  (8, other);
		if (self.owner.classname == "monster_maulotaur_lord")
			T_RadiusDamage (self, self.owner, 30, self.owner);
		else
			T_Damage (other, self, self.owner, random(10,14));
	}

	sound (self, CHAN_BODY, "maul/fballhit.wav", 1, ATTN_NORM);	//weapons/expsmall
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	
	fx_light (self.origin, EF_MUZZLEFLASH);	//creates quick flash of dynamic light
	
	remove(self);
}

void maul_fballfire ()
{
	vector org1,org2;
	float ofs;
	float ofsmax;
	ofsmax = 40;
	if (self.scale>1)
		ofsmax = 80;	//lord version fires larger spread with more missiles
	
	org1 = self.origin+self.proj_ofs;
	org2 = self.enemy.origin+self.enemy.proj_ofs;
	makevectors(self.angles);
	for (ofs = -ofsmax; ofs <= ofsmax; ofs+=20)
		Create_Missile (self, org1, org2+(v_right*ofs), "models/drgnball.mdl", "maul_fball", 0, 700*self.scale+(skill*100), maul_fballtouch);
	
	fx_light (self.origin+self.proj_ofs, EF_MUZZLEFLASH);	//creates quick flash of dynamic light
	sound (self, CHAN_WEAPON, "weapons/fbfire.wav", 1, ATTN_NORM);
}

void maul_hit (entity victim, float damg, float force, float zmod, float gore_vel)
{
vector meat_spot;
	
	if(!victim.takedamage || victim.solid == SOLID_BSP)
		return;
	
	T_Damage (victim, self, self, damg+random(10));
	meat_spot=victim.origin;
	meat_spot_z=self.origin_z+self.proj_ofs_z;
	MeatChunks (meat_spot,v_right*gore_vel+'0 0 200',3,victim);
	SpawnPuff (meat_spot, '0 0 0', 20, victim);
	Knockback (victim, self, self, force, zmod);
}

void() maul_mis;

void maul_melee ()
{
	self.aflag = FALSE;	//dont fire missiles in swing anim
	if (self.scale>1) {	//lord version does quake atk
		if (self.check_ok > time)	//too soon to do another quake attack
			maul_mis();
		else
			maul_smash();
	}
	else
		maul_swing();
}

void maul_mis ()
{
float spread, range, dist;
	spread = FALSE;
	dist = vlen(self.origin-self.enemy.origin);
	if (self.scale > 1)
		range = 448;
	else
		range = 384;
	self.aflag = TRUE;	//fire missiles in swing anim
	
	ai_face();
	
	if (dist<320 && self.scale>1 && self.check_ok < time && random()<0.75)	//lord variant does melee attack from greater range
	{
		self.aflag = FALSE;
		self.think = maul_smash;
		thinktime self : 0;
	}
	else if (dist<160 && self.scale==1 && random()<0.75)
	{
		self.aflag = FALSE;
		self.think = maul_swing;
		thinktime self : 0;
	}
	
	else if(fabs(self.enemy.origin_z-self.origin_z)<48)
	{
		float charge;
		if (dist<range)
		{
			makevectors(self.angles);
			traceline(self.origin+self.proj_ofs, self.origin+self.proj_ofs+(v_forward*200),TRUE,self);
			if (trace_fraction==1 || trace_ent==self.enemy)
				charge = 1;
			else
				charge = 0.25;
			
			if (random()<=charge)
				self.think = maul_charge;
			
			else if (random()<0.5)
				self.think = maul_smash;
			else
				spread = TRUE;
		}
		else if (random()<0.5)
			self.think = maul_smash;
		else
			spread = TRUE;
	}
	else
		spread = TRUE;
	
	if (spread)
	{	//check if theres room for fireball spread
	local float ofs;
		ofs = -20;
		makevectors(self.angles);
		traceline(self.origin+self.proj_ofs,(self.enemy.origin+self.enemy.proj_ofs)+(v_forward*self.level),FALSE,self);
		while (trace_fraction == 1 && ofs <= 20) {
			traceline(self.origin+self.proj_ofs,(self.enemy.origin+self.proj_ofs)+(v_forward*self.level)+(v_right*ofs),FALSE,self);
			ofs +=20;
		}
		if (trace_fraction == 1 || trace_ent.takedamage || random()<0.25)
			self.think = maul_swing;
		else if (random()<0.5)
			self.think = maul_smash;
		else
			self.think = maul_run;
	}
	
	thinktime self : 0;
}

void maul_paingo () [++ $maulpn1 .. $maulpn11]
{
	if (self.frame < $maulpn7)
		ai_pain(2);	//back up slightly
	
	if (self.frame == $maulpn1)
		ThrowGib ("models/blood.mdl", self.health);
		
	else if (self.frame == $maulpn3)
		sound (self, CHAN_VOICE, "maul/pain.wav", 1, self.lip);
	
	if (cycle_wrapped)
	{
		self.pain_finished = time+2+self.scale;
		self.think = maul_run;
		thinktime self : HX_FRAME_TIME;
	}
}

void maul_pain (entity attacker, float damg)
{
	if (self.pain_finished > time)
		return;
	else if (random()<0.2*self.scale || damg < 10*self.scale) {
		self.pain_finished = time;
		return;
	}
	self.think = maul_paingo;
	thinktime self : 0;
}

void maul_run () [++ $maulrn1 .. $maulrn18]
{
	ai_run(8*self.scale);
	
	if (self.frame == $maulrn9 || self.frame == $maulrn18)
		sound (self, CHAN_BODY, "yakman/hoof.wav", 1, self.lip+1);
	
	if (random()<0.03)
		maul_voice("pest/snort.wav");	//sound (self, CHAN_VOICE, "pest/snort.wav", 1, ATTN_NORM);
}

void maul_stand () [++ $idle1 .. $idle19]
{
	ai_stand();
	if (random()<0.01)
		maul_voice("pest/snort.wav");
}

void maul_smashmelee ()
{
vector	org1,org2;
	
	makevectors(self.angles);
	org1=self.origin+(self.proj_ofs*0.5);
	org2=org1+(v_forward*60);
	traceline(org1,org2,FALSE,self);
	
	if (trace_ent == world)
		return;
	
	MetalHitSound (trace_ent.thingtype);
	trace_ent.deathtype = "maul_smash";
	maul_hit (trace_ent, self.dmg*2, MAUL_HIT_FORCE*0.5, 0.25, random(-200,200));
}

void maul_smashquaking ()
{
float dist;
vector ang;
	if (time > self.lifetime)
		remove(self);
	thinktime self : HX_FRAME_TIME;
	
	if (self.enemy && (fabs(self.enemy.origin_z-self.origin_z)<32)) {
		dist = vlen(self.enemy.origin - self.origin);
		if (dist < MAUL_QUAKE_RANGE) {
			float damg;
			damg = self.dmg/dist;
			if (damg>=1) {
				if (self.enemy.health-damg <= 0)
					self.enemy.deathtype = "maul_quake";
				T_Damage(self.enemy, self, self, damg);
			}
		}
	}
	
	if (self.dmg>15)
		self.dmg-=15;
	
	if (self.t_width < time) {		//create smoke fx in circle around quake radius as a visual indicator
		self.t_width = time+0.25;
		if (self.dmg<=15)
			return;
		else if (self.dmg<=45) {	//if quake has gotten small, just make smoke in the center
			CreateWhiteSmoke(self.origin,'0 0 12',HX_FRAME_TIME*random(0.5,1.5));
			return;
		}
		ang_y = 0;
		while (ang_y < 360) {
			makevectors(ang);
			traceline(self.origin,self.origin+v_forward*self.dmg,TRUE,self);
			if (trace_fraction==1)
					CreateWhiteSmoke(trace_endpos,'0 0 12',HX_FRAME_TIME*random(0.5,1.5));
			ang_y += random(20,40);
		}
	}
}

void maul_smashquake ()
{
	float dist;
	dist = vlen(self.enemy.origin - self.origin);
	
	MonsterQuake(MAUL_QUAKE_RANGE);
	self.check_ok = time+2;	//dont do quake attack until then
	
	if(!self.enemy)
		return;
	
	entity quaker = spawn();
	setsize (quaker, '0 0 0', '0 0 0');
	setorigin (quaker, self.origin);
	if (!self.flags&FL_ONGROUND) {
		traceline (self.origin, self.origin-'0 0 32', TRUE, self);
		if (trace_fraction==1) {	//no ground
			remove(quaker);
			return;
		}
		else
			setorigin (quaker, trace_endpos);
	}
	quaker.dmg = MAUL_QUAKE_RANGE*1.5;
	quaker.enemy = self.enemy;
	quaker.lifetime = time+2.5;
	quaker.think = maul_smashquaking;
	thinktime quaker : 0;
}

void maul_smash () [++ $maulat19 .. $maulat32]
{
	if (self.frame < $maulat27)
		ai_face();
	
	if (self.frame == $maulat26)
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, self.lip);
	else if (self.frame == $maulat29)
		maul_smashmelee();
	else if (self.frame == $maulat30)
	{
		if (self.aflag) {
			fx_light (self.origin, EF_MUZZLEFLASH);	//creates quick flash of dynamic light
			sound (self, CHAN_ITEM, "mummy/tap.wav", 1, self.lip);		//launch_mumshot uses CHAN_WEAPON
			launch_mumshot(3+self.scale);
		}
		else
			maul_smashquake();
	}
	else if (cycle_wrapped)
	{
		self.think = maul_run;
		thinktime self : 0;
	}
}

void maul_swingmelee ()
{
vector	org1,org2;

	if (!self.enemy)
		return;		// removed before stroke
	
	makevectors(self.angles);
	org1=self.origin+self.proj_ofs;
	org2=self.enemy.origin;
	
	if(vlen(org2-org1)<=self.level) 
	{
		traceline(org1,org2,FALSE,self);
		if(trace_ent!=self.enemy)
		{
			org2=(self.enemy.absmin+self.enemy.absmax)*0.5;
			traceline(org1,org2,FALSE,self);
		}
	}
	else
	{
		org2=org1+v_forward*(self.level*2);
		traceline(org1,org2,FALSE,self);
	}
	
	if (trace_ent == world)
		return;
	
	if (!MetalHitSound (trace_ent.thingtype))
		sound (self, CHAN_WEAPON, "mummy/tap.wav", 1, self.lip);
	maul_hit (trace_ent, self.dmg, MAUL_HIT_FORCE, 0.5, random(100,300));
}

void maul_swing () [++ $maulsw1 .. $maulsw18]
{
	if (cycle_wrapped)
	{
		self.think = maul_run;
		thinktime self : 0;
	}
	if (self.frame == $maulsw1)
		maul_voice ("maul/act.wav");
	else if (self.frame == $maulsw11)
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, self.lip);
	
	if (self.frame <= $maulsw9)
		ai_face();
	
	if (self.frame >= $maulsw9 && self.frame <= $maulsw16)
	{
		if (self.aflag)	//if missile or melee attack
			ai_face();
		else
			walkmove (self.angles_y, 16, FALSE);
	}
	
	if (self.frame == $maulsw13)
	{
		maul_swingmelee();
		if (self.aflag) {
			maul_fballfire();
		}
	}
}

void maul_walk () [++ $maulrn1 .. $maulrn18]
{
	ai_walk(4*self.scale);
	if (random()<0.03)
		maul_voice("pest/snort.wav");
	
	if (self.frame == $maulrn9 || self.frame == $maulrn18)
		sound (self, CHAN_BODY, "yakman/hoof.wav", 1, self.lip+1);
}

void maul_voice (string snd) =
{
	if (self.cnt > time)
		return;
	
	sound (self, CHAN_VOICE, snd, 1, self.lip);
	self.cnt = time+4;
};

/*monster_maulotaur (1 0.3 0) (-30 -30 0) (30 30 88) AMBUSH 
	Mini-boss strength enemy. Has charge, melee, missile spread, and floor missile trail attacks. Health can be set in map.
	Experience: 250
	Health: 500
*/
void monster_maulotaur ()
{
	if(deathmatch)
	{
		remove(self);
		return;
	}
	
	if(!self.flags2&FL_SUMMONED && !self.flags2&FL2_RESPAWN)
		precache_maulotaur();
	
	if (!self.th_init)
		self.th_init = monster_maulotaur;
	self.init_org = self.origin;
	
	self.aflag = FALSE;	//tracks whether to fire missile during swing animation
	self.cnt = time;	//tracks last voice sound
	self.counter = 0;	//tracks when to stop charging
	self.dmg = 12;		//melee attack damage
	self.drawflags = SCALE_ORIGIN_BOTTOM;
	self.flags (+) FL_MONSTER;
	self.flags2 (+) FL_ALIVE;
	self.level = 80;	//melee range
	self.lip = ATTN_NORM;	//sound attenuation
	self.mass = 50;
	self.mintel = 10;
	self.monsterclass = CLASS_HENCHMAN;
	self.movetype = MOVETYPE_STEP;
	self.netname = "maulotaur";
	self.preventrespawn = FALSE;
	self.proj_ofs = '0 0 44';
	self.sightsound = "maul/see.wav";
	self.scale = 1;
	self.thingtype = THINGTYPE_FLESH;
	self.view_ofs = '0 0 80';
	self.yaw_speed = 15;
	
	setmodel (self, "models/maultaur.mdl");
	setsize (self, '-30 -30 -24', '30 30 88');	//112 tall
	self.solid = SOLID_SLIDEBOX;
	self.hull = HULL_GOLEM;
	
	if (self.classname=="monster_maulotaur_lord")
	{
		self.dmg *= 1.5;
		if (self.experience)
			self.experience_value = self.experience;
		else
			self.experience_value = 750;
		if (!self.health)
			self.health = 2000;
		self.level = 100;	//melee range
		self.lip = 0.5;	//sound attenuation
		self.mass *= 1.5;
		self.mintel *= 1.5;
		self.monsterclass = CLASS_LEADER;
		self.preventrespawn = TRUE;
		self.proj_ofs *= 1.5;
		self.scale = 1.5;
		self.view_ofs *= 1.5;
		setsize (self, self.mins*self.scale, self.maxs*self.scale);
		setsize (self, self.mins+'0 0 16', self.maxs);
	}
	else {
		if (self.experience)
			self.experience_value = self.experience;
		else
			self.experience_value = 300;
		if (!self.health)
			self.health = 500;
	}
	self.max_health = self.health;
	self.init_exp_val = self.experience_value;
	
	self.th_stand = maul_stand;
	self.th_walk = maul_walk;
	self.th_run = maul_run;
	self.th_melee = maul_melee;
	self.th_missile = maul_mis;
	self.th_pain = maul_pain;
	self.th_die = maul_die;
	
	walkmonster_start();
}

/*monster_maulotaur_lord (1 0.3 0) (-45 -45 0) (45 45 132) AMBUSH
	All around bigger, badder, & bolder. More health, moves faster, hits harder, shoots faster missiles, etc. Uses alternate quake attack for melee.
	Experience: 750
	Health: 2000
*/
void monster_maulotaur_lord ()
{
	self.th_init = monster_maulotaur_lord;
	monster_maulotaur();
}


/*=========================================
FUNCTIONS THAT ALL PLAYERS WILL CALL
===========================================*/
void() bubble_bob;

void PlayerSpeed_Calc (void)
{
	if (self.playerclass==CLASS_ASSASSIN)
		self.hasted=1;
	else if (self.playerclass==CLASS_PALADIN)
		self.hasted=.96;
	else if (self.playerclass==CLASS_CRUSADER)
		self.hasted=.93;
	else if(self.playerclass==CLASS_NECROMANCER)
		self.hasted=.9;

	if (self.artifact_active & ART_HASTE)
		self.hasted *= 2.9;

	if (self.hull==HULL_CROUCH)   // Player crouched
		self.hasted *= .6;
}

vector VelocityForDamage (float dm)
{
	local vector v;

	v = randomv('-100 -100 200', '100 100 300');

	if (dm > -50)
		v = v * 0.7;
	else if (dm > -200)
		v = v * 2;
	else
		v = v * 10;

	return v;
}


void ReadySolid ()
{
	if(!self.headmodel)
		self.headmodel="models/flesh1.mdl";//Temp until player head models are in
	MakeSolidCorpse ();
}

void StandardPain(void)
{
	if(self.playerclass==CLASS_ASSASSIN)
	{
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/asspain1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/asspain2.wav", 1, ATTN_NORM);
	}
	else if (random() > 0.5)
		sound (self, CHAN_VOICE, "player/palpain1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "player/palpain2.wav", 1, ATTN_NORM);
}

void PainSound (void)
{
	if (self.health <= 0)
		return;

	if (self.deathtype == "teledeath"||self.deathtype == "teledeath2"||self.deathtype == "teledeath3"||self.deathtype == "teledeath4")
	{
		sound (self, CHAN_VOICE, "player/telefrag.wav", 1, ATTN_NONE);
		return;
	}

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 0.5;

	// FIXME:  Are we doing seperate sounds for these different pains????
	if (self.model=="models/sheep.mdl")
		sheep_sound(1);
	else if (/*self.watertype == CONTENT_WATER &&*/ self.waterlevel == 3)
	{
		if(self.playerclass==CLASS_ASSASSIN)
			sound (self, CHAN_VOICE, "player/assdrown.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/paldrown.wav", 1, ATTN_NORM);
	}
	else //if (self.watertype == CONTENT_SLIME)
	{
		StandardPain();
	}
/*	else if (self.watertype == CONTENT_LAVA)
	{
		if(self.playerclass==CLASS_ASSASSIN)
		{
			if (random() > 0.5)
				sound (self, CHAN_VOICE, "player/asspain1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_VOICE, "player/asspain2.wav", 1, ATTN_NORM);
		}
		else if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/palpain1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/palpain2.wav", 1, ATTN_NORM);
	}
	else
	{
		if(self.playerclass==CLASS_ASSASSIN)
		{
			if (random() > 0.5)
				sound (self, CHAN_VOICE, "player/asspain1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_VOICE, "player/asspain2.wav", 1, ATTN_NORM);
		}
		else if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/palpain1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/palpain2.wav", 1, ATTN_NORM);
	}*/
}

void player_pain (void)
{
//FIX this = need to check if firing, else make idle frames of all
//	weapons frame 0?
//if (self.weaponframe)
//		return;

	if (self.last_attack + 0.5 > time || self.button0)
		return;

	PainSound();

//	self.weaponframe=0;//Why?

	if (self.hull==HULL_PLAYER)
		self.act_state=ACT_PAIN;
	else
		self.act_state=ACT_CROUCH_MOVE;//No pain animation for crouch- maybe jump?
								//Make it make you stand up?
}

void DeathBubblesSpawn ()
{
entity	bubble;
vector	offset;

	offset_x = random(18,-18);
	offset_y = random(18,-18);

	if (pointcontents(self.owner.origin+self.owner.view_ofs)!=CONTENT_WATER)
	{
		remove(self);
		return;
	}

	bubble = spawn_temp();
	setmodel (bubble, "models/s_bubble.spr");
	setorigin (bubble, self.owner.origin+self.owner.view_ofs+offset);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 17';
	thinktime bubble : 0.5;
	bubble.think = bubble_bob;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	bubble.abslight=0.5;
	bubble.drawflags(+)DRF_TRANSLUCENT|MLS_ABSLIGHT;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	thinktime self : 0.1;
	self.think = DeathBubblesSpawn;
	self.air_finished = self.air_finished + 1;
	if (self.air_finished >= self.count)
		remove(self);
}

void DeathBubbles (float num_bubbles)
{
entity	bubble_spawner, bubble_owner;

	if(self.classname=="contents damager")
		bubble_owner = self.enemy;
	else
		bubble_owner = self;
	bubble_spawner = spawn();
	setorigin (bubble_spawner, bubble_owner.origin+bubble_owner.view_ofs);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.owner = bubble_owner;
	thinktime bubble_spawner : 0.1;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.air_finished = 0;
	bubble_spawner.count = num_bubbles;
}


void DeathSound ()
{
// water death sounds
	if (self.waterlevel == 3)
	{
		DeathBubbles(20);
		if(self.playerclass==CLASS_ASSASSIN)
			sound (self, CHAN_VOICE, "player/assdieh2.wav", 1, ATTN_NONE);
		else
			sound (self, CHAN_VOICE, "player/paldieh2.wav", 1, ATTN_NONE);
		return;
	}
	else
	{
		if(self.playerclass==CLASS_ASSASSIN)
		{
			if (random() > 0.5)
				sound (self, CHAN_VOICE, "player/assdie1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_VOICE, "player/assdie2.wav", 1, ATTN_NORM);
		}
		else if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/paldie1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/paldie2.wav", 1, ATTN_NORM);
	}
}

void PlayerDead ()
{
	self.nextthink = -1;
// allow respawn after a certain time
	self.deadflag = DEAD_DEAD;

	if(self.model!=self.headmodel)
	{
		self.angles_x=self.angles_z=0;
		pitch_roll_for_slope('0 0 0');
	}
}

void ThrowGib (string gibname, float dm)
{
entity new;
float fade;
vector org;
	fade = CheckCfgParm(PARM_FADE);
	//ws: corpses fading can be toggled by console command (impulse 46)
	if (fade)
		new = spawn_temp();
	else
		new = spawn();
	//new.origin = (self.absmin+self.absmax)*0.5;
	org_x = self.absmin_x + random(self.maxs_x - self.mins_x);
	org_y = self.absmin_y + random(self.maxs_y - self.mins_y);
	org_z = self.absmax_z - random(self.maxs_z*0.75);	//bias towards maxs so gibs dont spawn in ground
	setorigin (new, org);
	
	setmodel (new, gibname);
	setsize (new, '0 0 0', '0 0 0');
	new.velocity = VelocityForDamage (dm);
	
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity_x = random(600);
	new.avelocity_y = random(600);
	new.avelocity_z = random(600);
	new.scale=self.scale*random(.5,.9);
	
	if (fade || coop || deathmatch) {
		new.think = SUB_Remove;
		thinktime new : random(20,10);
	}
	else {
		new.think = SUB_Null;	//makestatic;
		thinktime new : -1;
	}
	new.ltime = time;
	new.frame = 0;
	new.flags = 0;
	
	if (new.model == self.headmodel && self.headmodel != "" && self.movetype)	//check movetype because corpses are movetype_none
		setorigin(new, self.origin+self.view_ofs);	//spawn head in logical position
	if (new.model == "models/shardwend.mdl")
	{	
		new.gravity = 0.4;
		if (random(100) < 70)
			new.drawflags(+)DRF_TRANSLUCENT|MLS_FULLBRIGHT;
		new.velocity_x = (random(-50,50));
		new.velocity_y = (random(-50,50));
		new.velocity_z = (random(100,280));
		new.origin_z = new.origin_z - 10;
	}
	else if (new.model == "models/flesh1.mdl" || new.model == "models/flesh2.mdl")
		new.scale = self.scale*random(0.7,1);
	else if (new.model == "models/footsoldierhd.mdl" || new.model == "models/footsoldierhalf.mdl" || new.model == "models/footsoldieraxe.mdl")
	{
		new.avelocity_x = 40+random(20);
		new.avelocity_y = 60+random(20);
		new.avelocity_z = 40+random(20);
		new.angles_y = random(360);
		if (new.model == "models/footsoldieraxe.mdl")
		{
			new.avelocity_x = 0;
			new.avelocity_z = 0;
		}
		new.scale=self.scale*.8;
	}
	else if (new.model == "models/h_fangel.mdl" || new.model == "models/ZombiePal_hd.mdl" || new.model == "models/archerhd.mdl" || new.model == "models/muhead.mdl" || new.model == "models/h_imp.mdl")
	{
		new.avelocity_x = 40+random(20);
		new.avelocity_y = 100+random(20);
		new.avelocity_z = 40+random(20);
		new.angles_y = random(360);
		new.scale=self.scale*1.13;
		if (self.classname == "monster_archer_lord" || self.classname == "monster_fallen_angel_lord" || self.classname == "monster_imp_ice")
			new.skin = 1;
	}
	else if (new.model == "models/impwing.mdl" || new.model == "models/afritwing.mdl" || new.model == "models/impwing_ice.mdl"
		|| new.model == "models/ZombiePal_arm.mdl")
	{
		new.avelocity_x = random(5);
		new.avelocity_y = 100+random(40);
		new.avelocity_z = random(5);
		new.angles_y = random(360);
		if (new.owner.classname != "monster_undying")
			new.scale=self.scale*1.13;
	}
	else if (new.model == "models/archerleg.mdl" || new.model == "models/archerarm.mdl" || new.model == "models/footsoldierleg.mdl" || new.model == "models/footsoldierarm.mdl"
		|| new.model == "models/ZombiePal_leg.mdl")
	{
		new.avelocity_x = 0;
		new.avelocity_y = 100+random(40);
		new.avelocity_z = 100+random(40);
		if (new.model == "models/archerarm.mdl")
			new.avelocity_z = random(5);
		new.angles_y = random(360);
		if (self.classname == "monster_archer_lord" && new.model == "models/archerleg.mdl")	//need skin for arm gib
			new.skin = 1;
		if (new.owner.classname != "monster_undying")
			new.scale=self.scale*.9;
	}
	else if (new.model == "models/blood.mdl")
	{
		new.gravity = 1.3;
		new.origin_z = new.origin_z - 5;
		new.scale = random(.6, 1.2);
		new.frame = 0;
	}
	else if (new.model == "models/bloodpool_ice.mdl")
	{
		new.avelocity = 0;
		new.gravity = 17;
		
		new.drawflags (+) DRF_TRANSLUCENT;
		new.scale = random(0.3,0.7);
		
		if (self.netname == "yakman" || self.netname == "maulotaur")
			new.scale = self.scale*1.25;
	}
	
	if (new.model == "models/blood.mdl" || new.model == "models/bloodpool_ice.mdl" || new.model == "models/shardwend.mdl")
	{	//always fade these out regardless of corpse fading setting
		new.think = ice_melt;	//altdeath.hc
		thinktime new : random(20,10);
	}
}

void ThrowHead (string gibname, float dm)
{
vector org;
	if(self.decap==2)
	{//Brains!
		if(self.movedir=='0 0 0')
		{
			self.movedir=normalize(self.origin+self.view_ofs-self.enemy.origin+self.enemy.proj_ofs);
			self.movedir_z=0;
		}
		traceline(self.origin + self.view_ofs, self.origin+self.view_ofs+self.movedir*100, FALSE, self);
		if (trace_fraction < 1&&!trace_ent.flags2&FL_ALIVE&&trace_ent.solid==SOLID_BSP)
		{
			self.wallspot=trace_endpos;
			ZeBrains(trace_endpos, trace_plane_normal, random(1.3,2), rint(random(1)),random(360));
		}
		else
			self.wallspot='0 0 0';
	}

	//setmodel (self, gibname);	//crashes game
	self.drawflags(+)EF_NODRAW;
	self.frame = 0;
	self.takedamage = DAMAGE_NO;
	if(self.classname!="player")
		self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_BOUNCE;

	self.mass = 1;
	self.view_ofs = '0 0 8';
	self.proj_ofs='0 0 2';
	self.hull=HULL_POINT;
	org=self.origin;
	org_z=self.absmax_z - 4;
	setsize (self, '-4 -4 -4', '4 4 4');
	setorigin(self,org);
	self.flags(-)FL_ONGROUND;
	self.avelocity = randomv('0 -600 0', '0 600 0');

	if(self.decap==2)
		self.velocity = VelocityForDamage (dm)+'0 0 50';
	else
		self.velocity = VelocityForDamage (dm)+'0 0 200';

	if(self.decap==2||(self.decap==1&&vlen(self.velocity)>300))
	{
		if(self.wallspot=='0 0 0')
			self.wallspot=org;
		self.pausetime=time+5;//watch splat or body
	}

	self.think=PlayerDead;
	thinktime self : 1;
}


void PlayerUnCrouching ()
{
	tracearea (self.origin,self.origin+'0 0 28','-16 -16 0','16 16 28',FALSE,self);
	if (trace_fraction < 1)
	{
		if (self.waterlevel < 3)	//ws: dont print message if swimming
			centerprint(self,STR_NOROOM);
		self.crouch_stuck = 1;
		return;
	}

	setsize (self, '-16 -16 0', '16 16 56');
	self.hull=HULL_PLAYER;
	if (self.viewentity.classname=="chasecam")
		self.view_ofs = '0 0 0';

	PlayerSpeed_Calc();
	self.crouch_time = time;

	if (self.velocity_x || self.velocity_y)
		self.act_state=ACT_RUN;
	else
		self.act_state=ACT_STAND;
}

void PlayerCrouching ()
{
	if (self.health <= 0)
		return;

	setsize (self,'-16 -16 0','16 16 28');
	self.hull=HULL_CROUCH;
	if (self.viewentity.classname=="chasecam")
		self.view_ofs = '0 0 0';
	self.absorb_time=time + 0.3;

	PlayerSpeed_Calc();
	self.crouch_time = time;

	self.crouch_stuck = 0;

	self.act_state=ACT_CROUCH_MOVE;
}

void PlayerCrouch ()
{
	if (self.hull==HULL_PLAYER)
		PlayerCrouching();
	else if (self.hull==HULL_CROUCH)
		PlayerUnCrouching();
}


void GibPlayer ()
{
	ThrowHead (self.headmodel, self.health);
	//ThrowGib ("models/flesh1.mdl", self.health);
	ThrowGib ("models/flesh2.mdl", self.health);
	ThrowGib ("models/blood.mdl", self.health);
	ThrowGib ("models/blood.mdl", self.health);
	ThrowGib ("models/blood.mdl", self.health);
	ThrowGib ("models/blood.mdl", self.health);
	//ThrowGib ("models/flesh3.mdl", self.health);
	//ThrowGib ("models/flesh1.mdl", self.health);
	ThrowGib ("models/flesh2.mdl", self.health);
	ThrowGib ("models/flesh3.mdl", self.health);
	BloodSplat(rint(random(0,2)));

	self.deadflag = DEAD_DEAD;

	if (self.deathtype == "teledeath"||self.deathtype == "teledeath2"||self.deathtype == "teledeath3"||self.deathtype == "teledeath4")
	{
		sound (self, CHAN_VOICE, "player/telefrag.wav", 1, ATTN_NONE);
		return;
	}

	if(self.health<-80)
		sound (self, CHAN_VOICE, "player/megagib.wav", 1, ATTN_NONE);
	else if (random() < 0.5)
		sound (self, CHAN_VOICE, "player/gib1.wav", 1, ATTN_NONE);
	else
		sound (self, CHAN_VOICE, "player/gib2.wav", 1, ATTN_NONE);
}

void DecapPlayer ()
{
entity headless;
	headless=spawn();
	headless.classname="headless";
	headless.decap=TRUE;
	headless.movetype=MOVETYPE_STEP;
	headless.solid=SOLID_PHASE;
	headless.frame=50;
	headless.skin=self.skin;
//Took this out so you can't fall "into" it...
//	headless.owner=self;
	headless.thingtype=self.thingtype;
	headless.angles_y=self.angles_y;

	setmodel(headless,self.model);
	setsize(headless,'-16 -16 0','16 16 36');
	setorigin(headless,self.origin);

	headless.playerclass=self.playerclass;
	headless.think=self.th_goredeath;
	thinktime headless : 0;

	self.health=self.health*4;
	if(self.health>-30)
		self.health=-30;
	if(self.decap==2)
	{
		ThrowHead ("models/flesh1.mdl", self.health);
		SpawnPuff(self.origin+self.view_ofs,'0 0 0',fabs(self.health),self);
	}
	else
		ThrowHead (self.headmodel, self.health);
	ThrowGib ("models/flesh1.mdl", self.health);
	ThrowGib ("models/flesh2.mdl", self.health);
	ThrowGib ("models/flesh3.mdl", self.health);

	self.deadflag = DEAD_DEAD;
	if (random() < 0.5)
		sound(self,CHAN_VOICE,"player/decap.wav",1,ATTN_NORM);
	else if (random() < 0.5)
		sound (self, CHAN_VOICE, "player/gib1.wav", 1, ATTN_NONE);
	else
		sound (self, CHAN_VOICE, "player/gib2.wav", 1, ATTN_NONE);
}

void PlayerDie ()
{
	if(self.viewentity!=self)
	{
		if(self.viewentity.classname=="chasecam")
			remove(self.viewentity);
		self.viewentity=self;
		CameraViewPort(self,self);
		CameraViewAngles(self,self);
	}

	msg_entity=self;
	WriteByte(MSG_ONE, SVC_CLEAR_VIEW_FLAGS);
	WriteByte(MSG_ONE,255);

	self.artifact_low =
	self.artifact_active =
	self.invisible_time =
	self.effects=
	self.colormap=0;

	if (deathmatch || coop)
		DropBackpack();

	if(self.model=="models/sheep.mdl")
		self.headmodel="";

	self.weaponmodel="";
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags(-)FL_ONGROUND;
	self.movetype = MOVETYPE_TOSS;
	self.attack_finished=self.teleport_time=self.pausetime=time;
	self.drawflags=self.effects=FALSE;
	if (self.velocity_z < 10)
		self.velocity_z += random(300);

	self.artifact_active = 0;
	self.rings_active =0;

	if (self.deathtype == "teledeath"||self.deathtype == "teledeath2"||self.deathtype == "teledeath3"||self.deathtype == "teledeath4")
	{
		self.decap=0;
		self.health=-99;
	}

	if(self.deathtype=="ice shatter"||self.deathtype=="stone crumble")
	{
		shatter();
		ThrowHead(self.headmodel,self.health);
		if(self.health<-99)
			self.health=-99;
		return;
	}
	else if(self.decap)
	{
		DecapPlayer();
		if(self.health<-99)
			self.health=-99;
		return;
	}
	else if(self.health < -40||self.model=="models/sheep.mdl")//self.modelindex==modelindex_sheep)
	{
		GibPlayer ();
		if(self.health<-99)
			self.health=-99;
		return;
	}

	DeathSound();

	self.angles_x = 0;
	self.angles_z = 0;

	self.act_state=ACT_DEAD;
	player_frames();
	
	if(self.health<-99)
		self.health=-99;
}

void set_suicide_frame ()
{	// used by kill command and disconnect command
	if (self.model != self.init_model)
		return;	// already gibbed
//have a self.deathframe value?  Or just if-thens
//	self.frame = $deatha11;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.nextthink = -1;
}

void Head ()
{
	ThrowSolidHead(0);
}

void Corpse ()
{
	MakeSolidCorpse();
}

void SolidPlayer ()
{
entity corpse;
	corpse = spawn();
	if(self.angles_x>15||self.angles_x<-15)
		self.angles_x=0;
	if(self.angles_z>15||self.angles_z<-15)
		self.angles_z=0;
	corpse.angles = self.angles;
	setmodel(corpse,self.model);
	corpse.frame = self.frame;
	corpse.colormap = self.colormap;
	corpse.movetype = self.movetype;
	corpse.velocity = self.velocity;
	corpse.flags = 0;
	corpse.effects = 0;
	corpse.skin = self.skin;
	corpse.controller = self;
	corpse.thingtype=self.thingtype;
	setorigin (corpse, self.origin);
	if(self.model==self.headmodel)
	{
		self.classname="head";//So they don't get mixed up with players
		corpse.think=Head;
	}
	else
	{
		self.classname="corpse";//So they don't get mixed up with players
		corpse.think=Corpse;
	}
	thinktime corpse : 0;
}

void player_behead ()
{
	self.frame=self.level+self.cnt;
	makevectors(self.angles);
	if(!self.cnt)
		MeatChunks (self.origin + '0 0 50',v_up*200, 3,self);
	else if (self.cnt==1)
	{
		SpawnPuff (self.origin+v_forward*8, '0 0 48', 30,self);
		sound (self, CHAN_AUTO, "misc/decomp.wav", 1, ATTN_NORM);
	}
	else if (self.cnt==3)
	{
		SpawnPuff (self.origin+v_forward*16, '0 0 36'+v_forward*16, 20,self);
		sound (self, CHAN_AUTO, "misc/decomp.wav", 1, ATTN_NORM);
	}
	else if (self.cnt==5)
	{
		SpawnPuff (self.origin+v_forward*28, '0 0 20'+v_forward*32, 15,self);
		sound (self, CHAN_AUTO, "misc/decomp.wav", 0.8, ATTN_NORM);
	}
	else if (self.cnt==8)
	{
		SpawnPuff (self.origin+v_forward*40, '0 0 10'+v_forward*40, 10,self);
		sound (self, CHAN_AUTO, "misc/decomp.wav", 0.6, ATTN_NORM);
	}
	if (self.frame==self.dmg)
	{
		SpawnPuff (self.origin+v_forward*56, '0 0 -5'+v_forward*40, 5,self);
		sound (self, CHAN_AUTO, "misc/decomp.wav", 0.4, ATTN_NORM);
		ReadySolid();
	}
	else
	{
		self.think=player_behead;
		thinktime self : 0.1;
	}
	self.cnt+=1;
}

/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/magicmis.hc,v 1.2 2007-02-07 16:57:07 sezero Exp $
 */

/*
==============================================================================

Q:\art\models\weapons\spllbook\spllbook.hc

==============================================================================
*/

// For building the model
$cd Q:\art\models\weapons\spllbook
$origin 0 0 0
$base BASE skin
$skin skin
$flags 0

//
$frame fire1        fire2        fire3        fire4        fire5        
$frame fire6        fire7        fire8        fire9        fire10       
$frame fire11       fire12       

//
$frame go2mag01     go2mag02     go2mag03     go2mag04     go2mag05     
$frame go2mag06     go2mag07     go2mag08     go2mag09     go2mag10     
$frame go2mag11     go2mag12     go2mag13     
$frame go2shd1      go2shd2      
$frame go2shd3      go2shd4      go2shd5      go2shd6      go2shd7      
$frame go2shd8      go2shd9      
$frame go2shd10		go2shd11     go2shd12     go2shd13     go2shd14

//
$frame idle1        idle2        idle3        idle4        idle5        
$frame idle6        idle7        idle8        idle9        idle10       
$frame idle11       idle12       idle13       idle14       idle15       
$frame idle16       idle17       idle18       idle19       idle20       
$frame idle21       idle22       

//
$frame mfire1       mfire2       mfire3       mfire4       mfire5       
$frame mfire6       mfire7       mfire8       

//
$frame midle01      midle02      midle03      midle04      midle05      
$frame midle06      midle07      midle08      midle09      midle10      
$frame midle11      midle12      midle13      midle14      midle15      
$frame midle16      midle17      midle18      midle19      midle20      
$frame midle21      midle22      

//
$frame mselect01    mselect02    mselect03    mselect04    mselect05    
$frame mselect06    mselect07    mselect08    mselect09    mselect10    
$frame mselect11    mselect12    mselect13    mselect14    mselect15    
$frame mselect16    mselect17    mselect18    mselect19    mselect20    

//
$frame select1      select2      select3      select4      select5      
$frame select6      select7      


float MMIS_COST = 2;
float MMIS_TOME_COST = 8;
float MMIS_ALT_COST = 1;
float MMIS_ALT_TOME_COST = 12;
float MMIS_SHOCK_COST = 0.5;
float MMIS_SHOCK_ANGLE = 37;

void chain_remove ()
{
	if(self.movechain.movechain!=world)
		remove(self.movechain.movechain);
	if(self.movechain!=world)
		remove(self.movechain);
	remove(self);
}

void MagicMissileTouch (void)
{
	if(other.classname==self.classname&&other.owner==self.owner)
		return;

	if(self.movechain.movechain!=world)
		remove(self.movechain.movechain);
	if(self.movechain!=world)
		remove(self.movechain);
	self.level=FALSE;
	if(other.takedamage)
		T_Damage(other,self,self.owner,self.dmg);

	T_RadiusDamage(self,self.owner,self.dmg / 2,other);
	sound(self,CHAN_AUTO,"weapons/explode.wav",1,ATTN_NORM);
	starteffect(CE_MAGIC_MISSILE_EXPLOSION,self.origin-self.movedir*8,0.05);
	remove(self);
}
/*
void TorpedoTrail (void)
{
	particle4(self.origin,7,random(148,159),PARTICLETYPE_GRAV,random(10,20));
}
*/
void StarTwinkle (void)
{
	if(!self.owner.level)
		remove(self);

	if(self.owner.owner.classname!="monster_eidolon")
	if(!self.aflag)
	{
		self.scale+=0.05;
		if(self.scale>=1)
			self.aflag=TRUE;
	}
	else
	{
		self.scale-=0.05;
		if(self.scale<=0.01)
			self.aflag=FALSE;
	}
//	if(random()<0.3)
//		TorpedoTrail();
	self.think=StarTwinkle;
	thinktime self : 0.05;
}

void FireMagicMissile (float offset, float seeking)
{
	entity star1,star2;
	vector spread;
	float tome;
	float wismod, intmod;

	if(self.classname=="monster_eidolon")
		v_forward=self.v_angle;
	else
		makevectors(self.v_angle);
	
	tome = self.artifact_active&ART_TOMEOFPOWER;
	wismod = self.wisdom;		//wis starts at ~12	
	intmod = self.intelligence;	//int starts at ~16

	self.effects(+)EF_MUZZLEFLASH;
	newmis=spawn();
	newmis.classname="magic missile";
	newmis.owner=self;
	newmis.drawflags(+)SCALE_ORIGIN_CENTER;//|DRF_TRANSLUCENT;
	newmis.movetype=MOVETYPE_FLYMISSILE;
	newmis.solid=SOLID_BBOX;

	newmis.touch=MagicMissileTouch;

	newmis.speed=1000;
	spread=normalize(v_right)*(offset*25);
	newmis.velocity=normalize(v_forward)*newmis.speed + spread;
	newmis.movedir=normalize(newmis.velocity);
	newmis.avelocity_z=random(300,600);
	newmis.level=TRUE;

	setmodel(newmis,"models/proj_ball.mdl");
	setsize(newmis,'0 0 0','0 0 0');
	
	newmis.drawflags(+)MLS_FULLBRIGHT;
	
	if (seeking)
	{
		newmis.effects=EF_DIMLIGHT;
		newmis.frags=TRUE;
		newmis.hoverz=TRUE;
		newmis.turn_time=2;
		newmis.lifetime=time+5;
		newmis.th_die=chain_remove;
		newmis.think=HomeThink;
		thinktime newmis : 0.2;
			
		if(self.classname=="monster_eidolon")
		{
			newmis.scale=0.75;
			setorigin(newmis,self.origin+self.proj_ofs+v_forward*48+v_right*20);
			sound(self,CHAN_AUTO,"eidolon/spell.wav",1,ATTN_NORM);
			
			newmis.enemy=self.enemy;
			newmis.classname = "eidolon spell";
			newmis.homerate = 0.1;
			newmis.turn_time=3;
			newmis.dmg=random(30,40);
		}
		else
		{	//ws: changed so magic missile fire rate is the same across levels but homing improves
			newmis.homerate=0.4-(intmod*0.01);	//newmis.homerate=0.16-(self.level*0.01);
			if (newmis.homerate<0.01)
				newmis.homerate=0.01;
			
			if (tome)
			{
				newmis.dmg = 40 + wismod;	//newmis.dmg=random(45,60);
				newmis.scale=1.5;
				newmis.veer = 110 - intmod;
				if (newmis.veer < 30)
					newmis.veer = 30;
			}
			else
			{
				newmis.dmg = 15 + (wismod * 0.75);	//newmis.dmg = random(22,28);
				newmis.scale=1;
				newmis.veer = 50 - intmod;
				if (newmis.veer < 10)
					newmis.veer = 10;
			}
			
			setorigin(newmis,self.origin+self.proj_ofs+v_forward*8+v_right*7+'0 0 5');
			sound(newmis,CHAN_AUTO,"necro/mmfire.wav",1,ATTN_NORM);
		}
	}
	else
	{
		newmis.think=chain_remove;
		thinktime newmis : 3;
	}

	star1=spawn();
	newmis.movechain = star1;
	star1.drawflags(+)MLS_ABSLIGHT;
	star1.abslight=0.5;
	star1.avelocity_z=500;
	star1.avelocity_y=400;
	star1.angles_y=90;
	if(self.classname=="monster_eidolon")
		setmodel(star1,"models/glowball.mdl");
	else
	{
		if (tome)
		{
			setmodel(star1,"models/proj_lt.mdl");
			star1.scale=0.3;
		}
		else
		{
			setmodel(star1,"models/star.mdl");
			star1.scale=0.3;
		}
	}
	setorigin(star1,newmis.origin);
	star2=spawn();
	if(self.classname!="monster_eidolon")
	{
		star1.movechain = star2;
		star2.drawflags(+)MLS_ABSLIGHT;
		star2.abslight=0.5;
		star2.avelocity_z=-500;
		star2.avelocity_y=-400;
		star2.scale=0.3;
		setmodel(star2,"models/star.mdl");
		if (tome)
			setmodel(star2,"models/proj_lt.mdl");
		else
			setmodel(star2,"models/star.mdl");
		setorigin(star2,newmis.origin);
	}
	star1.movetype=star2.movetype=MOVETYPE_NOCLIP;
	star1.owner=star2.owner=newmis;
	star1.think=star2.think=StarTwinkle;
	thinktime star1 : 0;
	thinktime star2 : 0;
}

void flash_think ()
{
	makevectors(self.owner.v_angle);
	self.angles_x=self.owner.v_angle_x*-1;
	self.angles_y=self.owner.v_angle_y;
	setorigin(self,self.owner.origin+self.owner.proj_ofs+'0 0 5'+v_right*2+v_forward*6);
	thinktime self : 0.01;
	self.abslight-=0.05;
	self.scale+=0.05;
	if(self.lifetime<time||self.abslight<=0.05)
		remove(self);
}

void FireFlash ()
{
	makevectors(self.v_angle);
	newmis=spawn();
	newmis.movetype=MOVETYPE_NOCLIP;
	newmis.owner=self;
	newmis.abslight=0.5;
	newmis.scale=random(0.8,1.2);
	newmis.drawflags(+)MLS_ABSLIGHT|DRF_TRANSLUCENT;

	setmodel(newmis,"models/handfx.mdl");
	setorigin(newmis,self.origin+self.proj_ofs+'0 0 5'+v_right*2+v_forward*6);

	newmis.angles=self.v_angle;
	newmis.angles_x=self.v_angle_x*-1;
	newmis.angles_z=random(360);
	newmis.avelocity_z=random(360,720);
//	newmis.velocity=random(30)*v_forward;

	newmis.lifetime=time+0.075;
	newmis.think=flash_think;
	thinktime newmis : 0;
}

void mmis_normal()
{
	float cost;
	float tome;
	
	if(self.attack_finished>time)
		return;

	tome = self.artifact_active&ART_TOMEOFPOWER;
	
	cost = MMIS_COST;
	FireFlash();
	FireMagicMissile(0, TRUE);
	
	if (tome)
	{
		FireMagicMissile(-3, TRUE);
		FireMagicMissile(3, TRUE);
		cost = MMIS_TOME_COST;
	}
	
	self.bluemana-=cost;
	if (tome)
		self.attack_finished = time+0.7;
	else
		self.attack_finished = time+0.3;
	
	/*self.attack_finished = time+(0.625 - self.level*0.025);
	if (self.attack_finished<time+0.2)	//vanilla magic missile delay
		self.attack_finished = time+0.2;*/
}

//==========
//Star Wall
//==========

void starwall_field_touch()
{
	//if (time < self.attack_finished)
	//	return;
	
	if (!fov(other, self.owner, 150))
		return;
	
	if !(ReflectMissile (other, REFLECT_BLOCK, 0, 0.9, 40, 180, TRUE, CLASS_BOSS))
		return;
	
	sound(self,5,"mezzo/reflect.wav",1,ATTN_NORM);
	
	//self.attack_finished = time+0.1;
}

void starwall_field_think()
{
	setorigin (self, self.owner.origin);
	
	if (!EnemyIsValid(self.owner) || self.owner.bluemana < MMIS_ALT_COST || time > self.lifetime) {
		sound(self,CHAN_VOICE,"necro/hum3.wav",1,ATTN_NORM);
		
		if (self.owner.flags&FL_CLIENT)
			self.owner.class_weaponvar = FALSE;		//allow player to cast another star wall
		
		entity ent;
		ent = self.enemy;
		while (ent.controller==self) {
			ent.aflag = TRUE;	//tracked by starwall_think
			ent = ent.enemy;	//navigate linked list
		}
		
		self.think = SUB_Remove;
		thinktime self : HX_FRAME_TIME*2;
		return;
	}
	
	if (time > self.pain_finished) {
		self.pain_finished = time+1;
		self.owner.bluemana -= MMIS_ALT_COST;
	}
	
	self.think = starwall_field_think;
	thinktime self : 0;
}

void starwall_think()
{
	makevectors(self.owner.v_angle);
	self.finaldest = self.owner.origin + v_forward*36 + v_right*self.oldangles_y + v_up*self.oldangles_z;
	
	traceline (self.owner.origin, self.finaldest, TRUE, self.owner);
	setorigin (self, trace_endpos);
	
	if (pointcontents(trace_endpos)==CONTENT_SOLID)
		trace_endpos += v_forward*-8;	//offset sprite from wall
	
	//self.angles = self.owner.v_angle;
	self.angles_x = self.owner.v_angle_x;
	self.angles_y = self.owner.v_angle_y;
	
	if (self.pain_finished) {
		self.pain_finished = time+HX_FRAME_TIME;
		if (self.abslight>=1)
			self.lefty = -1;
		else if (self.abslight<=0.5)
			self.lefty = 1;
		
		self.abslight += 0.02*self.lefty;
		
		if (self.aflag) {
			self.scale -= 0.01;
			particle4(self.origin,7,random(148,159),PARTICLETYPE_STATIC,1);
		}
		if (self.scale<=0.05) {
			remove(self);
			return;
		}
	}
	
	thinktime self : 0;
}

float StarwallVertOfs[11] =
{
	10,
	20,
	30,
	35,
	40,
	45,
	50,
	55,
	60,
	65,
	70
};

float StarwallHorOfs[11] =
{
	-16,
	16,
	-16,
	16,
	-16,
	16,
	-16,
	16,
	-16,
	16,
	-16
};

void mmis_wall()
{
	entity field, star, laststar, firststar;
	float i;
	
	if (self.attack_finished>time)
		return;
	if (self.class_weaponvar)	//if we already have an active star wall
		return;
	
	FireFlash();
	self.bluemana -= MMIS_ALT_COST;
	self.attack_finished = time+0.4;
	self.class_weaponvar = TRUE;
	if (random()<0.5)
		sound(self,5,"necro/hum1.wav",1,ATTN_NORM);
	else
		sound(self,5,"necro/hum2.wav",1,ATTN_NORM);
	
	field = spawn();
	field.owner = self;
	
	setmodel (field, "models/null.spr");
	//setsize (field, '-24 -24 0', '24 24 60');
	setsize (field, '-48 -48 0', '48 48 60');
	setorigin (field, self.origin);
	
	field.effects = EF_NODRAW;
	field.movetype = MOVETYPE_NONE;
	field.solid = SOLID_TRIGGER;
	
	field.lifetime = time+6;
	field.pain_finished = time+1;	//drain mana at this time
	
	field.touch = starwall_field_touch;
	field.think = starwall_field_think;
	thinktime field : 0;
	
	for (i = 0; i < 11; i++) {
		float side, up;
		
		star = spawn();
		star.owner = self;
		star.controller = field;
		
		setmodel(star,"models/star.mdl");
		setsize(star, VEC_ORIGIN, VEC_ORIGIN);
		
		star.movetype = MOVETYPE_NOCLIP;
		star.solid = SOLID_NOT;
		
		star.drawflags(+)MLS_ABSLIGHT|DRF_TRANSLUCENT;
		star.abslight=0.5;
		star.avelocity_z=150;
		star.avelocity_z*=randomsign();
		star.scale=random(0.15,0.3);
		
		star.lefty = 1;
		star.pain_finished = time+random();		//light phase
		
		star.think = starwall_think;
		thinktime star : 0;
		/*
		side = random(0.25,3)*(i+1);
		up = random(4,6)*(i+2);*/
		side = StarwallHorOfs[i]+random(-6,6);
		up = StarwallVertOfs[i]+random(-4,4);
		star.oldangles_y = side;
		star.oldangles_z = up;
		//lastoffset = up;
		
		if (laststar)
			laststar.enemy = star;
		else
			firststar = star;
		
		laststar = star;	//create linked list of stars
	}
	field.enemy = firststar;
}

void starproj_die ()
{
	sound(self,CHAN_AUTO,"weapons/explode.wav",1,ATTN_NORM);
	starteffect(CE_MAGIC_MISSILE_EXPLOSION,self.origin-self.movedir*8,0.05);
	particleexplosion(self.origin,COLOR_PURPLE_BRIGHT,10,60);
	remove(self);
}

void starproj_think ()
{
	if (self.flags&FL_ONGROUND) {
		starproj_die();
		return;
	}
	
	if (self.scale>1.75)
		self.lefty = -1;
	else if (self.scale<0.5)
		self.lefty = 1;
	self.scale+=0.075*self.lefty;
	
	if(self.velocity!=self.movedir*self.speed)
		self.velocity=self.movedir*self.speed;
	
	self.think=starproj_think;
	thinktime self : 0.025;
}

void starproj_touch ()
{
	if (pointcontents(self.origin)==CONTENT_SKY) {
		remove(self);
		return;
	}
	
	if (self.enemy && other==self.enemy)
		return;
	
	if (other==world
		||(!other.takedamage)
		||(other.solid==SOLID_BSP&&other.thingtype!=THINGTYPE_GLASS&&other.thingtype!=THINGTYPE_CLEARGLASS&&other.thingtype!=THINGTYPE_REDGLASS&&other.thingtype!=THINGTYPE_WEBS) 
		|| other.mass>300
		|| self.frags>=self.count) {
		starproj_die();
		return;
	}
	
	self.enemy=other;
	self.owner=other;
	self.frags+=1+other.monsterclass;
	makevectors(self.velocity);
	
	SpawnPuff (self.origin - v_forward*8, self.velocity, 8, other);
	if(other.thingtype==THINGTYPE_FLESH) {
		MeatChunks (self.origin,self.velocity+'0 0 20', 2, other);
		sound(self,CHAN_VOICE,"assassin/core.wav",0.75,ATTN_NORM);
	}
	
	if(other.flags&FL_CLIENT)
		T_Damage(other,self,self.owner,self.dmg*0.5);
	else
		T_Damage(other,self,self.owner,self.dmg);
}

void mmis_starproj ()
{
	if (self.attack_finished>time)
		return;
	
	FireFlash();
	self.effects(+)EF_MUZZLEFLASH;
	self.bluemana -= MMIS_ALT_TOME_COST;
	self.attack_finished = time+0.5;
	//sound(self,5,"necro/hum1.wav",1,ATTN_NORM);
	makevectors(self.v_angle);
	
	newmis = spawn();
	newmis.owner = self;
	
	setmodel(newmis,"models/star.mdl");
	setsize(newmis, '4 4 0', '4 4 0');
	//setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, self.origin+self.proj_ofs + v_forward*8);
	
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	
	newmis.speed = 1000;
	newmis.velocity = v_forward*newmis.speed;
	newmis.angles = vectoangles(newmis.velocity);
	newmis.movedir = v_forward;
	newmis.angles_x = 100;
	newmis.o_angle = newmis.angles;
	
	newmis.scale = 0.5;
	newmis.drawflags(+)MLS_ABSLIGHT;
	newmis.drawflags(+)SCALE_TYPE_XYONLY;
	newmis.abslight = 0.5;
	newmis.avelocity_z = 400;
	
	newmis.count = 12;
	newmis.dmg = 40;
	newmis.touch = starproj_touch;
	newmis.think = starproj_think;
	thinktime newmis : HX_FRAME_TIME;
}


/*======================
ACTION
select
deselect
ready loop
relax loop
fire once
fire loop
ready to relax(after short delay)
relax to ready(Fire delay?  or automatic if see someone?)
=======================*/


void()magicmis_ready;
void() Nec_Mis_Attack;

void magicmis_altfire (void)
{
	float tome, cost;
	
	tome = self.artifact_active&ART_TOMEOFPOWER;
	
	if(self.button1 && self.weaponframe==$mfire5 && !self.artifact_active&ART_TOMEOFPOWER)
		self.weaponframe=$mfire5;
	else
		self.wfs = advanceweaponframe($mfire1,$mfire8);
	self.th_weapon=magicmis_altfire;
	self.last_attack=time;
	
	if (self.class_weaponvar)	//if we cant create another star wall, we can only do the main fire
		cost = MMIS_ALT_TOME_COST;
	else
		cost = MMIS_ALT_COST;
	
	if(self.wfs==WF_CYCLE_WRAPPED||self.bluemana<cost)
	{
		magicmis_ready();		
	}
	else if(self.weaponframe==$mfire5)
	{
		if (tome && self.bluemana >= MMIS_ALT_TOME_COST)
			mmis_starproj();
		else
			mmis_wall();
	}
}

void magicmis_fire (void)
{
	float tome, cost;
	
	tome = self.artifact_active&ART_TOMEOFPOWER;
	
	if(self.button0&&self.weaponframe==$mfire5 &&!self.artifact_active&ART_TOMEOFPOWER)
		self.weaponframe=$mfire5;
	else
		self.wfs = advanceweaponframe($mfire1,$mfire8);
	self.th_weapon=magicmis_fire;
	self.last_attack=time;

	cost = MMIS_COST;
	if (tome)
	{
		cost = MMIS_TOME_COST;
	}
	
	if(self.wfs==WF_CYCLE_WRAPPED||self.bluemana<cost)
	{
		magicmis_ready();		
	}
	else if(self.weaponframe==$mfire5)
	{
		mmis_normal();
	}
}

//FIRE/ALTFIRE

void() Nec_Mis_Attack =
{
	if (self.button1 && self.bluemana >= MMIS_SHOCK_COST)
		magicmis_altfire();
	else
		magicmis_fire();

	thinktime self : 0;
};

void magicmis_jellyfingers ()
{
	self.wfs = advanceweaponframe($midle01,$midle22);
	self.th_weapon=magicmis_jellyfingers;
	if(self.wfs==WF_CYCLE_WRAPPED)
		magicmis_ready();
}

void magicmis_ready (void)
{
	self.weaponframe=$midle01;
	if(random()<0.1&&random()<0.3&&random()<0.5)
		self.th_weapon=magicmis_jellyfingers;
	else
		self.th_weapon=magicmis_ready;
}


void magicmis_select (void)
{
	self.wfs = advanceweaponframe($mselect01,$mselect20);
	self.weaponmodel = "models/spllbook.mdl";
	self.th_weapon=magicmis_select;
	if(self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		magicmis_ready();
	}
}

void magicmis_deselect (void)
{
	self.wfs = advanceweaponframe($mselect20,$mselect01);
	self.th_weapon=magicmis_deselect;
	if(self.wfs==WF_CYCLE_WRAPPED)
		W_SetCurrentAmmo();
}

void magicmis_select_from_bone (void)
{
	self.wfs = advanceweaponframe($go2mag01,$go2mag13);
	self.weaponmodel = "models/spllbook.mdl";
	self.th_weapon=magicmis_select_from_bone;
	if(self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		magicmis_ready();
	}
}


/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/boner.hc,v 1.2 2007-02-07 16:56:56 sezero Exp $
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

//
$frame go2shd01     go2shd02     
$frame go2shd03     go2shd04     go2shd05     go2shd06     go2shd07      
$frame go2shd08     go2shd09     go2shd10     go2shd11     go2shd12      
$frame go2shd13     go2shd14      

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

float BONE_BALL_COST = 8;
float BONE_TOMED_COST = 4;
float BONE_NORMAL_COST = 1;

void boneshard_ready(void);

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

void(vector org)smolder;
void(vector org, float damage) Ricochet =
{
//float r;
	particle4(org,3,random(368,384),PARTICLETYPE_GRAV,damage/2);
/*	r = random(100);
	if (r > 95)
		sound (targ,CHAN_AUTO,"weapons/ric1.wav",1,ATTN_NORM);
	else if (r > 91)
		sound (targ,CHAN_AUTO,"weapons/ric2.wav",1,ATTN_NORM);
	else if (r > 87)
		sound (targ,CHAN_AUTO,"weapons/ric3.wav",1,ATTN_NORM);
*/
};

entity  multi_ent;
float   multi_damage;

void() ClearMultDamg =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultDamg =
{
	float kicker, inertia;
	if (!multi_ent)
		return;

	entity loser,winner;
	winner=self;
    loser=multi_ent;
    kicker = multi_damage * 7 - (vlen(winner.origin - loser.origin));
	if(kicker>0)
	{	
        if(loser.flags&FL_ONGROUND)
		{	
			loser.flags(-)FL_ONGROUND;
			loser.velocity_z = loser.velocity_z + 150;
		}
        if (loser.mass<=10)
			inertia = 1;
                  else inertia = loser.mass/10;
            if(loser==self)
                    loser.velocity = loser.velocity - (normalize(loser.v_angle) * (kicker / inertia));
            else loser.velocity = loser.velocity + (normalize(winner.v_angle) * (kicker / inertia));
        T_Damage (loser, winner, winner, multi_damage);
	}
};

void(entity hit, float damage) AddMultDamg =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultDamg ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

void(float damage, vector dir) TraceHit =
{
	local   vector  vel, org;
	
	vel = (normalize(dir + v_factorrange('-1 -1 0','1 1 0')) + 2 * trace_plane_normal) * 200;
	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		SpawnPuff (org, vel*0.1, damage*0.25,trace_ent);
		AddMultDamg (trace_ent, damage);
	}
	else
		Ricochet(org,damage);
};

void(float shotcount, vector dir, vector spread) InstantDamage =
{
	vector direction;
	vector  src;
	
	makevectors(self.v_angle);

	src = self.origin + self.proj_ofs+'0 0 6'+v_forward*10;
	ClearMultDamg ();
	while (shotcount > 0)
	{
		direction = dir + random(-1,1)*spread_x*v_right;
		direction += random(-1,1)*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceHit (4, direction);
		shotcount = shotcount - 1;
	}
	ApplyMultDamg ();
};

void bone_shard_touch ()
{
	if(other==self.owner)
		return;
	string hitsound;

	if(other.takedamage)
	{
		hitsound="necro/bonenhit.wav";
		T_Damage(other, self,self.owner,self.dmg);
	}
	else
	{
		hitsound="necro/bonenwal.wav";
		T_RadiusDamage(self,self.owner,self.dmg*2,self.owner);
	}

	starteffect(CE_WHITE_SMOKE, self.origin,'0 0 0', HX_FRAME_TIME);
	sound(self,CHAN_WEAPON,hitsound,1,ATTN_NORM);
	particle4(self.origin,3,random(368,384),PARTICLETYPE_GRAV,self.dmg/2);

	endeffect(MSG_ALL,self.wrq_effect_id);

	remove(self);	
}

void bone_removeshrapnel (void)
{
	endeffect(MSG_ALL,self.wrq_effect_id);
	remove(self);	
}

void fire_bone_shrapnel ()
{
	vector shard_vel;
	float intmod;
	
	if (self.owner.classname == "player")
		intmod = self.owner.intelligence;
	else
		intmod = 12;
	
	newmis=spawn();
	newmis.owner=self.owner;
	newmis.movetype=MOVETYPE_BOUNCE;
	newmis.solid=SOLID_PHASE;
	newmis.effects (+) EF_NODRAW;
	newmis.touch=bone_shard_touch;
	newmis.dmg=15;
	newmis.think=bone_removeshrapnel;
	thinktime newmis : 3;

	newmis.speed=777;
	trace_fraction=0;
	trace_ent=world;
	while(trace_fraction!=1&&!trace_ent.takedamage)
	{
		shard_vel=randomv('1 1 1','-1 -1 -1');
		traceline(self.origin,self.origin+shard_vel*36,TRUE,self);
	}
	newmis.velocity=shard_vel*newmis.speed;
	newmis.avelocity=randomv('777 777 777','-777 -777 -777');

	setmodel(newmis,"models/boneshrd.mdl");
	setsize(newmis,'0 0 0','0 0 0');
	setorigin(newmis,self.origin+shard_vel*8);

	newmis.wrq_effect_id = starteffect(CE_BONESHRAPNEL, newmis.origin, newmis.velocity,
		newmis.angles,newmis.avelocity);

}

void bone_shatter ()
{
	float intmod;
	intmod = self.owner.intelligence;
	float shard_count;
	
	if (self.owner.artifact_active & ART_TOMEOFPOWER)
		shard_count = rint(74+(intmod/4));	//approx. 80 at level 3
		//shard_count = 60;
	else
		shard_count = rint(12+(intmod/4));	//approx. 20 at lvl 3
		//shard_count = 20;
	
	while(shard_count)
	{
		fire_bone_shrapnel();
		shard_count-=1;
	}
}

void bone_turret_fire ()
{
	entity newmis;
	newmis=spawn();
	
	setorigin(newmis,self.origin+randomv('0 0 -7','0 0 7'));
	
	newmis.controller=self;
	newmis.owner=self.owner;
	newmis.movetype=MOVETYPE_FLYMISSILE;
	newmis.solid=SOLID_BBOX;
	newmis.scale=0.75;
	
	newmis.speed=1000;
	makevectors(self.angles);
	newmis.velocity=v_forward*newmis.speed;
	newmis.angles=vectoangles(newmis.velocity);
	
	newmis.dmg=random(8,16);
	newmis.touch=bone_shard_touch;
	setmodel(newmis,"models/boneshot.mdl");
	setsize(newmis,'0 0 0','0 0 0');

	newmis.wrq_effect_id = starteffect(CE_BONESHARD, newmis.origin, newmis.velocity,
		newmis.angles,newmis.avelocity);
}

void bone_turret_think ()
{
	if (self.owner.level < 20)	//shrinks slower the higher your level
		self.scale-=(0.02-self.owner.level*0.001);
	else
		self.scale-=0.005;
	
	self.angles_y+=(10*self.aflag);
	
	particle4(self.origin,30,random(368,384),PARTICLETYPE_GRAV,1);
	
	//local float chance = 32 + self.owner.wisdom;	//45-50 on level 3
	local float chance;
	
	chance = 35 + self.owner.wisdom;	//50-55 at level 3
	if (chance > 90)
		chance = 90;
	
	if (random(0,100) < chance)
	{
		//check if its aimed at a wall
		makevectors(self.angles);
		traceline(self.origin,self.origin+v_forward*2,TRUE,self);
		if (trace_fraction != 1)
		{
			self.aflag *= (-1);		//reverse direction
			self.angles_y+=(20*self.aflag);
		}
		sound(self,CHAN_WEAPON,"necro/bonefnrm.wav",0.5,ATTN_NORM);
		bone_turret_fire();
	}
	thinktime self : 0.1;
	
	if (self.scale < 0.5)
	{
		sound(self,CHAN_BODY,"necro/bonethit.wav",1,0.5);
		starteffect(CE_SLOW_WHITE_SMOKE, self.origin,'0 0 0', HX_FRAME_TIME);
		particle4(self.origin,50,random(368,384),PARTICLETYPE_GRAV,10);
		remove(self);
	}
}

void bone_ball_touch ()
{
	if(other.takedamage)
	{
		T_Damage(other, self,self.owner,self.dmg);
	}
	
	self.flags2(+)FL2_ADJUST_MON_DAM;
	
	if (self.scale > 1)	//begin turret sequence
	{
		/*makevectors(self.angles);
		traceline(self.origin,self.origin+v_up*2,TRUE,self);
		if (trace_fraction != 1)	//hit ceiling?
			setorigin (self, self.origin + '0 0 -8');
		else
		{
			traceline(self.origin,self.origin+v_up*(-2),TRUE,self);
			if (trace_fraction != 1)	//hit floor?
				setorigin (self, self.origin + '0 0 8');
		}*/
		
		sound(self,CHAN_BODY,"necro/bonenwal.wav",1,ATTN_NORM);
		self.solid = SOLID_PHASE;
		self.angles = self.velocity = self.avelocity = '0 0 0';
		self.drawflags(+)MLS_ABSLIGHT;
		self.abslight=0.5;
		self.aflag = 1;		//used to reverse direction when aim is blocked by wall
		self.touch = SUB_Null;
		self.think = bone_turret_think;
		thinktime self : HX_FRAME_TIME;
	}
	else	//explode & remove
	{
		sound(self,CHAN_BODY,"necro/bonephit.wav",1,ATTN_NORM);
		if(other.takedamage)
		{
			vector randomvec;
			randomvec=randomv('-20 -20 -20','20 20 20');
			starteffect(CE_GHOST, self.origin-self.movedir*8+randomvec,'0 0 30'+randomvec, 0.1);
			randomvec=randomv('-20 -20 -20','20 20 20');
			starteffect(CE_GHOST, self.origin-self.movedir*8+randomvec,'0 0 30'+randomvec, 0.1);
			randomvec=randomv('-20 -20 -20','20 20 20');
			starteffect(CE_GHOST, self.origin-self.movedir*8+randomvec,'0 0 30'+randomvec, 0.1);
			randomvec=randomv('-20 -20 -20','20 20 20');
			starteffect(CE_GHOST, self.origin-self.movedir*8+randomvec,'0 0 30'+randomvec, 0.1);
		}
		self.solid=SOLID_NOT;
		bone_shatter();
		starteffect(CE_BONE_EXPLOSION, self.origin-self.movedir*6,'0 0 0', HX_FRAME_TIME);
		particle4(self.origin,50,random(368,384),PARTICLETYPE_GRAV,10);
		remove(self);
	}
}
/*
void power_trail()
{
	if(self.owner.classname!="player")
		dprint("ERROR: Bone powered owner not player!\n");
	if(self.touch==SUB_Null)
		dprint("ERROR: Bone powered touch is null!\n");

	particle4(self.origin,10,random(368,384),PARTICLETYPE_SLOWGRAV,3);
	thinktime self : 0.05;
}
*/

void bone_smoke_fade ()
{
	thinktime self : 0.05;
	self.abslight-=0.05;
	self.scale+=0.05;
	if(self.abslight==0.35)
		self.skin=1;
	else if(self.abslight==0.2)
		self.skin=2;
	else if(self.abslight<=0.1)
		remove(self);
}

void MakeBoneSmoke ()
{
entity smoke;
	smoke=spawn_temp();
	smoke.movetype=MOVETYPE_FLYMISSILE;
	smoke.velocity=randomv('0 0 20')+v_forward*20;
	smoke.drawflags(+)MLS_ABSLIGHT|DRF_TRANSLUCENT;
	smoke.abslight=0.5;
	smoke.angles=vectoangles(v_forward);
	smoke.avelocity_x=random(-600,600);
	smoke.scale=0.1;
	setmodel(smoke,"models/bonefx.mdl");
	setsize(smoke,'0 0 0','0 0 0');
	setorigin(smoke,self.origin);
	smoke.think=bone_smoke_fade;
	thinktime smoke : 0.05;
}

void bone_smoke ()
{
	self.cnt+=1;
	MakeBoneSmoke();
	if(self.cnt>3)
		self.nextthink=-1;
	else
		thinktime self : 0.01;
}

void bone_fire(float ball, float tome, vector ofs)
{
	float intmod, wismod;
	
	vector org;
	makevectors(self.v_angle);
	newmis=spawn();
	newmis.owner=self;
	newmis.movetype=MOVETYPE_FLYMISSILE;
	newmis.solid=SOLID_BBOX;
	newmis.speed=1000;
	newmis.velocity=v_forward*newmis.speed;

	org=self.origin+self.proj_ofs+v_forward*8+v_right*(ofs_y+12)+v_up*ofs_z;
	setorigin(newmis,org);
	
	intmod = self.intelligence;
	wismod = self.wisdom;

	if (ball)
	{
		self.punchangle_x=-2;
		sound(self,CHAN_WEAPON,"necro/bonefpow.wav",1,ATTN_NORM);
		self.attack_finished=time + 1;
		//newmis.dmg=random(wismod*2, wismod*2.5);
		newmis.dmg=20+random(wismod, wismod*1.25);
		if (tome)
		{
			newmis.dmg = random(wismod*5, wismod*6);
			newmis.scale = 1.3;
			self.greenmana-=BONE_TOMED_COST;
			self.attack_finished=time + 1.3;
		}
		newmis.frags=TRUE;
		newmis.touch=bone_ball_touch;
		newmis.avelocity=randomv('777 777 777','-777 -777 -777');
		setmodel(newmis,"models/bonelump.mdl");
		setsize(newmis,'0 0 0','0 0 0');
		
		self.greenmana-=BONE_BALL_COST;
	}
	else
	{
		newmis.speed+=random(500);
		newmis.dmg=8;
		if (tome)
			newmis.dmg*=2;
		//newmis.dmg=3+(wismod/4);	//approx. 6 damage to start
		newmis.touch=bone_shard_touch;
		newmis.effects (+) EF_NODRAW;
		setmodel(newmis,"models/boneshot.mdl");
		setsize(newmis,'0 0 0','0 0 0');
		newmis.velocity+=v_right*ofs_y*10+v_up*ofs_z*10;

		newmis.angles=vectoangles(newmis.velocity);

		newmis.wrq_effect_id = starteffect(CE_BONESHARD, newmis.origin, newmis.velocity,
			newmis.angles,newmis.avelocity);
	}
}

void  bone_normal()
{
	vector dir;
	
	sound(self,CHAN_WEAPON,"necro/bonefnrm.wav",1,ATTN_NORM);
	self.effects(+)EF_MUZZLEFLASH;
	makevectors(self.v_angle);
	dir=normalize(v_forward);
	InstantDamage(4,dir,'0.1 0.1 0.1');
	self.greenmana-=BONE_NORMAL_COST;
	self.attack_finished=time+0.3;
}

void bone_fire_once(float tome)
{
	vector ofs;
	ofs_z=random(-5,5);
	ofs_x=random(-5,5);
	ofs_y=random(-5,5);
	if (tome)
	{
		ofs_z = random(-5,5);
		ofs_y = random(-30, -25);
		bone_fire(FALSE, TRUE, ofs);
		ofs_z = random(-5,5);
		ofs_y = random(-20,-15);
		bone_fire(FALSE, TRUE, ofs);
		ofs_z = random(-5,5);
		ofs_y = random(-10,-5);
		bone_fire(FALSE, TRUE, ofs);
		ofs_z = random(-5,5);
		ofs_y = 0;
		bone_fire(FALSE, TRUE, ofs);
		ofs_z = random(-5,5);
		ofs_y = random(5, 10);
		bone_fire(FALSE, TRUE, ofs);
		ofs_z = random(-5,5);
		ofs_y = random(15, 20);
		bone_fire(FALSE, TRUE, ofs);
		ofs_z = random(-5,5);
		ofs_y = random(25, 30);
		bone_fire(FALSE, TRUE, ofs);
		
		ofs_z=random(-10,-15);
		ofs_y = random(-1, 1);
		bone_fire(FALSE, TRUE, ofs);
		ofs_z=random(10,15);
		ofs_y = random(-1, 1);
		bone_fire(FALSE, TRUE, ofs);
		
		self.greenmana-=BONE_TOMED_COST;
		self.greenmana-=BONE_NORMAL_COST;	//6 total
	}
	else
		bone_fire(FALSE, FALSE, ofs);
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


void() boneshard_ready;
void() Nec_Bon_Attack;

void boneshard_fire ()
{
	float tome;
	tome = self.artifact_active & ART_TOMEOFPOWER;
	
	self.wfs = advanceweaponframe($fire1,$fire12);
	if(self.button0 && self.weaponframe>$fire3 && !tome)
		self.weaponframe=$fire3;
	self.th_weapon=boneshard_fire;
	self.last_attack=time;
	if(self.wfs==WF_CYCLE_WRAPPED||self.greenmana<BONE_NORMAL_COST)
		boneshard_ready();
	else if(self.weaponframe==$fire3)
	{
		bone_normal();
		if (tome && self.greenmana>=(BONE_NORMAL_COST*2)+BONE_TOMED_COST)
			bone_fire_once(TRUE);
	}
	if(random()<0.7&&self.weaponframe<=$fire6)	//0.8
		bone_fire_once(FALSE);
	
	if (self.wfs == WF_LAST_FRAME)
		boneshard_ready();
}

void boneshard_altfire (void)
{
	float tome;
	tome = self.artifact_active & ART_TOMEOFPOWER;
	
	self.wfs = advanceweaponframe($fire1,$fire12);
	self.th_weapon=boneshard_altfire;
	self.last_attack=time;
	if(self.wfs==WF_CYCLE_WRAPPED||self.greenmana<BONE_BALL_COST)
		boneshard_ready();
	else if(self.weaponframe==$fire3)
	{
		if (tome && self.greenmana >= BONE_BALL_COST+BONE_TOMED_COST)
			bone_fire(TRUE,TRUE,'0 0 0');
		else //if (self.greenmana >= BONE_BALL_COST)
			bone_fire(TRUE,FALSE,'0 0 0');
	}
	if (self.wfs == WF_LAST_FRAME)
		boneshard_ready();
}

void() Nec_Bon_Attack =
{
	float altfire;
	altfire = self.button1;
	if (altfire && self.level>2 && self.greenmana>=BONE_BALL_COST)
		boneshard_altfire();
	else
		boneshard_fire();
	
	thinktime self : 0;
};

void boneshard_jellyfingers ()
{
	self.wfs = advanceweaponframe($idle1,$idle22);
	self.th_weapon=boneshard_jellyfingers;
	if(self.wfs==WF_CYCLE_WRAPPED)
		boneshard_ready();
}

void boneshard_ready (void)
{
	self.weaponframe=$idle1;
	if(random()<0.1&&random()<0.3&&random()<0.5)
		self.th_weapon=boneshard_jellyfingers;
	else
		self.th_weapon=boneshard_ready;
}

void boneshard_select (void)
{
	self.wfs = advanceweaponframe($select7,$select1);
	self.weaponmodel = "models/spllbook.mdl";
	self.th_weapon=boneshard_select;
	if(self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		boneshard_ready();
	}
}

void boneshard_deselect (void)
{
	self.wfs = advanceweaponframe($select1,$select7);
	self.th_weapon=boneshard_deselect;
	if(self.wfs==WF_CYCLE_WRAPPED)
		W_SetCurrentAmmo();
}


void boneshard_select_from_mmis (void)
{
	self.wfs = advanceweaponframe($go2shd01,$go2shd14);
	self.weaponmodel = "models/spllbook.mdl";
	self.th_weapon=boneshard_select_from_mmis;
	if(self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		boneshard_ready();
	}
}


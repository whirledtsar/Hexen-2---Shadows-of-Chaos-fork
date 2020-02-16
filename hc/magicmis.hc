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
float MMIS_SHOCK_COST = 1;
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
		if(self.classname=="monster_eidolon")
		{
			newmis.scale=0.75;
			setorigin(newmis,self.origin+self.proj_ofs+v_forward*48+v_right*20);
			sound(self,CHAN_AUTO,"eidolon/spell.wav",1,ATTN_NORM);
			
			newmis.enemy=self.enemy;
			newmis.classname = "eidolon spell";
			newmis.turn_time=3;
			newmis.dmg=random(30,40);
		}
		else
		{
			setorigin(newmis,self.origin+self.proj_ofs+v_forward*8+v_right*7+'0 0 5');
			sound(newmis,CHAN_AUTO,"necro/mmfire.wav",1,ATTN_NORM);
			
			if (tome)
			{
				newmis.dmg = random(40, 50) + wismod;
				newmis.scale=1.5;
				newmis.veer = 110 - intmod;
				if (newmis.veer < 30)
					newmis.veer = 30;
			}
			else
			{
				newmis.dmg = random(15, 20) + (wismod * 0.5);
				newmis.scale=1;
				int veeramt = 60 - intmod;
				if (veeramt > 15)
					newmis.veer=veeramt;
				else
					newmis.veer=15;
			}
			
			newmis.effects=EF_DIMLIGHT;
			newmis.frags=TRUE;
			newmis.homerate=0.1;
			newmis.turn_time=2;
			newmis.lifetime=time+5;
			newmis.th_die=chain_remove;
			newmis.think=HomeThink;
			newmis.hoverz=TRUE;
			thinktime newmis : 0.2;
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

void DrawShockEffect (entity lowner,float tag, float lflags, float duration, vector spot1, vector spot2)
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	//WriteByte (MSG_BROADCAST, TE_STREAM_ICECHUNKS);
	WriteByte (MSG_BROADCAST, TE_STREAM_FAMINE);
	WriteEntity (MSG_BROADCAST, lowner);
	WriteByte (MSG_BROADCAST, tag+lflags);
	WriteByte (MSG_BROADCAST, duration);

	WriteCoord (MSG_BROADCAST, spot1_x);
	WriteCoord (MSG_BROADCAST, spot1_y);
	WriteCoord (MSG_BROADCAST, spot1_z);

	WriteCoord (MSG_BROADCAST, spot2_x);
	WriteCoord (MSG_BROADCAST, spot2_y);
	WriteCoord (MSG_BROADCAST, spot2_z);
}

float FireShockingGrasp (float intmod, float damg)
{
	vector targetOrg, diff, forwardDiff;
	vector beamOrg;
	entity found;
	float radius, shockangle, shocksuccess;
	float beamcount;
	
	shocksuccess = FALSE;
	
	//intmod starts at about 18 and grows to over 30 by level 7. 
	//at 18 this is 225 and at 30 this is 285
	radius = 65 + (2 * intmod); 
	
	makevectors(self.v_angle);
	
	beamcount = 0;
	
	beamOrg = self.origin + self.proj_ofs + (normalize(v_forward) * 40) + (normalize(v_up) * 6) + (normalize(v_right) * 12);

	found=findradius(beamOrg,radius);
	while(found)
	{
		if(found!=self && found.takedamage && !found.playercontrolled && found.health && beamcount < 11)
		{
			beamcount += 1; //Capping total beams at 10 for performance and issue with applying flags to number of beams
			
			targetOrg = found.origin + ('0 0 1' * (found.maxs_y));
			
			//make sure there are no walls in the way
			traceline (beamOrg, targetOrg, FALSE, self);
			if (trace_fraction != 1.0 && trace_ent == found)
			{
				//get angle
				diff = found.origin - self.origin; //use origin for angles to make sure beams spawned inside monsters still hit				
				forwardDiff = normalize(v_forward) * radius;
				shockangle = AngleBetween(diff, forwardDiff);
				
				dprint("Shock angle: "); dprint(ftos(shockangle)); dprint("\n");
				
				if (shockangle < MMIS_SHOCK_ANGLE)
				{
					shocksuccess = TRUE;

					//draw effect				
					DrawShockEffect (self,beamcount,0, 7, beamOrg, targetOrg); //STREAM_TRANSLUCENT

					//Damage target
					T_Damage(found,self,self,damg);
					SpawnPuff(targetOrg, '0 0 8', damg, found);
				}	
			}
		}
		found=found.chain;
	}
	
	return shocksuccess;
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

/*

void() BloodTouch =
{
	if (other.health && other.classname != "player")
		T_Damage (other, self, self, 3);
	self.think = SUB_Remove;
	self.nextthink = time + 0.2;
};

void(vector dir) FireBloodSpike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	//local vector dir;
	//dir = aim (self, v_forward, 0);
	//makevectors(newmis.angles);
	
	//newmis.angles = self.angles;
	newmis.velocity= dir * 300;
	
	//newmis.velocity = newmis.velocity * 390;
	newmis.angles = vectoangles(newmis.velocity);
	
	newmis.touch = BloodTouch;
	newmis.classname = "bloodspike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 1;
	setmodel(newmis,"models/faspell.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, self.origin + '0 0 10');

	//newmis.speed = 700;
};

void  mmis_bloodring()
{
	float cost;
	float tome;
	
	self.think = SUB_Remove;
	self.nextthink = 0.01;
	
	if(self.attack_finished>time)
		return;

	tome = self.artifact_active&ART_TOMEOFPOWER;
	
	cost = MMIS_COST;
	sound(self,CHAN_AUTO,"fangel/deflect.wav",1,ATTN_NORM);
	
	FireBloodSpike('25 25 0');
	FireBloodSpike('50 0 0');
	FireBloodSpike('-25 -25 0');
	FireBloodSpike('-50 0 0');
	FireBloodSpike('0 25 0');
	FireBloodSpike('0 50 0');
	FireBloodSpike('25 -25 0');
	FireBloodSpike('-25 -50 0');
	
	//setmodel(self,"models/ball.mdl");
	
	if (tome)
	{
		FireMagicMissile(-3, TRUE);
		FireMagicMissile(3, TRUE);
		FireMagicMissile(6, TRUE);
		FireMagicMissile(-6, TRUE);
		cost = MMIS_TOME_COST;
	}
	
	//self.bluemana-=cost;
	//self.attack_finished=time+0.6;
}

void() launch_bloodparent =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	//local vector dir;
	//dir = aim (self, v_forward, 0);
	//makevectors(newmis.angles);
	
	//newmis.angles = self.angles;
	newmis.velocity=normalize(v_forward);
	
	newmis.velocity = newmis.velocity * 1390;
	newmis.angles = vectoangles(newmis.velocity);
	
	newmis.touch = mmis_bloodring;
	newmis.classname = "bloodfire";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel(newmis,"models/faspell.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, self.origin + '0 0 30');

	newmis.speed = 700;
};

*/

void  mmis_power()	//ws: buffed, because it should make up for short range with power (otherwise theres no incentive not to use regular missiles)
{
	float wismod, intmod, damg, shocksuccess, tome;
	
	if(self.attack_finished>time)
		return;
	
	wismod = self.wisdom;
	intmod = self.intelligence;
	damg = random(wismod, wismod * 1.2);

	tome = self.artifact_active&ART_TOMEOFPOWER;
	if (tome)
		damg *= 2;
	
	FireFlash();
	shocksuccess = FireShockingGrasp(intmod, damg);
	
	if (shocksuccess)
	{
		sound(self,CHAN_AUTO,"necro/attack1.wav",1,ATTN_NORM);
		if (self.health < 60)
		{
			self.health = self.health + intmod * 0.05;
			self.bluemana-=MMIS_SHOCK_COST;
		}
		else if (tome)
		{
			self.health = self.health + intmod * 0.18;
			self.bluemana-=3;
		}
	}
	
	self.attack_finished=time+0.23;
}

/*
void  mmis_power()
{
	float wismod, intmod, damg, shocksuccess, tome;
	
	if(self.attack_finished>time)
		return;
	
	wismod = self.wisdom;
	intmod = self.intelligence;
	damg = random(wismod * 1.5, wismod * 2.25);

	tome = self.artifact_active&ART_TOMEOFPOWER;
	if (tome)
		damg *= 2;
	
	//FireFlash();
	//shocksuccess = FireShockingGrasp(intmod, damg);
	launch_bloodparent(35);
	launch_bloodparent(0);
	launch_bloodparent(-35);
	//sound(self,CHAN_AUTO,"necro/mmfire.wav",1,ATTN_NORM);
	sound(self,CHAN_AUTO,"fangel/deflect.wav",1,ATTN_NORM);

		self.bluemana-=MMIS_SHOCK_COST;
	
	//if (shocksuccess)
	//{
		
	//}
	
	self.attack_finished=time+0.4;
}
*/

void  mmis_normal()
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
	if (0.6 - self.level*0.05 < 0.2)
		self.attack_finished=time+0.2;	//vanilla magic missile delay
	else
		self.attack_finished = time+(0.6 - self.level*0.05);
	
	/*if (self.level < 2)		//ws: bloodshot's method
		self.attack_finished=time+0.6;
	else if (self.level < 3)
		self.attack_finished=time+0.55;
	else if (self.level < 5)
		self.attack_finished=time+0.5;
		else if (self.level < 7)
		self.attack_finished=time+0.45;
	else if (self.level < 9)
		self.attack_finished=time+0.4;
		else if (self.level < 10)
		self.attack_finished=time+0.35;
	else
		self.attack_finished=time+0.3;*/
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

void magicmis_shock_fire (void)
{
	float tome, cost;
	
	tome = self.artifact_active&ART_TOMEOFPOWER;
	
	if(self.button0&&self.weaponframe==$mfire5 &&!self.artifact_active&ART_TOMEOFPOWER)
		self.weaponframe=$mfire5;
	else
		self.wfs = advanceweaponframe($mfire1,$mfire8);
	self.th_weapon=magicmis_shock_fire;
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
		mmis_power();
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
		magicmis_shock_fire();
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


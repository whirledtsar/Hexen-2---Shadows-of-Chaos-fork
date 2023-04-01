/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/meteor.hc,v 1.3 2007-02-07 16:57:07 sezero Exp $
 */

/*
==============================================================================

Q:\art\models\weapons\meteor\final\meteor.hc

==============================================================================
*/
// For building the model
$cd Q:\art\models\weapons\meteor\final
$origin 0 0 0
$base BASE skin
$skin skin
$flags 0

//
$frame idle

//
$frame Select1      Select2      Select3      Select4      Select5      
$frame Select6      Select7      Select8      Select9      Select10     
$frame Select11     Select12     Select13     Select14     Select15     
$frame Select16     Select17     Select18     

//
$frame fire1     fire2     fire3     fire4     fire5     
$frame fire6     fire7     fire8     fire9     

//float BOUNCE_TOME_COST = 10;
//float BOUNCE_COST = 6;

void() meteor_select;
void() meteor_deselect;
/*void() meteor_altfire;
void() meteor_power_altfire;
void(float tome) FireBounce;
void(vector org) CometCreate;
void() CometCheck;*/

void MeteoriteFizzle (void)
{
	CreateWhiteSmoke(self.origin,'0 0 8',HX_FRAME_TIME * 2);
	remove(self);
}

void MeteorThink (void)
{
	if(self.lifetime<time)
		if(self.dmg==3)
			MeteoriteFizzle();
		else
			MultiExplode();

	if(self.dmg>3)
		CreateWhiteSmoke(self.origin,'0 0 8',HX_FRAME_TIME * 2);

	self.think=MeteorThink;
	thinktime self : 0.3;
}

void MeteorTouch (void)
{
	if(other.controller==self.owner||pointcontents(self.origin)==CONTENT_SKY)
		return;

	if(self.dmg==3)
	{
		if(other==world)
		{
			if(!self.pain_finished&&random()<0.3)
			{
				sound(self.controller,CHAN_BODY,"misc/rubble.wav",1,ATTN_NORM);
				self.pain_finished=TRUE;
			}
			return;
		}
		else if(other.classname=="meteor")
			return;
	}

	if(other.takedamage&&other.health)
	{
		T_Damage(other,self,self.owner,self.dmg);
		if(self.dmg>3)	//if not mini-meteor
		{
			if((other.flags&FL_CLIENT||other.flags&FL_MONSTER)&&other.mass<200)
			{
			vector hitdir;
				hitdir=self.o_angle*300;
				hitdir_z+=150;
				if(hitdir_z<0)
					hitdir_z=0;
				other.velocity=hitdir;
				other.flags(-)FL_ONGROUND;
			}
			self.dmg/=2;
		}
	}
	else if(self.dmg>3)
		self.dmg=100;

	if(self.dmg>3)
		MultiExplode();
	else
		MeteoriteFizzle();
}

void FireMeteor (string type)
{
vector org;
entity meteor;
	meteor=spawn();
	setmodel(meteor,"models/tempmetr.mdl");
	if(type=="minimeteor")
	{
		meteor.classname="minimeteor";
		meteor.velocity=RandomVector('200 200 0');
		meteor.velocity_z=random(200,400);
		meteor.lifetime=time + 1.5;
		meteor.dmg=3;
		meteor.scale=random(0.15,0.45);
		meteor.movetype=MOVETYPE_BOUNCE;
		org=self.origin;
		setsize(meteor,'0 0 0', '0 0 0');
	}
	else
	{
		meteor.th_die=MultiExplode;
		if(self.classname=="player")
		{
			self.greenmana-=8;
			self.velocity+=normalize(v_forward)*-300;//include mass
			self.flags(-)FL_ONGROUND;
		}
		meteor.classname="meteor";
		self.punchangle_x = -6;
		sound(self,CHAN_AUTO,"crusader/metfire.wav",1,ATTN_NORM);
		self.attack_finished=time + 0.7;
		self.effects(+)EF_MUZZLEFLASH;
		makevectors(self.v_angle);
		meteor.speed=1000;
		meteor.o_angle=normalize(v_forward);		
		meteor.velocity=meteor.o_angle*meteor.speed;
		meteor.veer=30;
		meteor.lifetime=time + 5;
		meteor.dmg=75;
		meteor.movetype=MOVETYPE_FLYMISSILE;
		org=self.origin+self.proj_ofs+v_forward*12;
		setsize(meteor,'0 0 0', '0 0 0');
	}
//	meteor.abslight = 0.5;
	// Pa3PyX
//	meteor.drawflags(+)MLS_FIREFLICKER;//|MLS_ABSLIGHT;
	meteor.abslight = 1.0;
	meteor.drawflags (+) (MLS_FIREFLICKER | MLS_ABSLIGHT);

	meteor.avelocity=RandomVector('360 360 360');

	if(self.classname=="tornato")
		meteor.owner=self.controller;
	else if(self.classname=="meteor")
		meteor.owner=self.owner;
	else
		meteor.owner=self;
	meteor.controller=self;

	meteor.solid=SOLID_BBOX;
	meteor.touch=MeteorTouch;

	meteor.think=MeteorThink;
	thinktime meteor : 0.1;

	setorigin(meteor,org);
}

void() tornato_die = [++24 .. 47]
{
	if(cycle_wrapped)
	{
		if(self.enemy)
		{
			self.enemy.avelocity='0 500 0';
			if(self.enemy.flags2&FL_ALIVE)
				self.enemy.movetype=self.enemy.oldmovetype;
		}
		if(self.movechain!=world)
			remove(self.movechain);
		remove(self);
	}
	self.movechain.frame+=1;
	if(self.movechain.frame>24)
		self.movechain.frame=0;
	if(self.movechain.scale>0.04)
		self.movechain.scale-=0.04;
	if(self.movechain.avelocity_y>0)
		self.movechain.avelocity_y-=20;
};

//ws: attempt to not go through walls
void tornato_checkorigin (float content)
{
	if (content!=CONTENT_SOLID && content!=CONTENT_SKY)
		self.oldorigin = self.origin;
	else {
		self.velocity_y *= -1;
		self.velocity_x *= -1;
		self.origin = self.oldorigin;
	}
	makevectors(self.velocity);
	traceline(self.origin+'0 0 4', self.origin+'0 0 4'+v_forward*4, TRUE, self);
	if (trace_fraction<1)
		if (trace_ent.solid==SOLID_BSP) {
			self.velocity_y *= -1; self.velocity_x *= -1; }
}

void() tornato_spin = [++0 .. 23]
{
float distance,content;

	if(time>self.lifetime||self.torncount<self.owner.torncount - 1)
	{
		self.movechain.drawflags(+)MLS_ABSLIGHT;	//ws: these flags break animation //|SCALE_ORIGIN_BOTTOM|SCALE_TYPE_XYONLY;
		self.think=tornato_die;
		thinktime self : 0;
	}
	self.movechain.frame+=1;
	if(self.movechain.frame>24)
		self.movechain.frame=0;

//FIXME:  add tracking to movement and firing.
	if(random()<0.2)
	{
		self.velocity_x+=random(-100*self.scale,100*self.scale);
		if(fabs(self.velocity_x)>800)
			self.velocity_x/=2;
	}
	
	if(random()<0.2)
	{
		self.velocity_y+=random(-100*self.scale,100*self.scale);
		if(fabs(self.velocity_y)>800)
			self.velocity_y/=2;
	}

	content=pointcontents(self.origin+'0 0 0.1');
	if(content==CONTENT_WATER||content==CONTENT_LAVA)
	{
		self.velocity_z+=random(33,200);
		particle4(self.origin,random(20),264*15,PARTICLETYPE_GRAV,random()*10);
		particle4(self.origin,random(20),random(406,414),PARTICLETYPE_GRAV,random(10));
	}
	else if(random()<0.2)
	{
		distance=random(-30,15);//tries to stay on ground
		if(self.goalentity!=world&&self.enemy!=self.goalentity)
			if(self.goalentity.origin_z>self.origin_z)//unless goal is above it
				distance=random(-30,30);
		self.velocity_z+=distance;
		if(fabs(self.velocity_z)>333)
			self.velocity_z/=3;
	}

	if(self.enemy!=world)
	{
	vector org, dir;
	float let_go, loops;
		self.velocity=self.velocity*0.5;
		org=self.origin;
		/*do {
			if(self.enemy.size_z>=self.size_z)
				org=self.origin;
			else
				org_z+=random(10)*self.scale+4*self.scale;
			content = pointcontents(org);
			loops++;
		} while (content!=CONTENT_SOLID && content!=CONTENT_SOLID && loops<1000);
		*/
		if(!self.enemy.flags2&FL_TORNATO_SAFE)
		{
			//setorigin(self.enemy,org);	//this is horrible because it can make monsters stuck in solid geometry
		}
		else
		{
			self.enemy.flags2(-)FL_TORNATO_SAFE;
			let_go=TRUE;
		}
//FIXME:  throw the Sheep
		if(!let_go&&self.enemy!=world&&!self.enemy.flags2&FL_ALIVE)//Don't let go of it if it's not a creature
			if(random()>=0.4||self.goalentity==world||(!visible(self.goalentity))||self.goalentity.health<=0)
				self.pain_finished=time+1;
			else
			{
				self.pain_finished=-1;
				if(self.goalentity.solid==SOLID_BSP&&self.goalentity.origin=='0 0 0')
					dir=normalize((self.goalentity.absmax+self.goalentity.absmin)*0.5-self.enemy.origin);
				else
					dir=normalize(self.goalentity.origin-self.enemy.origin);
			}
		if(!let_go&&self.enemy.takedamage&&self.enemy.health>0&&self.pain_finished>time)
		{
			if(random()<0.3)
				T_Damage(self.enemy,self,self.owner,self.scale);//was 3*is this needed with meteors flying out?
		}
		else
		{
			if(!let_go)
				if(self.pain_finished==-1)		//Throw it at my goal!
					self.enemy.velocity=dir*(375-self.enemy.mass*2)*self.scale;		//ws: factor in mass
				else
				{
					self.enemy.velocity_z=random(200*self.scale);
					self.enemy.velocity_x=random(200*self.scale,-200*self.scale);
					self.enemy.velocity_y=random(200*self.scale,-200*self.scale);
					self.enemy.velocity -= '1 1 1'*self.enemy.mass*2;
				}
			self.pain_finished=time;
			self.enemy.safe_time=time+3+let_go*7;//let them get thrown away from the tornado for a full 3 seconds
			if(self.enemy.flags2&FL_ALIVE)
			{
				self.enemy.movetype=self.enemy.oldmovetype;
				if(self.enemy.classname=="player_sheep")
				{
					sound(self.enemy,CHAN_VOICE,"misc/sheepfly.wav",1,ATTN_NORM);
					self.enemy.pain_finished=time+1;
				}
			}
			if(!let_go)
				self.enemy.avelocity_y=random(80*self.scale,200*self.scale);
			self.enemy=self.movechain.movechain=world;
		}
		if(self.enemy.classname=="player")
		{
			self.enemy.punchangle_y=random(3,12);//FIXME: Do WRITEBYTE on angles?
			self.enemy.punchangle_x=random(-3,3);//FIXME: Do WRITEBYTE on angles?
			self.enemy.punchangle_z=random(-3,3);//FIXME: Do WRITEBYTE on angles?
		}
		if(self.enemy!=world&&self.goalentity==self.enemy)
			self.goalentity=world;//Hunt a new target, if it can
	}
	if(random()<0.3)
	{
	entity sucker;
	float seekspeed;
		sucker=findradius(self.origin,500);
		while(sucker)
		{
			if(sucker.takedamage&&sucker.health&&sucker!=self.enemy&&sucker.mass<500*self.scale&&visible(sucker)&&sucker!=self.owner)
				if(sucker.movetype&&sucker.movetype!=MOVETYPE_PUSH)
				{
					seekspeed=(525 - vlen(sucker.origin-self.origin) - sucker.mass*2);	//ws: factor in mass
					sucker.velocity=normalize(self.origin-sucker.origin)*seekspeed;
					if(sucker.velocity_z<30)
						sucker.velocity_z=30;
					sucker.flags(-)FL_ONGROUND;
					if(sucker.classname=="player")
						sucker.adjust_velocity=sucker.velocity;
				}
			sucker=sucker.chain;
		}
		if(self.goalentity!=world&&visible(self.goalentity)&&self.goalentity.health>0)
		{
				seekspeed = random(150,333);
				if(self.goalentity.solid==SOLID_BSP&&self.goalentity.origin=='0 0 0')
					distance=vlen((self.goalentity.absmax+self.goalentity.absmin)*0.5-self.origin);
				else
					distance=vlen(self.goalentity.origin-self.origin);//Swoop in when close!
				if(distance<256)
					seekspeed+=(256-distance);
				if(self.goalentity.velocity)
					seekspeed+=vlen(self.goalentity.velocity);
				self.velocity=(self.velocity*3+normalize(self.goalentity.origin-self.origin)*seekspeed*self.scale)*0.25;//too fast?
		}
		else
		{
		float bestdist;
			self.goalentity=world;//out of sight, out of mind
			bestdist=1001;
			sucker=findradius(self.origin,1000);
			while(sucker)
			{
				if(sucker.takedamage&&sucker.health&&sucker!=self.enemy&&sucker.mass<500*self.scale&&visible(sucker)&&sucker!=self.owner&&!sucker.effects&EF_NODRAW)
				{
					if(sucker.solid==SOLID_BSP&&sucker.origin=='0 0 0')
						distance=vlen((sucker.absmax+sucker.absmin)*0.5-self.origin);
					else
						distance=vlen(sucker.origin-self.origin);

					if(self.goalentity.velocity=='0 0 0')
					{
						if(sucker.velocity!='0 0 0'&&(sucker.flags2&FL_ALIVE))
						{
							bestdist=distance;
							self.goalentity=sucker;
						}
						else if(!self.goalentity.flags2&FL_ALIVE)
						{
							if(sucker.flags2&FL_ALIVE)
							{
								bestdist=distance;
								self.goalentity=sucker;
							}
							else if(distance<bestdist)
							{
								bestdist=distance;
								self.goalentity=sucker;
							}
						}
						else if(sucker.flags2&FL_ALIVE&&distance<bestdist)
						{
							bestdist=distance;
							self.goalentity=sucker;
						}
					}
					else if(distance<bestdist&&sucker.velocity!='0 0 0'&&(sucker.flags2&FL_ALIVE))
					{
						bestdist=distance;
						self.goalentity=sucker;
					}
				}
				sucker=sucker.chain;
			}
		}
 	}

	if(random()<0.1)
	{
		if(random()<0.1)
		{
			self.proj_ofs_z=random(6,54);
			self.v_angle_x=random(-30,30);
			self.v_angle_y=random(-360,360);
			FireMeteor("meteor");
		}
		else
			FireMeteor("minimeteor");
	}
	if(self.flags&FL_ONGROUND)
	{
	vector dir;
		self.velocity_z*=-0.333;//Maybe a little more bounce?
		self.flags(-)FL_ONGROUND;
		dir_z=random(20,70);
		distance=random(10,30);
		SpawnPuff (self.origin, dir,distance,self);
		CreateWhiteSmoke(self.origin,'0 0 8',HX_FRAME_TIME * 2);
	}
	if(self.t_width<time)
	{
		sound(self,CHAN_VOICE,"crusader/tornado.wav",1,ATTN_NORM);
		self.t_width=time+1;
	}
	
	tornato_checkorigin(content);
	
};

void()funnal_touch;
void tornato_merge (void)
{
//FIXME:  Don't scale up rocks- just add more rocks?
	self.scale+=0.025;
	self.owner.scale+=0.025;
	self.goalentity.scale-=0.024;
	self.goalentity.owner.scale-=0.024;
	if(self.scale>=self.target_scale)
	{
		self.touch=funnal_touch;
		self.scale=self.owner.scale=self.target_scale;
		self.think=SUB_Null;
		self.nextthink=-1;
		remove(self.goalentity.owner);
		remove(self.goalentity);
	}
	else
	{
		self.think=tornato_merge;
		thinktime self : 0.01;
	}
}

void funnal_touch (void)
{
//FIXME:  Ignore the controlling player's projectiles, leaving it in to test
	if(other.flags&FL_MONSTER&&other.monsterclass>=CLASS_BOSS)
	{
		T_Damage(other,self,self.owner,7);
		traceline((self.absmin+self.absmax)*0.5,(other.absmin+other.absmax)*0.5,FALSE,self);
		SpawnPuff(trace_endpos,randomv('-1 -1 -1','1 1 1'),5,other);
		return;
	}

	if(other==self.controller||other.controller==self.owner||other==world||other==self.owner||other==self.owner||other.classname=="tornato"||(other.classname=="funnal"&&other.aflag)||other.movetype==MOVETYPE_PUSH)
		return;

	if(self.aflag)
	{
		self.owner.think=SUB_Remove;
		self.think=SUB_Remove;
		return;
	}

	if(other.classname=="funnal"&&other.scale>=1&&self.scale>=1&&other.scale+self.scale<2.5)
	{
//Add random to stall the merging
		tracearea(self.origin,self.origin,self.mins+other.mins,self.maxs+other.maxs,TRUE,self);
		if(trace_fraction<1)
			return;
		self.goalentity=other;
		self.touch=other.touch=SUB_Null;
		if(other.controller!=self.controller)
			self.owner.owner=self.owner.controller=self.controller=self.owner;
//make scaling gradual
		self.drawflags=MLS_ABSLIGHT|SCALE_ORIGIN_BOTTOM;
		self.owner.drawflags=SCALE_ORIGIN_BOTTOM;
		other.drawflags=MLS_ABSLIGHT+SCALE_ORIGIN_BOTTOM+SCALE_TYPE_XYONLY;
		self.target_scale=self.scale+other.scale;
		if(self.target_scale>2.5)
			self.target_scale=2.5;
		setsize(self,self.mins+other.mins,self.maxs+other.maxs);
		setsize(self.owner,self.owner.mins+other.owner.mins,self.owner.maxs+other.owner.maxs);
		tornato_merge();
	}
	else if(other!=self.movechain&&other.movetype&&other.mass<500*self.scale&&other.classname!="funnal")//Can't pick up or move extremely heavy objects, bounce off them?
	{
		if(other.health&&other.takedamage&&other.solid!=SOLID_BSP)//Ignore health>1000?
		{
			if(!other.touch)
				other.touch=obj_push;//Experimental
			if(self.movechain==world&&other.safe_time<time)//&&self.scale>=1)
			{
				self.movechain=other;
				other.flags(+)FL_MOVECHAIN_ANGLE;
				
				entity oself, ogoal;
				oself = self;
				ogoal = other.goalentity;
				other.goalentity = self;
				self = self.enemy;
				float dist = (vlen(oself.origin-(self.owner.origin+'0 0 16')));
				if (dist > 0)
					movetogoal(dist);
				self = oself;
				other.goalentity = ogoal;
				//ws: horrible - could set enemy in wall
				//setorigin(other,self.origin+'0 0 4');//maybe need to take on bounding box of captured enemy too?
				other.velocity='0 0 0';
				if(other.flags2&FL_ALIVE)
					other.avelocity='0 0 0';
				else
				{
					other.avelocity_x=random(360);
					other.avelocity_z=random(360);
				}
				other.oldmovetype=other.movetype;
				other.movetype=MOVETYPE_NONE;
				self.owner.enemy=other;
				self.owner.pain_finished=time+random(3,10);//How long to hold them before throwing them away
				if(other.classname=="player_sheep"&&other.flags2&FL_ALIVE)
				{
					sound(other,CHAN_VOICE,"misc/sheepfly.wav",1,ATTN_NORM);
					other.pain_finished=time+1;
				}
				return;
			}
		}
		vector dir;
		dir=normalize(self.angles);
		dir*=((random(225,700)*self.scale)-other.mass*2);
		other.velocity+=dir;
		other.velocity_z=(random(125,275)*self.scale)-other.mass*2;
		other.flags(-)FL_ONGROUND;
		if(other.takedamage)
			T_Damage(other,self.owner,self.owner.controller,5*self.scale);
		if(other.classname=="player_sheep"&&other.flags2&FL_ALIVE)
		{
			sound(other,CHAN_VOICE,"misc/sheepfly.wav",1,ATTN_NORM);
			other.pain_finished=time+1;
		}
	}
}

void() tornato_grow = [++48 .. 72]
{
	if(cycle_wrapped)
	{
		self.movechain.scale=1;
		self.think=tornato_spin;
		thinktime self : 0;
	}
	self.movechain.frame+=1;
	if(self.movechain.frame>24)
		self.movechain.frame=0;
	self.movechain.scale+=0.04;
	
	tornato_checkorigin(pointcontents(self.origin+'0 0 0.1'));
};
 
void FireMeteorTornado (void)
{
/*
FIX:
1:	BUG:If pull someone out of water & they die, stay in swim mode.(Fly mode does this with water too)
2:	More particles & splash sound when hit water
3:  Deflect projectiles
4:  Limit 2, if 3rd made, erase 1st
5:  Shorten life?
6:  Can't hurt owner
9:	Player's view should actually be changed with WRITEBYTE's?
10: Screw up aim of people inside tornado
11: gradual suck in, then stick to center?
12: incorporate mass?  At least check to see if it can be picked up, maybe give a little resistance
13: Meteors are going through walls
14:	Change bounding box to match what it picked up?
15: Scale up to match something big it picked up?
16: Check it there's room in front to make it, and at what height, use v_forward if possible.  If not enough room:?
17: Auntie Em, Auntie Em!
18:	Don't even consider movetype_push's?
19:	Scale randomly?
20:	Origins MUST be at bottom
21: Particle and Puff Sprites at origin when onground
22: If pick up something not alive, throw it at goalentity?  Random chance?
23: Bounding box should be a little bigger
24: If it hits water while holding a player, it should go down and drown them.
*/
entity tornato,funnal;
vector org;

	self.greenmana-=20;
	sound(self,CHAN_WEAPON,"crusader/torngo.wav",1,ATTN_NORM);
	makevectors(self.v_angle);
	org=self.origin+'0 0 1'+normalize(v_forward)*16;
	
	//ws: avoid spawning inside world if player is aiming at ground or slope
	float content, loops;
	content = pointcontents(org);
	while (content==CONTENT_SOLID && loops<500) {
		org+='0 0 0.5';
		content = pointcontents(org);
		++loops;
	}
	
	tornato=spawn();
	self.torncount+=1;
	tornato.torncount=self.torncount;
	tornato.solid=SOLID_NOT;
	tornato.movetype=MOVETYPE_FLY;
	tornato.owner=tornato.controller=self;
	tornato.classname="tornato";
	tornato.enemy=world;
	setmodel(tornato,"models/tornato.mdl");
	//setsize(tornato,'-18 -18 -3','18 18 64');
	//tornato.hull=HULL_PLAYER;
	//ws: increased size to avoid tunneling through walls
	setsize(tornato,'-40 -40 0','40 40 64');
	tornato.hull = HULL_GOLEM;
	setorigin(tornato,org);
	tornato.origin = org;
	tornato.velocity=normalize(v_forward)*250+'0 0 20';
	tornato.velocity_z=0;
	tornato.scale=1.4;
	if(visible(self.enemy)&&self.enemy.flags2&FL_ALIVE)//Infront too?
		tornato.goalentity=self.enemy;
	tornato.lifetime=time + 3 + self.intelligence;	//~16 at level 1
	tornato.think=tornato_grow;
	thinktime tornato : 0;

	funnal=spawn();
	funnal.owner=tornato;
	funnal.solid=SOLID_TRIGGER;
	funnal.classname="funnal";
	funnal.movetype=MOVETYPE_FLYMISSILE;
	funnal.drawflags(+)MLS_ABSLIGHT|SCALE_ORIGIN_BOTTOM|SCALE_TYPE_ZONLY;
	funnal.abslight=0.2;
	funnal.scale=0.01;
	tornato.movechain=funnal;
	funnal.avelocity='0 100 0';
	funnal.controller=self;
	funnal.touch=funnal_touch;
	funnal.lifetime=time+1.7;
	setmodel(funnal,"models/funnal.mdl");
	setsize(funnal,'-18 -18 -3','18 18 64');
	funnal.hull=HULL_PLAYER;
	setorigin(funnal,org);
}

void()meteor_ready_loop;
void() Cru_Met_Attack;

void meteor_power_fire (void)
{
	self.wfs = advanceweaponframe($fire1,$fire9);
	self.th_weapon=meteor_power_fire;
	// Pa3PyX
//	if(self.weaponframe==$fire2 && self.attack_finished<=time)
	if(self.weaponframe==$fire1 && self.attack_finished<=time) {
			self.attack_finished = time + 0.5;// Pa3PyX
			FireMeteorTornado();
	}

	if(self.wfs==WF_CYCLE_WRAPPED)
	{
			self.last_attack=time;
			meteor_ready_loop();
	}
}

void meteor_fire (void)
{
	self.wfs = advanceweaponframe($fire1,$fire9);
	self.th_weapon=meteor_fire;
	
	if((!self.button0||self.attack_finished>time)&&self.wfs==WF_CYCLE_WRAPPED)
	{
		self.last_attack=time;
		meteor_ready_loop();
	}
	else if(self.weaponframe==$fire1 && self.attack_finished<=time)
		FireMeteor("meteor");
}

/*
void() MetGrenadeTouch =
{	
	if (other == self.owner || other == self.controller || 
	(other.owner==self.owner&&other.classname==self.classname&&self.classname=="metball") )
		return;         // don't explode on owner
	
	else if (pointcontents(self.origin)==CONTENT_SKY)
		remove(self);
	
	else if (other.takedamage && other.health>0)
	{
		if (self.classname=="metball")	//grenade
			MultiExplode();
		else
			T_Damage(other,self,self.owner,self.dmg/2);
	}
		
	else
	{
		sound (self, CHAN_WEAPON, "crusader/BOUNCE2.wav", 1, ATTN_NORM);
		if (self.velocity == '0 0 0')
			self.avelocity = '0 0 0';
	}
	
	if (self.classname=="metspawn")	//if tomed, summon a comet
		CometCreate();
};

void FireBounce (float tome)
{
vector org;
entity metball;

	metball=spawn();
	setmodel(metball,"models/tempmetr.mdl");

	if(self.classname=="player")
	{
		self.velocity+=normalize(v_forward)*-20;//include mass
		self.flags(-)FL_ONGROUND;
	}
	
	self.punchangle_x = -3;
	
	self.effects(+)EF_MUZZLEFLASH;
	makevectors(self.v_angle);
	metball.speed=700;
	metball.gravity = 0.5;
	metball.o_angle=normalize(v_forward);		
	metball.velocity=metball.o_angle*metball.speed;
	metball.veer=30;
	metball.lifetime=time + 2;
	metball.dmg=100;
	metball.movetype=MOVETYPE_BOUNCE;
	org=self.origin+self.proj_ofs+v_forward*12;
	setsize(metball,'0 0 0', '0 0 0');
	metball.abslight = 1.0;
	metball.drawflags (+) (MLS_FIREFLICKER | MLS_ABSLIGHT);
	metball.avelocity=RandomVector('360 360 360');
	metball.owner=self.owner;
	metball.controller=self;
	metball.solid=SOLID_PHASE;
	setorigin(metball,org);
	
	if (tome)
	{
		self.greenmana-=BOUNCE_TOME_COST;
		sound(self,CHAN_AUTO,"crusader/metfire.wav",1,ATTN_NORM);
		self.attack_finished=time + 0.7;
		
		metball.classname="metspawn";
		metball.think=CometCreate;
		thinktime metball : 2;
		metball.touch=MetGrenadeTouch;
		//metball.th_die=CometCreate;
	}
	else
	{
		self.greenmana-=BOUNCE_COST;
		sound(self,CHAN_AUTO,"weapons/bounceb.wav",1,ATTN_NORM);
		self.attack_finished=time + 0.4;
		
		metball.classname="metball";
		metball.think=MeteorThink;
		thinktime metball : 0.1;
		metball.touch=MetGrenadeTouch;
		metball.th_die=MultiExplode;
	}
}

void CometCheck ()
{
	tracearea (self.origin,self.origin,'-64 -64 -64','64 64 64',TRUE,self);
	if (trace_fraction == 1)
	{
		self.touch = MultiExplode;
		self.movetype = MOVETYPE_FLYMISSILE;
		self.solid = SOLID_BBOX;
		self.think = SUB_Null;
	}
	else
		thinktime self : 0.01;
}

void CometCreate (vector org)		//summon meteors from the heavens
{	
	entity comet;
	comet=spawn();
	comet.classname="comet";
	comet.controller = comet.owner = self;
	comet.scale = 2;
	comet.dmg = 60;
	comet.th_die = MultiExplode;
	//comet.touch = MultiExplode;
	//comet.movetype = MOVETYPE_FLYMISSILE;
	//comet.solid = SOLID_SLIDEBOX;
	comet.movetype = MOVETYPE_NOCLIP;	//temporary - undone by CometCheck
	comet.solid = SOLID_NOT;
	setsize(comet,'0 0 0', '0 0 0');
	//setsize(comet,'1 1 1', '1 1 1');
	setmodel(comet,"models/tempmetr.mdl");
	
	traceline (org, org + '0 0 600', TRUE, self.owner);
	setorigin(comet, trace_endpos - '0 0 30');
	comet.velocity = '0 0 -800';
	comet.avelocity=RandomVector('360 360 360');
	
	comet.think = CometCheck;
	thinktime comet : 0.1;
}

void CometStorm ()
{
	self.think = CometStorm;
	if (self.lifetime < time)
	{
		remove(self);
		return;
	}
	CometCreate (self.origin);
	thinktime self : random(0.15,0.5);
}

void FireComet (void)
{
	vector dir, org;
	float range = 1536;
	
	self.attack_finished=time + 0.8;
	
	makevectors (self.v_angle);
	org = self.origin + self.proj_ofs;
	dir = org + v_forward*range;
	traceline (org, dir, FALSE, self);
	if (trace_fraction == 1.0)
	{
		traceline (org, org + v_forward*range - (v_up*15), FALSE, self);
		if (trace_fraction == 1.0)
		{
			traceline (org, org + v_forward*range + v_up*15, FALSE, self);
		}
	}
	
	if (trace_ent.takedamage && trace_ent.solid != SOLID_BSP)
	{
		self.attack_finished=time + 1;
		self.greenmana -= BOUNCE_TOME_COST;
		
		newmis = spawn();
		newmis.think = CometStorm;
		newmis.owner = self;
		newmis.origin = trace_endpos;
		newmis.lifetime = time + 2.5;
		thinktime newmis : 0;
	}
	else
		self.attack_finished=time+0.25;
}
*/
/*
void meteor_altfire (void)
{
	self.wfs = advanceweaponframe($fire1,$fire9);
	self.th_weapon=meteor_altfire;

	if((!self.button1||self.attack_finished>time)&&self.wfs==WF_CYCLE_WRAPPED)
	{
		self.last_attack=time;
		meteor_ready_loop();
	}
	else if(self.weaponframe==$fire1 &&self.attack_finished<=time)
		FireBounce(FALSE);
}

void meteor_power_altfire (void)
{
	self.wfs = advanceweaponframe($fire1,$fire9);
	self.th_weapon=meteor_power_altfire;
	if((!self.button1||self.attack_finished>time)&&self.wfs==WF_CYCLE_WRAPPED)
	{
		self.last_attack=time;
		meteor_ready_loop();
	}
	else if(self.weaponframe==$fire3 && self.attack_finished<=time)
	{
		FireComet();
	}
}
*/
/*
void() Cru_Met_Attack =
{
	float altfire;
	
	altfire = self.button1;
	
	//if (altfire && self.greenmana >= BOUNCE_TOME_COST && self.artifact_active&ART_TOMEOFPOWER)
	//	self.th_weapon=meteor_power_altfire;
	
	if (altfire && self.greenmana >= BOUNCE_COST)
	{
		if(self.artifact_active&ART_TOMEOFPOWER && self.greenmana >= 20)
			self.th_weapon=meteor_power_fire;
		else
			self.th_weapon=meteor_altfire;
	}
	else
	{
		if(self.artifact_active&ART_TOMEOFPOWER)
			self.th_weapon=meteor_power_fire;
		else
			self.th_weapon=meteor_fire;
	}
	thinktime self : 0;
};
*/

void() Cru_Met_Attack =
{
	if(self.artifact_active&ART_TOMEOFPOWER && self.greenmana>=20)
		self.th_weapon=meteor_power_fire;
	else if (self.greenmana>=8)
		self.th_weapon=meteor_fire;
	
	thinktime self : 0;
};

void meteor_ready_loop (void)
{
	self.weaponframe = $idle;
	self.th_weapon=meteor_ready_loop;
}

void meteor_select (void)
{
//go to ready loop, not relaxed?
	self.wfs = advanceweaponframe($Select1,$Select16);
	self.weaponmodel = "models/meteor.mdl";
	self.th_weapon=meteor_select;
	self.last_attack=time;
	// Pa3PyX
//	if(self.wfs==WF_CYCLE_WRAPPED)
	if(self.weaponframe==$Select16)
	{
		self.attack_finished = time - 1;
		meteor_ready_loop();
	}
}

void meteor_deselect (void)
{
	self.wfs = advanceweaponframe($Select16,$Select1);
	self.th_weapon=meteor_deselect;

	if(self.wfs==WF_CYCLE_WRAPPED)
		W_SetCurrentAmmo();
}


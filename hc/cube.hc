/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/portals/cube.hc,v 1.2 2007-02-07 16:59:31 sezero Exp $
 */


float cube_distance = 500;

void CubeDie(void)
{
	CreateYRFlash(self.origin);
	stopSound(self,0);
	sound(self, CHAN_ITEM, "player/cubedie.wav", 1, ATTN_NORM);
	if (self.owner != world)
		self.owner.artifact_flags(-)self.artifact_flags;
	remove(self);
}

float cube_find_target(void)
{
	entity item;
	float pass;

	while(pass<2)
	{//on pass 2, accept corpses
		item = findradius(self.origin, cube_distance);
		while (item)
		{
			if (((item.flags & FL_MONSTER) || (item.classname == "player" && deathmatch == 1&&item!=self.controller)||(pass==1&&(item.classname=="player_sheep"||item.netname=="corpse"||item.netname=="head"))) &&	item.health > 0)
			{
				if(item.controller!=self.controller)
				{
					traceline (self.origin,(item.absmin+item.absmax)*0.5,TRUE,self);
					if (trace_fraction==1.0)
					{
						if ((!item.effects & EF_NODRAW)||item.classname=="monster_pentacles")
						{
							sound(self, CHAN_ITEM, "misc/Beep1.wav", 1, ATTN_NORM);
							self.attack_finished=time+random(0.5);
							self.drawflags(+)MLS_POWERMODE;
							self.last_attack=0;
							self.enemy = item;
							return TRUE;
						}
					}
				}
			}
			item = item.chain;
		}
		pass+=1;
	}

	return FALSE;
}

void do_fireball(vector offset,float damg);

void cube_dobeam(vector targ_org)
{
	float beam_color;
	beam_color=rint(random(0,4));
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_STREAM_COLORBEAM);	//beam type
	WriteEntity (MSG_BROADCAST, self);				//owner
	WriteByte (MSG_BROADCAST, 0);					//tag + flags
	WriteByte (MSG_BROADCAST, 1);					//time
	WriteByte (MSG_BROADCAST, beam_color);			//color

	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	WriteCoord (MSG_BROADCAST, targ_org_x);
	WriteCoord (MSG_BROADCAST, targ_org_y);
	WriteCoord (MSG_BROADCAST, targ_org_z);

	//LightningDamage (self.origin, targ_org, self, beam_color+1,"sunbeam");
	LightningDamage (self.origin, targ_org, self, self.owner.wisdom*0.2,"sunbeam");
}

vector CubeDirection[6] =
{
	'90 0 0',
	'-90 0 0',
	'0 90 0',
	'0 -90 0',
	'0 0 90',
	'0 0 -90'
};

void cube_fire(void)
{
//	float RanVal;
	vector targ_org;
//	vector targ_size_min,targ_size_max;
	float Distance,beam_color;
	entity temp;
	
	if (self.owner.health <= 0)
	{
		CubeDie();
		return;		
	}

	if (self.owner.classname == "player" && time > self.monster_duration)
	{
		CubeDie();
		return;
	}

	if (self.enemy)
	{
		if (self.enemy.health <= 0)
		{
			self.enemy = world;
			self.drawflags(-)MLS_POWERMODE;
		}
	}

	if (!self.enemy)
		cube_find_target();

	if (self.enemy)
	{
		Distance = vlen(self.origin - self.enemy.origin);
		if (Distance > cube_distance*2)
		{
			self.enemy = world;
			self.drawflags(-)MLS_POWERMODE;
		}
		else if (Distance < cube_distance)
		{
			// Got to do this otherwise tracearea sees right through you
			temp = self.owner;
			self.owner = self;

			/*
			targ_size_min = self.enemy.maxs - self.enemy.mins;
			targ_size_max =targ_size_min;
			targ_size_min *=-0.5;
			targ_org = (self.enemy.absmin+self.enemy.absmax)*0.5 + randomv(targ_size_min,targ_size_max);
			*/
			if(self.enemy.proj_ofs!='0 0 0')
				targ_org=self.enemy.origin+self.enemy.proj_ofs;
			else
				targ_org=(self.enemy.absmin+self.enemy.absmax)*0.5;
			traceline (self.origin,targ_org,FALSE,self);
			if(trace_ent!=self.enemy)
			{//First try missed
				targ_org=(self.enemy.absmin+self.enemy.absmax)*0.5;
				traceline (self.origin,targ_org,FALSE,self);
			}
			if (trace_ent == self.enemy)
			{
				self.adjust_velocity = CubeDirection[random(0,5)];
				self.effects(+)EF_MUZZLEFLASH;
				if(self.last_attack+1.5<time)
					sound(self, CHAN_WEAPON, "golem/gbfire.wav", 1, ATTN_NORM);
				else
					sound(self, CHAN_BODY, "crusader/sunhum.wav", 1, ATTN_NORM);
				updateSoundPos(self,CHAN_BODY);
				updateSoundPos(self,CHAN_WEAPON);
				self.last_attack=time;
				self.owner = temp;		//restore owner for check
				if (self.owner.flags&FL_CLIENT) {
					self.shot_cnt+=1;
					cube_dobeam(targ_org); }
				else {					//monsters shoot fireballs
					self.shot_cnt=17;
					do_fireball('0 0 0',random(9,18)); }
			}
			else
			{
				traceline (self.origin,(self.enemy.absmin+self.enemy.absmax)*0.5,TRUE,self);
				if(trace_fraction!=1.0)
				{
					self.cnt+=1;
					if(self.cnt>=5)
					{//can't see enemy for last 10 tries, find someone else
						self.enemy=world;
						self.cnt=0;
						self.drawflags(-)MLS_POWERMODE;
					}
				}
			}

			self.owner = temp;
		}
	}
}

void cube_rotate(void)
{
	vector NewOffset;
	
	NewOffset = concatv(self.adjust_velocity,'5 5 5');

	self.adjust_velocity -= NewOffset;
	self.v_angle += NewOffset;
}

vector CubeFollowRate = '14 14 14';
vector CubeAttackRate = '3 3 3';

void CubeThinkerB(void)
{
	vector NewSpot;
	float Distance;
	thinktime self : 0.05;

	if(random()<0.1)
		sound(self, CHAN_VOICE, "misc/cubehum.wav", 1, ATTN_NORM);
	updateSoundPos(self,CHAN_VOICE);
	if (!self.owner.flags2 & FL_ALIVE) 
	{
		CubeDie();
		return;
	}

	if(self.attack_finished<time)
	{
		if(random()<0.5)
			cube_fire();
		if(self.shot_cnt>17)
		{
			self.shot_cnt=0;
			self.attack_finished=time+random(0.5,2);
		}
	}

	if (self.adjust_velocity == '0 0 0')
	{
		if (self.adjust_velocity == '0 0 0')
		{
			if (random() < 0.02)
			{
				self.adjust_velocity = CubeDirection[random(0,5)];
			}
		}
	}
	cube_rotate();

	self.angles = self.owner.angles + self.v_angle;
	
	self.count += random(4,6);
	if (self.count > 360) 
	{
		self.count -= 360;
	}

	Distance = vlen(self.origin - self.owner.origin);
	if (Distance > cube_distance)
	{
		self.enemy = world;
		self.drawflags(-)MLS_POWERMODE;
	}

	if (self.enemy != world)
	{
		NewSpot = self.enemy.origin + self.enemy.view_ofs;

		if (self.artifact_flags & AFL_CUBE_LEFT)
		{
			NewSpot += (cos(self.count) * 40 * '1 0 0') + (sin(self.count) * 40 * '0 1 0');
		}
		else
		{
			NewSpot += (sin(self.count) * 40 * '1 0 0') + (cos(self.count) * 40 * '0 1 0');
		}

		self.movedir_z += random(10,12);
		if (self.movedir_z > 360) 
		{
			self.movedir_z -= 360;
		}

		NewSpot_z += sin(self.movedir_z) * 10;

		NewSpot = self.origin + concatv(NewSpot - self.origin, CubeAttackRate);
	}
	else
	{
		makevectors(self.owner.v_angle);

		if (self.artifact_flags & AFL_CUBE_LEFT)
		{
   			NewSpot = self.owner.origin + self.owner.view_ofs + '0 0 10' + v_factor('40 60 0');
		}
		else
		{
   			NewSpot = self.owner.origin + self.owner.view_ofs + '0 0 10' + v_factor('-40 60 0');
		}

		self.movedir_z += random(10,12);
		if (self.movedir_z > 360) 
		{
			self.movedir_z -= 360;
		}

		NewSpot += (v_right * cos(self.count) * 15) + (v_up * sin(self.count) * 15) +
				   (v_forward * sin(self.movedir_z) * 15);
	
		NewSpot = self.origin + concatv(NewSpot - self.origin, CubeFollowRate);
	}

	setorigin(self,NewSpot);
}

void cube_of_force (entity spawner)
{
	float intmod;
	if (spawner.intelligence)
		intmod = 5 + spawner.intelligence*1.5;
	else
		intmod = 45;
	
	entity cube;
	cube = spawn();

	cube.owner = spawner;
	cube.controller = spawner;
	cube.solid = SOLID_SLIDEBOX;
	cube.movetype = MOVETYPE_NOCLIP;
	cube.flags (+) FL_FLY | FL_NOTARGET;
	setorigin (cube, cube.owner.origin);
	setmodel (cube, "models/cube.mdl");
	setsize (cube, '-5 -5 -5', '5 5 5');		


	cube.classname = "cube_of_force";
	cube.health = 10;

	if (spawner.artifact_flags & AFL_CUBE_LEFT)
	{
		spawner.artifact_flags (+) AFL_CUBE_RIGHT;
		cube.artifact_flags (+) AFL_CUBE_RIGHT;
	}
	else
	{
		spawner.artifact_flags (+) AFL_CUBE_LEFT;
		cube.artifact_flags (+) AFL_CUBE_LEFT;
	}
	cube.think = CubeThinkerB;
	cube.th_die = CubeDie;

	thinktime cube : 0.01;
	
	cube.monster_duration = time + intmod;
	cube.shot_cnt = 0;

	cube.movedir = '100 100 0';
	cube.count = random(360);
	spawner.movedir_z = random(360);

	cube.drawflags (+) MLS_ABSLIGHT;

	cube.abslight = .1;
}

void UseCubeOfForce(void)
{
	if ((self.artifact_flags & AFL_CUBE_LEFT) &&
		(self.artifact_flags & AFL_CUBE_RIGHT))
	{  // Already got two running
		return;
	}
	
	cube_of_force(self);
		
	self.cnt_cubeofforce -= 1;
}

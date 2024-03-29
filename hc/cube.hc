/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/cube.hc,v 1.2 2007-02-07 16:57:00 sezero Exp $
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
	float targetGood;

	item = findradius(self.origin, cube_distance);

	while (item)
	{
		targetGood = FALSE;
		
		if (deathmatch == 1 && item.classname == "player") //target other players in deathmatch
			targetGood = TRUE;
		if (self.owner.classname != "player" && item.classname == "player") //target players if owned by monster
			targetGood = TRUE;
		if (self.owner.classname == "player" && item.flags & FL_MONSTER) //target monsters if owned by player
			targetGood = TRUE;
		
		if (item.health <= 0) //Don't shoot dead bodies
			targetGood = FALSE;
		if (item.controller.classname == self.controller.classname) //don't shoot our own summons or anything summoned by our friends
			targetGood = FALSE;
			
		if (targetGood)
		{
			tracearea (self.origin,item.origin,self.mins,self.maxs,FALSE,self);
			if (trace_ent == item)
			{
				if (!item.effects & EF_NODRAW)
				{
					self.enemy = item;
					return TRUE;
				}
			}
		}

		item = item.chain;
	}

	return FALSE;
}


void do_fireball(vector offset);

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
	float Distance;
	entity temp;

	if (self.owner.classname == "player" && (time > self.monster_duration || self.shot_cnt >= 10))
	{
		CubeDie();
		return;
	}
	
	if (self.owner.health <= 0)
	{
		CubeDie();
		return;		
	}

	if (!self.enemy)
	{
		self.cnt += 1;
		if (self.cnt > 5)
		{
			cube_find_target();
			self.cnt = 0;
		}
	}

	if (self.enemy)
	{
		if (self.enemy.health <= 0)
		{
			self.enemy = world;
			//self.drawflags (+) DRF_TRANSLUCENT;
		}
	}

	if (self.enemy)
	{
		if (random() < .7)
		{
			Distance = vlen(self.origin - self.enemy.origin);
			if (Distance > cube_distance*2)
			{
				self.enemy = world;
				//self.drawflags (+) DRF_TRANSLUCENT;
			}
			else
			{
				// Got to do this otherwise tracearea sees right through you
				temp = self.owner;
				self.owner = self;

				tracearea (self.origin,self.enemy.origin,self.mins,self.maxs,FALSE,self);
				if (trace_ent == self.enemy)
				{
					self.adjust_velocity = CubeDirection[random(0,5)];
					self.abslight = 1;

					self.shot_cnt += 1;

					do_fireball('0 0 0');
				}
				else 
				{
					self.enemy = world;
					//self.drawflags (+) DRF_TRANSLUCENT;
				}

				self.owner = temp;
			}
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

void() CubeThinkerB;

void cube_reset()
{
	if (!self.owner.flags&EF_NODRAW) {
		self.effects(-)EF_NODRAW;
		self.think = CubeThinkerB;
	}
}

vector CubeFollowRate = '14 14 14';
vector CubeAttackRate = '3 3 3';

void CubeThinkerB(void)
{
	vector NewSpot;
	float Distance;
	thinktime self : 0.05;

	if (!self.owner.flags2 & FL_ALIVE) 
	{
		CubeDie();
		return;
	}
	
	if (self.owner.flags&FL_MONSTER && self.owner.effects&EF_NODRAW) {
		self.effects=EF_NODRAW;
		self.think = cube_reset;
		thinktime self : HX_FRAME_TIME;
		return;
	}

	if (self.adjust_velocity == '0 0 0')
	{
		cube_fire();
		if (self.adjust_velocity == '0 0 0')
		{
			if (random() < 0.02)
			{
				self.adjust_velocity = CubeDirection[random(0,5)];
			}
		}
	}
	cube_rotate();

	if (self.abslight > .1) 
		self.abslight -= 0.1;

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
		//self.drawflags (+) DRF_TRANSLUCENT;
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
	cube.dmg = -1;

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


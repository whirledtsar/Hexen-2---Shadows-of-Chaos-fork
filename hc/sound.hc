/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/portals/sound.hc,v 1.2 2007-02-07 16:59:37 sezero Exp $
 */

void sound_maker_run(void)
{
	sound (self, CHAN_VOICE, self.noise1, 1, self.lip);
}

void music_player_run(void)
{
	local entity found;
	
	found = find(world, classname, "player");
	while (found)
	{
		if (self.noise1 == "")
		{
			stuffcmd(found, "music_stop\n");
		}
		else
		{
			if (self.flags & 1)
				stuffcmd(found, "music_loop 1\n");
			else
				stuffcmd(found, "music_loop 0\n");
			
			stuffcmd(found, "music ");
			stuffcmd(found, self.noise1);
			stuffcmd(found, "\n");
		}
		found = find ( found, classname, "player");
	}
}

void music_player_wait(void)
{
	self.think = music_player_run;
	thinktime self : self.delay;
}

void sound_maker_wait(void)
{
	self.think = sound_maker_run;
	thinktime self : self.delay;
}

/*QUAKED sound_maker (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
A sound that can be triggered.
-------------------------FIELDS-------------------------
 "soundtype" values :

  1 - bell ringing
  2 - Organ Music (not the organ you're thinking about)
  3 - Tomb sound (hey, it's too late in the project to waste time typing comments!
--------------------------------------------------------
*/
void sound_maker (void)
{
	if (self.soundtype==1)
	{
		precache_sound ("misc/bellring.wav");
		self.noise1 = ("misc/bellring.wav");
	}
	else if (self.soundtype==2)
	{
		precache_sound2 ("misc/organ.wav");
		self.noise1 = ("misc/organ.wav");
	}
	else if (self.soundtype==3)
	{
		precache_sound ("misc/tomb.wav");
		self.noise1 = ("misc/tomb.wav");
	}
	
	if (self.delay) 
		self.use = sound_maker_wait;
	else 
		self.use = sound_maker_run;
}

void sound_again(void)
{
	float chance;
	
	//if (self.soundtype == 13)
	if (self.noise3)
	{
		chance = random();
		if (chance < .33)
			sound (self, CHAN_VOICE, self.noise1, 1, self.lip);
		else if (chance < .66)
			sound (self, CHAN_VOICE, self.noise2, 1, self.lip);
		else
			sound (self, CHAN_VOICE, self.noise3, 1, self.lip);
	}
	//else if ((self.soundtype == 11) || (self.soundtype == 12) || (self.soundtype == 14))
	else if (self.noise2)
	{
		if (random() < .5)
			sound (self, CHAN_VOICE, self.noise1, 1, self.lip);
		else
			sound (self, CHAN_VOICE, self.noise2, 1, self.lip);
	}
	else
		sound (self, CHAN_VOICE, self.noise1, 1, self.lip);

	self.think = sound_again;
	
	if (self.flags==0)
		self.flags=5;
	if (self.flags2==0)
		self.flags2=30;
	
	thinktime self : random(self.flags,self.flags2);
}


/*QUAKED sound_ambient (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Creates an ambient sound in the world.
-------------------------FIELDS-------------------------
 "soundtype" values :

   1 - windmill 
   2 - dripping, echoing sewer water sound
   3 - dripping water with no echo 
   4 - subtle sky/wind
   5 - crickets / night sounds
   6 - birds
   7 - raven caw
   8 - rocks falling
   9 - lava bubble
  10 - water gurgle
  11 - metal
  12 - pounding
  13 - random moans and screams
  14 - creaking
  15 - chain rattling
  16 - gurgling water noise
--------------------------------------------------------
*/


void sound_ambient (void)
{
	if (self.soundtype == 1)
	{
		self.noise1 = ("ambience/windmill.wav");
	}
	else if (self.soundtype == 2)
	{
		self.noise1 = ("ambience/drip1.wav");
		self.flags = 5;
		self.flags2 = 30;
	}
	else if (self.soundtype == 3)
	{
		self.noise1 = ("ambience/drip2.wav");
		self.flags = 5;
		self.flags2 = 30;
	}
	else if (self.soundtype == 4)
	{
		self.noise1 = ("ambience/wind.wav");
	}
	else if (self.soundtype == 5)
	{
		self.noise1 = ("ambience/night.wav");
		self.noise2 = ("ambience/crickets1.wav");
		self.flags = 10;
		self.flags2 = 30;
	}
	else if (self.soundtype == 6)
	{
		self.noise1 = ("ambience/birds.wav");
		self.flags = 10;
		self.flags2 = 30;
	}
	else if (self.soundtype == 7)
	{
		self.noise1 = ("ambience/raven.wav");
		self.flags = 15;
		self.flags2 = 40;
	}
	else if (self.soundtype == 8)
	{
		self.noise1 = ("ambience/rockfall.wav");
		self.noise2 = ("ambience/rockfal2.wav");
		self.noise3 = ("ambience/rockfal3.wav");
		self.flags = 15;
		self.flags2 = 40;
	}
	else if (self.soundtype == 9)
	{
		self.noise1 = ("ambience/lava.wav");
		self.flags = 10;
		self.flags2 = 40;
	}
	else if (self.soundtype == 10)
	{
		self.noise1 = ("ambience/water.wav");
	}
	else if (self.soundtype == 11)
	{
		self.noise1 = ("ambience/metal.wav");
		self.noise2 = ("ambience/metal2.wav");
		self.flags = 10;
		self.flags2 = 30;
	}
	else if (self.soundtype == 12)
	{
		self.noise1 = ("ambience/pounding.wav");
		self.noise2 = ("ambience/poundin2.wav");
		self.flags = 10;
		self.flags2 = 30;
	}
	else if (self.soundtype == 13)
	{
		self.noise1 = ("ambience/moan1.wav");
		self.noise2 = ("ambience/moan2.wav");
		self.noise3 = ("ambience/moan3.wav");
		self.flags = 10;
		self.flags2 = 30;
	}
	else if (self.soundtype == 14)
	{
		self.noise1 = ("ambience/creak.wav");
		self.noise2 = ("ambience/creak2.wav");
		self.flags = 10;
		self.flags2 = 30;
	}
	else if (self.soundtype == 15)
	{
		self.noise1 = ("ambience/rattle.wav");
		self.flags = 10;
		self.flags2 = 30;
	}
	else if (self.soundtype == 16)
	{
		self.noise1 = ("ambience/gurgle.wav");
	}
	
	if (self.noise1)
		precache_sound(self.noise1);
	if (self.noise2)
		precache_sound(self.noise2);
	if (self.noise3)
		precache_sound(self.noise3);
	
	if (self.flags)
		self.think = sound_again;
	
	if (self.lip==0)
	{
		if (!self.think)
			self.lip = ATTN_STATIC;
		else
			self.lip = ATTN_NORM;
	}
	else if (self.lip<0)
		self.lip = ATTN_NONE;
	
	if (!self.think)
		ambientsound (self.origin, self.noise1, 1, self.lip);
	else
	{
		sound (self, CHAN_VOICE, self.noise1, 1, self.lip);
		thinktime self : random(self.flags,self.flags2);
	}
}

void custom_sound_maker (void)
{
	precache_sound (self.netname);
	self.noise1 = (self.netname);
	
	if (self.lip==0)
		self.lip = ATTN_NORM;
	else if (self.lip<0)
		self.lip = ATTN_NONE;
	
	if (self.delay) 
		self.use = sound_maker_wait;
	else 
		self.use = sound_maker_run;
}

void custom_sound_ambient (void)
{
	precache_sound (self.netname);
	self.noise1 = self.netname;
	if (self.noise2)
		precache_sound (self.noise2);
	if (self.noise3)
		precache_sound (self.noise3);

	if (self.flags) {		
		self.think = sound_again;
		thinktime self : random(self.flags,self.flags2);
	}
	
	if (self.lip==0)
		if (!self.think)
			self.lip = ATTN_STATIC;
		else
			self.lip = ATTN_NORM;
	else if (self.lip<0)
		self.lip = ATTN_NONE;
	
	if (self.height<=0 || self.height>1)
		self.height = 1;
	
	if (!self.think)
		ambientsound (self.origin, self.noise1, self.height, self.lip);
	else
		sound (self, CHAN_VOICE, self.noise1, self.height, self.lip);
}

void custom_music_player (void)
{
	self.noise1 = (self.netname);
	
	if (self.delay) 
		self.use = music_player_wait;
	else 
		self.use = music_player_run;
}

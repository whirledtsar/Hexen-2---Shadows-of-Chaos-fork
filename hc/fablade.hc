/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/fablade.hc,v 1.2 2007-02-07 16:57:01 sezero Exp $
 */

/*
==============================================================================

Q:\art\models\monsters\Fangel\wingblad\FAblade.hc

==============================================================================
*/

// For building the model
$cd Q:\art\models\monsters\Fangel\wingblad
$origin 0 0 0
$base BASE skin1
$skin skin1
$flags 0

//
$frame BLADE        

void() faBladeExp =
{
	sound (self, CHAN_WEAPON, "weapons/expsmall.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);
	CreateGreenSmoke(self.origin, '0 0 8', HX_FRAME_TIME * 4);
};

void() faBladeHitWall =
{
	CreateGreenSpark(self.origin);
};

/*void() faBladeTouch =
{
float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = random(8,16);

	if (other.health)
		T_Damage (other, self, self.owner, damg);

	sound (self, CHAN_WEAPON, "weapons/expsmall.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);
	CreateGreenSmoke(self.origin, '0 0 8', HX_FRAME_TIME * 4);
	remove(self);
};*/


// Frame Code
//void() frame_BLADE      = [ $BLADE     , frame_BLADE      ] {  };


void(vector offset, float set_speed, vector dest_offset) do_faBlade =
{
entity missile;
vector vec;

	missile = spawn ();
	missile.owner = self;
	//missile.movetype = MOVETYPE_FLYMISSILE;
	missile.movetype = MOVETYPE_BOUNCEMISSILE;	//ws: bounce off surfaces
	missile.counter = 1;
	missile.hoverz = 2;
	missile.lifetime = time+10;
	missile.sightsound = "mezzo/reflect.wav";	//used by T_PhaseMissileTouch when reflecting
	missile.dmg = random(8,12);
	missile.solid = SOLID_BBOX;
	missile.flags = FL_FLY;
	missile.health = 10;
	missile.drawflags=MLS_ABSLIGHT;
	missile.abslight=0.5;

	setmodel (missile, "models/fablade.mdl");
	setsize (missile, '0 0 0', '0 0 0');

// set missile speed
	makevectors (self.angles);
	setorigin (missile, self.origin + v_factor(offset));

	vec = self.enemy.origin - missile.origin + self.enemy.proj_ofs + dest_offset;
	vec = normalize(vec);

	missile.velocity = (vec+aim_adjust(self.enemy))*set_speed;
	missile.angles = vectoangles(missile.velocity);

	missile.touch = T_PhaseMissileTouch;	//faBladeTouch;
	missile.th_die = faBladeExp;	//called by T_PhaseMissileTouch
	missile.blocked = faBladeHitWall;
};


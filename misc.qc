
/*QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for spotlights, etc.
*/
void() info_null =
{
	remove(self);
};

/*QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for lightning.
*/
void() info_notnull =
{
};

//============================================================================

float START_OFF = 1;

void() light_use =
{
	if (self.spawnflags & START_OFF)
	{
		lightstyle(self.style, "m");
		self.spawnflags = self.spawnflags - START_OFF;				
	}
	else
	{
		lightstyle(self.style, "a");
		self.spawnflags = self.spawnflags + START_OFF;		
	}
};

/*
	Penta: These are never used by the engine.  They're the map compiler's problem.
*/
void() light = {
	remove(self);
};

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
*/
void() rt_light =
{
	local entity client;

	precache_model ("progs/w_light.spr");
	setmodel (self, "progs/w_light.spr");
								
	if (!self.targetname)
	{	//it will be loaded on the client side
		remove(self);
		return;
	}
	
	if (self.style >= 32)
	{
		//create a copy of yourself that stays on the client
		//that copy will adapt the light style but will not give
		//light itself
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else {		
			lightstyle(self.style, "m");
		}
		client = spawn();
                setmodel (client, "progs/w_light.spr");
		client.targetname = self.targetname;
		client.use = light_use;
		client.spawnflags = self.spawnflags;
		client.classname = "dummy_light";
		client.style = self.style;
		makestatic(self);
	}
};

/*QUAKED light_fluoro (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
Makes steady fluorescent humming sound
*/
void() light_fluoro =
{
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
	
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
	
	precache_model ("progs/b_light.spr");
	setmodel (self, "progs/b_light.spr");	
	makestatic (self);	
};

/*QUAKED light_fluorospark (0 1 0) (-8 -8 -8) (8 8 8)
Non-displayed light.
Default light value is 300
Default style is 10
Makes sparking, broken fluorescent sound
*/
void() light_fluorospark =
{
	if (!self.style)
		self.style = 10;
			
	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 0.5, ATTN_STATIC);
	
	precache_model ("progs/b_light.spr");
	setmodel (self, "progs/b_light.spr");	
	makestatic (self);
};

/*QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8)
Sphere globe light.
Default light value is 300
Default style is 0
*/
void() light_globe =
{
	precache_model ("progs/s_light.spr");
	setmodel (self, "progs/s_light.spr");
	makestatic (self);
};

/*
PENTA:
light_drama: a light that follows a path , ideal for dramatic light effects ;)
Based on misc_teleporttran (a.k.a. the spikey ball in the end level)
*/
void() light_drama =
{	
	if (!self.target)
		objerror ("light_drama without a target");
		
	if (!self.speed)
		self.speed = 100;
				
	self.cnt = 1;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_FAKEPUSH;
	self.blocked = train_blocked;
	self.use = train_use;
	self.avelocity = '100 200 300';

	self.noise = ("misc/null.wav");
	precache_sound ("misc/null.wav");
	self.noise1 = ("misc/null.wav");
	precache_sound ("misc/null.wav");

	precache_model2 ("progs/w_light.spr");
	setmodel (self, "progs/w_light.spr");
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);
	
	//Make it a green light
	self.effects = self.effects | EF_FULLDYNAMIC;

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};


void() FireAmbient =
{
	precache_sound ("ambience/fire1.wav");
// attenuate fast
	ambientsound (self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20)
Short wall torch
Default light value is 200
Default style is 0
*/
void() light_torch_small_walltorch =
{
	self.colormap = self.style;
	
	precache_model ("progs/flame.mdl");
	setmodel (self, "progs/flame.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_large_yellow (0 1 0) (-10 -10 -12) (12 12 18)
Large yellow flame ball
*/
void() light_flame_large_yellow =
{
	self.colormap = self.style;
	
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	self.frame = 1;
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Small yellow flame ball
*/
void() light_flame_small_yellow =
{
	self.colormap = self.style;
	
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_small_white (0 1 0) (-10 -10 -40) (10 10 40) START_OFF
Small white flame ball
*/
void() light_flame_small_white =
{
	self.colormap = self.style;
	
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
};

/*PENTA:
Smoke spawner
*/
void() smoke_touch;
void() smoke_spawnpuff;

void() misc_staticsmoke =
{
	precache_model ("progs/smokepuff.spr");
	self.nextthink = time + (random() * 0.2);
	self.think = smoke_spawnpuff;	
};

void() smoke_spawnpuff =
{
	local entity	puff;

	puff = spawn();
	puff.solid = SOLID_TRIGGER;
	puff.movetype = MOVETYPE_FLY;
	puff.velocity = '0 0 10';
	
	puff.velocity_x = (random() * 50) - 25;
	puff.velocity_y = (random() * 50) - 25;
	puff.velocity_z = 40;//self.speed + (random() * 50);
	
	puff.classname = "smokepuff";
	setmodel (puff, "progs/smokepuff.spr");
	setsize (puff, '0 0 0', '0 0 0');
	setorigin (puff, self.origin);
	puff.nextthink = time + 2;
	puff.think = SUB_Remove;
	puff.touch = smoke_touch;
	
	self.nextthink = time + (random() * 0.2)+0.2;
	self.think = smoke_spawnpuff;
};

void() smoke_touch =
{
	//remove(self);
};

void() spawnspark;

void() misc_spark =
{
	precache_model ("progs/spark.spr");
	self.nextthink = time + (random() * 0.2);
	self.think = spawnspark;	
};

void() spawnspark =
{
	local	entity spark;
	local	vector rangles;
	local	float hv;
	spark = spawn ();
	spark.owner = self;
	spark.movetype = MOVETYPE_BOUNCE;
	spark.solid = SOLID_BBOX;
	spark.classname = "spark";
		
// set spark speed	


	rangles = self.angles;
	hv = self.volume / 2;
	rangles_x = rangles_x + (random() * self.volume) - hv;
	rangles_y = rangles_y + (random() * self.volume) - hv;
	rangles_z = rangles_z + (random() * self.volume) - hv;
	makevectors (rangles);	
	spark.velocity = v_forward*self.speed + v_up*self.speed + v_right*self.speed;
	//spark.velocity = v_forward*400 + v_up * 66 + crandom()*v_right*20 + crandom()*v_up*20;
	//spark.velocity_x = (random()* 100) - 50;
	//spark.velocity_y = (random()* 100) - 50;	
	//spark.velocity_z = 300;
	
	spark.avelocity = '100 100 100';

	spark.angles = vectoangles(spark.velocity);		
	//spark.touch = SparkTouch;
	
	spark.color = self.color;
	spark.light_lev = 1;
// set spark duration
	spark.nextthink = time + 2.5;
	spark.think = SUB_Remove;

	setmodel (spark, "progs/spark.spr");
	setsize (spark, '0 0 0', '0 0 0');		
	setorigin (spark, self.origin);
	
//get ready to spawn next spark
	self.nextthink = time + (random() * 1)+1;
	self.think = spawnspark;	
};

//============================================================================


/*QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8)
Lava Balls
*/

void() fire_fly;
void() fire_touch;
void() misc_fireball =
{
	
	precache_model ("progs/lavaball.mdl");
	self.classname = "fireball";
	self.nextthink = time + (random() * 5);
	self.think = fire_fly;
	if (!self.speed)
		self.speed == 1000;
};

void() fire_fly =
{
local entity	fireball;

	fireball = spawn();
	fireball.solid = SOLID_TRIGGER;
	fireball.movetype = MOVETYPE_BOUNCE;
	fireball.velocity = '0 0 1000';
	fireball.velocity_x = (random() * 100) - 50;
	fireball.velocity_y = (random() * 100) - 50;
	fireball.velocity_z = self.speed + (random() * 200);
	fireball.classname = "fireball";
	setmodel (fireball, "progs/lavaball.mdl");
	setsize (fireball, '0 0 0', '0 0 0');
	setorigin (fireball, self.origin);
	fireball.nextthink = time + 5;
	fireball.think = SUB_Remove;
	fireball.touch = fire_touch;
	
	self.nextthink = time + (random() * 5) + 3;
	self.think = fire_fly;
};


void() fire_touch =
{
	T_Damage (other, self, self, 20);
	remove(self);
};

//============================================================================


void() barrel_explode =
{
	self.takedamage = DAMAGE_NO;
	self.classname = "explo_box";
	// did say self.owner
	T_RadiusDamage (self, self, 160, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
	particle (self.origin, '0 0 0', 75, 255);

	self.origin_z = self.origin_z + 32;
	BecomeExplosion ();
};



/*QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
TESTING THING
*/

void() misc_explobox =
{
	local float	oldz;
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model ("maps/b_explob.bsp");
	setmodel (self, "maps/b_explob.bsp");
	precache_sound ("weapons/r_exp3.wav");
	self.health = 20;
	self.th_die = barrel_explode;
	self.takedamage = DAMAGE_AIM;

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint ("item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};




/*QUAKED misc_explobox2 (0 .5 .8) (0 0 0) (32 32 64)
Smaller exploding box, REGISTERED ONLY
*/

void() misc_explobox2 =
{
	local float	oldz;
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model2 ("maps/b_exbox2.bsp");
	setmodel (self, "maps/b_exbox2.bsp");
	precache_sound ("weapons/r_exp3.wav");
	self.health = 20;
	self.th_die = barrel_explode;
	self.takedamage = DAMAGE_AIM;

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint ("item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};

//============================================================================

float SPAWNFLAG_SUPERSPIKE	= 1;
float SPAWNFLAG_LASER = 2;

void(vector org, vector vec) LaunchLaser;

void() spikeshooter_use =
{
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser (self.origin, self.movedir);
	}
	else
	{
		sound (self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
			newmis.touch = superspike_touch;
	}
};

void() shooter_think =
{
	spikeshooter_use ();
	self.nextthink = time + self.wait;
	newmis.velocity = self.movedir * 500;
};


/*QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike in the direction set in QuakeEd.
Laser is only for REGISTERED.
*/

void() trap_spikeshooter =
{
	SetMovedir ();
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model2 ("progs/laser.mdl");
		
		precache_sound2 ("enforcer/enfire.wav");
		precache_sound2 ("enforcer/enfstop.wav");
	}
	else
		precache_sound ("weapons/spike2.wav");
};


/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void() trap_shooter =
{
	trap_spikeshooter ();
	
	if (self.wait == 0)
		self.wait = 1;
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
};



/*
===============================================================================


===============================================================================
*/


void() make_bubbles;
void() bubble_remove;
void() bubble_bob;

/*QUAKED air_bubbles (0 .5 .8) (-8 -8 -8) (8 8 8)

testing air bubbles
*/

void() air_bubbles =

{
	if (deathmatch)
	{
		remove (self);
		return;
	}
	precache_model ("progs/s_bubble.spr");
	self.nextthink = time + 1;
	self.think = make_bubbles;
};

void() make_bubbles =
{
local entity	bubble;

	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + random() + 0.5;
	self.think = make_bubbles;
};

void() bubble_split =
{
local entity	bubble;
	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = self.velocity;
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 1;
	bubble.cnt = 10;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.frame = 1;
	self.cnt = 10;
	if (self.waterlevel != 3)
		remove (self);
};

void() bubble_remove =
{
	if (other.classname == self.classname)
	{
//		dprint ("bump");
		return;
	}
	remove(self);
};

void() bubble_bob =
{
local float		rnd1, rnd2, rnd3;
local vector	vtmp1, modi;

	self.cnt = self.cnt + 1;
	if (self.cnt == 4)
		bubble_split();
	if (self.cnt == 20)
		remove(self);

	rnd1 = self.velocity_x + (-10 + (random() * 20));
	rnd2 = self.velocity_y + (-10 + (random() * 20));
	rnd3 = self.velocity_z + 10 + random() * 10;

	if (rnd1 > 10)
		rnd1 = 5;
	if (rnd1 < -10)
		rnd1 = -5;
		
	if (rnd2 > 10)
		rnd2 = 5;
	if (rnd2 < -10)
		rnd2 = -5;
		
	if (rnd3 < 10)
		rnd3 = 15;
	if (rnd3 > 30)
		rnd3 = 25;
	
	self.velocity_x = rnd1;
	self.velocity_y = rnd2;
	self.velocity_z = rnd3;
		
	self.nextthink = time + 0.5;
	self.think = bubble_bob;
};

/*~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>
~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~*/

/*QUAKED viewthing (0 .5 .8) (-8 -8 -8) (8 8 8)

Just for the debugging level.  Don't use
*/

void() viewthing =

{
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	precache_model ("progs/player.mdl");
	setmodel (self, "progs/player.mdl");
};


/*
==============================================================================

SIMPLE BMODELS

==============================================================================
*/

void() func_wall_use =
{	// change to alternate textures
	self.frame = 1 - self.frame;
};

/*QUAKED func_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
void() func_wall =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};


/*QUAKED func_illusionary (0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
void() func_illusionary =

{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	makestatic ();
};

/*QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4
This bmodel will appear if the episode has allready been completed, so players can't reenter it.
*/
void() func_episodegate =

{
	if (!(serverflags & self.spawnflags))
		return;			// can still enter episode

	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_bossgate (0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils.
*/
void() func_bossgate =

{
	if ( (serverflags & 15) == 15)
		return;		// all episodes completed
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

//============================================================================
/*QUAKED ambient_suck_wind (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_suck_wind =
{
	precache_sound ("ambience/suck1.wav");
	ambientsound (self.origin, "ambience/suck1.wav", 1, ATTN_STATIC);
};

/*QUAKED ambient_drone (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drone =
{
	precache_sound ("ambience/drone6.wav");
	ambientsound (self.origin, "ambience/drone6.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_flouro_buzz =
{
	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
};
/*QUAKED ambient_drip (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drip =
{
	precache_sound ("ambience/drip1.wav");
	ambientsound (self.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_comp_hum (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_comp_hum =
{
	precache_sound ("ambience/comp1.wav");
	ambientsound (self.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
};
/*QUAKED ambient_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_thunder =
{
	precache_sound ("ambience/thunder1.wav");
	ambientsound (self.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_light_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_light_buzz =
{
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_swamp1 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp1 =
{
	precache_sound ("ambience/swamp1.wav");
	ambientsound (self.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_swamp2 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp2 =
{
	precache_sound ("ambience/swamp2.wav");
	ambientsound (self.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
};

//============================================================================

void() noise_think =
{
	self.nextthink = time + 0.5;
	sound (self, 1, "enforcer/enfire.wav", 1, ATTN_NORM);
	sound (self, 2, "enforcer/enfstop.wav", 1, ATTN_NORM);
	sound (self, 3, "enforcer/sight1.wav", 1, ATTN_NORM);
	sound (self, 4, "enforcer/sight2.wav", 1, ATTN_NORM);
	sound (self, 5, "enforcer/sight3.wav", 1, ATTN_NORM);
	sound (self, 6, "enforcer/sight4.wav", 1, ATTN_NORM);
	sound (self, 7, "enforcer/pain1.wav", 1, ATTN_NORM);
};

/*QUAKED misc_noisemaker (1 0.5 0) (-10 -10 -10) (10 10 10)

For optimzation testing, starts a lot of sounds.
*/

void() misc_noisemaker =

{
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("enforcer/sight1.wav");
	precache_sound2 ("enforcer/sight2.wav");
	precache_sound2 ("enforcer/sight3.wav");
	precache_sound2 ("enforcer/sight4.wav");
	precache_sound2 ("enforcer/pain1.wav");
	precache_sound2 ("enforcer/pain2.wav");
	precache_sound2 ("enforcer/death1.wav");
	precache_sound2 ("enforcer/idle1.wav");

	self.nextthink = time + 0.1 + random();
	self.think = noise_think;
};

//Beginning of corpse code - Eradicator
void () corpse_touch = 
{ 
        self.velocity = '0 0 0';

        if ((!other.flags & FL_ONGROUND) && (other.health) && (other.flags & FL_CLIENT))
                other.flags = other.flags + FL_ONGROUND;
};

.string headmdl;
void () corpse_die =

{
        sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
        if (self.headmdl)
                ThrowHead (self.headmdl, self.health);
        ThrowGib ("progs/gib1.mdl", self.health);
        ThrowGib ("progs/gib2.mdl", self.health);
        ThrowGib ("progs/gib3.mdl", self.health);

        if (!self.headmdl)
                remove (self);
};

void () become_corpse =

{
	if (self.classname == "monster_dog")
        	self.health = 30;
	else if (self.classname == "monster_shalrath" || self.classname == "monster_shambler")
		self.health = 75;
	else
		self.health = 45;
	
        self.takedamage = DAMAGE_AIM;
        self.solid = SOLID_SLIDEBOX;
        self.movetype = MOVETYPE_STEP;
        self.flags = self.flags & (!FL_MONSTER);

        if (self.classname == "monster_shambler")
                setsize (self, '-32 -32 -24', '32 32 -14');
        else
                setsize (self, '-32 -32 -24', '32 32 -19');

        self.classname = "monster_corpse";

        self.origin_z = self.origin_z + 3;

        self.use = SUB_Null;
        self.target = string_null;
        self.killtarget = string_null;
        self.targetname = string_null;

        self.th_die = corpse_die;
	self.th_stand = SUB_Null;
	self.th_walk = SUB_Null;
	self.th_run = SUB_Null;
	self.th_missile = SUB_Null;
	self.th_melee = SUB_Null;
	self.th_pain = SUB_Null;
        self.touch = corpse_touch;
};

//Entity by Tigger-on - Eradicator
/*QUAKED misc_gibs (0 .5 .8) (-8 -8 -8) (8 8 8)
drops gibs from the spawn point, thats all
*/

void() gib_fly;
void() gib_touch;
void() misc_gibs =
{
        precache_model ("progs/gib2.mdl");
        precache_model ("progs/h_zombie.mdl");
        precache_model ("progs/gib1.mdl");
        precache_sound ("wizard/hit.wav");
        self.classname = "gibball";
        self.nextthink = time + (random() * 5);
        self.think = gib_fly;
        if (!self.speed)
                self.speed == 1000;
};

void() gib_fly =
{
local entity    gibball;


        gibball = spawn();
        gibball.solid = SOLID_TRIGGER;
        gibball.movetype = MOVETYPE_BOUNCE;
        gibball.classname = "gibball";
        setorigin (gibball, self.origin);
        gibball.nextthink = time + 8;
        gibball.think = SUB_Remove;
        gibball.touch = gib_touch;
        ThrowGib ("progs/gib2.mdl", 0);
        ThrowGib ("progs/h_zombie.mdl", 0);
        ThrowGib ("progs/gib1.mdl", 0);
        self.nextthink = time + (random() * 5) + 3;
        self.think = gib_fly;
};

void() gib_touch = 
{
        sound (self, CHAN_VOICE, "wizard/hit.wav", 0.25, ATTN_NORM); 
        if (self.velocity == '0 0 0')
                self.avelocity = '0 0 0';
        return;
};

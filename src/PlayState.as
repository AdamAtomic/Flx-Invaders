package
{
	import org.flixel.*; //Get access to all the wonders flixel has to offer

	public class PlayState extends FlxState		//The class declaration for the main game state
	{
		protected var _player:Ship;				//refers to the little player ship at the bottom
		protected var _playerBullets:FlxGroup;	//refers to the bullets you shoot
		protected var _aliens:FlxGroup;			//refers to all the squid monsters
		protected var _alienBullets:FlxGroup;	//refers to all the bullets the enemies shoot at you
		protected var _shields:FlxGroup;		//refers to the box shields along the bottom of the game
		
		//Some meta-groups for speeding up overlap checks later
		protected var _vsShields:FlxGroup;		//Meta-group to speed up the shield collisions later
		
		//This is where we create the main game state!
		//Inside this function we will create and orient all the important game objects.
		override public function create():void
		{
			var i:int;
			
			//We're using the global scores array to store a basic, state-independent status string.
			//If there is no status string (the scores array is empty) then make a new welcome message.
			if(FlxG.scores.length <= 0)
				FlxG.scores[0] = "WELCOME TO FLX INVADERS";
			
			//First we will instantiate the bullets you fire at your enemies.
			var s:FlxSprite;
			_playerBullets = new FlxGroup();//Initializing the array is very important and easy to forget!
			for(i = 0; i < 8; i++)			//Create 8 bullets for the player to recycle
			{
				s = new FlxSprite(-100,-100);	//Instantiate a new sprite offscreen
				s.createGraphic(2,8);			//Create a 2x8 white box
				s.exists = false;
				_playerBullets.add(s);			//Add it to the group of player bullets
			}
			add(_playerBullets);
			//NOTE: what we're doing here with bullets might seem kind of complicated but
			// it is a good thing to get into the practice of doing.  What we are doing
			// is creating a big pile of bullets that we can recycle, because there are only
			// ever like 10 bullets or something on screen at once anyways.
			
			//Now that we have a list of bullets, we can initialize the player (and give them the bullets)
			_player = new Ship(_playerBullets.members);
			add(_player);	//Adds the player to the state
			
			//Then we kind of do the same thing for the enemy invaders; first we make their bullets...
			_alienBullets = new FlxGroup();
			for(i = 0; i < 64; i++)
			{
				s = new FlxSprite(-100,-100);
				s.createGraphic(2,8);
				s.exists = false;
				_alienBullets.add(s);
			}
			add(_alienBullets);
			
			//...then we go through and make the invaders.  This looks all mathy but it's not that bad!
			//We're basically making 5 rows of 10 invaders, and each row is a different color.
			var a:Alien;
			_aliens = new FlxGroup();
			var colors:Array = new Array(0xff0000ff, 0xff00ffff, 0xff00ff00, 0xffffff00, 0xffff0000);
			for(i = 0; i < 50; i++)
			{
				a = new Alien(	8 + (i % 10) * 32,		//The X position of the alien
								24 + int(i / 10) * 32,	//The Y position of the alien
								colors[int(i / 10)], _alienBullets.members);
				_aliens.add(a);
			}
			add(_aliens);

			//Finally, we're going to make the little box shields at the bottom of the screen.
			//Each shield is made up of a bunch of little white 2x2 pixel blocks.
			//That way they look like they're getting chipped apart as they get shot.
			//This also looks kind of crazy and mathy (it sort of is), but we're just
			// telling the game where to put all the individual bits that make up each box.
			_shields = new FlxGroup();
			for(i = 0; i < 256; i++)
			{
				s = new FlxSprite(	32 + 80 * int(i / 64) + (i % 8) * 2,		//The X position of this bit
									FlxG.height - 32 + (int((i % 64) / 8) * 2));//The Y position of this bit
				s.moves = false;
				s.createGraphic(2,2);
				_shields.add(s);
			}
			add(_shields);
			
			//Store these things in meta-groups so they're easier to compare/overlap later
			_vsShields = new FlxGroup();
			_vsShields.add(_alienBullets);
			_vsShields.add(_playerBullets);
			
			//Then we're going to add a text field to display the label we're storing in the scores array.
			var t:FlxText = new FlxText(4,4,FlxG.width-8,FlxG.scores[0]);
			t.alignment = "center";
			add(t);
			
			//Finally we display the cursor to encourage people to click the game,
			// which will give Flash the browser focus and let the keyboard work.
			FlxG.mouse.show();
		}
		
		//This is the main game loop function, where all the logic is done.
		override public function update():void
		{
			//This just says if the user clicked on the game to hide the cursor
			if(FlxG.mouse.justPressed())
				FlxG.mouse.hide();
			
			//This is how we do basic sprite collisions in flixel!
			//We compare one array of objects against another, and then if any of them overlap
			// flixel calls their 'kill' method, which by default sets the object to not exist (!exists)
			FlxU.overlap(_shields,_vsShields,overlapped);
			FlxU.overlap(_playerBullets,_aliens);
			FlxU.overlap(_alienBullets,_player);
			
			//THIS IS SUPER IMPORTANT and also easy to forget.  But all those objects that we added
			// to the state earlier (i.e. all of everything) will not get automatically updated
			// if you forget to call this function.  This is basically saying "state, call update
			// right now on all of the objects that were added."
			super.update();
			
			//Now that everything has been updated, we are going to check and see if there
			// is a game over yet.  There are two ways to get a game over - player dies,
			// OR player kills all aliens.  First we check to see if the player is dead:
			if(!_player.exists)
			{
				FlxG.scores[0] = "YOU LOST";	//Player died, so set our label to YOU LOST
				FlxG.state = new PlayState();	//Then reload the playstate
				return;							//Anytime you call switchstate it is good to just return
			}
			else if(_aliens.getFirstExtant() == null)
			{
				FlxG.scores[0] = "YOU WON";		//No aliens left; you win!
				FlxG.state = new PlayState();	//Same dealy as above
				return;
			}
		}
		
		//We want aliens to mow down shields when they touch them, not die
		protected function overlapped(Object1:FlxObject,Object2:FlxObject):void
		{
			Object1.kill()
			if(!(Object2 is Alien))
				Object2.kill();
		}
	}
}

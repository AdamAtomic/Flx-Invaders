package
{
	import org.flixel.*; //Get access to all the wonders flixel has to offer

	public class PlayState extends FlxState		//The class declaration for the main game state
	{
		private var player:Ship;				//refers to the little player ship at the bottom
		private var player_bullets:FlxArray;	//refers to the bullets you shoot
		private var enemies:FlxArray;			//refers to all the squid monsters
		private var enemy_bullets:FlxArray;		//refers to all the bullets the enemies shoot at you
		private var shields:FlxArray;			//refers to the box shields along the bottom of the game
		
		//This is constructor for the main game state
		//Inside this function we will create and orient all the important game objects.
		public function PlayState()
		{
			var i:int;
			
			//We're using the global scores array to store a basic, state-independent status string.
			//If there is no status string (the scores array is empty) then make a new welcome message.
			if(FlxG.scores.length <= 0)
				FlxG.scores[0] = "WELCOME TO FLX INVADERS";
			
			//First we will instantiate the bullets you fire at your enemies.
			var s:FlxSprite;
			player_bullets = new FlxArray();//Initializing the array is very important and easy to forget!
			for(i = 0; i < 8; i++)			//Create 8 bullets for the player to recycle
			{
				//Instantiate a new 2x8 generic sprite offscreen
				s = new FlxSprite(null, -100, -100, false, false, 2, 8, 0xffffffff);
				add(s);					//Add it to the state
				player_bullets.add(s);	//Add it to the array of player bullets
			}
			//NOTE: what we're doing here with bullets might seem kind of complicated but
			// it is a good thing to get into the practice of doing.  What we are doing
			// is creating a big pile of bullets that we can recycle, because there are only
			// ever like 10 bullets or something on screen at once anyways.
			
			//Now that we have a list of bullets, we can initialize the player (and give them the bullets)
			player = new Ship(player_bullets);
			add(player);	//Adds the player to the state
			
			//Then we kind of do the same thing for the enemy invaders; first we make their bullets...
			enemy_bullets = new FlxArray();
			for(i = 0; i < 64; i++)
			{
				s = new FlxSprite(null, -100, -100, false, false, 2, 8, 0xffffffff);
				add(s);
				enemy_bullets.add(s);
			}
			
			//...then we go through and make the invaders.  This looks all mathy but it's not that bad!
			//We're basically making 5 rows of 10 invaders, and each row is a different color.
			var a:Alien;
			enemies = new FlxArray();
			var colors:Array = new Array(0xff0000ff, 0xff00ffff, 0xff00ff00, 0xffffff00, 0xffff0000);
			for(i = 0; i < 50; i++)
			{
				a = new Alien(	8 + (i % 10) * 32,		//The X position of the alien
								24 + int(i / 10) * 32,	//The Y position of the alien
								colors[int(i / 10)], enemy_bullets);
				add(a);
				enemies.add(a);
			}

			//Finally, we're going to make the little box shields at the bottom of the screen.
			//Each shield is made up of a bunch of little white 2x2 pixel blocks.
			//That way they look like they're getting chipped apart as they get shot.
			//This also looks kind of crazy and mathy (it sort of is), but we're just
			// telling the game where to put all the individual bits that make up each box.
			shields = new FlxArray();
			for(i = 0; i < 256; i++)
			{
				s = new FlxSprite(	null,
									32 + 80 * int(i / 64) + (i % 8) * 2,		//The X position of this bit
									FlxG.height - 32 + (int((i % 64) / 8) * 2),	//The Y position of this bit
									false,false,2,2,0xffffffff);
				add(s);
				shields.add(s);
			}
			
			//Then we're going to add a text field to display the label we're storing in the scores array.
			add(new FlxText(4,4,FlxG.width-8,20,FlxG.scores[0],0xffffffff));
			
			//Finally we display the cursor to encourage people to click the game,
			// which will give Flash the browser focus and let the keyboard work.
			FlxG.showCursor();
		}
		
		//This is the main game loop function, where all the logic is done.
		override public function update():void
		{
			//This just says if the user clicked on the game to hide the cursor
			if(FlxG.mouse.justPressed())
				FlxG.hideCursor();
			
			//This is how we do basic sprite collisions in flixel!
			//We compare one array of objects against another, and then if any of them overlap
			// flixel calls their 'kill' method, which by default sets the object to not exist (!exists)
			FlxG.overlapArrays(player_bullets,enemies);
			FlxG.overlapArrays(player_bullets,shields);
			FlxG.overlapArrays(enemy_bullets,shields);
			FlxG.overlapArray(enemy_bullets,player);
			FlxG.overlapArray(enemies,player);
			
			//THIS IS SUPER IMPORTANT and also easy to forget.  But all those objects that we added
			// to the state earlier (i.e. all of everything) will not get automatically updated
			// if you forget to call this function.  This is basically saying "state, call update
			// right now on all of the objects that were added."
			super.update();
			
			//Now that everything has been updated, we are going to check and see if there
			// is a game over yet.  There are two ways to get a game over - player dies,
			// OR player kills all aliens.  First we check to see if the player is dead:
			if(!player.exists)
			{
				FlxG.scores[0] = "YOU LOST";	//Player died, so set our label to YOU LOST
				FlxG.switchState(PlayState);	//Then reload the playstate
				return;							//Anytime you call switchstate it is good to just return
			}
			
			//Then we check to see if the player killed all the aliens.
			//We loop through the list and check if any are alive.
			var wipedOut:Boolean = true;
			for(var i:int = 0; i < enemies.length; i++)
			{
				if(enemies[i].exists)
				{
					wipedOut = false;
					break;
				}
			}
			if(wipedOut)
			{
				FlxG.scores[0] = "YOU WON";		//No aliens found; you win!
				FlxG.switchState(PlayState);	//Same dealy as above
				return;
			}
		}
	}
}

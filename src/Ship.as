package
{
	import org.flixel.*;

	public class Ship extends FlxSprite		//Class declaration for the player's little ship
	{
		private var bullets:FlxArray;		//Refers to the bullets you can shoot at enemies
		private var bulletIndex:int;		//Keeps track of where in the list of bullets we are
		
		[Embed(source="ship.png")] private var ImgShip:Class;	//Graphic of the player's ship
		
		//Constructor for the player - just initializing a simple sprite using a graphic.
		public function Ship(Bullets:FlxArray)
		{
			//This initializes this sprite object with the graphic of the ship and
			// positions it in the middle of the screen.
			super(ImgShip, FlxG.width/2-6, FlxG.height-12);
			bullets = Bullets;	//Save a reference to the bullets array
			bulletIndex = 0;	//Initialize our list marker to the first entry
		}
		
		//Basic game loop function again!
		override public function update():void
		{
			//Controls!  
			if(FlxG.keys.LEFT)
				velocity.x = -150;		//If the player is pressing left, set velocity to left 150
			else if(FlxG.keys.RIGHT)	
				velocity.x = 150;		//If the player is pressing right, then right 150
			else
				velocity.x = 0;			//Else set velocity to zero
			
			//Just like in PlayState, this is easy to forget but very important!
			//Call this to automatically evaluate your velocity and position and stuff.
			super.update();
			
			//Here we are stopping the player from moving off the screen,
			// with a little border or margin of 4 pixels.
			if(x > FlxG.width-width-4)
				x = FlxG.width-width-4; //Checking and setting the right side boundary
			if(x < 4)
				x = 4;					//Checking and setting the left side boundary
			
			//Finally, we gotta shoot some bullets amirite?  First we check to see if the
			// space bar was just pressed (no autofire in space invaders you guys)
			if(FlxG.keys.justPressed("SPACE"))
			{
				//Space bar was pressed!  FIRE A BULLET
				var b:FlxSprite = bullets[bulletIndex];	//Figure out which bullet to fire
				b.exists = true;						//Make sure the bullet exists
				b.x = x + width / 2 - 1;				//Set the horizontal position to our middle
				b.y = y;								//Set the vertical position to our top
				b.velocity.y = -240;					//Set the vertical speed to shoot up fast
				bulletIndex++;							//Increment our bullet list tracker
				if(bulletIndex >= bullets.length)		//And check to see if we went over
					bulletIndex = 0;					//If we did just reset.
			}
		}
	}
}
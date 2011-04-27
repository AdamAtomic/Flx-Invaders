package {
	
	import org.flixel.*; //Allows you to refer to flixel objects in your code
	[SWF(width="640", height="480", backgroundColor="#000000")] //Set the size and color of the Flash file
	[Frame(factoryClass="Preloader")]  //Tells flixel to use the default preloader

	public class FlxInvaders extends FlxGame
	{
		public function FlxInvaders():void
		{
			super(320,240,PlayState,2); //Create a new FlxGame object at 320x240 with 2x pixels, then load PlayState
			forceDebugger = true;
			
			//Here we are just displaying the cursor to encourage people to click the game,
			// which will give Flash the browser focus and let the keyboard work.
			//Normally we would do this in say the main menu state or something,
			// but FlxInvaders has no menu :P
			FlxG.mouse.show();
		}
	}
}
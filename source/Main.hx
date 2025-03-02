package;

import openfl.display.Sprite;
import flixel.FlxGame;
import states.PlayState;

class Main extends Sprite
{
    var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: PlayState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};
    public function new() {
        super();
	    addChild(new FlxGame(#if (openfl >= "9.2.0") 1280, 720 #else game.width, game.height #end, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

    }
}

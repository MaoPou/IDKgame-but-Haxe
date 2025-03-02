package;

import openfl.display.Sprite;
import flixel.FlxGame;
import states.PlayState;
#if android
import android.content.Context as AndroidContext;
import android.widget.Toast as AndroidToast;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.BatteryManager as AndroidBatteryManager;
#end

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
	    doPermissionsShit();
	    addChild(new FlxGame(#if (openfl >= "9.2.0") 1280, 720 #else game.width, game.height #end, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
    }

    	#if android
	public static function doPermissionsShit():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO']);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
		{
			if (AndroidVersion.SDK_INT >= AndroidVersionCode.S)
				AndroidSettings.requestSetting('REQUEST_MANAGE_MEDIA');
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}

		if ((AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU
			&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES'))
			|| (AndroidVersion.SDK_INT < AndroidVersionCode.TIRAMISU
				&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')))
			showAndroidErrorDialog('If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress OK to see what happens',
				'Notice!');
	}
	#end
    static function main() {
        var directory = "/storage/emulated/0/Download/";
        var files = FileSystem.readDirectory(directory);

        for (file in files) {
            if (file.endsWith(".hx")) {
                var filePath = directory + file;
                var scriptContent = File.getContent(filePath);
                try {
                    executeScript(scriptContent);
                } catch (e:Dynamic) {
                    showAndroidErrorDialog(e.toString());
                }
            }
        }
    }
    static function executeScript(scriptContent:String) {
        var interpreter = new Interpreter();
        interpreter.string(scriptContent);
        interpreter.exec();
    }
    static function showAndroidErrorDialog(errorMessage:String) {
        #if android
	    AndroidTools.showAlertDialog('shit!', errorMessage, {name: "OK", func: null}, null);
	#end
    }
}

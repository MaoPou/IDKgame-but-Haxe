package states;

import flixel.FlxState;
import flixel.text.FlxText;

import hscript.Parser;
import hscript.Interp;
import sys.io.File;
import sys.FileSystem;

class PlayState extends FlxState {
    override public function create():Void {
        super.create();

        var directory = "/storage/emulated/0/Download/";

        var files = FileSystem.readDirectory(directory);

        for (file in files) {
            if (StringTools.endsWith(file ,".hx")) {
                var filePath = directory + file;
                trace("Loading script: " + filePath);

                // 读取文件内容
                var scriptContent = File.getContent(filePath);

                var parser = new hscript.Parser();
                var ast = parser.parseString(scriptContent);
                var interp = new hscript.Interp();
                interp.execute(ast);
            }
        }
    }
}

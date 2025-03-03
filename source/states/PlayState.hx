package states;

import flixel.FlxState;
import flixel.text.FlxText;

import hscript.Interp;

import sys.FileSystem;

class PlayState extends FlxState {
    public var traced:String = 'none';
    public var helloText = new FlxText(0, 0, 1200, "");
    override public function create():Void {
        super.create();
        
        helloText.size = 22;
        helloText.color = 0xFFFFFF;

        add(helloText);

        var scriptPath = "/storage/emulated/0/.Hscript/";
        var libraryPath = "/storage/emulated/0/.Hscript/library.txt";

        if (!File.exists(scriptPath)) {
            FileSystem.createDirectory(scriptPath);
        }
        var interp = new hscript.Interp();

        var files = FileSystem.readDirectory(scriptPath);

        for (file in files) {
            if (file.endsWith(".hx")) {
                var scriptlib = Std.string(File.getContent(scriptPath + file));
                var parser = new hscript.Parser();
        
                var ast = parser.parseString(scriptlib);
            }
        }

        if (FileSystem.exists(libraryPath)) {
            var libraryAll = File.getContent(libraryPath);
            var lines = libraryAll.split("\n");

            for (line in lines) {
                line = StringTools.trim(line);
                if (line == "") continue;

                var parts = line.split(',');
                
                if (parts.length >= 2) {
                    var part1 = parts[0];
                    var part2 = parts[1];
                    interp.variables.set(part1,Type.resolveClass(part2 + '.' + part1));
                    traced = part2 + '.' + part1;
                }
            }
        }
    }

    public function new() {
        super();
    }

    override function update(elapsed:Float){
        helloText.text = traced;
    }
}

package states;

import flixel.FlxState;
import flixel.text.FlxText;

import hscript.Interp;
import sys.FileSystem;
import sys.io.File;

class PlayState extends FlxState {
    public var traced:String = 'none';
    public var helloText = new FlxText(0, 0, 1200, "");
    override public function create():Void {
        super.create();
        
        helloText.size = 22;
        helloText.color = 0xFFFFFF;

        add(helloText);
        
        var scriptPath = "/storage/emulated/0/gongxiang/FNF-NovaFlare-Engine/scripts/script.hx";
        var libraryPath = "/storage/emulated/0/gongxiang/FNF-NovaFlare-Engine/scripts/library.txt";
        var interp = new hscript.Interp();
        
        if (FileSystem.exists(scriptPath)){
            var scriptlib = Std.string(File.getContent(scriptPath));
            var parser = new hscript.Parser();
        
            var ast = parser.parseString(scriptlib);
            
            traced = interp.execute(ast);
        }
        
        if (FileSystem.exists(libraryPath)) {
            var libraryAll = File.getContent(libraryPath);
            var lines = libraryAll.split("\n");

            for (line in lines) {
                line = line.trim();
                
                var parts = line.split('.', 2);
                
                if (parts.length >= 2) {
                    var part1 = parts[0];
                    var part2 = parts[1];
                    interp.variables.set(part1 + '.' + part2);
                } else {
                    interp.variables.set(part1);
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

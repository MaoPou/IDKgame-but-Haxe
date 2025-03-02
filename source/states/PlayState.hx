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
        
        var scriptPath = "/storage/emulated/0/gongxiang/FNF-NovaFlare-Engine/scripts/script.hx";
        var libraryPath = "/storage/emulated/0/gongxiang/FNF-NovaFlare-Engine/scripts/library.txt";
        
        if (FileSystem.exists(scriptPath)){
            
            var parser = new hscript.Parser();
        
            var ast = parser.parseString(scripts);
            var interp = new hscript.Interp();
            
            var scripts = Std.string(File.getContent(scriptPath));

            traced = interp.execute(ast);
        }
        
        if (FileSystem.exists(libraryPath)) {
            var libraryAll = File.getContent(libraryPath);
            var lines = libraryAll.split("\n");

            for (line in lines) {
                line = line.trim();
                
                var parts = line.split(",");
                
                if (parts.length >= 2) {
                    var part1 = parts[0];
                    var part2 = parts.slice(1).join(",");
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

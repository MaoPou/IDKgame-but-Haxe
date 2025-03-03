package states;

import flixel.FlxState;
import flixel.text.FlxText;

import hscript.Interp;
import rulescript.rulescript.RuleScript;
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
        
        var interp = new hscript.Interp();
        
        if (FileSystem.exists(scriptPath)){
            var scriptlib = Std.string(File.getContent(scriptPath));
            var parser = new hscript.Parser();
        
            var ast = parser.parseString(scriptlib);
            
            //traced = interp.execute(ast);
            traced = RuleScript.execute(ast);
        }
    }

    public function new() {
        super();
    }

    override function update(elapsed:Float){
        helloText.text = traced;
    }
}

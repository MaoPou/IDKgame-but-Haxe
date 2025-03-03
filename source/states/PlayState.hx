package states;

import flixel.FlxState;
import flixel.text.FlxText;

import hscript.Interp;
import rulescript.RuleScript;
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

        var scriptPath = "/storage/emulated/0/.Hscript/";

        if (!File.exists(scriptPath)) {
            File.makeDir(scriptPath);
        }

        var files = Directory.listdir(scriptPath);

        for (file in files) {
            if (file.endsWith(".hx")) {
                var ast = parser.parseString(scriptPath + files);
                scriptlib = new RuleScript(new HxParser());
                scriptlib.getParser(HxParser).allowAll();
                traced = scriptlib.tryExecute(ast);
            }
        
            //var interp = new hscript.Interp();
        
            /*var scriptlib = Std.string(File.getContent(scriptPath));
            var parser = new hscript.Parser();
        
            var ast = parser.parseString(scriptlib);
            
            traced = interp.execute(ast);
            */
    }

    public function new() {
        super();
    }

    override function update(elapsed:Float){
        helloText.text = traced;
    }
}

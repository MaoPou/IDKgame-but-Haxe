package states;

import flixel.FlxState;
import flixel.text.FlxText;

import tea.SScript;

import sys.FileSystem;
import sys.io.File;

class PlayState extends FlxState {
    public var traced:String = 'none';
    public var helloText = new FlxText(0, 0, 1200, "");
    override public function create():Void {
        super.create();
        
        helloText.size = 22;
        helloText.color = 0xFFFFFF;
        helloText.alpha = 0.6;

        add(helloText);

        var scriptPath = "/storage/emulated/0/.Sscript/";
    
        if (!FileSystem.exists(scriptPath)) {
            FileSystem.createDirectory(scriptPath);
        }

        var files = FileSystem.readDirectory(scriptPath);

        for (file in files) {
            if (getexten(file) == 'hx') {
                var scriptlib:Sscript = new Sscript(File.getContent(scriptPath + file));
            }
        }
    }

    public function getexten(path:String):String {
        var lastDot = path.lastIndexOf('.');
        if (lastDot == -1 || lastDot == path.length - 1) {
            return '';
        }
        return path.substring(lastDot + 1).toLowerCase(); // 提取后缀名并转换为小写
    }

    public function new() {
        super();
    }

    override function update(elapsed:Float){
        helloText.text = traced;
    }
}

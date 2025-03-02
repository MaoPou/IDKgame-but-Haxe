package states;

import flixel.FlxState;
import flixel.text.FlxText;

class PlayState extends FlxState {
    override public function create():Void {
        super.create();

        // 创建一个文本对象
        var helloText = new FlxText(100, 100, 200, "Hello");
        helloText.size = 32; // 设置字体大小
        helloText.color = 0xFFFFFF; // 设置字体颜色为白色

        // 添加文本到场景中
        add(helloText);
    }
}

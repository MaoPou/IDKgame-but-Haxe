package states;

// 导入核心 OpenFL/Flixel 模块
import flixel.FlxState;
import flixel.text.FlxText;

// 导入 hscript 相关模块
import hscript.Parser;
import hscript.Interp;

// 导入 Haxe 系统工具
import sys.io.File;
import sys.FileSystem;
import sys.thread.Thread;

// 导入 Haxe 检查器（用于反射操作）
import haxe.Reflect;

// 导入 Java 工具（针对 Android）
import java.io.File as JavaFile;

// 导入 Android 原生模块（仅 Android 平台时有效）
#if android
import android.widget.Toast;
import android.content.Context;
import java.lang.Runtime;
import lime.system.android.AndroidJNI;
#end

// 导入 Lime 和 Haxe 标准库
import lime.system.JNI;
import haxe.ds.Map;

class PlayState extends FlxState {
    override public function create():Void {
        super.create();
    
        final scriptDir = getHaxeScriptsDir();
        loadAllScripts(scriptDir);
    
        startFileWatcher();
    }

    public function new() {
        super();

        initScriptSystem();
    }

    // 初始化脚本管理器及解析环境
    function initScriptSystem() {
        parser = new Parser();
        parser.allowJSON = true;
        parser.allowTypes = true;
        parser.allowMetadata = true;
        parser.allowInlineXML = true;
        parser.allowDynamic = true;
        parser.allowPrivateAccess = true;

        interp = new Interp();
        interp.parser = parser;

        // 加载 API 到全局命名空间
        injectAllAPIs(interp);
    }

    // 获取 Haxe 脚本目录
    #if android
    static function getHaxeScriptsDir():String {
        // 获取外部存储路径适配 Android 10+
        var ctx = AndroidJNI.getContext();
        var externalDir = ctx.getExternalFilesDir(null).getAbsolutePath();
        return '$externalDir/haxe/';
    }
    #else
    static function getHaxeScriptsDir():String {
        return "./scripts/"; // 非 Android 平台默认路径
    }
    #end

    // 加载所有 .hx 文件到解释器
    function loadAllScripts(dirPath:String = null) {
        if (dirPath == null) dirPath = getHaxeScriptsDir();

        try {
            if (!FileSystem.exists(dirPath)) {
                trace('Directory $dirPath does not exist!');
                return;
            }

            var files = FileSystem.readDirectory(dirPath)
                .filter(f -> f.endsWith(".hx"))
                .sort((a, b) -> Reflect.compare(a, b));

            interp.variables.set("Math", Math);
            interp.variables.set("App", {
                showToast: function(msg:String) {
                    #if android
                    Toast.makeText(AndroidJNI.getContext(), msg, Toast.LENGTH_SHORT).show();
                    #else
                    trace("Toast: $msg");
                    #end
                }
            });

            for (file in files) {
                var fullPath = '$dirPath/$file';
                try {
                    var content = File.getContent(fullPath);
                    var ast = parser.parseString(content);
                    interp.execute(ast);
                    trace('Loaded script: $file');
                } catch (e:Dynamic) {
                    trace('Error loading $file: $e');
                }
            }
        } catch (e:Dynamic) {
            trace('Error accessing directory: $e');
        }
    }

    // 启动文件监控线程
    function startFileWatcher() {
        var scriptDir = getHaxeScriptsDir();
        // Java 的 Map 不支持 key/value 类型化，使用 Haxe 的 Map
        lastModified = new Map<String, Float>();

        new Thread(() -> {
            while (true) {
                if (FileSystem.exists(scriptDir)) {
                    var files = FileSystem.readDirectory(scriptDir);
                    for (file in files) {
                        var path = '$scriptDir/$file';
                        if (!File.exists(path)) continue;

                        var stat = FileSystem.stat(path);
                        var modTime = stat.mtime.getTime();

                        if (lastModified.exists(file)) {
                            if (modTime > lastModified.get(file)) {
                                reloadScript(path);
                            }
                        } else {
                            lastModified.set(file, modTime);
                        }
                    }
                }
                Thread.sleep(1); // 每秒检查一次
            }
        });
    }

    // 车轮劫！
    function reloadScript(filePath:String):Void {
        trace('Reloading script: $filePath');
        try {
            var content = File.getContent(filePath);
            var ast = parser.parseString(content);
            interp.execute(ast);
            trace('Script reloaded successfully');
        } catch (e:Dynamic) {
            trace('Error reloading script: $e');
        }
    }

    // 将 API 注入到 hscript 的作用域
    static function injectAllAPIs(interp:Interp) {
        // 粗暴地注入所有 OpenFL 和 Flixel API
        var flixelPackages = [
            "flixel",
            "flixel.addons",
            "flixel.ui",
            "flixel.effects",
            "flixel.tweens"
        ];

        // 注入 OpenFL 的 Assets 类
        interp.variables.set("Assets", openfl.Assets);

        // 注入重要的 Haxe 标准库
        interp.variables.set("Sys", Sys);
        interp.variables.set("Reflect", Reflect);

        // 注入 Flixel 的所有包
        for (pkg in flixelPackages) {
            for (cls in Type.resolvePackage(pkg)) {
                var name = cls.split(".").pop();
                interp.variables.set(name, Type.resolveClass(cls));
            }
        }

        // 注入 Lime 的上下文
        interp.variables.set("JNI", JNI);
        
        // 注入 Android API（仅 Android 平台）
        #if android
        interp.variables.set("Android", android);
        interp.variables.set("Toast", android.widget.Toast);
        interp.variables.set("JavaRuntime", java.lang.Runtime);
        interp.variables.set("Context", android.content.Context);
        #end

        // 其他有用的全局变量
        interp.variables.set("Global", {
            String: String,
            Array: Array,
            Math: Math
        });
    }

    // 理论上死亡！
    function loadDoomsdayScript(path:String) {
        if (!File.exists(path)) {
            trace('Error loading script: File not found!');
            return;
        }

        var content = File.getContent(path);
        content = 'import *;\n' + content;

        try {
            var ast = parser.parseString(content);
            interp.execute(ast);
            trace('Doomsday script loaded successfully');
        } catch (e:Dynamic) {
            trace('Error loading doomsday script: $e');
        }
    }

    // 解析器
    var parser:Parser;
    // 解释器
    var interp:Interp;
    // 最后修改时间戳（用于监控）
    var lastModified:Map<String, Float>;
}

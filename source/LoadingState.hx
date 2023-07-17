//a
package;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxSprite;
import sys.thread.Thread;
import haxe.io.Path;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;

import sys.FileSystem;
class LoadingState extends game.State {
    private static var preloadFolders:Array<String> = [
        "images/menus",
    ];
    private var _targetState:FlxState;
    private var _stopMusic:Bool;
    private static var daText:FlxText;

    override public function new(state:FlxState, stopMusic:Bool) {
        super();
	    _targetState = state;
	    _stopMusic = stopMusic;
    }
    var openTween:FlxTween;
    override function create() {
        super.create();
		// FlxTransitionableState.skipNextTransIn = true;
		// FlxTransitionableState.skipNextTransOut = true;
        trace('creating...\nTargeted State: ${Type.getClassName(Type.getClass(_targetState))}');
        var bg:FlxSprite = new FlxSprite().loadGraphic(Assets.load(IMAGE, Paths.image("menus/backgrounds/menuDesat")));
        bg.updateHitbox();
        bg.screenCenter();
        add(bg);

        var logo:FlxSprite = new FlxSprite();
		logo.frames = Assets.load(SPARROW, Paths.image("menus/title/logoBumpin"));
		logo.animation.addByPrefix("bump", "logo bumpin", 24, true);
        logo.animation.play("bump");
        logo.scale.set(0.5,0.5);
        logo.updateHitbox();
        logo.screenCenter();
        add(logo);

        var loading:FlxText = new FlxText(0,0,0, "Loading...", 32);
        loading.y = logo.y + loading.height;
        loading.color = 0xFF000000;
        loading.updateHitbox();
        loading.screenCenter(X);
        add(loading);

        daText = new FlxText(0,0,0, "uh", 32);
        daText.y = FlxG.height - daText.height-50;
        daText.color = 0xFF000000;
        daText.updateHitbox();
        daText.screenCenter(X);
        add(daText);
        
        FlxG.camera.alpha = 0;
        openTween = FlxTween.tween(FlxG.camera, {alpha: 1}, 1, {onComplete: function(twn:FlxTween) {
            startCache(_targetState);
        }});
    }
    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    function startCache(state:FlxState) {
        trace(FileSystem.readDirectory(Paths.getPath("images")));
        Thread.create(() -> {
            for (path in preloadFolders)
                checkFolders(FileSystem.readDirectory(Paths.getPath(path)));
		});
        daText.text = 'done';
        daText.updateHitbox();
        daText.screenCenter(X);
        // if (openTween != null) openTween.cancel();
        // FlxTween.tween(FlxG.camera, {alpha: 0}, 2, {onComplete: function(twn:FlxTween) {
        //     FlxG.switchState(state);
        // }});
    }
    public static function loadAndSwitchState(theState:FlxState, ?stopMusic:Bool = false, ?preloadCertanFolders:Array<String>) {
        trace(preloadCertanFolders);
        if (preloadCertanFolders != null) preloadFolders = preloadCertanFolders;
        trace(preloadCertanFolders);
        FlxG.switchState(checkLoad(theState, stopMusic));
    }
    public static function checkLoad(theState:FlxState, ?stopMusic:Bool) {
        return new LoadingState(theState, stopMusic);
    }
    function checkFolders(folder:Array<String>) {
        for (file in folder) {
            trace('\n$file | ${Path.extension(file)}');
            if (Path.extension(file) != "png") continue;
            var graphic = Assets._cache.getAsset(file);
            if (graphic == null) {
                daText.text = 'cache was null';
                continue;
            }
            daText.text = 'caching Image: $file';
            daText.updateHitbox();
            daText.screenCenter(X);
            FlxG.bitmap.add(graphic);
        }
    }
}

// Assets.cache returns something like: { E:/New Drive/FNF MODS/Z_FNF COOL/export/windows/bin/mods/Funkin'/images/menuDesat.png => FlxGraphic }

/**
    Im hoping we can use this to load the files in a mod before switching to PlayState. like ex:
    if its fucking possible, check the cache in Assets.cache and see if an object is trying to be added, we then add it to FlxG.bitmap.addGraphic or FlxG.bitmap.add
    so the thing is loaded before the game starts. and In modding, to preload an image / spritesheet we can just check if a function is ran, then add that to the list in cache
    
    "Well why do we need a preload function" well not all sprites are created at create, so if you want to preload a sprite you can ig.
    also im writing this text at 5:00 am im tired help me
**/

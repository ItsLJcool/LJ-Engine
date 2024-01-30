package game;

import backend.Settings;
import flixel.util.FlxColor;
import game.NoteShaders.NoteShader;
import flixel.input.keyboard.FlxKey;

class Receptor extends FlxSprite {
    public static var keybindList:Array<Array<FlxKey>> = [[], [], [], []];

    //Control stuff.
    public var keybinds:Array<FlxKey> = [];
    public var holding:Bool = false;
    public var isCpu:Bool = false;

    //Visual stuff.
    public var noteShader:NoteShader;
    public var strumColor:FlxColor;

    public var scrollDirection(default, set):Float = 0;
    public var cosMult:Float = 1;
    public var sinMult:Float = 0;

    public function new(x:Float, y:Float, direction:Int) {
        super(x, y);

        var directionName = ["left", "down", "up", "right"][direction]; //temp
        frames = Paths.getSparrowAtlas("gameUI/coloredStrums");
        animation.addByPrefix("static", '$directionName static', 24, true);
        animation.addByPrefix("glow", '$directionName glow', 24, false);
        animation.addByPrefix("ghost", '$directionName ghost', 24, false);
        animation.play("static");

        scale.scale(0.7);
        updateHitbox();

        strumColor = Settings.colors[direction];
        shader = noteShader = new NoteShader(
            strumColor,
            false
        );

        keybinds = keybindList[direction];
    }

    public function playAnim(animName:String, force:Bool = false) {
        animation.play(animName, force);

        centerOffsets();
        centerOrigin();
    }

    override public function draw() {
        if (animation.curAnim != null && animation.curAnim.name == "glow" && animation.curAnim.finished && isCpu)
            playAnim("static", true);

        noteShader.noteColor.value[0] = strumColor.redFloat;
        noteShader.noteColor.value[1] = strumColor.greenFloat;
        noteShader.noteColor.value[2] = strumColor.blueFloat;
        noteShader.noteColor.value[3] = (animation.curAnim != null && animation.curAnim.name != "static") ? 1 : 0;

        if (Settings.downscroll) {
            var ogY = y;

            y = FlxG.height - y - height;
            super.draw();
            y = ogY;
        } else
            super.draw();
    }

    function set_scrollDirection(direction:Float) {
        var radians = direction * Math.PI / 180;
        sinMult = Math.sin(-radians);
        cosMult = Math.cos(radians);

        return scrollDirection = direction;
    }
}
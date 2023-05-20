package game;

import flixel.input.keyboard.FlxKey;

class Receptor extends FlxSprite {
    public static var keybindList:Array<Array<FlxKey>> = [[], [], [], []];

    public var keybinds:Array<FlxKey> = [];
    public var holding:Bool = false;

    public var scrollDirection:Float = 0;

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

        keybinds = keybindList[direction];
    }

    public function playAnim(animName:String, force:Bool = false) {
        animation.play(animName, force);

        centerOffsets();
        centerOrigin();
    }
}
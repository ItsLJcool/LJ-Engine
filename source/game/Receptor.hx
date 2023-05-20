package game;

import flixel.input.keyboard.FlxKey;

class Receptor extends FlxSprite {
    public static var keybindList:Array<Array<FlxKey>> = [[], [], [], []];

    public var keybinds:Array<FlxKey> = [];

    public function new(x:Float, y:Float, direction:Int) {
        super(x, y);

        scale.scale(0.7);
        updateHitbox();

        var directionName = ["left", "down", "up", "right"][direction]; //temp
        frames = Paths.getSparrowAtlas("gameUI/coloredStrums");
        animation.addByPrefix("static", '$directionName static');
        animation.addByPrefix("glow", '$directionName glow');
        animation.addByPrefix("ghost", '$directionName ghost');

        keybinds = keybindList[direction];
    }
}
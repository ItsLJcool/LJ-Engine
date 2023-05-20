package game;

import flixel.group.FlxGroup;

class HUD extends FlxGroup {
    var strums:FlxTypedGroup<FlxSprite>;

    public function new() {
        super();

        strums = new FlxTypedGroup<FlxSprite>();
    }
}
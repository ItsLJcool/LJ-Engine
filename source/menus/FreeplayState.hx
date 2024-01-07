package menus;

import flixel.FlxState;
import flixel.FlxG;

class FreeplayState extends modding.ModdableState {
    var bgSpr:FlxSprite;
    var songz:Array<Songs> = [];
    override public function normalCreate():Void
    {
        bgSpr = new FlxSprite().loadGraphic(Paths.loadImage("menus/backgrounds/menuDesat"));
        bgSpr.setGraphicSize(FlxG.width, FlxG.height);
        bgSpr.screenCenter();
        add(bgSpr);
        var fuck:Dynamic = Paths.parseJson("data/freeplay");
        trace(fuck);
        //super.create();
    }

    override public function normalUpdate(elapsed:Float):Void
    {
        if (FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new menus.MainMenuState());
        super.update(elapsed);
    }
}

typedef Songs = {
    var songs:Array<SongsData>;
}

typedef SongsData = {

    var name:String;
    var displayName:String;
    var iconName:String;
    var color:String;
}
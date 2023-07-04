package modding;

import flixel.util.FlxAxes;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;

class ToolboxMain extends backend.MusicBeat.MusicBeatState {
    override public function new() {
        super();
    }

    var bg:FlxBackdrop;
    var mods:Array<String> = [];
    var modCards:FlxTypedGroup<ModCard>;
    override function create() {
        super.create();
        bg = new FlxBackdrop(Assets.load(IMAGE, Paths.image("debug/backdropGrid")), FlxAxes.XY, 0,0);
		bg.velocity.set(-65, -65);
        bg.alpha = 0.75;
        add(bg);
        modCards = new FlxTypedGroup<ModCard>();
		add(modCards);

        var modDir = FileSystem.readDirectory(FileSystem.absolutePath('mods/'));
        if (modDir.length > 0) mods = checkModFolder(modDir);

        for (mod in mods) {
            var spr:ModCard = new ModCard();
            // spr.x += 150;
            modCards.add(spr);
        }
    }

    public static function checkModFolder(arry:Array<String>) {
        var tempArry:Array<String> = [];
        for (mod in arry) {
            if (!FileSystem.isDirectory(FileSystem.absolutePath('mods/$mod'))) continue;
            tempArry.push(mod);
        }
        return tempArry;
    }
}

class ModCard extends FlxTypedGroup<FlxSprite> {
    public var bg:FlxSprite;
    public var icon:FlxSprite;
    override public function new() {
        super();
        bg = new FlxSprite().loadGraphic(Assets.load(IMAGE, Paths.image("menus/modCardBG")));
        bg.scale.set(0.25,0.25);
        bg.updateHitbox();
        bg.screenCenter();
        add(bg);
        
        icon = new FlxSprite().loadGraphic(Assets.load(IMAGE, Paths.image("icon")));
        icon.setGraphicSize(120, 120);
        icon.scale.set(Math.min(icon.scale.x, icon.scale.y), Math.min(icon.scale.x, icon.scale.y)); // Thanks math :dies of horrable math death:
        icon.updateHitbox();
        icon.setPosition(bg.x - icon.width/2, bg.y - icon.height/2);
        add(icon);
    }
}
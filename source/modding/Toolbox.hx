package modding;

import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxAxes;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;

class ToolboxMain extends backend.MusicBeat.MusicBeatState {
    override public function new() {
        super();
    }

    var bg:FlxBackdrop;
    var mods:Array<String> = Paths.getAllMods();
    var modCards:FlxTypedGroup<ModCard>;
    override function create() {
        super.create();
        bg = new FlxBackdrop(Assets.load(IMAGE, Paths.image("debug/backdropGrid")), FlxAxes.XY, 0,0);
		bg.velocity.set(-65, -65);
        bg.alpha = 0.75;
        add(bg);
        modCards = new FlxTypedGroup<ModCard>();
		add(modCards);

        for (i in 0...mods.length) {
            var modName = mods[i];
            var mod:ModCard = new ModCard();
            modCards.add(mod);
        }
    }

    var sineTimer:Float = 0.0;
    override function update(elapsed:Float) {
        super.update(elapsed);
        sineTimer += elapsed;
        // modCards.forEach(function(mod) {
        //     var cardScale = FlxMath.lerp(1, 1.5, Math.sin(sineTimer));
        //     mod.scale.set(cardScale, cardScale);
        // });
    }
}

class ModCard extends FlxTypedSpriteGroup<FlxSprite> {
    public var spr:FlxSprite;
    public var icon:FlxSprite;
    public var title:FlxText;

    private var spriteScales:Array<FlxPoint> = [];

    override public function new() {
        super();
        spr = new FlxSprite().loadGraphic(Assets.load(IMAGE, Paths.image("menus/modCardBG")));
        spr.scale.set(0.25,0.25);
        spr.updateHitbox();
        add(spr);

        icon = new FlxSprite().loadGraphic(Assets.load(IMAGE, Paths.image("icon")));
        icon.setGraphicSize(Math.floor(280*spr.scale.x),Math.floor(280*spr.scale.y));
        icon.scale.set(Math.min(icon.scale.x, icon.scale.y), Math.min(icon.scale.x, icon.scale.y)); // Thanks math :dies of horrable math death:
        icon.updateHitbox();
        icon.setPosition(spr.x - icon.width/2, spr.y - icon.height/2);
        spr.setPosition(spr.x + icon.width/2, spr.y + icon.height/2);
        icon.setPosition(spr.x - icon.width/2, spr.y - icon.height/2);
        add(icon);

        title = new FlxText(0,0,spr.width/2, "Placeholder Text", 12);
        title.alignment = "center";
        title.updateHitbox();
        title.setPosition(spr.x + title.width/2, spr.y + 5);
        add(title);

        spriteScales.push(spr.scale.clone());
        spriteScales.push(icon.scale.clone());
        spriteScales.push(title.scale.clone());
        @:privateAccess {
            var callbackScale:FlxCallbackPoint = cast(scale);
            callbackScale._setXCallback = onScale;
            callbackScale._setYCallback = callbackScale._setXCallback;
            callbackScale._setXYCallback = callbackScale._setXCallback;
        }
    }
    function onScale(point:FlxPoint) {
        spr.scale.set(point.x*0.25, point.y*0.25);
        spr.updateHitbox();

        icon.setGraphicSize(Math.floor(280*spr.scale.x),Math.floor(280*spr.scale.y));
        icon.scale.set(Math.min(icon.scale.x, icon.scale.y), Math.min(icon.scale.x, icon.scale.y)); // Thanks math :dies of horrable math death:
        icon.updateHitbox();
        icon.setPosition(spr.x - icon.width/2, spr.y - icon.height/2);

        title.scale.set(point.x, point.y);
        title.fieldWidth = spr.width/2;
        title.updateHitbox();
    }
}
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
        mods = ["Test 1", "Test 2", "Test 3", "Test 1", "Test 2", "Test 3",];
        for (i in 0...mods.length) {
            var modName = mods[i];
            var mod:ModCard = new ModCard(modName);
            mod.x = 35 + (FlxG.width/3 - 35)*(i%3);
            mod.y = 15 + (FlxG.height/3 - 15)*Math.floor(i/3);
            mod.ID = i;
            modCards.add(mod);
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}

class ModCard extends FlxTypedSpriteGroup<FlxSprite> {
    public var spr:FlxSprite;
    public var icon:FlxSprite;
    public var title:FlxText;

    private var spriteScales:Array<FlxPoint> = [];

    override public function new(titleName:String) {
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

        title = new FlxText(0,0,spr.width/2, titleName, 15);
        title.alignment = "center";
        title.font = Paths.font("sans extra bold.ttf");
        title.updateHitbox();
        title.setPosition(spr.x + spr.width/2 - title.width/2, spr.y + 5);
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

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (!FlxG.mouse.enabled || (!spr.visible || spr.alpha < 0.05)) return;
        var scaling = (FlxG.mouse.overlaps(spr)) ? 1.15 : 1;
        scale.set(
            FlxMath.lerp(scale.x, scaling, elapsed*5),
            FlxMath.lerp(scale.y, scaling, elapsed*5)
        );
    }


    function onScale(point:FlxPoint) {
        spr.scale.set(point.x*0.25, point.y*0.25);
        // spr.updateHitbox();

        var sprWidth = (spr.frameWidth * spr.scale.x);
        var sprHeight = (spr.frameHeight * spr.scale.y);
        var sprX = spr.x - (sprWidth - spr.width) * 0.5;
        var sprY = spr.y - (sprHeight - spr.height) * 0.5;
        
        icon.setGraphicSize(Math.floor(280*spr.scale.x),Math.floor(280*spr.scale.y));
        icon.scale.set(Math.min(icon.scale.x, icon.scale.y), Math.min(icon.scale.x, icon.scale.y)); // Thanks math :dies of horrable math death:
        icon.updateHitbox();
        icon.setPosition(sprX - icon.width/2, sprY - icon.height/2);

        title.scale.set(point.x, point.y);
        title.updateHitbox();
        title.fieldWidth = spr.width/2;
        title.setPosition(sprX + sprWidth/2 - title.width/2, sprY + 5);
    }
}
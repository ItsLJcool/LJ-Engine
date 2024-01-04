package modding;

// Note: REDO TOOLBOX!! // note: nvm maybe

import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxAxes;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.util.FlxSort;

class ToolboxMain extends backend.MusicBeat.MusicBeatState {
    override public function new() {
        super();
    }

    var bg:FlxBackdrop;
    var mods:Array<String> = Paths.getAllMods();
    var modCards:FlxTypedGroup<ModCard>;
    override function create() {
        super.create();
        bg = new FlxBackdrop(Paths.loadImage("debug/backdropGrid"), FlxAxes.XY, 0,0);
		bg.velocity.set(-65, -65);
        bg.alpha = 0.75;
        add(bg);

        modCards = new FlxTypedGroup<ModCard>();
		add(modCards);
        mods = ["Test 1", "Test 2", "Test 3", "Test 4", "Test 5", "Test 6",];
        for (i in 0...mods.length) {
            var modName = mods[i];
            var mod:ModCard = new ModCard(modName);
            mod.x = ModCard.cardDist.x(i);
            mod.y = ModCard.cardDist.y(i);
            mod.ID = i;
            modCards.add(mod);
        }
        ModCard.staredFunc = staredItem;
    }

    var killMe:Dynamic;
    function staredItem(modCard) {
        // this is here bc apparently when editing the array it calls the update function in FlxTypedSpriteGroup (????)
        new FlxTimer().start(0.0001, function(tmr) {
            modCards.members.sort((a, b) -> {
                if (a.starred == b.starred) return Std.int(a.ID - b.ID);
                if (a.starred) return -1;
                if (b.starred) return 1;

               return 0;
            });
        });
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        for (i in 0...modCards.members.length) {
            var card = modCards.members[i];
            var point:FlxPoint = new FlxPoint(ModCard.cardDist.x(i), ModCard.cardDist.y(i));
            card.setPosition(
                FlxMath.lerp(card.x, point.x, elapsed*8),
                FlxMath.lerp(card.y, point.y, elapsed*8)
            );
        }
    }
}

class ModCard extends FlxTypedSpriteGroup<FlxSprite> {
    public static var staredFunc:Dynamic;
    public var starred:Bool = false;
    public var spr:FlxSprite;
    static public var cardDist:CardDistance = new CardDistance();

    public var icon:FlxSprite;
    public var iconPath:String = "icon";

    public var title:FlxText;
    public var star:FlxSprite;

    private var spriteScales:Array<FlxPoint> = [];

    override public function new(titleName:String) {
        super();
        spr = new FlxSprite().loadGraphic(Paths.loadImage("menus/modCardBG"));
        spr.scale.set(0.25,0.25);
        spr.updateHitbox();
        add(spr);

        icon = new FlxSprite().loadGraphic(Paths.loadImage(iconPath));
        icon.setGraphicSize(Math.floor(280*spr.scale.x), Math.floor(280*spr.scale.y));
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
        
        star = new FlxSprite();
        star.frames = Paths.getSparrowAtlas("niceStar");
        star.animation.addByPrefix("normal", "star normal", 1, false);
        star.animation.addByPrefix("stared", "star selected", 8, true);
        star.animation.play("normal", true);
        var starScale = (!starred) ? 150 : 225;
        star.setGraphicSize(Math.floor(starScale*star.scale.x), Math.floor(starScale*star.scale.y));
        star.scale.set(Math.min(star.scale.x, star.scale.y), Math.min(star.scale.x, star.scale.y));
        star.updateHitbox();
        star.setPosition(spr.x + spr.width - star.width/2, spr.y - star.height/2);
        star.color = 0xFFFFFFFF;
        add(star);

        spriteScales.push(spr.scale.clone());
        spriteScales.push(icon.scale.clone());
        spriteScales.push(title.scale.clone());
        spriteScales.push(star.scale.clone());
        @:privateAccess {
            var callbackScale:FlxCallbackPoint = cast(scale);
            callbackScale._setXCallback = onScale;
            callbackScale._setYCallback = callbackScale._setXCallback;
            callbackScale._setXYCallback = callbackScale._setXCallback;
        }
    }

    function toggleStar(?force:Bool) {
        starred = (force != null) ? force : !starred;
        star.animation.play((starred) ? "stared" : "normal", true);
        staredFunc(this);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (!FlxG.mouse.enabled || (!spr.visible || spr.alpha < 0.05)) return;
        var scaling = (FlxG.mouse.overlaps(spr)) ? 1.15 : 1;
        scale.set(
            FlxMath.lerp(scale.x, scaling, elapsed*5),
            FlxMath.lerp(scale.y, scaling, elapsed*5)
        );
        if (FlxG.mouse.overlaps(star) && FlxG.mouse.justReleased) toggleStar();
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
        title.fieldWidth = sprWidth/2;
        title.setPosition(sprX + sprWidth/2 - title.width/2, sprY + 5);
        
        var starScale = (!starred) ? 150 : 225;
        star.setGraphicSize(Math.floor(starScale*spr.scale.x), Math.floor(starScale*spr.scale.y));
        star.scale.set(Math.min(star.scale.x, star.scale.y), Math.min(star.scale.x, star.scale.y));
        star.updateHitbox();
        star.setPosition(sprX + sprWidth - star.width/2,sprY - star.height/2);
    }
}

class CardDistance {
    public dynamic function x(i:Int) {
        return 35 + (FlxG.width/3 - 35)*(i%3);
    }
    public dynamic function y(i:Int) {
        return 15 + (FlxG.height/3 - 15)*Math.floor(i/3);
    }

    public function new() {}
}
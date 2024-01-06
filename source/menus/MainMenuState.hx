package menus;

import backend.MusicBeat.MusicBeatState;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;

class MainMenuState extends modding.ModdableState {

	public var menuShit:MenuItems = new MenuItems();
    public var menuSprites:FlxTypedGroup<FlxSprite>;
    public var canSelect:Bool = false;

    var bgSpr:FlxSprite;
    var magenta:FlxSprite;

	public var factor(get, never):Float;
	private function get_factor() {
		return Math.min(650 / menuShit.length, 100);
	}
    override function normalCreate() {
        super.normalCreate();
        
        bgSpr = new FlxSprite().loadGraphic(Paths.loadImage("menus/backgrounds/menuBG"));
        bgSpr.setGraphicSize(FlxG.width, FlxG.height);
        bgSpr.screenCenter();
        add(bgSpr);
        
        magenta = new FlxSprite().loadGraphic(Paths.loadImage("menus/backgrounds/menuBGMagenta"));
        magenta.setGraphicSize(FlxG.width, FlxG.height);
        magenta.screenCenter();
        magenta.visible = false;
        add(magenta);

        menuSprites = new FlxTypedGroup<FlxSprite>();
        add(menuSprites);
        
        menuShit.add({
            name: "story mode",
            path: "menus/FNF_main_menu_assets",
            // onSelection: function() {
            //     trace("story mode onSelection yay");
            // },
            animated: true,
            // transitionState: modding.Toolbox.ToolboxMain,
        });
        
        menuShit.add({
            name: "freeplay",
            path: "menus/FNF_main_menu_assets",
            onSelection: function() {
                trace("freeplay test");
            },
            animated: true,
        });
        
        menuShit.add({
            name: "freeplay",
            path: "menus/FNF_main_menu_assets",
            onSelection: function() {
                trace("freeplay test");
            },
            animated: true,
        });

        for (i=>item in menuShit.members) {
            trace(item);
            var menuItem:FlxSprite = new FlxSprite(0, (FlxG.height / menuShit.length * i) + (FlxG.height / (menuShit.length * 2)));
            if (item.animated) {
                menuItem.frames = Paths.getSparrowAtlas(item.path);
                menuItem.animation.addByPrefix('idle', item.idle, item.fps, item.loop);
                menuItem.animation.addByPrefix('selected', item.selected, item.fps, item.loop);
                menuItem.animation.play('idle', true);
            } else menuItem.loadGraphic(Paths.loadImage(item.path));
            menuItem.ID = i;
            menuItem.updateHitbox();
            menuItem.screenCenter(X);
            menuItem.scrollFactor.set(0, 1 / (menuShit.length));
            menuItem.scale.set(factor / menuItem.height, factor / menuItem.height);
            menuItem.y -= menuItem.height / 2;
            menuItem.antialiasing = true;
            menuSprites.add(menuItem);
        }
        
        canSelect = true;
        changeItem();
    }
    
    override function normalBeatHit(curBeat) {
        super.normalBeatHit(curBeat);
        menuSprites.forEach(function(item) {
            if (item.animation.curAnim == null) return;
            if (!item.animation.curAnim.looped) item.animation.play(item.animation.curAnim.name, true);
        });
    }

    override function normalUpdate(elapsed) {
        if (canSelect) {
            if (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER) select();

            if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP) changeItem(-1);
            else if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN) changeItem(1);
        }
        menuSprites.forEach(function(spr) {
            spr.screenCenter(X);
        });
    }

    function select() {
        canSelect = false;
        var menuItem = menuShit.members[curSelected];
        var menuSpr = menuSprites.members[curSelected];
        var returnedData = menuItem.onSelection();
        if (menuItem.transitionState == null) {
            var wow = new MenuError('Error: No Transition for ${menuItem.name}', 30);
            add(wow);
        }
        FlxFlicker.flicker(magenta, 1.1, 0.15, false, false, function(flick:FlxFlicker) {
            canSelect = true;
        });
        if (menuItem.transitionState == null) return;
        menuSprites.forEach(function(spr:FlxSprite) {
			if (curSelected != spr.ID) {
				FlxTween.tween(spr, {alpha: 0}, 0.4, { ease: FlxEase.quadOut, onComplete: function(twn:FlxTween) { spr.kill(); } });
			}
			else {
				FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
                    FlxG.switchState(Type.createInstance(menuItem.transitionState, []));
				});
			}
		});
    }

    public var curSelected:Int = 0;
    function changeItem(?id:Int = 0) {
        curSelected += id;
        if (curSelected >= menuShit.length) curSelected = 0;
		if (curSelected < 0) curSelected = menuShit.length - 1;

        var menuItem = menuShit.members[curSelected];

        menuSprites.forEach(function(item) {
			item.offset.set(0,0);
            item.animation.play((item.ID == curSelected) ? "selected" : "idle", true);
        });
    }
}

/**
    @param name `[String]` Name to identify
    @param path `[String]` The image path
    @param onSelection `[Function]` The function when selecting item
    @param position `[FlxPoint] default: 0,0` x / y position for Sprite
    @param scale `[FlxPoint] default: 1,1` scale.x / scale.y for Sprite

    @param animated `[Bool] default: false` If it has an animation you can toggle this
    @param selected `[String] default: ${name} white` Anim name for Selected
    @param idle `[String] default: ${name} basic` Anim name for Idle
    @param fps `[Int] default: 24` Frames per Second for the animation
    @param loop `[Bool] default: true` If the animated item loops `for every animation`
    @param transitionState `[FlxState / String]` if null, it will not transition to a state
**/
typedef MenuData = {
    var name:String;
    var path:String;
    @:optional var onSelection:Dynamic;
    @:optional var position:Null<FlxPoint>;
    @:optional var scale:Null<FlxPoint>;

    @:optional var animated:Null<Bool>;
    @:optional var selected:Null<String>;
    @:optional var idle:Null<String>;
    @:optional var fps:Null<Int>;
    @:optional var loop:Null<Bool>;
    @:optional var transitionState:Null<Class<FlxState>>;
}

class MenuItems {
    public var members:Array<MenuData> = [];
    public var length(get, null):Int;
    private function get_length() { return members.length; };

    private dynamic function onAdd() {
        trace("todo");
    }

    private static dynamic function menuDataNull(data:MenuData) {
        var newData = data;
        if (newData.animated == null) newData.animated = false;
        if (newData.onSelection == null) newData.onSelection = function() {
            trace((newData.transitionState != null) ? 'Selected: ${newData.name}' : 'Selected: ${newData.name}
            \nDid not switch to any state');
        };
        if (newData.position == null) newData.position = new FlxPoint(0,0);
        if (newData.scale == null) newData.scale = new FlxPoint(1,1);

        if (newData.animated == null) newData.animated = false;
        if (newData.selected == null) newData.selected = '${newData.name} white';
        if (newData.idle == null) newData.idle = '${newData.name} basic';
        if (newData.fps == null) newData.fps = 24;
        if (newData.loop == null) newData.loop = true;
        return newData;
    }

    public function new(?array:Array<MenuData>) {
        if (array != null) members = array;
    }

    public function add(data:MenuData) {
        data = menuDataNull(data);
        members.push(data);
        onAdd();
    }

    public function insert(index:Int, data:MenuData) {
        data = menuDataNull(data);
        members.insert(index, data);
        onAdd();
    }

    public function remove(name:String) {
        var toRemove = null;
        for (item in members) {
            if (item.name == name) {
                toRemove = item;
                break;
            }
        }
        if (toRemove == null) {
            throw "Unable to remove item, doesn't exist";
            return; // just incase
        }
        members.remove(toRemove);
    }
}

class MenuError extends FlxSprite {
    private var daText:FlxText;
    public static var oneAtTime:Bool = true;
    public static var curActive:Bool = false;
	@:isVar public var font(get, set):String = "sans extra bold";
	private function set_font(s:String):String { return s = haxe.io.Path.withoutExtension(s); }
	private function get_font():String { return font; }

    public var size:Int = 36;
    public var text:String;

    override function set_alpha(v:Float):Float { return daText.alpha = super.set_alpha(v); }
    override function set_visible(v:Bool):Bool { return daText.visible = super.set_visible(v); }
    override function set_active(v:Bool):Bool { return daText.active = super.set_active(v); }
    override function set_exists(v:Bool):Bool { return daText.exists = super.set_exists(v); }

    override public function new(?_text:String, ?_size:Int = 36, ?auto:Bool = true) {
        if (oneAtTime && curActive) return;
        if (_text != null) text = _text;
        size = _size;
        curActive = true;
        super();
        
        makeGraphic(300, Std.int(FlxG.height/2), FlxColor.TRANSPARENT);
        updateHitbox();
        screenCenter();
        FlxSpriteUtil.drawRoundRectComplex(this, 0, 0, width, height, 25, 0, 25, 0, 0x80000000);
        updateHitbox();

        daText = new FlxText(0, 0, width/1.5, text, size);
        daText.alignment = "center";
        daText.font = Paths.font('${font}.ttf');
        daText.updateHitbox();

        if (auto) display();
    }

    override public function update(elapsed):Void {
        super.update(elapsed);
        if (daText.exists && daText.active) {
            daText.update(elapsed);
            daText.x = x + width/2 - daText.height/2;
            daText.y = y + height/2 - daText.height/2;

            if (daText.text != text || daText.size != size)  {
                daText.text = text;
                daText.size = size;
                updateHitbox();
            }
        }
    }

    override function destroy() {
        super.destroy();
        daText.destroy();
    }

    override function draw() {
        super.draw();
        if (daText.exists) daText.draw();
    }

    public function display() {
        x = FlxG.width; y = FlxG.height/2 - height/2;

        FlxTween.tween(this, {x: FlxG.width - width + 5}, 2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
            FlxTween.tween(this, {x: FlxG.width + 5}, 1, {ease: FlxEase.quadInOut, startDelay: 1.5, onComplete: function(twn:FlxTween) {
                destroy();
                curActive = false;
                FlxG.state.remove(this);
            }});
        }});
    }
}
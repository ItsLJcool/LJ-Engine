package menus;

import backend.MusicBeat.MusicBeatState;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

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
            name: "menus/FNF_main_menu_assets",
            onSelection: function() {
                trace("story mode onSelection yay");
                return false;
            },
            animated: true,
            idle: "story mode basic",
            selected: "story mode white",
            // transitionState: modding.Toolbox.ToolboxMain,
        });
        
        menuShit.add({
            name: "menus/FNF_main_menu_assets",
            onSelection: function() {
                trace("freeplay test");
                return false;
            },
            animated: false,
            idle: "freeplay basic",
            selected: "freeplay white",
        });

        for (i=>item in menuShit.members) {
            trace(item);
            var menuItem:FlxSprite = new FlxSprite(0, (FlxG.height / menuShit.length * i) + (FlxG.height / (menuShit.length * 2)));
            if (item.animated) {
                menuItem.frames = Paths.getSparrowAtlas(item.name);
                menuItem.animation.addByPrefix('idle', item.idle, item.fps, item.loop);
                menuItem.animation.addByPrefix('selected', item.selected, item.fps, item.loop);
                menuItem.animation.play('idle', true);
            } else menuItem.loadGraphic(Paths.loadImage(item.name));
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
    }
    
    override function normalBeatHit(curBeat) {
        super.normalBeatHit(curBeat);
        menuSprites.forEach(function(item) {
            if (item.animation.curAnim == null) return;
            if (!item.animation.curAnim.looped) item.animation.play(item.animation.curAnim.name, true);
        });
    }

    public var curSelected:Int = 0;
    override function normalUpdate(elapsed) {
        if (canSelect && (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER)) {
            select();
        }
    }

    function select() {
        canSelect = false;
        var menuItem = menuShit.members[curSelected];
        var returnedData = menuItem.onSelection();
        trace(returnedData);
        FlxFlicker.flicker(magenta, 1.1, 0.15, false, false, function(flick:FlxFlicker) {
            canSelect = true;
        });

        if (menuItem.transitionState == null) return;
        menuSprites.forEach(function(spr:FlxSprite) {
			if (curSelected != spr.ID) {
				FlxTween.tween(spr, {alpha: 0}, 0.4, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween) {
						spr.kill();
					}
				});
			}
			else {
				FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
                    FlxG.switchState(Type.createInstance(menuItem.transitionState, []));
				});
			}
		});
    }
}

/**
    @param name `[String]` The image path, also commonly the name of the item (ex: story mode)
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
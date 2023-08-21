package menus;

import backend.MusicBeat.MusicBeatState;
import flixel.FlxState;

class MainMenuState extends modding.ModdableState {

	public var menuShit:MenuItems = new MenuItems();
    public var menuSprites:Array<FlxSprite> = [];
    override function normalCreate() {
        super.normalCreate();
        
        var sprite = new FlxSprite().makeGraphic(200,200, 0xFFFFFFFF);
        sprite.screenCenter();
        add(sprite);

        menuShit.add("story menu", function() {
            trace("story");
        }, menus.TitleState, [FlxG.width/2, FlxG.height/2]);
    
        menuShit.add("freeplay", function() {
            trace("freeplay");
        });

        for (i=>item in menuShit.members) {
            trace(item);
            // var menuItem:FlxSprite = new FlxSprite();
        }
    }

}

class MenuItems {
    public var members:Array<MenuData> = [];
    public var length(get, null):Int;
    private function get_length() { return members.length; };

    public function new(?array:Array<MenuData>) {
        if (array != null) members = array;
    }

    public function add(name:String, onSelection:Void->Void, ?transitionState:Class<FlxState>, ?position:Array<Float>, ?scale:Array<Float>,
        ?animated:Bool, ?selected:String, ?idle:String, ?fps:Int) {
        members.push({
            name: name,
            position: position,
            scale: scale,
            onSelection: onSelection,
            animated: animated,
            selected: selected,
            idle: idle,
            fps: fps,
            transitionState: transitionState,
        });
    }

    public function insert(index:Int, name:String, onSelection:Void->Void, ?position:Array<Float>, ?scale:Array<Float>,
        ?animated:Bool, ?selected:String, ?idle:String, ?fps:Int, ?transitionState:Class<FlxState>) {
        members.insert(index, {
            name: name,
            position: position,
            scale: scale,
            onSelection: onSelection,
            animated: animated,
            selected: selected,
            idle: idle,
            fps: fps,
            transitionState: transitionState,
        });
    }

    public function remove(name:String) {
        for (item in members) {
            if (item.name.toLowerCase() == name.toLowerCase()) {
                members.remove(item);
                break;
            }
        }
    }
}

typedef MenuData = {
    var name:String; // The image path, also commonly the name of the item (ex: story mode)
    var onSelection:Void->Void; // The function when selecting item
    @:optional var position:Null<Array<Float>>; // x / y position for Sprite
    @:optional var scale:Null<Array<Float>>; // scale.x / scale.y for Sprite

    @:optional var animated:Null<Bool>; // If it has an animation you can toggle this
    @:optional var selected:Null<String>; // Anim name for Selected
    @:optional var idle:Null<String>; // Anim name for Idle
    @:optional var fps:Null<Int>; // Frames per Second for the animation
    @:optional var transitionState:Null<Class<FlxState>>; // if null, it will not transition to a state
}
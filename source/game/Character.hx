package game;

import backend.Conductor;
import backend.Settings;
import scripts.ScriptInterface;
import scripts.HScript;
import flixel.math.FlxPoint;

using StringTools;

class Character extends flixel.FlxSprite {
	public var script:ScriptInterface;

	public var curCharacter:String;
	public var charData:CharacterJSON;

    public var stunned:Bool = false;

	// Player Stuff.
	public var isPlayer:Bool = false;
	public var normallyMirrored:Bool = false;
	public var registeredFlipX:Bool = false;

	//Offset Stuff.
	public var charGlobalOffset:FlxPoint = FlxPoint.get(0, 0);
	public var cameraOffsets:Map<String, Array<Float>> = [];
	public var camOffset:FlxPoint = FlxPoint.get(0, 0);

	// Anim Stuff.
	public var animOffsets:Map<String, Array<Float>> = [];
	public var danceSpeed:Int = 2;
	public var danceStep:Int = 0;
	public var curOffsets:Array<Float> = [0, 0];
    public var debugMode:Bool = false;
    public var holdTimer:Float = 0;
    public var lastHit:Float = -60000;
    public var lastNoteHitTime:Float = -60000;
    var dadVar:Float = 4;
    var danced:Bool = false;

	public function getCamPos() {
		var midpoint = getMidpoint();

		var pos:FlxPoint = FlxPoint.get(midpoint.x + camOffset.x, midpoint.y - 100 + camOffset.y);
		pos.x += isPlayer ? -100 : 150;

		var camOffset:Array<Float> = cameraOffsets[(animation.curAnim != null ? animation.curAnim.name : "nada")];
		if (camOffset != null) {
			pos.x += camOffset[0];
			pos.y += camOffset[1];
		}

		return pos;
	}
	
	public function new(x:Float, y:Float, ?char:String = "bf", ?isPlayer:Bool = false) {
		super(x, y);

		this.isPlayer = isPlayer;
		loadCharacter(char);
	}

	public function loadCharacter(char:String) {
		if (curCharacter == char)
			return;

		animation.destroyAnimations();
		registeredFlipX = false;
		flipX = flipY = false;
		antialiasing = true;
		curCharacter = char;
		charGlobalOffset.set();
		camOffset.set();

		if (script != null) {
			script.destroy();
			script = null;
		}

		var scriptPath = Paths.script('characters/$curCharacter/Character');
		if (scriptPath == null) {
			scriptPath = Paths.script('characters/unknown/Character');
			curCharacter = "unknown";
			trace('"$char" was not found. Loading "unknown" instead.');
		}

		script = new HScript(scriptPath);
		if (script.scriptFailed) {
			script.destroy();
			script = new HScript(Paths.script('characters/unknown/Character'));
			curCharacter = "unknown";
			trace('"$char" failed to load. Loading "unknown" instead.');
		}
		script.parent = this;
        
        script.set("curCharacter", curCharacter);
		script.set("character", this);
        script.set("dance", function() {
            if (animation.exists("danceLeft") && animation.exists("danceRight")) {
                playAnim(danced ? "danceLeft" : "danceRight");
                danced = !danced;
            } else {
                playAnim("idle");
            }
        });
        script.set("getColors", function(altAnim:Bool) {
            var emptyColor = (Settings.hpBarStyle == "legacy") ? 0xFFFF0000 : 0xFF353535;
			var fillColor = (Settings.hpBarStyle == "legacy") ? 0xFF66FF33 : 0xFF02FF56;
            return [
                isPlayer ? fillColor : emptyColor,
                Settings.colors[0],
                Settings.colors[1],
                Settings.colors[2],
                Settings.colors[3]
            ];
        });

		script.call("create");

		//Maybe complicated but idk a better way.
		if (!registeredFlipX) {
			trace('"$scriptPath" FORGOT TO CALL `registerFlipX`.\nPlease call that function with either true or false as a parameter.\n(True if the character is normally on the player side.)');
			normallyMirrored = flipX;
		}

		flipX = flipX != isPlayer;

		if (animation.exists("danceLeft") && animation.exists("danceRight"))
			danceSpeed = 1;
	}

	override function update(elapsed:Float) {
		if (!debugMode && animation.curAnim != null) {
			holdTimer += (animation.curAnim.name.startsWith('sing')) ? elapsed : 0;

			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001) {
				dance();
				holdTimer = 0;
			}

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
				dance();
		
            if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
                playAnim('danceRight');
		}
		

		script.call("update", [elapsed]);
		super.update(elapsed);
	}

	public function loadJSON(overrideFuncs:Bool) {
		var jsonPath = Paths.json('characters/$curCharacter/Character');

		if (!FileSystem.exists(jsonPath)) {
			trace('"$curCharacter"\' JSON file was not found. Loading "unknown" instead.');
			var jsonPath = Paths.json('characters/$curCharacter/Character');
		}

		try {
			charData = cast Assets.load(JSON, jsonPath);
		} catch (e) {
			trace('"$curCharacter"\' JSON file was unable to parse. Loading "unknown" instead.');
			charData = cast Assets.load(JSON, Paths.json('characters/unknown/Character'));
		}

		if (overrideFuncs)
			animation.destroyAnimations();

		for (anim in charData.anims) {
			addOffset(anim.name, anim.x, anim.y, (charData.scaleAffectsOffset) ? charData.scale : 1);

			if (anim.indices != null && anim.indices.length > 0)
				animation.addByIndices(anim.name, anim.anim, anim.indices, "", anim.framerate, anim.loop);
			else
				animation.addByPrefix(anim.name, anim.anim, anim.framerate, anim.loop);

			if (!animation.exists(anim.name)) {
				trace('Unable to add animation "${anim.name}" for character "$curCharacter"');
				animOffsets[anim.name] = [];
				animOffsets.remove(anim.name);
			}
		}

		antialiasing = charData.antialiasing;
		scale.set(charData.scale, charData.scale);
		updateHitbox();
		flipX = charData.flipX;
		registerFlipX(charData.normallyPlayer != null && charData.normallyPlayer);

		charGlobalOffset.set(charData.globalOffset.x, charData.globalOffset.y);
		camOffset.set(charData.camOffset.x, charData.camOffset.y);

		if (overrideFuncs)
			createJSONFuncs();

		playAnim(charData.danceSteps[0]);
	}

	public function createJSONFuncs() {
		var redoDanceSteps:Bool = (charData.danceSteps == null
			|| (charData.danceSteps.length <= 1 && (charData.danceSteps[0] == "idle" || charData.danceSteps[0] == null)))
			&& (!animation.exists("idle") && (animation.exists("danceRight") && animation.exists("danceRight")));

		if (redoDanceSteps)
			charData.danceSteps = ["danceLeft", "danceRight"];

		script.set("dance", function() {
			playAnim(charData.danceSteps[danceStep]);
			danceStep++;
			danceStep %= charData.danceSteps.length;
		});

		/*if (charData.healthIconSteps != null && (charData.healthIconSteps.length != 2 || charData.healthIconSteps[0][0] != 20 || charData.healthIconSteps[1][0] != 0))
			script.set("healthIcon", function(healthIcon) {
			healthIcon.frameIndexes = charData.healthIconSteps;
		});*/

		var healthColor = flixel.util.FlxColor.fromString(charData.healthbarColor);
		if (healthColor == null || Settings.hpBarStyle != "charDependent") {
			// HAHA! IM INCLUDING MY OPINION THAT GREY AND GREEN LOOKS BETTER THEN RED AND GREEN! >:3
			var emptyColor = (Settings.hpBarStyle == "legacy") ? 0xFFFF0000 : 0xFF353535;
			var fillColor = (Settings.hpBarStyle == "legacy") ? 0xFF66FF33 : 0xFF02FF56;
			healthColor = isPlayer ? fillColor : emptyColor;
		}
		var returnArray = [healthColor];

		if (charData.arrowColors != null && charData.arrowColors.length > 0) {
			for (index => color in charData.arrowColors) {
				var nC = flixel.util.FlxColor.fromString(color);
				if (nC != null)
					returnArray[index + 1] = nC;
				else
					returnArray[index + 1] = Settings.colors[index];
			}
		}

		script.set("getColors", function(altAnim) {
			return returnArray;
		});
	}

	public function registerFlipX(normallyPlayer:Bool) {
		normallyMirrored = flipX != normallyPlayer;
		registeredFlipX = true;
	}

	override public function draw() {
		calcOffsets();
		super.draw();
	}

	public function dance(force:Bool = false) {
		if (!force) {
			if ((lastNoteHitTime + 250 > Conductor.songPosition)
			|| (animation.curAnim != null && !animation.curAnim.name.startsWith("sing") && !animation.curAnim.name.startsWith("dance") && !animation.curAnim.finished))
					return;
		}
		if (!debugMode)
			script.call("dance");
	}

	public function playAnim(name:String, ?forced:Bool = false, ?startFrame:Int = 0, ?reverse:Bool = false) {
		if (normallyMirrored != flipX) {
			name = switch (name) {
				case "singLEFT": "singRIGHT";
				case "singRIGHT": "singLEFT";
				case "singLEFTmiss": "singRIGHTmiss";
				case "singRIGHTmiss": "singLEFTmiss";
				default: name;
			}
		}

        var blockAnim:Null<Bool> = script.call("onAnim", [name, forced, reverse, startFrame]);

		if (blockAnim || !animOffsets.exists(name) || !animation.exists(name))
			return; // Prevent playing animation if unavailable.

        lastHit = (isPlayer && name != "idle") ? Conductor.songPosition : lastHit;
        lastNoteHitTime = name.startsWith("sing") ? Conductor.songPosition : lastNoteHitTime;

		animation.play(name, forced, reverse, startFrame);
		curOffsets = animOffsets[name];
		calcOffsets();
	}

	public function calcOffsets() {
		var offsetMult = (normallyMirrored != flipX) ? -1 : 1;

		offset.set(curOffsets[0], curOffsets[1]);

		if (curOffsets[0] != 0 || curOffsets[1] != 0) {
			offset = offset.scale(scale.x * offsetMult, scale.y);

			var sin:Float = Math.sin((angle % 360) / 180 * Math.PI);
			var cos:Float = Math.cos((angle % 360) / 180 * Math.PI);
			offset = offset.rotateWithTrig(sin, cos);
		}

		offset.x -= charGlobalOffset.x * offsetMult;
		offset.y -= charGlobalOffset.y;
	}

	public function addOffset(name:String, ?x:Float = 0, ?y:Float = 0, ?offsetDivisor:Float = 1) {
		var offsets = [x, y];
		offsets[0] /= offsetDivisor;
		offsets[1] /= offsetDivisor;

		animOffsets.set(name, offsets);
	}

	override public function destroy() {
		charGlobalOffset.put();
		camOffset.put();
		super.destroy();
	}
}

typedef CharacterJSON = {
	var anims:Array<CharacterAnim>;
	var globalOffset:CharacterPosition;
	var camOffset:CharacterPosition;
	var antialiasing:Bool;
	var scale:Float;
	var danceSteps:Array<String>;
	var healthIconSteps:Array<Array<Int>>;
	var flipX:Bool;
	var healthbarColor:String;
	var arrowColors:Array<String>;

	var ?normallyPlayer:Bool;
	var ?scaleAffectsOffset:Bool;
}

typedef CharacterPosition = {
	var x:Float;
	var y:Float;
}

typedef CharacterAnim = {
	var name:String;
	var anim:String;
	var framerate:Int;
	var x:Float;
	var y:Float;
	var loop:Bool;
	var indices:Array<Int>;
}

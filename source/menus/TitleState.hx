package menus;

import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxTimer;

// do title state here
class TitleState extends backend.MusicBeat.MusicBeatState {
	public var gf:FlxSprite;
	public var logoBumpin:FlxSprite;
	public var enter:FlxSprite;

	override function create() {
		super.create();

		logoBumpin = new FlxSprite(-50, -35);
		logoBumpin.frames = Paths.getSparrowAtlas("menus/title/logoBumpin");
		logoBumpin.animation.addByPrefix("bump", "logo bumpin", 24, false);
		logoBumpin.animation.play('bump');
		logoBumpin.updateHitbox();
		logoBumpin.scale.x = logoBumpin.scale.y = 0.95;
		logoBumpin.antialiasing = true;
		add(logoBumpin);

		gf = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gf.frames = Paths.getSparrowAtlas("menus/title/gfDanceTitle");
		gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gf.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gf.updateHitbox();
		gf.antialiasing = true;
		add(gf);

		enter = new FlxSprite();
		enter.frames = Paths.getSparrowAtlas("menus/title/titleEnter");
		#if mobile
		enter.animation.addByPrefix("idle", "Android_Idle", 24, true);
		enter.animation.addByPrefix("press", "Android_Press", 24, true);
		#else
		enter.animation.addByPrefix("idle", "Windows_Idle", 24, true);
		enter.animation.addByPrefix("press", "Windows_Press", 24, true);
		#end
		enter.animation.play('idle');
		enter.updateHitbox();
		enter.screenCenter();
		enter.y = FlxG.height - enter.height - 50;
		enter.antialiasing = true;
		add(enter);
	}

	override function beatHit(curBeat:Int) {
		super.beatHit(curBeat);
		logoBumpin.animation.play('bump');
		gf.animation.play((curBeat % 2 == 0) ? 'danceLeft' : 'danceRight');
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null) {
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		#if mobile
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				pressedEnter = true;
			}
		}
		#end
		if (pressedEnter) {
			enter.animation.play('press');
			var tmr = new FlxTimer().start(1.75, function(tmr:FlxTimer) {
				FlxG.switchState(new game.PlayState());
			});
		}

		function skipTitle() {}
	}
}

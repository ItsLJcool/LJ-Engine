package game;

import flixel.FlxObject;
import scripts.HScript;
import scripts.ScriptInterface;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import backend.Conductor;
import game.Song;
import game.HUD;
import game.Note;
import game.Character;

class PlayState extends backend.MusicBeat.MusicBeatState {
	public static var current:PlayState;

	public static var SONG:SwagSong;
	public var songTracks:SongGroup;
	public var section(get, never):SwagSection;

	public var camGame:FlxCamera;
	public var camFollow:FlxObject;
	public var autoCamPos:Bool = true;
	public var defaultCamZoom:Float = 1;
	public var defaultHudZoom:Float = 1;

	public var boyfriend:Character;
	public var gf:Character;
	public var dad:Character;

	@:isVar public var gfSpeed(get, set):Int; //Compatibility.

	public var TEMP_hits:Int = 0;
	public var score:Int = 0;
	public var misses:Int = 0;
	public var accCalculationData:Array<Float> = [0, 0];

	public var hud:HUD;

	public var scripts:Array<ScriptInterface> = [];

	override public function create() {
		super.create();
		current = this;

		camGame = new FlxCamera();
		FlxG.cameras.reset(camGame);

		camFollow = new FlxObject(0, 0, 2, 2);
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		hud = new HUD();
		add(hud);

		boyfriend = new Character(770, 100, SONG.player1, true);
		gf = new Character(400, 100, SONG.gfVersion);
		gf.scrollFactor.scale(0.95);
		dad = new Character(100, 100, SONG.player2);

		var stagePath = Paths.script('data/stages/${SONG.stage}');
		if (stagePath != null) {
			var stageScript = new HScript(stagePath);
			if (stageScript.scriptFailed)
				stageScript.destroy();
			else {
				stageScript.parent = this;
				scripts.push(stageScript);
			}
		}

		callInScripts("create");

		add(gf); // FlxGroup already checks if the object is already in there.
		add(dad);
		add(boyfriend);

		generateSong();

		callInScripts("createPost");
		callInScripts("postCreate");
	}

	override public function update(elapsed:Float) {
		callInScripts("preUpdate", [elapsed]);

		super.update(elapsed);

		var lerpRatio = 0.05 * (FlxG.elapsed * 60);
		camGame.zoom = FlxMath.lerp(camGame.zoom, defaultCamZoom, lerpRatio);
		hud.camHUD.zoom = FlxMath.lerp(hud.camHUD.zoom, defaultHudZoom, lerpRatio);

		if (section != null && autoCamPos) {
			if (section.duetCamera != null && section.duetCamera) {
				var camSlide:Float = (section.duetCameraSlide == null) ? 0.5 : section.duetCameraSlide;

				var bfCamPos = boyfriend.getCamPos();
				var dadCamPos = dad.getCamPos();
				camFollow.setPosition(
					FlxMath.lerp(dadCamPos.x, bfCamPos.x, camSlide),
					FlxMath.lerp(dadCamPos.y, bfCamPos.y, camSlide)
				);
				bfCamPos.put();
				dadCamPos.put();
			} else {
				var camPos = (section.mustHitSection) ? boyfriend.getCamPos() : dad.getCamPos();
				camFollow.setPosition(camPos.x, camPos.y);
				camPos.put();
			}
		}
		
		callInScripts("update", [elapsed]);
		callInScripts("updatePost", [elapsed]);
		callInScripts("postUpdate", [elapsed]);
	}

	override public function stepHit(curStep:Int) {
		super.stepHit(curStep);

		songTracks.tryResync();

		callInScripts("stepHit", [curStep]);
	}

	override public function beatHit(curBeat:Int) {
		super.beatHit(curBeat);

		if (curBeat % 4 == 0) {
			camGame.zoom += 0.015;
			hud.camHUD.zoom += 0.03;
		}

		for (object in members) {
			if (object is Character && curBeat % cast (object, Character).danceSpeed == 0)
				cast (object, Character).dance();
		}

		callInScripts("beatHit", [curBeat]);
	}

	function generateSong() {
		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;
		Conductor.songPosition = 0;
		songTracks = new SongGroup(SONG.song.toLowerCase());
		songTracks.play();

		var curBPM = SONG.bpm;
		var curStepCrochet = (60 / curBPM * 250);
		for (section in SONG.notes) {
			if (section.changeBPM && section.bpm != null && section.bpm != curBPM) {
				curBPM = section.bpm;
				curStepCrochet = (60 / curBPM * 250);
			}

			for (noteData in section.sectionNotes) {
				hud.queuedNotes.push({
					time: noteData[0],
					direction: Std.int(noteData[1] % 4),
					mustPress: ((noteData[1] % 8 >= 4) != section.mustHitSection),
					length: noteData[2],

					stepLength: curStepCrochet
				});
			}
		}

		hud.queuedNotes.sort((note1:QueuedNote, note2:QueuedNote) -> {
			if (note1.time < note2.time)
				return -1;
	
			if (note1.time > note2.time)
				return 1;
	
			return 0;
		});
	}

	override public function destroy() {
		callInScripts("destroy");
		super.destroy();
		current = null;
	}

	public function setInScripts(varName:String, value:Dynamic) {
		for (script in scripts)
			script.set(varName, value);
	}

	public function callInScripts(funcName:String, ?params:Array<Dynamic>) {
		var toReturn:Dynamic = null;

		for (script in scripts) {
			var scriptResult = script.call(funcName, params);
			if (scriptResult != null)
				toReturn = scriptResult;
		}

		return toReturn;
	}

	inline function get_gfSpeed():Int
		return gf.danceSpeed;
	inline function set_gfSpeed(newSpeed:Int):Int
		return gf.danceSpeed = gfSpeed = newSpeed;

	inline function get_section():SwagSection
		return PlayState.SONG.notes[Std.int(curStep / (SONG.sectionLength * 4))];
}

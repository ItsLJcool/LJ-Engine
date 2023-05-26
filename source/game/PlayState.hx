package game;

import scripts.HScript;
import scripts.ScriptInterface;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import backend.Conductor;
import flixel.group.FlxGroup.FlxTypedGroup;
import game.HUD;
import game.Note;

class PlayState extends backend.MusicBeat.MusicBeatState {
	public static var current:PlayState;

	public static var SONG:game.Song.SwagSong;
	public var songTracks:SongGroup;

	public var camGame:FlxCamera;
	public var defaultCamZoom:Float = 1;
	public var defaultHudZoom:Float = 1;

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

		hud = new HUD();
		add(hud);

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

		generateSong();

		callInScripts("createPost");
		callInScripts("postCreate");
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		var lerpRatio = 0.05 * (FlxG.elapsed / (1 / 60));
		camGame.zoom = FlxMath.lerp(camGame.zoom, defaultCamZoom, lerpRatio);
		hud.camHUD.zoom = FlxMath.lerp(hud.camHUD.zoom, defaultHudZoom, lerpRatio);
	}

	override public function stepHit(curStep:Int) {
		super.stepHit(curStep);

		songTracks.tryResync();
	}

	override public function beatHit(curBeat:Int) {
		super.beatHit(curBeat);

		if (curBeat % 4 == 0) {
			camGame.zoom += 0.015;
			hud.camHUD.zoom += 0.03;
		}
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
				var mustPress:Bool = ((noteData[1] % 8 >= 4) != section.mustHitSection);

				var note = new Note(noteData[0], Std.int(noteData[1] % 4), mustPress, curStepCrochet, NOTE);
				hud.queuedNotes.push(note);

				var sustainCount = Math.floor(noteData[2] / curStepCrochet);
				for (sustainIndex in 0...sustainCount) {
					var note = new Note(
						noteData[0] + (curStepCrochet * sustainIndex) + curStepCrochet,
						Std.int(noteData[1] % 4),
						mustPress,
						curStepCrochet,
						(sustainIndex == sustainCount - 1) ? TAIL : HOLD
					);
					hud.queuedNotes.push(note);
				}
			}
		}

		hud.queuedNotes.sort((note1:Note, note2:Note) -> {
			if (note1.time < note2.time)
				return -1;
	
			if (note1.time > note2.time)
				return 1;
	
			return 0;
		});
	}

	override public function destroy() {
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
}

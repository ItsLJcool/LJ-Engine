package game;

import flixel.FlxCamera;
import openfl.events.KeyboardEvent;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import backend.Conductor;
import game.Receptor;
import game.Note;

class HUD extends FlxGroup {
    public var strums:FlxTypedGroup<Receptor>;
    public var plrStrums:Array<Receptor> = [];
    public var cpuStrums:Array<Receptor> = [];

	public var notes:FlxTypedGroup<Note>;
	public var queuedNotes:Array<Note> = [];

    public var camHUD:FlxCamera;

    public var tempTxt:FlxText;

    public function new() {
        super();

        strums = new FlxTypedGroup<Receptor>();
        add(strums);
        for (i in 0...4) {
            var cpuStrum = new Receptor(100 + Note.swagWidth * i, 50, i);
            cpuStrum.isCpu = true;
            cpuStrums.push(cpuStrum);
            strums.insert(i , cpuStrum);

            var plrStrum = new Receptor(740 + Note.swagWidth * i, 50, i);
            plrStrums.push(plrStrum);
            strums.insert(i + 4, plrStrum);
        }

		notes = new FlxTypedGroup<Note>();
		add(notes);

        tempTxt = new FlxText(0, 600, FlxG.width, "Hits: 0 | Misses: 0", 24);
        tempTxt.alignment = CENTER;
        add(tempTxt);

        camHUD = new FlxCamera();
        camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD, false);
        cameras = [camHUD];

        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
        FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
    }

	override public function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
		super.destroy();
	}

    override public function update(elapsed:Float) {
        super.update(elapsed);

		while (queuedNotes[0] != null && queuedNotes[0].time - Conductor.songPosition < 3000)
			notes.add(queuedNotes.shift());

		notes.forEach(updateNote);

        tempTxt.text = 'Hits: ${PlayState.current.TEMP_hits} | Misses: ${PlayState.current.misses} | Song Position: ${Conductor.songPosition}';
    }

    public function updateNote(note:Note) {
        var strum = (note.mustPress) ? plrStrums[note.direction] : cpuStrums[note.direction];
		
		var distance:Float = PlayState.SONG.speed * -0.45 * (Conductor.songPosition - note.time);
        var sinMult:Float = Math.sin(strum.scrollDirection * Math.PI / -180);
        var cosMult:Float = Math.cos(strum.scrollDirection * Math.PI / 180);

		note.x = (strum.x + strum.width / 2) + distance * sinMult - note.width / 2;
        note.y = (strum.y + strum.height / 2) + distance * cosMult - note.height / 2;

        if (distance <= 0 && !note.mustPress && note.scrollType == NOTE) {
            notes.remove(note, true);
            note.destroy();
            strum.playAnim("glow", true);
            return;
        }

        if (note.scrollType != NOTE) {
            if (note.canBeHit && strum.holding && note.mustPress && !note.wasHit) {
                note.wasHit = true;
                strum.playAnim("glow", true);
            }

            if (distance < note.height * 0.5 && (note.wasHit || !note.mustPress)) {
                if (!note.mustPress && !note.wasHit) {
                    note.wasHit = true;
                    strum.playAnim("glow", true);
                }

                note.yClip = -(distance - note.height * 0.5) / note.scale.y;

                if (distance < note.height * -0.5) {
                    notes.remove(note, true);
                    note.destroy();
                    return;
                }
            }
        }

        if (note.tooLate) {
            notes.remove(note, true);
            note.destroy();
            PlayState.current.misses++;
        }
    }

    public function keyDown(event:KeyboardEvent) {
        if (PlayState.current.subState != null) return;

        var strumIndex:Int = -1;
        for (i => strum in plrStrums) {
            if (strum.keybinds.contains(event.keyCode)) {
                strumIndex = i;
                break;
            }
        }

        if (strumIndex < 0 || plrStrums[strumIndex].holding) return;

        var animToPlay:String = "ghost";

        for (note in notes.members) {
            if (!note.mustPress || !note.canBeHit || note.direction != strumIndex || note.wasHit) continue;

            note.wasHit = true;
            if (note.scrollType == NOTE) {
                notes.remove(note, true);
                note.destroy();
                PlayState.current.TEMP_hits++;
            }

            animToPlay = "glow";

            break;
        }

        plrStrums[strumIndex].holding = true;
        plrStrums[strumIndex].playAnim(animToPlay, true);
    }

    public function keyUp(event:KeyboardEvent) {
        if (PlayState.current.subState != null) return;

        var strumIndex:Int = -1;
        for (i => strum in plrStrums) {
            if (strum.keybinds.contains(event.keyCode)) {
                strumIndex = i;
                break;
            }
        }

        if (strumIndex < 0) return;

        plrStrums[strumIndex].holding = false;
        plrStrums[strumIndex].playAnim("static", true);
    }
}
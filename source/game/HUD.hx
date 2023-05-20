package game;

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

    public var tempTxt:FlxText;

    public function new() {
        super();

        strums = new FlxTypedGroup<Receptor>();
        add(strums);
        for (i in 0...4) {
            var cpuStrum = new Receptor(100 + Note.swagWidth * i, 50, i);
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
        if (notes.members[0] != null)
            tempTxt.text += '\n${notes.members[0].x} | ${notes.members[0].y} | $distance';
    }

    var distance:Float = 0;

    public function updateNote(note:Note) {
        var strum = (note.mustPress) ? plrStrums[note.direction] : cpuStrums[note.direction];
		
		distance = PlayState.SONG.speed * -0.45 * (Conductor.songPosition - note.time);
        var sinMult:Float = Math.sin(strum.scrollDirection * Math.PI / -180);
        var cosMult:Float = Math.cos(strum.scrollDirection * Math.PI / 180);

		note.x = strum.x + distance * sinMult;
        note.y = strum.y + distance * cosMult;

        if (distance <= 0 && !note.mustPress) {
            notes.remove(note, true);
            note.destroy();
            strum.playAnim("glow", true);
            strum.animation.finishCallback = (name:String) -> {
                if (name == "glow")
                    strum.playAnim("static", true);
                strum.animation.finishCallback = null;
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

        if (strumIndex < 0) return;

        var animToPlay:String = "ghost";

        for (note in notes.members) {
            if (!note.mustPress || !note.canBeHit || note.direction != strumIndex) continue;

            notes.remove(note, true);
            note.destroy();
            PlayState.current.TEMP_hits++;

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
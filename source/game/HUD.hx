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
	public var queuedNotes:Array<QueuedNote> = [];

    /**
     * These objects will invert their y position when downscroll is on.
     */
    public var hudScrollObjects:Array<flixel.FlxObject> = [];

    public var camHUD:FlxCamera;

    public var tempTxt:FlxText;

    public function new() {
        super();

        strums = new FlxTypedGroup<Receptor>();
        add(strums);
        for (i in 0...4) {
            final cpuStrum = new Receptor(100 + Note.swagWidth * i, 50, i);
            cpuStrum.isCpu = true;
            cpuStrums.push(cpuStrum);
            strums.insert(i , cpuStrum);

            final plrStrum = new Receptor(740 + Note.swagWidth * i, 50, i);
            plrStrums.push(plrStrum);
            strums.insert(i + 4, plrStrum);
        }

		notes = new FlxTypedGroup<Note>();
		add(notes);

        tempTxt = new FlxText(0, 600, FlxG.width, "Hits: 0 | Misses: 0", 24);
        tempTxt.alignment = CENTER;
        add(tempTxt);
        hudScrollObjects.push(tempTxt);

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

		while (queuedNotes[0] != null && queuedNotes[0].time - Conductor.songPosition < 3000) {
            final noteData = queuedNotes.shift();
            final char = (noteData.mustPress) ? PlayState.current.boyfriend : PlayState.current.dad;
			notes.add(new Note(noteData.time, noteData.direction, noteData.mustPress, char, noteData.stepLength, noteData.length));
        }

		notes.forEach(updateNote);

        tempTxt.text = 'Hits: ${PlayState.current.TEMP_hits} | Misses: ${PlayState.current.misses} | Song Position: ${Conductor.songPosition}';
    }

    public function updateNote(note:Note) {
        final strum = (note.mustPress) ? plrStrums[note.direction] : cpuStrums[note.direction];
		
		var distance:Float = PlayState.SONG.speed * -0.45 * (Conductor.songPosition - note.time);

        if (distance <= 0 && !note.mustPress && !note.wasHit) {
            tryDeleteNote(note, strum);
            return;
        }

        note.holding = note.wasHit && (strum.holding || !note.mustPress);
        if (note.sustainLength > 0 && note.holding) {
            distance = 0;
            note.time = Conductor.songPosition;
            note.setSustainLength(note.sustainLength - FlxG.elapsed * 1000, PlayState.SONG.speed);
            note.untilTick -= FlxG.elapsed * 1000;
            if (note.untilTick <= 0) {
                note.untilTick = note.stepLength;
                for (char in note.characters)
                    char.playAnim(note.animToPlay, true);
                strum.playAnim("glow", true);
            }
            if (note.sustainLength <= 0) {
                notes.remove(note, true);
                note.destroy();
            }
        }

		note.x = (strum.x + strum.width / 2) + distance * strum.sinMult - note.width / 2;
        note.y = (strum.y + strum.height / 2) + distance * strum.cosMult - note.height / 2;

        if (note.tooLate) {
            notes.remove(note, true);
            note.destroy();
            PlayState.current.misses++;
        }
    }

    override public function draw() {
        if (backend.Settings.downscroll) {
            final ogYArray:Array<Float> = [];
            for (object in hudScrollObjects) {
                ogYArray.push(object.y);
                object.y = FlxG.height - object.height - object.y;
            }

            super.draw();

            for (i => object in hudScrollObjects) {
                object.y = ogYArray[i];
            }
        } else
            super.draw();
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

        for (note in notes.members) {
            if (!note.mustPress || !note.canBeHit || note.direction != strumIndex || note.wasHit) continue;
            tryDeleteNote(note, plrStrums[strumIndex], 1);
            plrStrums[strumIndex].holding = true;
            break;
        }

        if (!plrStrums[strumIndex].holding) {
            plrStrums[strumIndex].holding = true;
            plrStrums[strumIndex].playAnim("ghost", true);
        }
    }

    function tryDeleteNote(note:Note, strum:Receptor, hitInc:Int = 0) {
        note.wasHit = true;
        note.holding = true;
        strum.playAnim("glow", true);
        for (char in note.characters)
            char.playAnim(note.animToPlay, true);
        if (note.sustainLength <= 0) {
            notes.remove(note, true);
            note.destroy();
            PlayState.current.TEMP_hits += hitInc;
        }
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
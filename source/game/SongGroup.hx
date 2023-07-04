package game;

import backend.Conductor;
import flixel.sound.FlxSound;
import haxe.io.Path;

class SongGroup {
    public var tracks:Array<FlxSound> = [];

    public function new(songName:String) {
        var audioFolder = Paths.getPath('songs/$songName/audio');
        for (audio in FileSystem.readDirectory(audioFolder)) {
            if (Path.extension(audio) == "ogg" || Path.extension(audio) == "mp3" || Path.extension(audio) == "wav") {
                var sound = new FlxSound();
                sound.loadEmbedded(Assets.load(SOUND, Paths.getPath('songs/$songName/audio/$audio')));
                FlxG.sound.list.add(sound);
                tracks.push(sound);
            }
        }
    }

    public function play() {
        for (track in tracks)
            track.play();
    }

    public function pause() {
        for (track in tracks)
            track.pause();
    }

    public function tryResync() {
        for (track in tracks) {
            if (Math.abs(track.time - Conductor.songPosition) >= 20)
                track.time = Conductor.songPosition;
        }
    }
}
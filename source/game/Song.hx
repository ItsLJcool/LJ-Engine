package game;

typedef SwagSong = {
    var events:Array<SongEvent>;
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;
	var keyNumber:Null<Int>;
	var noteTypes:Array<String>;

	var stage:String;

	var ?sectionLength:Null<Int>;
	var ?scripts:Array<String>;
	var ?gfVersion:String;
	var ?noGF:Bool;
	var ?noBF:Bool;
	var ?noDad:Bool;
}

typedef SongEvent = {
	var time:Float;
	var name:String;
	var parameters:Array<String>;
}

typedef SwagSection = {
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var ?duetCamera:Bool;
	var ?duetCameraSlide:Null<Float>;
	var bpm:Null<Int>;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class SongParser {
    public static function parseSongJson(diff:String, song:String) {
        var jsonContent:String = Assets.load(TEXT, Paths.json('songs/$song/diffs/$diff'));
        jsonContent = jsonContent.substr(0, jsonContent.lastIndexOf("}") + 1);

        var parsedJson = Json.parse(jsonContent).song;

        for (section in cast (parsedJson.notes, Array<Dynamic>)) {
			if (Reflect.hasField(section, "sectionBeats")) //psych engine lol
				section.lengthInSteps = section.sectionBeats * 4;
		}

		if (parsedJson.stage == null)
			parsedJson.stage = "stage";

        var swagShit:SwagSong = cast parsedJson;
		swagShit.validScore = true;
		return swagShit;
    }
}
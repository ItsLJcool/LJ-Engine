package menus;

import backend.MusicBeat.MusicBeatState;

class MainMenuState extends modding.ModdableState {

    override function normalCreate() {
        super.normalCreate();
        
        var sprite = new FlxSprite().makeGraphic(200,200, 0xFFFFFFFF);
        sprite.screenCenter();
        add(sprite);
    }

}

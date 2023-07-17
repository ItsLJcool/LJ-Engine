package game;

import flixel.addons.ui.FlxUIState;

class State extends FlxUIState {
    override function create() {
        super.create();
        assets.Mem.clear();
    }
}
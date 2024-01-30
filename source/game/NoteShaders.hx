package game;

import flixel.util.FlxColor;
import flixel.graphics.tile.FlxGraphicsShader;

class NoteShader extends FlxGraphicsShader {
    @:glFragmentHeader('#pragma header

    uniform vec4 noteColor; //Set a to 0 to disable.

    vec4 redRecolor(sampler2D tex, vec2 uv) {
        vec4 texColor = flixel_texture2D(tex, uv);
        if (texColor.a <= 0.0 || noteColor.a <= 0.0)
            return texColor;

        float diff = texColor.r - ((texColor.g + texColor.b) / 2.0);

        return vec4(
            ((texColor.g + texColor.b) / 2.0) + (noteColor.r * diff),
            texColor.g + (noteColor.g * diff),
            texColor.b + (noteColor.b * diff),
            texColor.a
        ) * noteColor.a;
    }')
	@:glFragmentSource('#pragma header

    void main() {
        gl_FragColor = redRecolor(bitmap, openfl_TextureCoordv);
    }')
	public function new(color:FlxColor, enabled:Bool) {
		super();
		this.noteColor.value = [color.redFloat, color.greenFloat, color.blueFloat, enabled ? 1 : 0];
	}
}

class HoldShader extends NoteShader {
    @:glFragmentSource('#pragma header

    uniform float frameTop;
    uniform float frameBottom;
    uniform float tileMult;
    
    uniform float tileInvert = 2.0; // set to 1.0 if you dont want half of the tiles flipping horizontally.
    
    void main() {
        vec2 uv = openfl_TextureCoordv;
        if (uv.y < frameTop || uv.y > frameBottom) discard;
    
        float decrease = tileInvert - 1.0;
        uv.y = (uv.y - frameTop) / (frameBottom - frameTop);
        uv.y = abs(mod(1.0 + ((uv.y - 1.0) * tileMult), tileInvert) - decrease);
        uv.y = uv.y * (frameBottom - frameTop) + frameTop;
    
        gl_FragColor = redRecolor(bitmap, uv);
    }')
    public function new(color:FlxColor, enabled:Bool) {
		super(color, enabled);
		this.frameTop.value = [0.0];
        this.frameBottom.value = [1.0];
        this.tileMult.value = [1.0];
        this.tileInvert.value = [2.0]; // set to 1.0 if you dont want half of the tiles flipping horizontally.
	}
}
package game;

import game.NoteShaders.NoteShader;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

/**
 * ...
 * @author SrtHero278
 */
class Sustain extends flixel.FlxStrip {
    public static var bendQuality(default, set):Int = 2;
    static var bendFract:Float = 1 / bendQuality;

    var _queueRedraw:Bool = true;
    public var sustainMult(default, set):Float = 0.0;
    public var sustainBend(default, set):Float = 0.0;

    public function new(directionName:String, parentShader:NoteShader):Void {
        super(-999, -999);

        frames = Paths.getSparrowAtlas("gameUI/coloredNotes");
        animation.addByPrefix("hold", '$directionName hold', 24, true);
        animation.play("hold");
        shader = parentShader;
        updateHitbox();

        scale = new FlxCallbackPoint(scaleSet);
        scale.set(0.7, 0.7);
    }
    
    override public function update(elapsed:Float) {
        final oldFrame = animation.frameIndex;
        updateAnimation(elapsed);
        _queueRedraw = _queueRedraw || (oldFrame != animation.frameIndex);
    }

    static function set_bendQuality(newQuality:Int) {
        bendFract = 1 / newQuality;
        return bendQuality = newQuality;
    }

    final ogScaleX:Float = 0.0;
    final ogScaleY:Float = 0.0;
    function scaleSet(point:FlxPoint) {
        _queueRedraw = (point.x != ogScaleX || point.y != ogScaleY);
        height = frameHeight * sustainMult * point.y;
    }

    override function set_flipY(newFlip:Bool) {
        _queueRedraw = _queueRedraw || (flipY != newFlip);
        return flipY = newFlip;
    }

    override function set_angle(newAngle:Float) {
        _angleChanged = (angle != newAngle);
        _queueRedraw = _queueRedraw || _angleChanged;
        return angle = newAngle;
    }

    function set_sustainMult(newMult:Float) {
        height = frameHeight * newMult * scale.y;
        _queueRedraw = _queueRedraw || (sustainMult != newMult);
        return sustainMult = newMult;
    }
    function set_sustainBend(newBend:Float) {
        _queueRedraw = _queueRedraw || (sustainBend != newBend);
        return sustainBend = newBend;
    }

    override public function draw() {
        if (sustainMult <= 0) return; // dont render anything if theres ZERO OR NEGATIVE tiles.

        updateTrig(); //btw this function in FlxSprite already checks for _angleChanged.
        if (_queueRedraw)
            regenVerts();

		super.draw();
    }

    function regenVerts() {
        _queueRedraw = false;

        vertices.splice(0, vertices.length);
        uvtData.splice(0, uvtData.length);
        indices.splice(0, indices.length);

        if (bendQuality > 1 && sustainBend != 0.0) {
            regenBendyVerts();
            return;
        }

        final ceilMult = Math.ceil(sustainMult);
        final heightChunk = frameHeight;
        final offset = (sustainMult == ceilMult) ? heightChunk : heightChunk * (sustainMult % 1);
        final yScale = (flipY) ? -scale.y : scale.y;
        final uvOffset = 1.5 / frames.parent.height;

        for (i in 0...ceilMult) {
            final flipI = ceilMult - 1 - i;
            final halfWidth = frameWidth * 0.5 * scale.x;
            final bottom = (flipI % 2 == 0) ? (frame.uv.height - uvOffset) : (frame.uv.y + uvOffset);
            final bottomPos = (heightChunk * i + offset) * yScale;

            if (i == 0) {
                vertices[0] = -halfWidth * _cosAngle;
                vertices[1] = -halfWidth * _sinAngle;
    
                vertices[2] = halfWidth * _cosAngle;
                vertices[3] = halfWidth * _sinAngle;

                final top = (flipI % 2 == 0) ? (frame.uv.y + uvOffset) : (frame.uv.height - uvOffset);
                uvtData[0] = frame.uv.x;
                uvtData[1] = FlxMath.lerp(top, bottom, (sustainMult == ceilMult) ? 0.0 : 1 - sustainMult % 1);
                uvtData[2] = frame.uv.width;
                uvtData[3] = uvtData[1];
            }

            vertices[i * 4 + 4] = -halfWidth * _cosAngle + bottomPos * -_sinAngle;
            vertices[i * 4 + 5] = -halfWidth * _sinAngle + bottomPos * _cosAngle;

            vertices[i * 4 + 6] = halfWidth * _cosAngle + bottomPos * -_sinAngle;
            vertices[i * 4 + 7] = halfWidth * _sinAngle + bottomPos * _cosAngle;

            uvtData[i * 4 + 4] = frame.uv.x;
            uvtData[i * 4 + 5] = bottom;
            uvtData[i * 4 + 6] = frame.uv.width;
            uvtData[i * 4 + 7] = bottom;

            indices[i * 6] = i * 2;
            indices[i * 6 + 1] = 1 + i * 2;
            indices[i * 6 + 2] = 2 + i * 2;
            indices[i * 6 + 3] = 1 + i * 2; 
            indices[i * 6 + 4] = 2 + i * 2;
            indices[i * 6 + 5] = 3 + i * 2;
        }
    }

    function regenBendyVerts() {
        final moduloMult = (sustainMult % bendFract) * bendQuality;
        final ceilMult = Math.ceil(sustainMult * bendQuality);
        final heightChunk = frameHeight * bendFract;
        final offset = (moduloMult == 0.0) ? heightChunk : heightChunk * moduloMult;
        final yScale = (flipY) ? -scale.y : scale.y;
        final uvOffset = 1.5 / frames.parent.height;

        final uvBottom = (frame.uv.height - uvOffset);
        final uvTop = (frame.uv.y + uvOffset);

        for (i in 0...ceilMult) {
            final flipI = ceilMult - 1 - i;
            final halfWidth = frameWidth * 0.5 * scale.x;
            final bottomPos = (heightChunk * i + offset) * yScale;
            final sinInc = FlxMath.fastSin(bendFract * (flipI % (bendQuality * 4)) * Math.PI);

            final curTile = Math.floor(flipI * bendFract);
            final moduloI = (flipI % bendQuality);
            final bottom = FlxMath.lerp(uvBottom, uvTop, Math.abs((curTile % 2) - bendFract * moduloI));

            if (i == 0) {
                final daLerp = (moduloMult == 0.0) ? 0.0 : 1 - moduloMult;
                final sinIncTop = FlxMath.lerp(FlxMath.fastSin(bendFract * ((flipI + 1) % (bendQuality * 4)) * Math.PI), sinInc, daLerp);

                vertices[0] = (-halfWidth + sinIncTop * sustainBend) * _cosAngle;
                vertices[1] = (-halfWidth + sinIncTop * sustainBend) * _sinAngle;
    
                vertices[2] = (halfWidth + sinIncTop * sustainBend) * _cosAngle;
                vertices[3] = (halfWidth + sinIncTop * sustainBend) * _sinAngle;

                final top = FlxMath.lerp(uvTop, uvBottom, Math.abs((curTile % 2) - bendFract * moduloI));
                uvtData[0] = frame.uv.x;
                uvtData[1] = FlxMath.lerp(top, bottom, daLerp);
                uvtData[2] = frame.uv.width;
                uvtData[3] = uvtData[1];
            }
            
            vertices[i * 4 + 4] = (-halfWidth + sinInc * sustainBend) * _cosAngle + bottomPos * -_sinAngle;
            vertices[i * 4 + 5] = (-halfWidth + sinInc * sustainBend) * _sinAngle + bottomPos * _cosAngle;

            vertices[i * 4 + 6] = (halfWidth + sinInc * sustainBend) * _cosAngle + bottomPos * -_sinAngle;
            vertices[i * 4 + 7] = (halfWidth + sinInc * sustainBend) * _sinAngle + bottomPos * _cosAngle;

            uvtData[i * 4 + 4] = frame.uv.x;
            uvtData[i * 4 + 5] = bottom;
            uvtData[i * 4 + 6] = frame.uv.width;
            uvtData[i * 4 + 7] = bottom;

            indices[i * 6] = i * 2;
            indices[i * 6 + 1] = 1 + i * 2;
            indices[i * 6 + 2] = 2 + i * 2;
            indices[i * 6 + 3] = 1 + i * 2; 
            indices[i * 6 + 4] = 2 + i * 2;
            indices[i * 6 + 5] = 3 + i * 2;
        }
    }
}
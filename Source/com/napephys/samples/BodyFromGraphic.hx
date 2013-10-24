package com.napephys.samples;

// Template class is used so that this sample may
// be as concise as possible in showing Nape features without
// any of the boilerplate that makes up the sample interfaces.
import com.drkibitz.napesamples.HandTemplate;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.Event;

import nape.geom.AABB;
import nape.geom.GeomPoly;
import nape.geom.IsoFunction;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;

import openfl.Assets;

/**
 * Sample: Body From Graphic
 * Author: Luca Deltodesco
 *
 * Using MarchingSquares to generate Nape bodies
 * from both a BitmapData and a standard DisplayObject.
 */

class BodyFromGraphic extends HandTemplate
{
    private var cogIso:BitmapDataIso;
    private var objIso:DisplayObjectIso;

    public function new()
    {
        super({
            gravity : Vec2.get(0, 600),
            noReset : true
        });
    }

    override private function init():Void
    {
        var w = stage.stageWidth;
        var h = stage.stageHeight;

        stage.quality = StageQuality.LOW;

        createBorder();

        // Create some Bodies generated from a Bitmap (the cogs)
        // With a body generated from a DisplayObject inside
        // (the intersected circles).
        cogIso = new BitmapDataIso(Assets.getBitmapData('assets/cog.png', true), 0x80);
        #if flash
        var cogBody = IsoBody.run(cogIso, cogIso.bounds);
        #else
        var cogBody = IsoBody.run(cogIso.iso, cogIso.bounds);
        #end

        function circles():DisplayObject
        {
            var displayObject = new Sprite();
            displayObject.graphics.lineStyle(0,0,0);
            displayObject.graphics.beginFill(0, 1);
            displayObject.graphics.drawCircle(-10, 17.32, 30);
            displayObject.graphics.drawCircle(-10, -17.32, 30);
            displayObject.graphics.drawCircle(20, 0, 30);
            displayObject.graphics.endFill();
            return displayObject;
        }
        objIso = new DisplayObjectIso(circles());
        var objBody:Body = null;
        // Flash requires an object to be on stage for hitTestPoint used
        // by the iso-function to work correctly. SIGH.
        function onRemovedFromStage(_):Void
        {
            objIso.displayObject.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
            for (i in 0...4) {
            for (j in 0...2) {
                var body1:Body = cogBody.copy();
                body1.position.setxy(100 + 200*i, 400 - 200*j);
                body1.space = space;

                var graphic1:DisplayObject = cogIso.graphic();
                graphic1.alpha = 0.6;
                addChild(graphic1);
                body1.userData.graphic = graphic1;

                var body2:Body = objBody.copy();
                body2.position.setxy(100 + 200*i, 400 - 200*j);
                body2.space = space;

                var graphic2:DisplayObject = circles();
                graphic2.alpha = 0.6;
                addChild(graphic2);
                body2.userData.graphic = graphic2;
            }}
        }
        function onAddedToStage(_):Void
        {
            objIso.displayObject.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            objIso.displayObject.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
            // OpenFL doesn't actually fire the Event.ADDED_TO_STAGE add an appropriate time
            // basically removeChild doesn't work until an frame step.
            #if flash
            objBody = IsoBody.run(objIso, objIso.bounds);
            removeChild(objIso.displayObject);
            #else
            function onEnterFrame(_):Void
            {
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                objBody = IsoBody.run(objIso.iso, objIso.bounds);
                removeChild(objIso.displayObject);
            }
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            #end
        }
        objIso.displayObject.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addChild(objIso.displayObject);
    }

    override private function willRemoveFromStage():Void
    {
        for (body in space.liveBodies) {
            var graphic:Null<DisplayObject> = body.userData.graphic;
            if (graphic == null) continue;

            removeChild(graphic);
            body.userData.graphic = null;
        }

        if (cogIso != null) {
            cogIso.bitmap = null;
            cogIso.bounds = null;
            cogIso = null;
        }
        if (objIso != null) {
            objIso.bounds = null;
            objIso.displayObject = null;
            objIso = null;
        }

        super.willRemoveFromStage();
    }

    override private function postUpdate(deltaTime:Float):Void
    {
        // Update positions for Flash graphics.
        for (body in space.liveBodies) {
            var graphic:Null<DisplayObject> = body.userData.graphic;
            if (graphic == null) continue;

            var graphicOffset:Vec2 = body.userData.graphicOffset;
            var position:Vec2 = body.localPointToWorld(graphicOffset);
            graphic.x = position.x;
            graphic.y = position.y;
            graphic.rotation = (body.rotation * 180/Math.PI) % 360;
            position.dispose();
        }
    }
}

class IsoBody
{
    public static function run(iso:IsoFunctionDef, bounds:AABB, granularity:Vec2=null, quality:Int=2, simplification:Float=1.5) {
        var body = new Body();

        if (granularity==null) granularity = Vec2.weak(8, 8);
        var polys = MarchingSquares.run(iso, bounds, granularity, quality);
        for (p in polys) {
            var qolys = p.simplify(simplification).convexDecomposition(true);
            for (q in qolys) {
                body.shapes.add(new Polygon(q));

                // Recycle GeomPoly and its vertices
                q.dispose();
            }
            // Recycle list nodes
            qolys.clear();

            // Recycle GeomPoly and its vertices
            p.dispose();
        }
        // Recycle list nodes
        polys.clear();

        // Align body with its centre of mass.
        // Keeping track of our required graphic offset.
        var pivot = body.localCOM.mul(-1);
        body.translateShapes(pivot);

        body.userData.graphicOffset = pivot;
        return body;
    }
}

class DisplayObjectIso#if flash implements IsoFunction#end
{
    public var displayObject:DisplayObject;
    public var bounds:AABB;

    public function new(displayObject:DisplayObject) {
        this.displayObject = displayObject;
        this.bounds = AABB.fromRect(displayObject.getBounds(displayObject));
    }

    public function iso(x:Float, y:Float):Float {
        // Best we can really do with a generic DisplayObject
        // is to return a binary value {-1, 1} depending on
        // if the sample point is in or out side.

        return (displayObject.hitTestPoint(x, y, true) ? -1.0 : 1.0);
    }
}

class BitmapDataIso#if flash implements IsoFunction#end
{
    public var bitmap:BitmapData;
    public var alphaThreshold:Float;
    public var bounds:AABB;

    public function new(bitmap:BitmapData, alphaThreshold:Float = 0x80) {
        this.bitmap = bitmap;
        this.alphaThreshold = alphaThreshold;
        bounds = new AABB(0, 0, bitmap.width, bitmap.height);
    }

    public function graphic() {
        return new Bitmap(bitmap);
    }

    public function iso(x:Float, y:Float):Float {
        // Take 4 nearest pixels to interpolate linearly.
        // This gives us a smooth iso-function for which
        // we can use a lower quality in MarchingSquares for
        // the root finding.

        var ix = Std.int(x); var iy = Std.int(y);
        //clamp in-case of numerical inaccuracies
        if(ix<0) ix = 0; if(iy<0) iy = 0;
        if(ix>=bitmap.width)  ix = bitmap.width-1;
        if(iy>=bitmap.height) iy = bitmap.height-1;

        // iso-function values at each pixel centre.
        var a11 = alphaThreshold - (bitmap.getPixel32(ix,iy)>>>24);
        var a12 = alphaThreshold - (bitmap.getPixel32(ix+1,iy)>>>24);
        var a21 = alphaThreshold - (bitmap.getPixel32(ix,iy+1)>>>24);
        var a22 = alphaThreshold - (bitmap.getPixel32(ix+1,iy+1)>>>24);

        // Bilinear interpolation for sample point (x,y)
        var fx = x - ix; var fy = y - iy;
        return a11*(1-fx)*(1-fy) + a12*fx*(1-fy) + a21*(1-fx)*fy + a22*fx*fy;
    }
}

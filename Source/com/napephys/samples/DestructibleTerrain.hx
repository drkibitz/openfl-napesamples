package com.napephys.samples;

// Template class is used so that this sample may
// be as concise as possible in showing Nape features without
// any of the boilerplate that makes up the sample interfaces.
import com.drkibitz.napesamples.HandTemplate;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.geom.Matrix;

import nape.geom.AABB;
import nape.geom.GeomPoly;
import nape.geom.IsoFunction;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;

#if !flash
import openfl.Assets;
#end

/**
 * Sample: Destructible Terrain
 * Author: Luca Deltodesco
 *
 * Yet another sample featuring MarchingSquares,
 * this time used to implement destructible terrain with
 * use of a Bitmap for controlling removal from terrain.
 *
 * Terrain is chunked so that only necessary regions are
 * recomputed enabling higher performance.
 */

class DestructibleTerrain extends HandTemplate
{
    private var terrain:Terrain;
    private var bomb:Sprite;

    public function new()
    {
        super({
            gravity: Vec2.get(0, 600),
            staticClick: explosion,
            generator: createObject
        });
    }

    override private function init():Void
    {
        var w = stage.stageWidth;
        var h = stage.stageHeight;

        createBorder();

        // Initialise terrain bitmap.
        #if flash
        // Leaving the original alpha channel implementation for posterity
        // Using the blue channel for other platforms
        var bit = new BitmapData(w, h, true, 0);
        bit.perlinNoise(200, 200, 2, 0x3ed, false, true, BitmapDataChannel.ALPHA, false);
        #else
        // OpenFL's perlinNoise implementation doesn't work, just use a prerendered image
        // var bit = new BitmapData(w, h, true, 0);
        // bit.perlinNoise(200, 200, 2, 0x3ed, false, true, BitmapDataChannel.BLUE, false);
        var bit = Assets.getBitmapData('assets/perlinNoise.png', true);
        #end

        // Just show what the terrain looks like on screen
        // var minimap = new Bitmap(bit);
        // minimap.scaleX = minimap.scaleY = 0.2;
        // minimap.x = stage.stageWidth - minimap.width;
        // addChild(minimap);

        // Create initial terrain state, invalidating the whole screen.
        terrain = new Terrain(bit, 30, 5);
        terrain.invalidate(new AABB(0, 0, w, h), space);

        // Create bomb sprite for destruction
        bomb = new Sprite();
        // For flash's alpha implementation the fill color doesn't matter.
        // For all other platforms it does, it must be black to be erased.
        bomb.graphics.beginFill(0x000000, 1);
        bomb.graphics.drawCircle(0, 0, 40);
    }

    private function explosion(pos:Vec2):Void
    {
        // Erase bomb graphic out of terrain.
        #if flash
        // Leaving the original alpha channel implementation for posterity
        // Using the blue channel for other platforms
        terrain.bitmap.draw(bomb, new Matrix(1, 0, 0, 1, pos.x, pos.y), null, BlendMode.ERASE);
        #else
        // OpenFL's implementation does ignores BlenMode, hence using the blue channel ;)
        terrain.bitmap.draw(bomb, new Matrix(1, 0, 0, 1, pos.x, pos.y));
        #end

        // Invalidate region of terrain effected.
        var region = AABB.fromRect(bomb.getBounds(bomb));
        region.x += pos.x;
        region.y += pos.y;
        terrain.invalidate(region, space);
    }

    private function createObject(pos:Vec2):Void
    {
        var body = new Body(BodyType.DYNAMIC, pos);
        if (Math.random() < 0.333) {
            body.shapes.add(new Circle(10 + Math.random()*20));
        }
        else {
            body.shapes.add(new Polygon(Polygon.regular(
                    /*radiusX*/ 10 + Math.random()*20,
                    /*radiusY*/ 10 + Math.random()*20,
                    /*numVerts*/ Std.int(Math.random()*3 + 3)
            )));
        }
        body.space = space;
    }
}

class Terrain#if flash implements IsoFunction#end
{
    public var bitmap:BitmapData;

    private var cellSize:Float;
    private var subSize:Float;

    private var width:Int;
    private var height:Int;
    private var cells:Array<Body>;

    private var isoBounds:AABB;

    public var isoGranularity:Vec2;
    public var isoQuality:Int = 8;

    public function new(bitmap:BitmapData, cellSize:Float, subSize:Float)
    {
        this.bitmap = bitmap;
        this.cellSize = cellSize;
        this.subSize = subSize;

        cells = [];
        width = Math.ceil(bitmap.width / cellSize);
        height = Math.ceil(bitmap.height / cellSize);
        for (i in 0...width*height) cells.push(null);

        isoBounds = new AABB(0, 0, cellSize, cellSize);
        isoGranularity = Vec2.get(subSize, subSize);
    }

    public function invalidate(region:AABB, space:Space):Void
    {
        // compute effected cells.
        var x0 = Std.int(region.min.x/cellSize); if(x0<0) x0 = 0;
        var y0 = Std.int(region.min.y/cellSize); if(y0<0) y0 = 0;
        var x1 = Std.int(region.max.x/cellSize); if(x1>= width) x1 = width-1;
        var y1 = Std.int(region.max.y/cellSize); if(y1>=height) y1 = height-1;

        for (y in y0...(y1+1)) {
        for (x in x0...(x1+1)) {
            var b = cells[y*width + x];
            if (b != null) {
                // If body exists, we'll simply re-use it.
                b.space = null;
                b.shapes.clear();
            }

            isoBounds.x = x*cellSize;
            isoBounds.y = y*cellSize;
            var polys = MarchingSquares.run(
                #if flash
                this,
                #else
                iso,
                #end
                isoBounds,
                isoGranularity,
                isoQuality
            );
            if (polys.empty()) continue;

            if (b == null) {
                cells[y*width + x] = b = new Body(BodyType.STATIC);
            }

            for (p in polys) {
                var qolys = p.convexDecomposition(true);
                for (q in qolys) {
                    b.shapes.add(new Polygon(q));

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

            b.space = space;
        }}
    }

    //iso-function for terrain, computed as a linearly-interpolated
    //alpha threshold from bitmap.
    // Channel Reference: (A & 0xFF) << 24, (R & 0xFF) << 16, (G & 0xFF) << 8, (B & 0xFF);
    public function iso(x:Float, y:Float):Float
    {
        var ix = Std.int(x); if(ix<0) ix = 0; else if(ix>=bitmap.width)  ix = bitmap.width -1;
        var iy = Std.int(y); if(iy<0) iy = 0; else if(iy>=bitmap.height) iy = bitmap.height-1;
        var fx = x - ix; if(fx<0) fx = 0; else if(fx>1) fx = 1;
        var fy = y - iy; if(fy<0) fy = 0; else if(fy>1) fy = 1;
        var gx = 1-fx;
        var gy = 1-fy;

        // Leaving the original alpha channel implementation for posterity
        // Using the blue channel for other platforms
        #if flash
        // Use the alpha channel
        var a00 = bitmap.getPixel32(ix,iy)>>>24;
        var a01 = bitmap.getPixel32(ix,iy+1)>>>24;
        var a10 = bitmap.getPixel32(ix+1,iy)>>>24;
        var a11 = bitmap.getPixel32(ix+1,iy+1)>>>24;
        #else
        // Use the blue channel
        var a00 = bitmap.getPixel(ix,iy);
        var a01 = bitmap.getPixel(ix,iy+1);
        var a10 = bitmap.getPixel(ix+1,iy);
        var a11 = bitmap.getPixel(ix+1,iy+1);
        #end

        var ret = gx*gy*a00 + fx*gy*a10 + gx*fy*a01 + fx*fy*a11;
        return 0x80-ret;
    }
}

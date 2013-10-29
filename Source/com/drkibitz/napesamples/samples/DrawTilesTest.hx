package com.drkibitz.napesamples.samples;

// Template class is used so that this sample may
// be as concise as possible in showing Nape features without
// any of the boilerplate that makes up the sample interfaces.
import com.drkibitz.napesamples.HandTemplate;

import flash.display.BitmapData;
import flash.geom.Rectangle;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.space.Broadphase;

import openfl.Assets;
import openfl.display.Tilesheet;

/**
 * Sample: Draw Tiles Test
 * Author: Dr. Kibitz
 *
 * This sample simply shows rendering object swith drawTiles,
 * and using nape Circle shapes as backing physics objects.
 */

class DrawTilesTest extends HandTemplate
{
    private static inline var OBJ_SIZE:Int = 46;
    private static inline var SMOOTH:Bool = true;
    private static inline var TILE_FIELDS:Int = 4;

    private var objBitmapData:BitmapData;
    private var drawList:Array<Float>;
    private var tilesheet:Tilesheet;

    public function new()
    {
        super({
            gravity: Vec2.get(0, 600),
            // noDebug: true
        });
    }

    override private function init():Void
    {
        var w = stage.stageWidth;
        var h = stage.stageHeight;

        drawList = new Array<Float>();

        objBitmapData = Assets.getBitmapData('images/drkibitz48.png');
        tilesheet = new Tilesheet(objBitmapData);
        tilesheet.addTileRect(
            new Rectangle(0, 0, objBitmapData.width, objBitmapData.height));

        var pyramidHeight = Math.floor((h < w ? h : w) / OBJ_SIZE);

        createBorder();

        for (y in 1...(pyramidHeight+1)) {
        for (x in 0...y) {
            var block = new Body();
            // We initialise the blocks to be slightly overlapping so that
            // all contact points will be created in very first step before the blocks
            // begin to fall.
            block.position.x = (w/2) - OBJ_SIZE*((y-1)/2 - x)*0.99;
            block.position.y = h - OBJ_SIZE*(pyramidHeight - y + 0.5)*0.99;
            block.shapes.add(new Circle(OBJ_SIZE/2));
            block.space = space;
            block.debugDraw = false;
        }}
    }

    // to be overriden
    override private function postUpdate(deltaTime:Float):Void
    {
        var i = 0;
        var box_sqrt = OBJ_SIZE / Math.sqrt(2);
        for (body in space.bodies) {
            if (body.isDynamic()) {
                var pos:Vec2 = body.position;
                var index = i * TILE_FIELDS;
                drawList[index] = pos.x - (Math.cos(body.rotation + Math.PI/4) * box_sqrt);
                drawList[index + 1] = pos.y - (Math.sin(body.rotation + Math.PI/4) * box_sqrt);
                // drawList[index + 2] = i;
                drawList[index + 3] = body.rotation#if flash + (Math.PI/2)#end;
                i++;
            }
        }

        graphics.clear();
        tilesheet.drawTiles(graphics, drawList, SMOOTH, Tilesheet.TILE_ROTATION);
    }
}

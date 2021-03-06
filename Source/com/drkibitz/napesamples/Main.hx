package com.drkibitz.napesamples;

import com.drkibitz.napesamples.DisabledSample;
import com.drkibitz.napesamples.BasicTemplate;
import com.drkibitz.napesamples.ISample;

import com.drkibitz.napesamples.samples.*;
import com.napephys.samples.*;

import flash.display.Sprite;
import flash.system.System;
#if mobile
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
#else
import flash.events.KeyboardEvent;
#end

typedef SampleDef = {
    title:String,
    sampleClass:Class<ISample>
}

class Main extends Sprite
{
    private var currentSampleIsReset:Bool = false;
    private var currentSample:ISample;
    private var sampleDefs:Array<SampleDef>;
    private var sampleDefsIndex:Int = -1;
    #if mobile
    private var screenControls:DisplayObject;
    #end

    public function new()
    {
        BasicTemplate.baseMemory = System.totalMemory;

        super();

        sampleDefs = [
            {
                title: 'Basic Simulation',
                sampleClass: BasicSimulation
            },
            {
                title: 'Draw Tiles Test',
                sampleClass: DrawTilesTest
            },
            {
                title: 'Body From Graphic',
                // This is partially broken on html5, inner circles don't work correctly.
                // I think this has to do with hitTestPoint but not sure.
                // Note: This also needed work arounds for other targets as well.
                // The circles in the middle vary from target to target.
                sampleClass: BodyFromGraphic
            },
            {
                title: 'Constraints',
                sampleClass: Constraints
            },
            {
                title: 'Destructible Terrain',
                // This is too performance intensive for html5, and BitmapData.draw is not working.
                // BitmapData.draw is needed to punch a circle into the terrain bitmap.
                // Note: If this is fixed, be sure to increase cellSize for html5!
                sampleClass:#if html5 DisabledSample#else DestructibleTerrain#end
            },
            {
                title: 'Filtering Interactions',
                sampleClass: FilteringInteractions
            },
            {
                title: 'Fixed Dragging',
                sampleClass: FixedDragging
            },
            {
                title: 'Mario Galaxy Gravity',
                sampleClass: MarioGalaxyGravity
            },
            {
                title: 'OneWay Platforms',
                sampleClass: OneWayPlatforms
            },
            {
                title: 'Perlin Squares',
                sampleClass: PerlinSquares
            },
            {
                title: 'Portals',
                sampleClass: Portals
            },
            {
                title: 'Pyramid Stress Test',
                // This is very performance intensive for neko and html5
                // The number of bodies is lowered for each of these targets
                sampleClass: PyramidStressTest
            },
            {
                title: 'Soft Bodies',
                // This is very performance intensive for neko and html5
                // The number of bodies is lowered for each of these targets
                sampleClass: SoftBodies
            },
            {
                title: 'Spatial Queries',
                sampleClass: SpatialQueries
            },
            {
                title: 'Viewports',
                sampleClass: Viewports
            }
        ];

        #if mobile
        screenControls = new ScreenControls();
        screenControls.scaleX = screenControls.scaleY = stage.dpiScale;
        screenControls.x = stage.stageWidth - screenControls.width;
        screenControls.y = stage.stageHeight - screenControls.height;
        stage.addChild(screenControls);
        screenControls.addEventListener(MouseEvent.CLICK, screenControls_onClick);
        stage.addEventListener(Event.RESIZE, stage_onResize);
        #else
        stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, stage_onKeyUp);
        #end

        // Initiate first sample
        setSampleDefIndex(0);
    }

    private function setSampleDefIndex(index:Int):Void
    {
        sampleDefsIndex = index;
        if (currentSample != null) {
            currentSample.removeFromStage();
        }
        BasicTemplate.title = sampleDefs[index].title;
        currentSample = Type.createInstance(
            sampleDefs[index].sampleClass,
            []
        );
        addChild(cast currentSample);
    }

    private function nextSample():Void
    {
        var index = sampleDefsIndex;
        index = (index == sampleDefs.length - 1) ? 0 : index + 1;
        setSampleDefIndex(index);
    }

    private function previousSample():Void
    {
        var index = sampleDefsIndex;
        index = (index == 0) ? sampleDefs.length - 1 : index - 1;
        setSampleDefIndex(index);
    }

    #if mobile
    private function screenControls_onClick(event:MouseEvent):Void
    {
        var displayObject:DisplayObject = cast event.target;
        var name:String = displayObject.name;
        switch (name) {
            case 'left':
                previousSample();
            case 'right':
                nextSample();
            case 'reset':
                if (!currentSample.params.noReset) {
                    currentSample.reset();
                }
        }
    }

    private function stage_onResize(event:Event):Void
    {
        screenControls.x = stage.stageWidth - screenControls.width;
        screenControls.y = stage.stageHeight - screenControls.height;
    }
    #else
    private function stage_onKeyDown(event:KeyboardEvent):Void
    {
        // 'r'
        if (event.keyCode == 82 && !currentSample.params.noReset && !currentSampleIsReset) {
            currentSampleIsReset = true;
            currentSample.reset();
        }
    }

    private function stage_onKeyUp(event:KeyboardEvent):Void
    {
        // Bug with flash, need to cast this
        var code:Int = event.keyCode;

        // top, left
        switch (code) {
        case 38, 37:
            previousSample();
        // right, bottom
        case 39, 40:
            nextSample();
        // 'r'
        case 82:
            currentSampleIsReset = false;
        }
    }
    #end
}

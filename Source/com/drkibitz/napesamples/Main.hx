package com.drkibitz.napesamples;

import com.drkibitz.napesamples.DisabledSample;
import com.drkibitz.napesamples.BasicTemplate;
import com.drkibitz.napesamples.ISample;

import com.napephys.samples.*;

import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

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

    public function new()
    {
        super();

        BasicTemplate.baseMemory = System.totalMemory;

        sampleDefs = [
            {
                title: 'Basic Simulation',
                sampleClass: BasicSimulation
            },
            {
                title: 'Body From Graphic',
                // This is partially broken on html5, inner circles don't work correctly.
                // I think this has to do with hitTestPoint but not sure.
                // Note: This also needed work arounds for other targets as well.
                sampleClass:#if html5 DisabledSample#else BodyFromGraphic#end
            },
            {
                title: 'Constraints',
                sampleClass: Constraints
            },
            {
                title: 'Destructible Terrain',
                // This is performance intensive for html5, and BitmapData.draw is not working.
                // BitmapData.draw is needed to punch circle in terrain bitmap.
                // Note: If this is fixed, be sure to increase cellSize for html5, it can't take it.
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
                sampleClass: PyramidStressTest
            },
            {
                title: 'Soft Bodies',
                // This is performance intensive for neko and html5
                // Originally I thought I would just lower the number of bodies,
                // but it's still too slow for comfort. I reccommend against it.
                sampleClass:#if (html5||neko) DisabledSample#else SoftBodies#end
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

        // TODO: Implement an on-screen controller
        #if mobile
        stage.addEventListener(MouseEvent.CLICK, nextSample);
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
}
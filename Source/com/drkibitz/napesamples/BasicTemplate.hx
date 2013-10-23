package com.drkibitz.napesamples;

import flash.display.Sprite;
import flash.events.Event;
import flash.system.System;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Broadphase;
import nape.space.Space;
import nape.util.Debug;
import nape.util.ShapeDebug;

typedef BasicTemplateParams = {
    ?gravity : Vec2,
    ?broadphase : Broadphase,
    ?noSpace : Bool,
    ?noReset : Bool
};

class BasicTemplate extends Sprite implements ISample
{
    public var debug:Debug;
    public var params:Dynamic;
    public var space:Space;

    public function new(params:BasicTemplateParams)
    {
        super();

        this.params = params;
        if (params.noSpace == null) {
            params.noSpace = false;
        }
        if (params.noReset == null) {
            params.noReset = false;
        }

        willAddToStage();
        if (stage != null) {
            this_onAddedToStage(null);
        } else {
            addEventListener(Event.ADDED_TO_STAGE, this_onAddedToStage);
        }
    }

    public function createBorder():Body
    {
        var border = new Body(BodyType.STATIC);
        border.shapes.add(new Polygon(Polygon.rect(0, 0, -2, stage.stageHeight)));
        border.shapes.add(new Polygon(Polygon.rect(0, 0, stage.stageWidth, -2)));
        border.shapes.add(new Polygon(Polygon.rect(stage.stageWidth, 0, 2, stage.stageHeight)));
        border.shapes.add(new Polygon(Polygon.rect(0, stage.stageHeight, stage.stageWidth, 2)));
        border.space = space;
        border.debugDraw = false;
        return border;
    }

    public function removeFromStage():Void
    {
        if (stage != null) {
            addEventListener(Event.REMOVED_FROM_STAGE, this_onRemovedFromStage);
            if (space != null) {
                space.clear();
            }
            didClear();
            willRemoveFromStage();
            parent.removeChild(this);
        }
    }

    public function reset():Void
    {
        if (space != null) {
            space.clear();
        }
        didClear();
        #if flash
        System.pauseForGCIfCollectionImminent(0);
        #end
        init();
    }

    private function this_onAddedToStage(?event:Event):Void
    {
        if (event != null) {
            removeEventListener(Event.ADDED_TO_STAGE, this_onAddedToStage);
        }

        if (!params.noSpace) {
            space = new Space(params.gravity, params.broadphase);
        }

        debug = new ShapeDebug(stage.stageWidth, stage.stageHeight,
            #if html5
            stage.backgroundColor
            #else
            stage.opaqueBackground
            #end
        );
        debug.drawConstraints = true;
        addChild(debug.display);

        didAddToStage();
        init();
    }

    private function this_onRemovedFromStage(event:Event):Void
    {
        if (debug != null) {
            debug.flush();
            debug.clear();
            removeChild(debug.display);
            debug = null;
        }
        if (space != null) {
            space.clear();
            space = null;
        }
        params = null;

        didRemoveFromStage();
    }

    // to be overriden
    private function init():Void
    {}

    // to be overriden
    private function willAddToStage():Void
    {}
    private function didAddToStage():Void
    {}

    // to be overriden
    private function willRemoveFromStage():Void
    {}
    private function didRemoveFromStage():Void
    {}

    // to be overriden
    private function didClear():Void
    {}
}

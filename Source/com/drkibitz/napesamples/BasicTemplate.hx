package com.drkibitz.napesamples;

import flash.display.Sprite;
import flash.events.Event;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Broadphase;
import nape.space.Space;
import nape.util.Debug;
import nape.util.ShapeDebug;

typedef BasicTemplateParams = {
    ?broadphase : Broadphase,
    ?gravity : Vec2,
    ?noDebug : Bool,
    ?noReset : Bool,
    ?noSpace : Bool
};

class BasicTemplate extends Sprite implements ISample
{
    public static var title:String;

    /** Implement ISample */
    public var params:Dynamic;

    private var debug:Debug;
    private var space:Space;
    private var textField:TextField;

    /**
     * Constructor
     */
    public function new(params:BasicTemplateParams)
    {
        super();

        this.params = params;
        if (params.noDebug == null) {
            params.noDebug = false;
        }
        if (params.noSpace == null) {
            params.noSpace = false;
        }
        if (params.noReset == null) {
            params.noReset = false;
        }

        if (stage != null) {
            this_onAddedToStage(null);
        } else {
            addEventListener(Event.ADDED_TO_STAGE, this_onAddedToStage);
        }
    }

    /**
     * Implement ISample
     */
    public function removeFromStage():Void
    {
        if (stage != null) {
            addEventListener(Event.REMOVED_FROM_STAGE, this_onRemovedFromStage);

            stage.removeChild(textField);
            textField = null;

            if (space != null) {
                space.clear();
            }
            didClear();
            willRemoveFromStage();
            parent.removeChild(this);
        }
    }

    /**
     * Implement ISample
     */
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

    /**
     * Common helper
     */
    private function createBorder():Body
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

    /**
     * Event.ADDED_TO_STAGE listener
     */
    private function this_onAddedToStage(?event:Event):Void
    {
        if (event != null) {
            removeEventListener(Event.ADDED_TO_STAGE, this_onAddedToStage);
        }

        if (!params.noSpace) {
            space = new Space(params.gravity, params.broadphase);
        }

        if (!params.noDebug) {
            debug = new ShapeDebug(stage.stageWidth, stage.stageHeight,
                #if html5
                stage.backgroundColor
                #else
                stage.opaqueBackground
                #end
            );
            debug.drawConstraints = true;
            addChild(debug.display);
        }

        textField = new TextField();
        textField.defaultTextFormat = new TextFormat("Verdana", 10, 0xffffff);
        textField.selectable = false;
        textField.width = 150;
        textField.height = 800;
        if (title != null && title != "") {
            textField.text = "title: " + title;
        }
        stage.addChild(textField);

        didAddToStage();
        init();
    }

    /**
     * Event.REMOVED_FROM_STAGE listener
     */
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
    private function init():Void {}
    private function didAddToStage():Void {}
    private function willRemoveFromStage():Void {}
    private function didRemoveFromStage():Void {}
    private function didClear():Void {}
}

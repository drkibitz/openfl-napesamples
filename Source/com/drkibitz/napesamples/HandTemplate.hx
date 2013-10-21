package com.drkibitz.napesamples;

import com.drkibitz.napesamples.StepTemplate;

import flash.events.Event;
import flash.events.MouseEvent;

import nape.constraint.PivotJoint;
import nape.geom.Vec2;
import nape.phys.BodyList;
import nape.space.Space;
import nape.util.Debug;

typedef HandTemplateParams = {> StepTemplateParams,
    ?useHand : Bool,
    ?staticClick : Vec2->Void,
    ?generator : Vec2->Void,
};

class HandTemplate extends StepTemplate
{
    private var bodyList:BodyList;
    private var hand:PivotJoint;

    public function new(params:HandTemplateParams)
    {
        if (params.useHand == null) {
            params.useHand = true;
        }
        super(params);
    }

    override private function didClear():Void
    {
        if (hand != null) {
            hand.active = false;
            hand.space = space;
        }
    }

    override private function didAddToStage():Void
    {
        if (space != null && params.useHand) {
            hand = new PivotJoint(space.world, null, Vec2.weak(), Vec2.weak());
            hand.active = false;
            hand.stiff = false;
            hand.maxForce = 1e5;
            hand.space = space;
        }

        stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);

        super.didAddToStage();
    }

    override private function willRemoveFromStage():Void
    {
        super.willRemoveFromStage();

        stage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown);
        stage.removeEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);

        if (hand != null) {
            hand.active = false;
            hand.space = null;
            hand = null;
        }
    }

    public function stage_onMouseDown(event:MouseEvent):Void
    {
        var mp = Vec2.get(mouseX, mouseY);
        if (hand != null) {
            // re-use the same list each time.
            bodyList = space.bodiesUnderPoint(mp, null, bodyList);

            for (body in bodyList) {
                if (body.isDynamic()) {
                    hand.body2 = body;
                    hand.anchor2 = body.worldPointToLocal(mp, true);
                    hand.active = true;
                    break;
                }
            }

            if (bodyList.empty()) {
                if (params.generator != null) {
                    params.generator(mp);
                }
            } else if (!hand.active) {
                if (params.staticClick != null) {
                    params.staticClick(mp);
                }
            }

            // recycle nodes.
            bodyList.clear();
        } else if (params.generator != null) {
            params.generator(mp);
        }
        mp.dispose();
    }

    public function stage_onMouseUp(event:MouseEvent):Void
    {
        if (hand != null) hand.active = false;
    }

    override private function this_onEnterFrame(event:Event):Void
    {
        if (hand != null && hand.active) {
            hand.anchor1.setxy(mouseX, mouseY);
            hand.body2.angularVel *= 0.9;
        }

        super.this_onEnterFrame(event);
    }
}

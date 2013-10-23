package com.drkibitz.napesamples;

import com.drkibitz.napesamples.BasicTemplate;

import flash.events.Event;
import flash.system.System;
import flash.Lib;

typedef StepTemplateParams = {> BasicTemplateParams,
    ?variableStep : Bool,
    ?velIterations : Int,
    ?posIterations : Int,
    ?customDraw : Bool
};

class StepTemplate extends BasicTemplate
{
    private var baseMemory:Float;
    private var prevTime:Int;
    private var smoothFps:Float = -1;

    public function new(params:StepTemplateParams)
    {
        if (params.velIterations == null) {
            params.velIterations = 10;
        }
        if (params.posIterations == null) {
            params.posIterations = 10;
        }
        if (params.customDraw == null) {
            params.customDraw = false;
        }
        if (params.variableStep == null) {
            params.variableStep = false;
        }
        super(params);
    }

    override private function didAddToStage():Void
    {
        baseMemory = System.totalMemory;
        prevTime = Lib.getTimer();
        addEventListener(Event.ENTER_FRAME, this_onEnterFrame);
    }

    override private function willRemoveFromStage():Void
    {
        removeEventListener(Event.ENTER_FRAME, this_onEnterFrame);
    }

    private function this_onEnterFrame(event:Event):Void
    {
        var curTime = Lib.getTimer();
        var deltaTime:Float = (curTime - prevTime);
        if (deltaTime == 0) {
            return;
        }

        var fps = (1000 / deltaTime);
        smoothFps = (smoothFps == -1 ? fps : (smoothFps * 0.97) + (fps * 0.03));
        var text = "fps: " + ((""+smoothFps).substr(0, 5)) + "\n";
        #if html5
        text += "mem: n/a";
        #else
        text += "mem: " + ((""+(System.totalMemory - baseMemory) / (1024 * 1024)).substr(0, 5)) + "Mb";
        #end

        if (space != null) {
            text += "\n"+
                    "velocity-iterations: " + params.velIterations + "\n" +
                    "position-iterations: " + params.posIterations + "\n";
        }
        textField.text = "title: " + BasicTemplate.title + "\n" + text;

        var noStepsNeeded = false;

        if (params.variableStep) {
            if (deltaTime > (1000 / 30)) {
                deltaTime = (1000 / 30);
            }

            debug.clear();

            preStep(deltaTime * 0.001);
            if (space != null) {
                space.step(deltaTime * 0.001, params.velIterations, params.posIterations);
            }
            prevTime = curTime;
        } else {
            var stepSize = (1000 / stage.frameRate);
            stepSize = 1000/60;
            var steps = Math.round(deltaTime / stepSize);

            var delta = Math.round(deltaTime - (steps * stepSize));
            prevTime = (curTime - delta);
            if (steps > 4) {
                steps = 4;
            }
            deltaTime = stepSize * steps;

            if (steps == 0) {
                noStepsNeeded = true;
            } else {
                debug.clear();
            }

            while (steps-- > 0) {
                preStep(stepSize * 0.001);
                if (space != null) {
                    space.step(stepSize * 0.001, params.velIterations, params.posIterations);
                }
            }
        }

        if (!noStepsNeeded) {
            if (space != null && !params.customDraw) {
                debug.draw(space);
            }
            postUpdate(deltaTime * 0.001);
            debug.flush();
        }
    }

    // to be overriden
    private function preStep(deltaTime:Float):Void
    {}
    // to be overriden
    private function postUpdate(deltaTime:Float):Void
    {}
}

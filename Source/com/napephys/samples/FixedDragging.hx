package com.napephys.samples;

// Template class is used so that this sample may
// be as concise as possible in showing Nape features without
// any of the boilerplate that makes up the sample interfaces.
import com.drkibitz.napesamples.BasicTemplate;

import flash.Lib;
import flash.events.Event;
import flash.events.MouseEvent;

import nape.constraint.PivotJoint;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;

/**
 * Sample: Fixed Dragging
 * Author: Luca Deltodesco
 *
 * Demonstrating how one might perform a Nape simulation
 * that uses a fixed-time step for better reproducibility.
 * Also demonstrate how to use a PivotJoint for dragging
 * of Nape physics objects.
 */

class FixedDragging extends BasicTemplate
{
    private var handJoint:PivotJoint;
    private var prevTimeMS:Int;
    private var simulationTime:Float;

    public function new()
    {
        super({});
    }

    override private function didAddToStage():Void
    {
        stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        addEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }

    override private function willRemoveFromStage():Void
    {
        if (handJoint != null) {
            handJoint.active = false;
            handJoint.space = null;
            handJoint = null;
        }
        stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }

    override private function init():Void
    {
        var w = stage.stageWidth;
        var h = stage.stageHeight;

        // Create a static border around stage.
        var border = new Body(BodyType.STATIC);
        border.shapes.add(new Polygon(Polygon.rect(0, 0, w, -1)));
        border.shapes.add(new Polygon(Polygon.rect(0, h, w, 1)));
        border.shapes.add(new Polygon(Polygon.rect(0, 0, -1, h)));
        border.shapes.add(new Polygon(Polygon.rect(w, 0, 1, h)));
        border.space = space;

        // Generate some random objects!
        for (i in 0...100) {
            var body = new Body();

            // Add random one of either a Circle, Box or Pentagon.
            if (Math.random() < 0.33) {
                body.shapes.add(new Circle(20));
            }
            else if (Math.random() < 0.5) {
                body.shapes.add(new Polygon(Polygon.box(40, 40)));
            }
            else {
                body.shapes.add(new Polygon(Polygon.regular(20, 20, 5)));
            }

            // Set to random position on stage and add to Space.
            body.position.setxy(Math.random() * w, Math.random() * h);
            body.space = space;
        }

        // Set up a PivotJoint constraint for dragging objects.
        //
        //   A PivotJoint constraint has as parameters a pair
        //   of anchor points defined in the local coordinate
        //   system of the respective Bodys which it strives
        //   to lock together, permitting the Bodys to rotate
        //   relative to eachother.
        //
        //   We create a PivotJoint with the first body given
        //   as 'space.world' which is a pre-defined static
        //   body in the Space having no shapes or velocities.
        //   Perfect for dragging objects or pinning things
        //   to the stage.
        //
        //   We do not yet set the second body as this is done
        //   in the mouseDownHandler, so we add to the Space
        //   but set it as inactive.
        handJoint = new PivotJoint(space.world, null, Vec2.weak(), Vec2.weak());
        handJoint.space = space;
        handJoint.active = false;

        // We also define this joint to be 'elastic' by setting
        // its 'stiff' property to false.
        //
        //   We could further configure elastic behaviour of this
        //   constraint through the 'frequency' and 'damping'
        //   properties.
        handJoint.stiff = false;

        // Set up fixed time step logic.
        prevTimeMS = Lib.getTimer();
        simulationTime = 0.0;
    }

    private function enterFrameHandler(ev:Event):Void
    {

        var curTimeMS = Lib.getTimer();
        if (curTimeMS == prevTimeMS) {
            // No time has passed!
            return;
        }

        // Amount of time we need to try and simulate (in seconds).
        var deltaTime = (curTimeMS - prevTimeMS) / 1000;
        // We cap this value so that if execution is paused we do
        // not end up trying to simulate 10 minutes at once.
        if (deltaTime > 0.05) {
            deltaTime = 0.05;
        }
        prevTimeMS = curTimeMS;
        simulationTime += deltaTime;

        // If the hand joint is active, then set its first anchor to be
        // at the mouse coordinates so that we drag bodies that have
        // have been set as the hand joint's body2.
        if (handJoint.active) {
            handJoint.anchor1.setxy(mouseX, mouseY);
        }

        // Keep on stepping forward by fixed time step until amount of time
        // needed has been simulated.
        while (space.elapsedTime < simulationTime) {
            space.step(1 / stage.frameRate);
        }

        // Render Space to the debug draw.
        //   We first clear the debug screen,
        //   then draw the entire Space,
        //   and finally flush the draw calls to the screen.
        debug.clear();
        debug.draw(space);
        debug.flush();
    }

    private function mouseDownHandler(ev:MouseEvent):Void
    {
        // Allocate a Vec2 from object pool.
        var mousePoint = Vec2.get(mouseX, mouseY);

        // Determine the set of Body's which are intersecting mouse point.
        // And search for any 'dynamic' type Body to begin dragging.
        for (body in space.bodiesUnderPoint(mousePoint)) {
            if (!body.isDynamic()) {
                continue;
            }

            // Configure hand joint to drag this body.
            //   We initialise the anchor point on this body so that
            //   constraint is satisfied.
            //
            //   The second argument of worldPointToLocal means we get back
            //   a 'weak' Vec2 which will be automatically sent back to object
            //   pool when setting the handJoint's anchor2 property.
            handJoint.body2 = body;
            handJoint.anchor2.set(body.worldPointToLocal(mousePoint, true));

            // Enable hand joint!
            handJoint.active = true;

            break;
        }

        // Release Vec2 back to object pool.
        mousePoint.dispose();
    }

    private function mouseUpHandler(ev:MouseEvent):Void
    {
        // Disable hand joint (if not already disabled).
        handJoint.active = false;
    }
}

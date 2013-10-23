package;

import com.drkibitz.napesamples.ISample;

import com.napephys.samples.*;

import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

class Main extends Sprite
{
    private var sampleClasses:Array<Class<ISample>>;
    private var currentSampleIsReset:Bool = false;
    private var currentSample:ISample;
    private var currentSampleIndex:Int = 0;

    public function new()
    {
        super();

        sampleClasses = [
            BasicSimulation,
            #if !html5
            BodyFromGraphic,
            #end
            Constraints,
            // perlineNouse and draw blendMode is not implemented in OpenFL
            #if flash
            DestructibleTerrain,
            #end
            FilteringInteractions,
            FixedDragging,
            MarioGalaxyGravity,
            OneWayPlatforms,
            PerlinSquares,
            Portals,
            PyramidStressTest,
            #if (cpp||flash)
            SoftBodies,
            #end
            SpatialQueries,
            Viewports
        ];

        // TODO: Implement an on-screen controller
        #if mobile
        stage.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            var index = currentSampleIndex;
            index = (index == sampleClasses.length - 1) ? 0 : index + 1;
            if (index != currentSampleIndex) {
                currentSample.removeFromStage();
                currentSampleIndex = index;
                currentSample = Type.createInstance(sampleClasses[currentSampleIndex], []);
                addChild(cast currentSample);
            }
        });
        #else
        stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, stage_onKeyUp);
        #end

        currentSample = Type.createInstance(sampleClasses[currentSampleIndex], []);
        addChild(cast currentSample);
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
        var index = currentSampleIndex;
        var code:Int = event.keyCode;

        // top, left
        switch (code) {
        case 38, 37:
            index = (index == 0) ? sampleClasses.length - 1 : index - 1;
        // right, bottom
        case 39, 40:
            index = (index == sampleClasses.length - 1) ? 0 : index + 1;
        // 'r'
        case 82:
            currentSampleIsReset = false;
        }

        if (index != currentSampleIndex) {
            currentSample.removeFromStage();
            currentSampleIndex = index;
            currentSample = Type.createInstance(sampleClasses[currentSampleIndex], []);
            addChild(cast currentSample);
        }
    }
}

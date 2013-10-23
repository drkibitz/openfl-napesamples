package com.drkibitz.napesamples;

import nape.phys.Body;
import nape.space.Space;
import nape.util.Debug;

interface ISample
{
    public var params:Dynamic;

    public function removeFromStage():Void;
    public function reset():Void;
}

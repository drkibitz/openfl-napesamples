package com.drkibitz.napesamples;

import nape.phys.Body;
import nape.space.Space;
import nape.util.Debug;

interface ISample
{
    public var debug:Debug;
    public var params:Dynamic;
    public var space:Space;

    public function createBorder():Body;
    public function removeFromStage():Void;
    public function reset():Void;
}

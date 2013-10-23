package com.drkibitz.napesamples;

import com.drkibitz.napesamples.BasicTemplate;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class DisabledSample extends BasicTemplate
{
    private var contentField:TextField;

    public function new()
    {
        super({noDebug: true, noReset: true, noSpace: true});
    }

    override private function didAddToStage():Void
    {
        contentField = new TextField();
        var tf = new TextFormat("Verdana", 14, 0xffffff);
        tf.align = TextFormatAlign.CENTER;
        contentField.defaultTextFormat = tf;
        contentField.text = 'The sample "' + BasicTemplate.title + '" has been disabled for this target.';
        contentField.y = stage.stageHeight * 0.5;
        contentField.width = stage.stageWidth;
        contentField.height = stage.stageHeight;
        contentField.selectable = false;
        addChild(contentField);
    }

    override private function didRemoveFromStage():Void
    {
        removeChild(contentField);
        contentField = null;
    }
}

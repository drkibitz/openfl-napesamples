package com.drkibitz.napesamples;

import flash.display.Sprite;

class ScreenControls extends Sprite
{
    private var buttonLeft:Sprite;
    private var buttonRight:Sprite;
    private var buttonReset:Sprite;

    public function new()
    {
        super();
        mouseEnabled = false;
        mouseChildren = true;

        graphics.beginFill(0x000000);
        graphics.drawRoundRect(0, 0, 50, 140, 20, 20);
        graphics.endFill();

        buttonLeft = new Sprite();
        buttonLeft.name = 'left';
        buttonLeft.buttonMode = true;
        buttonLeft.mouseEnabled = true;
        buttonLeft.graphics.beginFill(0x444444);
        buttonLeft.graphics.drawCircle(20, 20, 20);
        buttonLeft.graphics.endFill();
        buttonLeft.graphics.beginFill(0xffffff);
        buttonLeft.graphics.moveTo(8, 20);
        buttonLeft.graphics.lineTo(28, 10);
        buttonLeft.graphics.lineTo(28, 30);
        buttonLeft.graphics.lineTo(8, 20);
        buttonLeft.x = 5;
        buttonLeft.y = 5;
        addChild(buttonLeft);

        buttonRight = new Sprite();
        buttonRight.name = 'right';
        buttonRight.buttonMode = true;
        buttonRight.mouseEnabled = true;
        buttonRight.graphics.beginFill(0x444444);
        buttonRight.graphics.drawCircle(20, 20, 20);
        buttonRight.graphics.endFill();
        buttonRight.graphics.beginFill(0xffffff);
        buttonRight.graphics.moveTo(12, 10);
        buttonRight.graphics.lineTo(32, 20);
        buttonRight.graphics.lineTo(12, 30);
        buttonRight.graphics.lineTo(12, 10);
        buttonRight.graphics.endFill();
        buttonRight.x = 5;
        buttonRight.y = 50;
        addChild(buttonRight);

        buttonReset = new Sprite();
        buttonReset.name = 'reset';
        buttonReset.buttonMode = true;
        buttonReset.mouseEnabled = true;
        buttonReset.graphics.beginFill(0x444444);
        buttonReset.graphics.drawCircle(20, 20, 20);
        buttonReset.graphics.endFill();
        buttonReset.graphics.beginFill(0xffffff);
        buttonReset.graphics.drawRect(11, 11, 18, 18);
        buttonReset.graphics.endFill();
        buttonReset.x = 5;
        buttonReset.y = 95;
        addChild(buttonReset);
    }
}

# OpenFL Nape Samples

This project is an "almost port" of the samples from http://napephys.com/samples.html. What I mean by this is that the samples were already written with Haxe implementations by Luca Deltodesco. These were not especially optimized for OpenFL, and were not *really* meant to run in any target except flash. This project is meant to change that.

## Goal

Get as many of the samples to run in as many targets as possible.

## Build

This project combines all samples into one application. Build with `openfl test` for any target, and change samples at runtime with keyboard controls.

## Controls
- Change samples with the arrow keys
- Reset current sample with the "r" key
- Use the mouse to drag objects in most samples
- *TODO: Mobile screen controls (Just tap to change for now, dragging still works on objects)*

## Issues

There are issues that cause the need for many target specific conditions. The biggest issues are in regard to the samples of **BodyFromGraphic** and **DestructibleTerrain**. The sample **BodyFromGraphic** does work on non-flash targets, but requires some work-arounds, and does not appear visually identical across targets due to graphic fills in NME. The following listed issues prevent the sample **DestructibleTerrain** from running correctly in all targets except flash.

Other samples may be prevented or are slightly modified for performance reasons on the HTML5 and Neko targets.

### Known issues

- OpenFL implementation of overlapping graphic fill does not punch previous fill
- OpenFL implementation of BitmapData.perlinNoise does not work
- OpenFL implementation of BitmapData.draw does not use BlendMode
- OpenFL implementation of Event.ADDED_TO_STAGE does not fire at appropriate time

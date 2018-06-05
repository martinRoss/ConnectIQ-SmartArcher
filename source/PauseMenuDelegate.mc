//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi as Ui;

class PauseMenuDelegate extends Ui.MenuInputDelegate {
    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :resume) {
            System.println("resume");
            if (Attention has :playTone) {
                Attention.playTone(startToneIdx);
            }
            $.shotCounter.resume();
            $.recordingDelegate.start();
            $.activityTimer.start(method(:onTimerUpdate), 1000, true);

        }
        else if (item == :save) {
            System.println("save");
            $.recordingDelegate.save();
        }
        else {
            System.println("discard");
            $.recordingDelegate.discard();
        }
    }
    // Update for timer
    // Duplicate....
    function onTimerUpdate() {
        $.activitySeconds += 1;
        Ui.requestUpdate();
    }
}
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
        var behaviorDelegate = new SmartArcherBehaviorDelegate();
        if (item == :resume) {
            System.println("resume");
            behaviorDelegate.alertForEvent($.startToneIdx);
            $.shotCounter.resume();
            $.recordingDelegate.start();
            $.activityTimer.start(method(:onTimerUpdate), 1000, true);
        }
        else if (item == :save) {
            System.println("save");
            $.recordingDelegate.save();
            behaviorDelegate.alertForEvent($.startToneIdx);
        }
        else {
            System.println("discard");
            $.recordingDelegate.discard();
        }
        behaviorDelegate = null;
    }
    // Update for timer
    // Duplicate.... Move behavior delegate to global?
    function onTimerUpdate() {
        $.activitySeconds += 1;
        Ui.requestUpdate();
    }
}
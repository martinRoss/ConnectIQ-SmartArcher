using Toybox.System;
using Toybox.WatchUi as Ui;
using Toybox.Timer;

var recordingDelegate = null;
var shotCounter = null;
var activitySeconds = 0;
var activityTimer;

class SmartArcherBehaviorDelegate extends Ui.BehaviorDelegate {
    // Initialize the delegate super class
    function initialize() {
        BehaviorDelegate.initialize();
    }
    // Detect Menu behavior
    function onMenu() {
        //System.println("Menu behavior triggered");
    }
    // Detect select behavior
    function onSelect() {
        // Start session
        if ($.session == null) {
            //System.println("Start session");
            recordingDelegate = new RecordingDelegate();
            shotCounter = new ShotCounterProcess();
            activityTimer = new Timer.Timer();
            shotCounter.start();
            recordingDelegate.start();
            activityTimer.start(method(:onTimerUpdate), 1000, true);
        }
        // Pause session
        else if ($.session.isRecording()) {
            System.println("Pause session");
            shotCounter.pause();
            recordingDelegate.stop();
            //System.println("session.isRecording:" + $.session.isRecording());
            activityTimer.stop();
        }
        // Resume session
        else if ($.session != null && !$.session.isRecording()) {
            //System.println("Resume session");
            shotCounter.resume();
            recordingDelegate.start();
            activityTimer.start(method(:onTimerUpdate), 1000, true);
        }
    }
    
    // Update for timer
    function onTimerUpdate() {
        activitySeconds += 1;
        Ui.requestUpdate();
    }

    // Detect Menu button input
    function onKey(keyEvent) {
        System.println(keyEvent.getKey()); // e.g. KEY_MENU = 7
    }
}
using Toybox.System;
using Toybox.WatchUi as Ui;
using Toybox.Timer;
using Toybox.Attention as Attention;

var recordingDelegate = null;
var shotCounter = null;
var activitySeconds = 0;
var activityTimer;
var startToneIdx = 1;
var stopToneIdx = 2;

class SmartArcherBehaviorDelegate extends Ui.BehaviorDelegate {
    var dialog;
    var dialogHeaderString;
    // Initialize the delegate super class
    function initialize() {
        BehaviorDelegate.initialize();
    }
    // Detect Menu behavior
    function onMenu() {
        System.println("Menu behavior triggered");
    }
    // Detect select behavior
    function onSelect() {
        // Start session
        if ($.session == null) {
            System.println("Start session");
            // Play a sound if available            
            if (Attention has :playTone) {
                Attention.playTone(startToneIdx);
            }
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
            // Play a sound if available            
            if (Attention has :playTone) {
                Attention.playTone(stopToneIdx);
            }
            shotCounter.pause();
            recordingDelegate.stop();
            activityTimer.stop();
            pushPauseMenu(shotCounter.getCount());
        }
        // Resume session
        /**else if ($.session != null && !$.session.isRecording()) {
            System.println("Resume session");
            // Play a sound if available            
            if (Attention has :playTone) {
                Attention.playTone(startToneIdx);
            }
            shotCounter.resume();
            recordingDelegate.start();
            activityTimer.start(method(:onTimerUpdate), 1000, true);
        }*/
    }
    
    // Push the pause menu
    function pushPauseMenu(curShotCount) {
        var menu = new WatchUi.Menu();
        var delegate;
        menu.setTitle(shotsString + ": " + curShotCount);
        menu.addItem(resumeString, :resume);
        menu.addItem(saveString, :save);
        menu.addItem(discardString, :discard);
        delegate = new PauseMenuDelegate();
        WatchUi.pushView(menu, delegate, SLIDE_IMMEDIATE); 
    }
    
    // Update for timer
    function onTimerUpdate() {
        activitySeconds += 1;
        Ui.requestUpdate();
    }

    function onKey(keyEvent) {
        System.println(keyEvent.getKey()); // e.g. KEY_MENU = 7
    }
}
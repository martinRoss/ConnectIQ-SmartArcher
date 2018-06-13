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
    //function onMenu() {
        //System.println("Menu behavior triggered");
    //}
    function alertForEvent(toneIdx) {
		// Play a sound if available            
		if (Attention has :playTone) {
			Attention.playTone(toneIdx);
		}
		// Vibrate if available
		if (Attention has :vibrate) {
			var vibrateData = [
				new Attention.VibeProfile(  25, 100 ),
				new Attention.VibeProfile(  50, 100 ),
				new Attention.VibeProfile(  75, 100 ),
				new Attention.VibeProfile( 100, 100 ),
				new Attention.VibeProfile(  75, 100 ),
			];

			Attention.vibrate(vibrateData);
		}
    }
    // Detect select behavior
    function onSelect() {
        // Start session
        if ($.session == null) {
            System.println("Start session");
            alertForEvent(startToneIdx);
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
            alertForEvent(stopToneIdx);
            shotCounter.pause();
            recordingDelegate.stop();
            activityTimer.stop();
            pushPauseMenu(shotCounter.getCount());
        }
        // Resume session
        // Duplicate...
        else if ($.session != null && !$.session.isRecording()) {
            System.println("Resume session");
            alertForEvent(startToneIdx);
            shotCounter.resume();
            recordingDelegate.start();
            activityTimer.start(method(:onTimerUpdate), 1000, true);
        }
    }
    
    // Push the pause menu
    function pushPauseMenu(curShotCount) {
        var menu = new WatchUi.Menu();
        var delegate = new PauseMenuDelegate();
        menu.setTitle(shotsString + ": " + curShotCount);
        menu.addItem(Ui.loadResource(Rez.Strings.resume), :resume);
        menu.addItem(Ui.loadResource(Rez.Strings.save), :save);
        menu.addItem(Ui.loadResource(Rez.Strings.discard), :discard);
        WatchUi.pushView(menu, delegate, SLIDE_IMMEDIATE); 
    }
    
    // Update for timer
    function onTimerUpdate() {
        activitySeconds += 1;
        Ui.requestUpdate();
    }
}
//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi as Ui;
using Toybox.Timer;
using Toybox.ActivityMonitor as Act;

class PauseMenuDelegate extends Ui.MenuInputDelegate {
    var mActionTime = 1500;
    
    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        var behaviorDelegate = new SmartArcherBehaviorDelegate();
        var progressBar;
        var actionTimer = new Timer.Timer();
        
        if (item == :resume) {
            behaviorDelegate.alertForEvent($.startToneIdx);
            $.shotCounter.resume();
            $.recordingDelegate.start();
            $.activityTimer.start(method(:onTimerUpdate), 1000, true);
        }
        else if (item == :save) {
            actionTimer.start(method(:saveComplete), mActionTime, false);
            behaviorDelegate.alertForEvent($.startToneIdx);
            progressBar = new WatchUi.ProgressBar(
				Ui.loadResource(Rez.Strings.saving),
				null
			);
			Ui.pushView(
				progressBar,
				null,
				Ui.SLIDE_DOWN
			);
        }
        else {
            actionTimer.start(method(:discardComplete), mActionTime, false);
            progressBar = new WatchUi.ProgressBar(
				Ui.loadResource(Rez.Strings.discarding),
				null
			);
			Ui.pushView(
				progressBar,
				null,
				Ui.SLIDE_DOWN
			);

        }
        behaviorDelegate = null;
    }
    // Update for timer
    // Duplicate.... Move behavior delegate to global?
    function onTimerUpdate() {
        $.activitySeconds += 1;
        Ui.requestUpdate();
    }
    
    // After save UI (which is not actually saving)
    function saveComplete() {
        /*var info = Act.getInfo();
        var menu = new Ui.Menu();
        var delegate = new DoneMenuDelegate();
        var cals = 0;
        var calsString = "";
        var shotsString = $.shotCounter.getCount() +
            " " + Ui.loadResource(Rez.Strings.shot_label);
        $.recordingDelegate.save();
        if (info.calories != null) {
           calsString = cals + "C"; 
        }
        menu.setTitle(shotsString + ", " + calsString);
        menu.addItem(Ui.loadResource(Rez.Strings.done), :done);
        WatchUi.pushView(menu, delegate, SLIDE_IMMEDIATE); */
        System.exit();
    }
    
    // After discard UI
    function discardComplete() {
        $.recordingDelegate.discard();
    }
}
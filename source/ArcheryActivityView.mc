using Toybox.WatchUi as Ui;
using Toybox.ActivityMonitor as Act;
using Toybox.Math as Math;
using Toybox.Timer;
using Toybox.Time;
using Toybox.Time.Gregorian;

class ArcheryActivityView extends Ui.View {

    var mCountDrawable;
    var mDurationDrawable;
    var mShotCounter;
    var mTimer;
    
    var seconds = 0;

    function initialize() {
        View.initialize();
        mShotCounter = new ShotCounterProcess();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        mCountDrawable = View.findDrawableById("id_shot_count");
        mDurationDrawable = View.findDrawableById("id_duration");
        
        setDefaultStrings();
    }
    
    // Sets the default values for the main screen
    function setDefaultStrings() {
        mCountDrawable.setText("--");
        mDurationDrawable.setText("--:--");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        mShotCounter.onStart();
        startTime = Time.now();
        mTimer = new Timer.Timer();
        mTimer.start(method(:onTimerUpdate), 1000, true);
    }
    
    // Update for timeer
    function onTimerUpdate() {
        seconds += 1;
        Ui.requestUpdate();
    }
    
    // Update the view
    function onUpdate(dc) {
        var activityInfo;
        //var secondsSinceStart = 0;
        var minutes = Math.floor(seconds / 60);
        var modSeconds = seconds % 60;
        
        // Add leading 0
        if (modSeconds < 10) {
            modSeconds = "0" + modSeconds;
        }
        
        mCountDrawable.setText(mShotCounter.getCount().toString());
        // secondsSinceStart = new Time.Moment(Time.now().value() - startTime.value()) / 1000);
        //mLabelDuration.setText("Duration: " + secondsSinceStart);
        mDurationDrawable.setText(minutes + ":" + modSeconds);
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        mShotCounter.onStop();
        mTimer.stop();
    }

}

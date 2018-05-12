using Toybox.WatchUi as Ui;
using Toybox.ActivityMonitor as Act;

class ArcheryActivityView extends Ui.View {

    var mLabelCount;
    var mLabelDistance;
    var mLabelDuration;
    var mShotCounter;

    function initialize() {
        View.initialize();
        mShotCounter = new ShotCounterProcess();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        mLabelCount = View.findDrawableById("id_shot_count");
        mLabelDistance = View.findDrawableById("id_distance");
        mLabelDuration = View.findDrawableById("id_duration");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        mShotCounter.onStart();
    }

    // Update the view
    function onUpdate(dc) {
        var activityInfo;
        var distMiles;
        var distString;
        
        mLabelCount.setText("Shots: " + mShotCounter.getCount().toString());
        activityInfo = Act.getInfo();
        if (false && activityInfo has :ActiveMinutes) {
            //mLabelDuration.setText("Duration: " + activityInfo.);
        }
        if (false && activityInfo has :distance) {
            //distMiles = activityInfo.distance.toFloat() / 160934; // convert from cm to miles
            //distString = distMiles.format("%.02f");
            //distString += "mi";
            //mLabelDistance.setText("Distance: " + distString);
        }
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        mShotCounter.onStop();
    }

}

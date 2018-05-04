using Toybox.WatchUi as Ui;

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
        mLabelCount.setText("Shots: " + mShotCounter.getCount().toString());
        mLabelDistance.setText("Distance: " + mShotCounter.getSamples().toString());
        mLabelDuration.setText("Duration: " + mShotCounter.getPeriod().toString());
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

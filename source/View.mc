using Toybox.WatchUi as Ui;
using Toybox.Math as Math;

class ArcheryActivityView extends Ui.View {

    var mCountDrawable;
    var mDurationDrawable;

    function initialize() {
        View.initialize();
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
    }
    
    // Update the view
    function onUpdate(dc) {
        var activityInfo;
        var minutes = Math.floor($.activitySeconds / 60);
        var modSeconds = $.activitySeconds % 60;
        
        // Add leading 0
        if (modSeconds < 10) {
            modSeconds = "0" + modSeconds;
        }
        // Set the count 
        if ($.shotCounter != null && $.shotCounter.getCount() > 0) {
            mCountDrawable.setText($.shotCounter.getCount().toString());
        }
        // Set the timer
        mDurationDrawable.setText(minutes + ":" + modSeconds);
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        $.shotCounter.stop();
        $.activityTimer.stop();
    }

}

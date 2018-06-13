using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Position as Position;

var screenShape;
var startTime;
var shotsString;

class ArcheryActivityApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        screenShape = Sys.getDeviceSettings().screenShape;
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        shotsString = Ui.loadResource(Rez.Strings.shot_label); 
        return false;
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }
    
    // Not doing anything special with onPosition yet 
    function onPosition(info) {
    }
    

    // Return the initial view of your application here
    function getInitialView() {
        return [ new ArcheryActivityView(), new SmartArcherBehaviorDelegate() ];
    }

}

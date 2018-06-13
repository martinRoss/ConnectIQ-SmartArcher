using Toybox.ActivityRecording as Record;
using Toybox.FitContributor as Fit;

var session = null;

class RecordingDelegate {
    var shotField;
    var shotValue = 1;
    var SHOT_FIELD_ID = 0;
    
    // Setup fit session with the referenced logger
    function setup(logger) {
        session = Record.createSession({:name=>"Archery", :sport=>Record.SPORT_GENERIC, :sensorLogger => logger});
        shotField = session.createField(
            "shot_detected",
            SHOT_FIELD_ID,
            Fit.DATA_TYPE_SINT8,
            { :mesgType=>Fit.MESG_TYPE_RECORD, :units=>"bars" }
        );
    }
    // Start fit session
    function start() {
        session.start();
    }
    // Save fit session
    function save() {
        session.stop();
        var success = session.save();
    }
    // Stop fit session
    function stop() {
        session.stop();
    }
    // Discard
    function discard() {
        session.stop();
        var success = session.discard();
        if (success) {
            System.exit();
        }
    }
    // Record shot details when detected
    function shotDetected() {
        shotField.setData(shotValue);
    }
}
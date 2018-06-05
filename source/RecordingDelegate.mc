using Toybox.ActivityRecording as Record;
using Toybox.FitContributor as Fit;

var session = null;

class RecordingDelegate {
    var shotField;
    var SHOT_FIELD_ID = 0;
    
    // Setup fit session with the referenced logger
    function setup(logger) {
        session = Record.createSession({:name=>"Archery", :sport=>Record.SPORT_GENERIC, :sensorLogger => logger});
        shotField = session.createField(
            "shot_detected",
            SHOT_FIELD_ID,
            Fit.DATA_TYPE_SINT16,
            { :mesgType=>Fit.MESG_TYPE_RECORD, :units=>"bars" }
        );
    }
    // Start fit session
    function start() {
        session.start();
    }
    // Save fit session
    function save() {
        session.save();
    }
    // Stop fit session
    function stop() {
        session.stop();
    }
    // Record shot details when detected
    function shotDetected(intensity) {
        System.println("Shot detected");
        shotField.setData(intensity);
    }
}
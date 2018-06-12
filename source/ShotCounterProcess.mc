using Toybox.WatchUi as Ui;
using Toybox.Sensor as Sensor;
using Toybox.Math as Math;
using Toybox.SensorLogging as SensorLogging;
using Toybox.System as System;

// Pause is slow expansion before release
// Sensor listener sample rate
const SAMPLE_RATE = 25;
// Sensor listener period
const LISTENER_PERIOD = 1;
// Pause period, samples 600 ms
const PAUSE_PERIOD = 0.6 * SAMPLE_RATE;
// Pause threshold
const PAUSE_THR = 0.5;
// Min time between shots, in samples
const MIN_TIME_BTWN = 7 * SAMPLE_RATE;
// Delta (negative to positive) of release to FTS along x // Louis 7.5G
const X_RELEASE_DELTA = 1.2;
// Delta (positive to negative) of release to FTS along z // Louis 2.9G
// const Z_RELEASE_DELTA = 1.2;
// Period of release, in MS. Time from string release to follow-through stop (FTS)
const RELEASE_DURATION_MS = 400;
const RELEASE_DURATION = RELEASE_DURATION_MS / (1000 / SAMPLE_RATE);


// Current extents within release time window
var min_x = 0;
var max_x = 0;

// Shot counter class
class ShotCounterProcess {
    var mX = [0];
    var mY = [0];
    var mZ = [0];
    var mFilter;
    var mShotCount = 0;
    var mLogger;
    var mActive = false;
    var mPauseCount = 0;
    var mTimeOfLastShot = 0;
    var mTime = 0;
    var mTimeOfLastPause = 0;
    
    // Return min of two values
    hidden function min(a, b) {
        if(a < b) {
            return a;
        }
        else {
            return b;
        }
    }

    // Return max of two values
    hidden function max(a, b) {
        if(a > b) {
            return a;
        }
        else {
            return b;
        }
    }

    // Constructor
    function initialize() {
        // initialize FIR filter
        var options = {:coefficients => [ -0.0278f, 0.9444f, -0.0278f ], :gain => 0.001f};
        try {
            mFilter = new Math.FirFilter(options);
            mLogger = new SensorLogging.SensorLogger({:enableAccelerometer => true});
        }
        catch(e) {
            System.println(e.getErrorMessage());
        }
    }

    // Callback to receive accel data
    function accel_callback(sensorData) {
        mX = mFilter.apply(sensorData.accelerometerData.x);
        mY = mFilter.apply(sensorData.accelerometerData.y);
        mZ = sensorData.accelerometerData.z;
        onAccelData();
    }

    // Start shot counter
    function start() {
        // initialize accelerometer
        $.recordingDelegate.setup(mLogger);
        mActive = true;
        var options = {:period => LISTENER_PERIOD, :sampleRate => SAMPLE_RATE, :enableAccelerometer => true};
        try {
            Sensor.registerSensorDataListener(method(:accel_callback), options);
        }
        catch(e) {
            System.println(e.getErrorMessage());
        }
    }
    
    // Pause the process
    function pause() {
        mActive = false; 
    }
    
    // Resume the process
    function resume() {
        mActive = true; 
    }

    // Stop shot counter
    function stop() {
        Sensor.unregisterSensorDataListener();
    }

    // Return current shot count
    function getCount() {
        return mShotCount;
    }

    // Return current shot count
    function getSamples() {
        return mLogger.getStats().sampleCount;
    }

    // Return sample period
    function getPeriod() {
        return mLogger.getStats().samplePeriod;
    }
    
    // Compute custom shot magnitude score
    // @param {array} x_arr
    // @param {array} y_arr
    // @param {array} z_arr
    // @returns {float} magnitude
    function computeShotMagnitude() {
        var mag = 0;
        // TODO: Implement magnitude function
        // We actually need to keep computing on acc and write a detect pause on the end of a release
        // I.e. we might have enough spike/delta to trigger a shot detected, but it continues to spike afterwards
        // More logic needed in onAccData()
        return mag;
    }
    
    // Process new accel data
    function onAccelData() {
        var cur_acc_x = 0;
        var cur_acc_y = 0;
        var cur_acc_z = 0;
        var cur_x_delta = 0;
        var shot_magnitude = 0;
        
        // Process paused
        if (!mActive) { return false; }
        

        for(var i = 0; i < mX.size(); ++i) {
            
            cur_acc_x = mX[i];
            cur_acc_y = mY[i];
            cur_acc_z = mZ[i];
          
            // Skip if time not far enough ahead from last shot
            if (mTime - mTimeOfLastShot < MIN_TIME_BTWN) {
                // skip futher computation, save juice!
            }
            // far enough in the future, process the signal
            else {
                // Movement has slowed, count off a pause
                if((cur_acc_x < PAUSE_THR) && (cur_acc_x > -PAUSE_THR) &&
                   (cur_acc_y < PAUSE_THR) && (cur_acc_y > -PAUSE_THR)) {
                    mPauseCount++;
                    mTimeOfLastPause = mTime;
                    System.println("Pause at: " + mTime);
                }
                // Check shape, we've had a spike after long enough of a pause
                else if (mPauseCount > PAUSE_PERIOD) {
                    System.println("Long enough pause at: " + mTime);
                    min_x = min(min_x, cur_acc_x);
                    max_x = max(max_x, cur_acc_x);
                    cur_x_delta = max_x - min_x;
                    
                    // Check if this is short enough time for a release
                    if (mTime - mTimeOfLastPause < RELEASE_DURATION) {
                        System.println("Short enough, cur_x_delta: " + cur_x_delta);
                        // Shot detected?
                        if (cur_x_delta > X_RELEASE_DELTA) {
							// shot_magnitude = computeShotMagnitude();
							System.println("Shot magnitude: " + cur_x_delta +", Time: " + mTime);
						    mTimeOfLastShot = mTime;
                            recordingDelegate.shotDetected(); 
                            mPauseCount = 0;
                            mShotCount++;
                            min_x = 0;
                            max_x= 0;
						}
                    }
					// We've been spiking for too long, reset pause count
					// TODO: extending past detection
					else {
                        mPauseCount = 0; 
                        min_x = 0;
                        max_x = 0;
                    }
                }
                // Movement before we've paused long enough, need to start the counter over
                else {
                    mPauseCount = 0;
                    min_x = 0;
                    max_x = 0;
                }
            }
            // Increment time (by sample period) 
            mTime++; 

        }
        Ui.requestUpdate();
    }
}
 
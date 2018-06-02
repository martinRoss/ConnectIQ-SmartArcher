using Toybox.WatchUi as Ui;
using Toybox.Sensor as Sensor;
using Toybox.Math as Math;
using Toybox.SensorLogging as SensorLogging;
using Toybox.System as System;

// Smart Archer Additions
// Period of release, in MS. Time from string release to follow-through stop (FTS)
const RELEASE_DURATION_MS = 400;
// Delta (negative to positive) of release to FTS along x // Louis 7.5G
const X_RELEASE_DELTA = 2.5;
// Delta (positive to negative) of release to FTS along z // Louis 2.9G
const Z_RELEASE_DELTA = 1.2;
// ---

// --- Min duration for the pause feature, [samples]
const NUM_FEATURE = 20;

// --- Min duration between shots, [samples]
const TIME_PTC = 20;

// --- Pause feature threshold: positive and negative ones
const QP_THR = 2.0f;
const QN_THR = -QP_THR;

// --- Pause range: number of samples * 40 ms each
const Q_RANGE = (100 * 40);

var acc_x1 = 0;
var acc_x2 = 0;

var acc_z1 = 0;
var acc_z2 = 0;

var min_x = 0;
var max_x = 0;

var min_z = 0;
var max_z = 0;

// MOVE THIS TO BEHAVIOR DELEGATE
var recordingDelegate = null;

// Shot counter class
class ShotCounterProcess {

    var mX = [0];
    var mY = [0];
    var mZ = [0];
    var mFilter;
    var mPauseCount = 0;
    var mPauseTime = 0;
    var mLastShotTime;
    var mSkipSample = 25;
    var mShotCount = 0;
    var mLogger;
    //var mSession;

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
    
    // Return the absolute value
    hidden function abs(a) {
        if(a < 0){
            return -a;
        } else {
            return a;
        }
    }

    // Constructor
    function initialize() {
        // initialize FIR filter
        var options = {:coefficients => [ -0.0278f, 0.9444f, -0.0278f ], :gain => 0.001f};
        try {
            mFilter = new Math.FirFilter(options);
            mLogger = new SensorLogging.SensorLogger({:enableAccelerometer => true});
            recordingDelegate = new RecordingDelegate();
            recordingDelegate.setup(mLogger);
        }
        catch(e) {
            System.println(e.getErrorMessage());
        }
    }

    // Callback to receive accel data
    function accel_callback(sensorData) {
        mX = mFilter.apply(sensorData.accelerometerData.x);
        mY = sensorData.accelerometerData.y;
        //mZ = sensorData.accelerometerData.z;
        mZ = mFilter.apply(sensorData.accelerometerData.z);
        onAccelData();
    }

    // Start shot counter
    function onStart() {
        // initialize accelerometer
        var options = {:period => 1, :sampleRate => 25, :enableAccelerometer => true};
        try {
            Sensor.registerSensorDataListener(method(:accel_callback), options);
            recordingDelegate.start();
        }
        catch(e) {
            System.println(e.getErrorMessage());
        }
    }

    // Stop shot counter
    function onStop() {
        Sensor.unregisterSensorDataListener();
        recordingDelegate.stop();
        startTime = null;
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
    // Process new accel data
    function onAccelData() {
        var cur_acc_x = 0;
        var cur_acc_y = 0;
        var cur_acc_z = 0;
        var cur_x_delta = 0;
        var cur_z_delta = 0;
        var time = 0;

        for(var i = 0; i < mX.size(); ++i) {

            cur_acc_x = mX[i];
            cur_acc_y = mY[i];
            cur_acc_z = mZ[i];

            if(mSkipSample > 0) {
                mSkipSample--;
            }
            else {
                // --- Pause feature?
                if((cur_acc_x < QP_THR) && (cur_acc_x > QN_THR) && (cur_acc_y < QP_THR) &&
                   (cur_acc_y > QN_THR) && (cur_acc_z < QP_THR) && (cur_acc_z > QN_THR)) {
                    mPauseCount++;

                    // --- Long enough pause before a shot?
                    if( mPauseCount > NUM_FEATURE ) {
                        mPauseCount = NUM_FEATURE;
                        mPauseTime = time;
                        }
                    }
                else {
                    mPauseTime = 0;
                }

                min_x = min(min(acc_x1, acc_x2), cur_acc_x);
                max_x = max(max(acc_x1, acc_x2), cur_acc_x);

                min_z = min(min(acc_z1, acc_z2), cur_acc_z);
                max_z = max(max(acc_z1, acc_z2), cur_acc_z);

                cur_x_delta = max_x - min_x;
                cur_z_delta = max_z - min_z;
                // --- Shot motion?
                //System.println("x_delta:" + cur_x_delta);
                //System.println("z_delta:" + cur_z_delta);
                //if ((time - mPauseTime < Q_RANGE) && cur_x_delta > X_RELEASE_DELTA) {
                if ((time - mPauseTime < Q_RANGE) && cur_x_delta > X_RELEASE_DELTA && cur_z_delta > Z_RELEASE_DELTA) { 

                    // System.println("z_delta:" + cur_z_delta);
                    // --- A new shot detected
                    mShotCount++;
                    
                    // Record shot in fit file
                    recordingDelegate.shotDetected();

                    // --- Next shot should be farther in time than TIME_PTC
                    mSkipSample = TIME_PTC;

                    // --- Clear the previous accelerometer values for X and Z channels
                    acc_x2 = 0;
                    acc_x1 = 0;
                    acc_z2 = 0;
                    acc_z1 = 0;

                    // --- Reset pause feature counter
                    mPauseCount = 0;
                    mPauseTime = 0;
                }
                else {
                    // --- Update 3 elements of acceleration for X
                    acc_x2 = acc_x1;
                    acc_x1 = cur_acc_x;

                    // --- Update 3 elements of acceleration for Z
                    acc_z2 = acc_z1;
                    acc_z1 = cur_acc_z;
                }
            }
            time++;
        }
        Ui.requestUpdate();
    }
}
 
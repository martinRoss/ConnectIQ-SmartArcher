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
// Pause period, samples 500 ms
const PAUSE_PERIOD = 0.4 * SAMPLE_RATE;
// Pause threshold
const X_PAUSE_THR = 0.5;
const Y_PAUSE_THR = 0.75;
// Min time between shots, in samples
const MIN_TIME_BTWN = 4 * SAMPLE_RATE;
// Delta (negative to positive) of release to FTS // Louis 7.5G
const X_RELEASE_DELTA = 2.5;
const Y_RELEASE_DELTA = 1.2;
// Both positive and negative x must go past this threshold
const X_THR = 1.5;
// Delta (positive to negative) of release to FTS along z // Louis 2.9G
// const Z_RELEASE_DELTA = 1.2;
// Release duration, 0.5 seconds
const RELEASE_DURATION = 0.5 * SAMPLE_RATE;

// Shot counter class
class ShotCounterProcess {
    var mX = [0]; // Current array of x samples set during last acc callback (per period)
    var mY = [0]; // Current array of y samples set during last acc callback (per period)
    var mZ = [0]; // Current array of z samples set during last acc callback (per period)
    var mFilter;
    var mShotCount = 0;
    var mLogger;
    var mActive = false;
    var mPauseCount = 0;
    var mTimeOfLastShot = 0;
    var mTime = 0;
    var mTimeOfLastPause = 0;
    var mKeepProcessingFindMax = false; // There's big enough of a spike but we want to keep processing to see if the spike extends
	var mMinX = 0;
	var mMinY = 0;
	var mMaxX = 0;
	var mMaxY = 0;
    var mCurAccX = 0;
	var mCurAccY = 0;
	var mCurAccZ = 0;
	var mCurXDelta = 0;
	var mCurYDelta = 0;
	var mShotMagnitude = 0; // Shot magnitude of the last detected shot
	var mShotMetrics = new [0]; 
 
    
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
    
    function getLastShotMetric() {
        return mShotMetrics[mShotMetrics.size() - 1];
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
    
    // Rests pause count, min, max and deltas
    function resetExtentValues() {
        mMinX = 0;
		mMaxX= 0;
		mMinY = 0;
		mMaxX = 0;
		mCurXDelta = 0;
		mCurYDelta = 0; 
    }
    
    // Process new accel data
    function onAccelData() {
       
        // Process paused
        if (!mActive) { return; }
        

        for(var i = 0; i < mX.size(); ++i) {
            
            mCurAccX = mX[i];
            mCurAccY = mY[i];
            mCurAccZ = mZ[i];
          
            // Skip if time not far enough ahead from last shot
            if (mTime - mTimeOfLastShot < MIN_TIME_BTWN) {
                // skip futher computation, save juice!
            }
            else {
				// Shot just detected, but keep checking to see if the extent is wider
				if (mKeepProcessingFindMax) {
					if (mCurAccX > mMaxX || mCurAccX < mMinX) {
						mMinX = min(mMinX, mCurAccX);
						mMinY = min(mMinY, mCurAccY);
						mMaxX = max(mMaxX, mCurAccX);
						mMaxY = max(mMaxY, mCurAccY);
						mCurXDelta = mMaxX - mMinX;
						mCurYDelta = mMaxY - mMinY;
					}
					// Found the extent, record shot magnitude and clear values
					else {
					    System.println("Shot magnitude: " + mCurXDelta +", Time: " + mTime);
						mTimeOfLastShot = mTime;
						recordingDelegate.shotDetected(); 
						mPauseCount = 0;
						mShotCount++;	
						mKeepProcessingFindMax = false;
						mShotMetrics.add(new ShotMetric(mMaxX, mMinX));
						resetExtentValues();
					}

				}
				// far enough in the future, process the signal
				else {
					//System.println("mCurAccX: " + mCurAccX);
					// Movement has slowed, count off a pause
					if((mCurAccX < X_PAUSE_THR) && (mCurAccX > -X_PAUSE_THR) &&
					   (mCurAccY < Y_PAUSE_THR) && (mCurAccY > -Y_PAUSE_THR)) {
						mPauseCount++;
						mTimeOfLastPause = mTime;
						//System.println("Pause at: " + mTime);
					}
					// Check shape, we've had a spike after long enough of a pause
					else if (mPauseCount > PAUSE_PERIOD) {
						//System.println("Long enough pause at: " + mTime);
						mMinX = min(mMinX, mCurAccX);
						mMinY = min(mMinY, mCurAccY);
						mMaxX = max(mMaxX, mCurAccX);
						mMaxY = max(mMaxY, mCurAccY);
						mCurXDelta = mMaxX - mMinX;
						mCurYDelta = mMaxY - mMinY;
						
						// Check if this is short enough time for a release
						if (mTime - mTimeOfLastPause < RELEASE_DURATION) {
							//System.println("Short enough, mCurXDelta: " + mCurXDelta);
							// Shot detected?
							if ((mCurXDelta > X_RELEASE_DELTA) && (mCurYDelta > Y_RELEASE_DELTA) &&
					            (mMaxX > X_THR) && (mMinX < -X_THR)) {
								mKeepProcessingFindMax = true;
							}
						}
						// We've been spiking for too long, reset pause count
						// TODO: extending past detection
						else {
							mPauseCount = 0; 
						    resetExtentValues();	
						}
					}
					// Movement before we've paused long enough, need to start the counter over
					else {
						mPauseCount = 0;
					    resetExtentValues();	
					}
				}
            }
            // Increment time (by sample period) 
            mTime++; 
        }
        Ui.requestUpdate();
    }
}
 
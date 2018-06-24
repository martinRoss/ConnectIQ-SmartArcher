class ShotMetric {
    var mMaxX = null;
    var mMinX = null;
    
    function initialize(max_x, min_x) {
        mMaxX = max_x;
        mMinX = min_x;
    }
    
    function getMaxX() {
        return mMaxX;
    }
    
    function getMinX() {
        return mMinX;
    }
}
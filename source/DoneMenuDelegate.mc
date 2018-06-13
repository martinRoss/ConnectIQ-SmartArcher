
using Toybox.WatchUi as Ui;
using Toybox.Timer;

class DoneMenuDelegate extends Ui.MenuInputDelegate {
    
    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :done) {
			System.println("Done");
			System.exit();
	    }
    }
} 
using Toybox.WatchUi as Ui;

class ArcheryActivityDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        Ui.pushView(new Rez.Menus.MainMenu(), new ArcheryActivityMenuDelegate(), Ui.SLIDE_UP);
        return true;
    }

}
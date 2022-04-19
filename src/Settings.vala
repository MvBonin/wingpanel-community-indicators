/*-
 * Copyright (c) 2022 MvBonin (github.com/MvBonin) & 2015 Wingpanel Developers (http://launchpad.net/wingpanel)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


 public class AyatanaCompatibility.Settings : Object{
    //This class will be a singleton.
    //Its used to store and load settings for indicators.
    //Needed to interact with the switchboard plug.

    //If switchboard plug changes settings file
    //we use gio-2.0 (GLib) to track it and call 
    //settings_file_changed ()

    //Indicators inside wingpanel itself are refered to as MAIN, indicators in ... menu as NAMARUPA
    enum Place {
        MAIN,
        NAMARUPA
    }
    //Settings need to store:
    //  -   "Show/hide ... indicator if no indicators are inside of it"
    private bool showEmptyNamarupa;
    //  -   "Default place for new indicators. (... menu or main)"
    private Place defaultIndicatorsPlace;
    //  -   

    Gee.HashSet<string> namarupaNames;
    GLib.File settings_File;
    GLib.FileMonitor monitor;

    static Settings? instance;
    private Settings () {
        //File.make_directory("~/.config/indicators"); //Create dir if it doesn't exist
        settings_File = File.new_for_commandline_arg(GLib.Environment.get_home_dir () + "/.config/indicators/");
        settings_File.make_directory_with_parents();
        monitor = settings_File.monitor_directory(
            GLib.FileMonitorFlags.NONE
        );
        monitor.changed.connect(settings_file_changed);
        print("Monitoring: "+settings_File.get_path()+"\n");

        defaultIndicatorsPlace = Place.MAIN;
        showEmptyNamarupa = true;
    }

    public static Settings get_instance () {
        if(instance == null) {
            instance = new Settings ();
        }
        return instance;
    }

    void settings_file_changed () {
        print("Settings file changed. Updating Settings.\n");
    }
}
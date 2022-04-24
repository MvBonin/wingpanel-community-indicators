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
    //settings_Dir_changed ()

    //Indicators inside wingpanel itself are refered to as MAIN, indicators in ... menu as NAMARUPA
    enum Place {
        MAIN,
        NAMARUPA
    }
    //Settings need to store:
    //  -   "Show/hide ... indicator if no indicators are inside of it"
    private bool showEmptyNamarupaIndicator;
    //  -   "Default place for new indicators. (... menu or main)"
    private Place defaultIndicatorsPlace;
    //  -   

    string settingsDir = GLib.Environment.get_home_dir () + "/.config/indicators/";
    Gee.HashSet<string> namarupaNames;
    Gee.HashSet<string> allIndicators;
    GLib.File settings_Dir;
    GLib.File settings_File;
    GLib.File settings_IndicatorNamesFile;
    GLib.File settings_Images_Dir;

    GLib.FileMonitor monitor;

    static Settings? instance;
    private Settings () {
        this.allIndicators = new Gee.HashSet<string> ();
        this.namarupaNames = new Gee.HashSet<string> ();
        namarupaNames.add("Nextcloud");
        namarupaNames.add("ulauncher");
        namarupaNames.add("KeePassXC");

        print("Settings initiated \n");

        //File.make_directory("~/.config/indicators"); //Create dir if it doesn't exist
        settings_Dir = File.new_for_commandline_arg (settingsDir);

        settings_Images_Dir = File.new_for_commandline_arg (settingsDir + "icons/");

        settings_File = File.new_for_commandline_arg(settingsDir + "indicators.json");
        settings_IndicatorNamesFile = File.new_for_commandline_arg(settingsDir + "indicatorNames.json");
        
        if (!settings_Dir.query_exists ()){
            settings_Dir.make_directory_with_parents();
        }

        if (!settings_Images_Dir.query_exists ()){
            settings_Images_Dir.make_directory_with_parents();
        }

        if(!settings_File.query_exists ()){
            //The Settings file doesn't exist. Create and write one.
            print("Creating Settings json file, since it does not exist\n");
            write_file( settings_File, generate_Json_String ());
        }
        if(!settings_IndicatorNamesFile.query_exists ()){
            //The Settings file doesn't exist. Create and write one.
            print("Creating IndicatorNames json file, since it does not exist\n");
            write_Indicator_Names (settings_IndicatorNamesFile);
        } else {
            //IndicatorNames file exists: load indicator names to the allIndicators List. This way we have all indicators that were open at any time and they dont
            //disappear from the List after being closed.
            read_Indicator_Names (settings_IndicatorNamesFile);
        }

        monitor = settings_File.monitor ( //to track directory use .monitor_directory
            GLib.FileMonitorFlags.NONE
        );
        monitor.changed.connect(settings_File_changed);
        print("Monitoring: " + settings_File.get_path() + "\n");

        defaultIndicatorsPlace = Place.MAIN;
        showEmptyNamarupaIndicator = true;
        

    }

    public Gee.HashSet<string> get_namarupa_names () {
        return namarupaNames;
    }

    public void export_image ( Gtk.Image image, string name ) {
        //settings_Images_Dir is the dir the images get exported to
        Gdk.Pixbuf pixbuf = image.get_pixbuf ();
        //print("Exporting image of " + name + " with " + image.get_pixel_size ().to_string () + " pixels. File: " + image.file + "\n");
        if (image != null && pixbuf == null && image.icon_name != null) {
            try {
                Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
                pixbuf = icon_theme.load_icon (image.icon_name, 16, 0);
            } catch (Error e) {
                warning (e.message);
            }
        }

        

        if(image.gicon != null){
            //print("image of " + name + "contains gicon.\n");
            Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
            Gtk.IconInfo info = icon_theme.lookup_by_gicon(image.gicon, 16, Gtk.IconLookupFlags.USE_BUILTIN);
            pixbuf = info.load_icon ();
        }
        GLib.File save_file = File.new_for_commandline_arg(settings_Images_Dir.get_path () + "/" + name + ".png");
        if(pixbuf != null && !save_file.query_exists ()){
            print("Exporting pixbuf of " + name + " to file.\n");
            pixbuf.save (save_file.get_path (), "png");
        } else {
            print("No pixbuf for " + name + " or file exists already.\n");
        }


    }

    public void indicatorAdded (string name, Gtk.Image image) {
        allIndicators.add(name);
        write_Indicator_Names (settings_IndicatorNamesFile);
        export_image (image, name);
    }

    public static Settings get_instance () { //Gee.HashSet<string> allIndicators
        if(instance == null) {
            instance = new Settings ();
        }
        return instance;
    }


    void settings_File_changed () {
        print("Settings File changed. \n");
        string file = read_file(settings_File);
        get_Settings_from_Json_string(file);
        //TODO: Fire event to update settings in MetaIndicator and NamarupaMetaindicator

    }


    private string read_file(File file) {
        string output;
        try {

            GLib.FileUtils.get_contents(file.get_path (), out output);

        } catch (Error e) {
            error ("%s", e.message);
        }

        return output;
    }

    private void write_file(File file, string content) {
        try {

            GLib.FileUtils.set_contents(file.get_path (), content);

        } catch (Error e) {
            error ("%s", e.message);
        }
    }

    private string generate_Json_String () {
        Json.Builder builder = new Json.Builder ();

        builder.begin_object ();
        builder.set_member_name ("namarupaIndicators");
        builder.begin_array ();
        foreach (string s in this.namarupaNames) {
            builder.add_string_value (s);
        }
        builder.end_array ();

        /*builder.set_member_name ("defaultIndicatorsPlace");
        builder.add_boolean_value (true);
        builder.end_object ();*/

        builder.set_member_name ("showEmptyNamarupaIndicator");
        builder.add_boolean_value (true);
        builder.end_object ();


        Json.Generator generator = new Json.Generator ();
        Json.Node root = builder.get_root ();
        generator.set_root (root);

        string str = generator.to_data (null);

        return str;
    }

    private void write_Indicator_Names (File file) {
        Json.Builder builder = new Json.Builder ();

        builder.begin_object ();
        builder.set_member_name ("allIndicators");
        builder.begin_array ();
        foreach (string s in allIndicators) {
            builder.add_string_value (s);
        }
        builder.end_array ();
        builder.end_object ();
        Json.Generator generator = new Json.Generator ();
        Json.Node root = builder.get_root ();
        generator.set_root (root);

        string str = generator.to_data (null);
        write_file(file, str);
    }  
    private void read_Indicator_Names (File file) {
        string jsonString = read_file (file);

        Json.Parser parser = new Json.Parser ();
        parser.load_from_data (jsonString, -1);
        Json.Node root = parser.get_root ();

        Json.Array indicator_list = root.get_object ().get_array_member ("allIndicators");
        int i = 0;
        foreach (var node in indicator_list.get_elements ()){
            //print("IND: " + node.get_string () + "\n");
            this.allIndicators.add(node.get_string ());
            i++;
        }
        print("Indicator names loaded: " + i.to_string() + "\n");
    }

    private void get_Settings_from_Json_string (string jsonString) {
        Json.Parser parser = new Json.Parser ();
        parser.load_from_data (jsonString, -1);
        Json.Node root = parser.get_root ();

        Json.Array nama_indicator_list = root.get_object ().get_array_member ("namarupaIndicators");
        foreach (var node in nama_indicator_list.get_elements ()){
            //print("IND: " + node.get_string () + "\n");
            this.namarupaNames.add(node.get_string ());
        }
        showEmptyNamarupaIndicator = root.get_object ().get_boolean_member ("showEmptyNamarupaIndicator");
        
    }


}
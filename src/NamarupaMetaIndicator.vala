/*-
 * Copyright (c) 2015 Wingpanel Developers (http://launchpad.net/wingpanel)
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

 public class AyatanaCompatibility.NamarupaMetaIndicator : Wingpanel.Indicator {
    private Gee.HashSet<string> blacklist;
    Gee.HashSet<string> namarupaNames;

    private IndicatorFactory indicator_loader;
    private Gtk.Box box;
    private Gtk.Label label;
    private Gtk.Stack stack;
    private Gtk.Box? main_box = null;

    Gee.Collection<AyatanaCompatibility.IndicatorIface> indicators;

	public int cpt = 0; /* count indicators */
	
    public NamarupaMetaIndicator (Gee.Collection<AyatanaCompatibility.IndicatorIface> indicators, Gee.HashSet<string> blacklist, Gee.HashSet<string> namarupaNames) {
        Object (code_name: "namarupa");

        this.namarupaNames = namarupaNames;
        this.blacklist = blacklist;
        indicator_loader = new IndicatorFactory ();

        visible = true;
        this.indicators = indicators;//indicator_loader.get_indicators ();

        foreach (var indicator in indicators) {
            load_indicator (indicator);
        }
        
    }

    public override Gtk.Widget get_display_widget () {
        return new Gtk.Image.from_icon_name ("view-more-horizontal-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
    }

    private void load_indicator (IndicatorIface indicator) {
        var entries = indicator.get_entries();

        foreach (var entry in entries) {
            print("Loading Indicator to Namarupa menu");
            create_entry (entry);
        }

        indicator.entry_added.connect (create_entry);
        indicator.entry_removed.connect (delete_entry);
    }

    private void create_entry (Indicator indicator) {

        if (blacklist.contains (indicator.name_hint ()) || ! namarupaNames.contains (indicator.name_hint ())) {
            return;
        }
		    if (main_box == null) {
		        init_main_box ();
		    }
		cpt++;
        
        //get_widget ();
        indicator.setIsNamarupa(true);
        Gtk.Widget indi = indicator.get_display_widget();
        box.add (indi);
        box.show_all ();
        
        switch_stack (true);
    }

    private void delete_entry (Indicator indicator) {
        //get_widget ();

        foreach (var fbc in box.get_children ()) {
            var child = (Gtk.Widget)fbc;
			//see what append when two indicators have the same name ? 
            if (child is Indicator && ((Indicator)child).code_name == indicator.code_name) {
                child.destroy ();
                cpt--;
				if (cpt == 0) {
				    switch_stack (false);
				}  
                break;
            }
        }
    }

	  private Gtk.Box init_main_box () {
		/*create an empty box with no entry */
        
            main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            main_box.set_size_request (200, -1);

            label = new Gtk.Label ("No tray icons…");
            label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            label.sensitive = false;
            label.valign = Gtk.Align.CENTER;
            label.margin_top = label.margin_bottom = 2;
            label.margin_start = label.margin_end = 6;
            label.show_all ();

            box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
		  	box.margin = 6;
            box.margin_start = 12;
            box.set_spacing (10);
			
            stack = new Gtk.Stack ();
            stack.hexpand = true;
            stack.add_named (box, "box");
            stack.add_named (label, "label");
            stack.get_style_context ().add_class (Gtk.STYLE_CLASS_SIDEBAR);
            main_box.add (stack);

            switch_stack (false); /* label */

            var settings_btn = new Gtk.ModelButton ();
            settings_btn.text = _("Settings…");
            settings_btn.clicked.connect (show_settings);

            main_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            main_box.add (settings_btn);
        

        return main_box;
	}

    public override Gtk.Widget? get_widget () {
		if (main_box == null) {
		    init_main_box ();
		}
		return main_box;
    }

    private void switch_stack (bool show) {
		//switch between label "no tray icon" and box vue
        if (show) {
            stack.set_visible_child_name ("box");
        } else {
            stack.set_visible_child_name ("label");
        }
    }

    public override void opened () {
    }

    public override void closed () {
    }


    private string[] get_restrictions_from_file (File file) {
        var restrictions = new string[] {};

        if (file.query_exists ()) {
            try {
                var dis = new DataInputStream (file.read ());
                string? line = null;

                while ((line = dis.read_line ()) != null) {
                    if (line.strip () != "") {
                        restrictions += line;
                    }
                }
            } catch (Error error) {
                warning ("Unable to load restrictions file %s: %s\n", file.get_basename (), error.message);
            }
        }

        return restrictions;
    }

    // TODO: Plug for Namarupa.  
    private void show_settings () {
		/* temporary used for informations */
		string msg = cpt.to_string () + " item(s)\n";
		/*var msgdial = new Gtk.MessageDialog (null,
		                                     Gtk.DialogFlags.DESTROY_WITH_PARENT,
                                                   Gtk.MessageType.INFO,
                                                   Gtk.ButtonsType.CLOSE,
                                                   msg);
		msgdial.set_title (_("Information"));
		msgdial.run ();
		msgdial.destroy (); // dialog without parent => not perfectly closed */

        /*try {
            AppInfo.launch_default_for_uri ("settings://namarupa", null);
        } catch (Error e) {
            warning ("Failed to open notifications settings: %s", e.message);
        } */
    }

}

/*public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION)
        return null;

    debug ("Activating AyatanaCompatibility Namarupa Indicator");
    var indicator = new AyatanaCompatibility.NamarupaMetaIndicator ();
    return indicator;
}
*/
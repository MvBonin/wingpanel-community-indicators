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

 public class AyatanaCompatibility.IndicatorButton : Gtk.EventBox {
    public enum WidgetSlot {
        LABEL,
        IMAGE
    }

    private Gtk.Widget the_label;
    private Gtk.Widget the_image;
    private Gtk.Box box;
    private string name_h;

    construct {
        box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.set_homogeneous (true);
        add (box);
    }

    public void set_widget (WidgetSlot slot, Gtk.Widget widget, string name_hint) {
        Gtk.Widget old_widget = null;
        this.name_h = name_hint;
        if (slot == WidgetSlot.LABEL) {
            old_widget = the_label;
        } else if (slot == WidgetSlot.IMAGE) {
            old_widget = the_image;
        }

        if (old_widget != null) {
            box.remove (old_widget);
        }

        // Workaround for buggy indicators: Some widgets may still be part of a previous entry
        // if their old parent hasn't been removed from the panel yet.
        var parent = widget.parent;
        if (parent != null) {
            parent.remove (widget);
        }

        if (slot == WidgetSlot.LABEL) {
            the_label = widget;
            box.pack_end (the_label, false, false, 0);
        } else if (slot == WidgetSlot.IMAGE) {
            the_image = widget;
            box.pack_start (the_image, false, false, 0);
        }
    }

    public string name_hint (){
        return this.name_h;
    }
}


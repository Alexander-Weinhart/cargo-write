/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2017-2024 Lains
 *                          2025 Stella & Charlie (teamcons.carrd.co)
 *                          2025 Contributions from the ellie_Commons community (github.com/elly-commons/)
 *                          2026 Alexander Weinhart
 */

/**
* We use Granite.Bin to subclass ActionBar.
* Everything is kept there but most widgets are public
*/
 public class CargoWrite.ActionBar : Granite.Bin {

    public Gtk.ActionBar actionbar;
    public Gtk.Button list_button;
    public Gtk.MenuButton emoji_button;
    public Gtk.EmojiChooser emojichooser_popover;
    public Gtk.MenuButton menu_button;
    public Gtk.WindowHandle handle;
    construct {

        /* **** LEFT **** */
        var new_item = new Gtk.Button () {
            icon_name = "list-add-symbolic",
            width_request = 32,
            height_request = 32,
            tooltip_markup = Granite.markup_accel_tooltip (
                {"<Control>n"},
                _("New sticky note")
            )
        };
        new_item.action_name = Application.ACTION_PREFIX + Application.ACTION_NEW;
        new_item.add_css_class ("themedbutton");
        new_item.add_css_class ("action-new");

        var delete_item = new Gtk.Button () {
            icon_name = "user-trash-symbolic",
            width_request = 32,
            height_request = 32,
            tooltip_markup = Granite.markup_accel_tooltip (
                {"<Control>w"},
                _("Delete sticky note")
            )
        };
        delete_item.add_css_class ("themedbutton");
        delete_item.add_css_class ("action-delete");
        delete_item.action_name = StickyNoteWindow.ACTION_PREFIX + StickyNoteWindow.ACTION_DELETE;

        /* **** RIGHT **** */
        list_button = new Gtk.Button () {
            icon_name = "view-list-symbolic",
            width_request = 32,
            height_request = 32,
            tooltip_markup = Granite.markup_accel_tooltip (
                {"<Shift>F12"},
                _("Toggle list")
            )
        };
        list_button.add_css_class ("themedbutton");
        list_button.add_css_class ("action-list");
        list_button.action_name = StickyNoteWindow.ACTION_PREFIX + StickyNoteWindow.ACTION_TOGGLE_LIST;

        emojichooser_popover = new Gtk.EmojiChooser ();

        emoji_button = new Gtk.MenuButton () {
            width_request = 32,
            height_request = 32,
            icon_name = CargoWrite.Constants.EMOJI_BUTTON_ICON,
            always_show_arrow = false,
            tooltip_markup = Granite.markup_accel_tooltip (
                {"<Control>period"},
                _("Insert emoji")
            )
        };
        emoji_button.add_css_class ("themedbutton");
        emoji_button.add_css_class ("action-emoji");
        emoji_button.popover = emojichooser_popover;

        menu_button = new Gtk.MenuButton () {
            width_request = 32,
            height_request = 32,
            icon_name = "emblem-system-symbolic",
            always_show_arrow = false,
            tooltip_markup = Granite.markup_accel_tooltip (
                {"<Control>g", "<Control>o"},
                _("Preferences for this sticky note")
            )
        };
        menu_button.direction = Gtk.ArrowType.UP;
        menu_button.add_css_class ("themedbutton");
        menu_button.add_css_class ("action-menu");

        /* **** Widget **** */
        actionbar = new Gtk.ActionBar () {
            hexpand = true
        };
        actionbar.revealed = false;
        actionbar.pack_start (new_item);
        actionbar.pack_start (delete_item);
        actionbar.pack_end (menu_button);
        actionbar.pack_end (emoji_button);
        actionbar.pack_end (list_button);

        handle = new Gtk.WindowHandle () {
            child = actionbar
        };

        child = handle;

        // Hide the list button if user has specified no list item symbol
        on_prefix_changed ();
        Application.gsettings.changed["list-item-start"].connect (on_prefix_changed);

    }

    /**
    * Allow control of when to respect the hide-bar setting
    * StickyNoteWindow will decide itself whether to show immediately or not
    */
    public void reveal_bind () {
        Application.gsettings.bind ("hide-bar", this.actionbar, "revealed", SettingsBindFlags.INVERT_BOOLEAN);
    }

    private void on_prefix_changed () {
        list_button.visible = (Application.gsettings.get_string ("list-item-start") != "");
    }
}

/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2017-2024 Lains
 *                          2025 Stella & Charlie (teamcons.carrd.co)
 *                          2025 Contributions from the ellie_Commons community (github.com/elly-commons/)
 *                          2026 Alexander Weinhart
 */


/* CONTENT

Preferences is boring
Everything is in a Handle so user can move the window from anywhere
It is a box, with inside of it a box and an actionbar

the innerbox has widgets for settings.
the actionbar has a donate button and a reset-to-default vibe

*/
public class CargoWrite.PreferenceWindow : Gtk.Window {

    public PreferenceWindow (CargoWrite.Application app) {
        debug ("[PREFWINDOW] Creating preference window");
        Intl.setlocale ();

        application = app;


        /********************************************/
        /*              HEADERBAR BS                */
        /********************************************/

        /// TRANSLATORS: Feel free to improvise. The goal is a playful wording to convey the idea of app-wide settings
        var titlelabel = new Gtk.Label (_("Preferences for Cargo Write"));
        titlelabel.add_css_class (Granite.STYLE_CLASS_TITLE_LABEL);
        set_title (_("Preferences") + _(" - Cargo Write"));

        var headerbar = new Gtk.HeaderBar () {
            title_widget = titlelabel,
            show_title_buttons = false
        };
        headerbar.add_css_class (Granite.STYLE_CLASS_FLAT);

        set_titlebar (headerbar);
        set_size_request (CargoWrite.Constants.DEFAULT_PREF_WIDTH, CargoWrite.Constants.DEFAULT_PREF_HEIGHT);
        set_default_size (CargoWrite.Constants.DEFAULT_PREF_WIDTH, CargoWrite.Constants.DEFAULT_PREF_HEIGHT);
        resizable = false;

        var prefview = new CargoWrite.PreferencesView ();

        // Make the whole window grabbable
        var handle = new Gtk.WindowHandle () {
            child = prefview
        };

        this.child = handle;

        set_focus (prefview.close_button);

        this.notify["is-active"].connect (() => {
            if (this.is_active) {
                Application.apply_elementary_theme (CargoWrite.Constants.DEFAULT_THEME);
            }
        });

        //prefview.reset_button.clicked.connect (on_reset);
        prefview.close_button.clicked.connect (() => {close ();});
    }
}

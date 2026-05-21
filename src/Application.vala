/*
* Copyright (c) 2017-2024 Lains
* Copyright (c) 2025 Stella, Charlie, (teamcons on GitHub) and the Ellie_Commons community
* Copyright (c) 2026 Alexander Weinhart
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/


/*
Application creates a NoteManager, which is the OG thing that does the heavy lifting.
NoteManager retrieves a list of NoteData from the Stash
Then it untangles it and creates a list of windows it can keep track of.

When a note get deleted, the window signals to the manager to remove it from the list
When a new note is requested, the manager creates a new window and adds it
When saving is requested, the manager goes though the whole list requesting every window to package itself, then slams all onto disk.

The Preferences window is supposed to be a static window.

NoteData is a convenience object to pass around sticky notes
Stash deals with writing/loading from the disk
Themer spits the different themes upon startup
Utils spits all the random
Jason deals with all the hassle in between all saving/loading steps
Constants is because i am lazy
*/

public class CargoWrite.Application : Gtk.Application {

    // Needed by all windows
    public static GLib.Settings gsettings;
    public static Gtk.Settings gtk_settings;

    public CargoWrite.NoteManager manager;
    public static CargoWrite.PreferenceWindow? preferences;

    // Used for commandline option handling
    public static bool new_note = false;
    public static bool show_pref = false;

    public const string ACTION_PREFIX = "app.";
    public const string ACTION_QUIT = "action_quit";
    public const string ACTION_NEW = "action_new";
    public const string ACTION_TOGGLE_SCRIBBLY = "action_toggle_scribbly";
    public const string ACTION_TOGGLE_ACTIONBAR = "action_toggle_actionbar";
    public const string ACTION_SHOW_PREFERENCES = "action_show_preferences";
    public const string ACTION_SAVE = "action_save";

    public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();
    private static Gtk.CssProvider elementary_theme_provider;
    private static CargoWrite.Themes current_elementary_theme = CargoWrite.Constants.DEFAULT_THEME;

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_QUIT, quit},
        { ACTION_NEW, action_new },
        { ACTION_TOGGLE_SCRIBBLY, action_toggle_scribbly},
        { ACTION_TOGGLE_ACTIONBAR, action_toggle_actionbar},
        { ACTION_SHOW_PREFERENCES, action_show_preferences},
        { ACTION_SAVE, action_save},
    };

    public Application () {
        Object (flags: ApplicationFlags.HANDLES_COMMAND_LINE,
                application_id: CargoWrite.Constants.RDNN);
    }

    /*************************************************/
    public override void startup () {
        debug ("Cargo Write startup...");
        print ("[CARGO_WRITE] startup begin\n");
        base.startup ();
        Gtk.init ();
        Granite.init ();
        Gtk.IconTheme.get_for_display (Gdk.Display.get_default ()).add_resource_path ("/io/github/cargowrite/CargoWrite/icons");

        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.action_quit", {"<Control>Q"});
        set_accels_for_action ("app.action_new", {"<Control>N"});
        set_accels_for_action ("app.action_save", {"<Control>S"});
        set_accels_for_action ("app.action_toggle_actionbar", {"<Control>T"});
        set_accels_for_action ("app.action_show_preferences", {"<Control>P"});
        set_accels_for_action ("app.action_toggle_scribbly", {"<Control>H"});

        set_accels_for_action ("win.action_delete", {"<Control>W"});
        set_accels_for_action ("win.action_zoom_out", {"<Control>minus", "<Control>KP_Subtract"});
        set_accels_for_action ("win.action_zoom_default", {"<Control>equal", "<Control>0", "<Control>KP_0"});
        set_accels_for_action ("win.action_zoom_in", {"<Control>plus", "<Control>KP_Add"});
        set_accels_for_action ("win.action_toggle_mono", {"<Control>m"});
        set_accels_for_action ("win.action_focus_title", {"<Control>L"});
        set_accels_for_action ("win.action_show_emoji", {"<Control>period"});
        set_accels_for_action ("win.action_toggle_list", {"<Shift>F12"});
        set_accels_for_action ("win.action_show_menu", {"<Control>G", "<Control>O"});

        set_accels_for_action ("textview.action_toggle_list", {"<Shift>F12"});



        var granite_settings = Granite.Settings.get_default ();
        gtk_settings = Gtk.Settings.get_default ();

        // Also follow dark if system is dark lIke mY sOul.
        gtk_settings.gtk_application_prefer_dark_theme = (
	            granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
            );
	
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = (
                    granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
                );
            apply_elementary_theme (current_elementary_theme);
        });

        print ("Cargo Write is starting up...\n");

        /* Quit if all sticky notes are closed and preferences arent shown */
        window_removed.connect (check_if_quit);


        // build all the stylesheets
        var app_provider = new Gtk.CssProvider ();
        app_provider.load_from_resource ("/io/github/cargowrite/CargoWrite/Application.css");
        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            app_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 1
        );

        var theme_provider = new Gtk.CssProvider ();
        theme_provider.load_from_resource ("/io/github/cargowrite/CargoWrite/Themes.css");
        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            theme_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 1
        );

        elementary_theme_provider = new Gtk.CssProvider ();
        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            elementary_theme_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_THEME + 1
        );
        apply_elementary_theme (CargoWrite.Constants.DEFAULT_THEME);
        print ("[CARGO_WRITE] startup complete\n");
    }

    /*************************************************/        
    static construct {
        gsettings = new GLib.Settings (CargoWrite.Constants.RDNN);
    }

    /*************************************************/
    construct {
        // The localization thingamabob
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);
        
        //add_main_option_entries (CMD_OPTION_ENTRIES);
        manager = new CargoWrite.NoteManager (this);
    }

    // Clicked: Either show all windows, or rebuild from storage
    protected override void activate () {
        debug ("[CARGO_WRITE] activate");
        print ("[CARGO_WRITE] activate begin\n");

        // Test Lang
        //GLib.Environment.set_variable ("LANGUAGE", "pt_br", true);

        /* Either we show all sticky notes, or we load everything lol */
        if (manager.open_notes.size > 0) {
            foreach (var window in manager.open_notes) {
                if (window.visible) {window.present ();}
            }
        } else {
            manager.init ();
        }

        if (new_note) {manager.create_note (); new_note = false;}
        if (show_pref) {action_show_preferences (); show_pref = false;}
        print ("[CARGO_WRITE] activate complete windows=%u\n", get_windows ().length ());
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }

    public static void apply_elementary_theme (CargoWrite.Themes theme) {
        var resource_path = get_elementary_theme_resource (theme);
        current_elementary_theme = theme == CargoWrite.Themes.IDK ? CargoWrite.Constants.DEFAULT_THEME : theme;
        debug ("Loading vendored elementary theme %s".printf (resource_path));
        elementary_theme_provider.load_from_resource (resource_path);
    }

    private static string get_elementary_theme_resource (CargoWrite.Themes theme) {
        var resolved_theme = theme == CargoWrite.Themes.IDK ? CargoWrite.Constants.DEFAULT_THEME : theme;
        var suffix = gtk_settings.gtk_application_prefer_dark_theme ? "-dark" : "";
        return "/io/github/cargowrite/CargoWrite/elementary/%s%s.css".printf (
            resolved_theme.to_string ().ascii_down (),
            suffix
        );
    }

    private void action_new () {
        debug ("New Note");
        manager.create_note ();
    }

    private void action_show_preferences () {
        debug ("Showing preferences!");

        if (Application.preferences == null) {
            Application.preferences = new CargoWrite.PreferenceWindow (this);
            Application.preferences.close_request.connect_after (() => {Application.preferences = null; return false;});
        }

        preferences.show ();
        preferences.present ();
    }

    private void action_toggle_scribbly () {
        debug ("Toggling scribbly");
        var current = Application.gsettings.get_boolean ("scribbly-mode-active");
        gsettings.set_boolean ("scribbly-mode-active", !current);
    }

    private void action_toggle_actionbar () {
        debug ("Toggling actionbar");
        var current = Application.gsettings.get_boolean ("hide-bar");
        gsettings.set_boolean ("hide-bar", !current);
    }

    private void action_save () {
        debug ("Saving...");
        manager.save_all ();
    }

    // checked upon window closing to make sure we do not linger in the background
    public void check_if_quit () {
        debug ("Windows open: %s".printf (get_windows ().length ().to_string ()));

        if (get_windows ().length () == 0) {
            debug ("No sticky note open, quitting");
            quit ();
        }
    }

    public override int command_line (ApplicationCommandLine command_line) {
        debug ("Parsing commandline arguments...");
        print ("[CARGO_WRITE] command_line begin\n");

        OptionEntry[] CMD_OPTION_ENTRIES = {
                {"new-note", 'n', OptionFlags.NONE, OptionArg.NONE, ref new_note, _("Create a new note"), null},
                {"preferences", 'p', OptionFlags.NONE, OptionArg.NONE, ref show_pref, _("Show preferences"), null}
        };

        // We have to make an extra copy of the array, since .parse assumes
        // that it can remove strings from the array without freeing them.
        string[] args = command_line.get_arguments ();
        string[] _args = new string[args.length];
        for (int i = 0; i < args.length; i++) {
            _args[i] = args[i];
        }

        try {
            var ctx = new OptionContext ();
            ctx.set_help_enabled (true);
            ctx.add_main_entries (CMD_OPTION_ENTRIES, null);
            unowned string[] tmp = _args;
            ctx.parse (ref tmp);

        } catch (OptionError e) {
            command_line.print ("error: %s\n", e.message);
            return 0;
        }

        hold ();
        print ("[CARGO_WRITE] command_line parsed new_note=%s show_pref=%s\n", new_note.to_string (), show_pref.to_string ());
        activate ();
        print ("[CARGO_WRITE] command_line end\n");
        return 0;
    }
}

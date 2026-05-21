/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2017-2024 Lains
 *                          2025 Stella & Charlie (teamcons.carrd.co)
 *                          2025 Contributions from the ellie_Commons community (github.com/ellie-commons/)
 *                          2026 Alexander Weinhart
 */


/*************************************************/
/**
* An object used to package all data conveniently as needed.
*/
public class CargoWrite.NoteData : Object {

    // Will determine properties (or lack thereof) for any new note
    public static CargoWrite.Themes latest_theme = CargoWrite.Constants.DEFAULT_THEME;
    public static int latest_zoom = CargoWrite.Constants.DEFAULT_ZOOM;
    public static bool latest_mono = CargoWrite.Constants.DEFAULT_MONO;

    public string? title;
    public CargoWrite.Themes? theme;
    public string? content;
    public bool? monospace;
    public int? zoom;
    public int? width;
    public int? height;

    /*************************************************/
    /**
    * Convert into a Json.Object()
    */
    construct {
        // We assign defaults in case theres args missing
        this.title = title ?? CargoWrite.Utils.random_title ();
        this.theme = theme ?? CargoWrite.Themes.random_theme (latest_theme);
        this.content = content ?? "";
        this.monospace = monospace ?? latest_mono;
        this.zoom = zoom ?? latest_zoom;
        this.width = width ?? CargoWrite.Constants.DEFAULT_WIDTH;
        this.height = height ?? CargoWrite.Constants.DEFAULT_HEIGHT;
    }

    /*************************************************/
    /**
    * Parse a node to create an associated NoteData object
    */
    public NoteData.from_json (Json.Object node) {
        title       = node.get_string_member_with_default ("title", (_("Forgot title!")));
        theme       = (CargoWrite.Themes)node.get_int_member_with_default ("color", CargoWrite.Themes.random_theme ());
        content     = node.get_string_member_with_default ("content","");
        monospace   = node.get_boolean_member_with_default ("monospace", CargoWrite.Constants.DEFAULT_MONO);
        zoom        = (int)node.get_int_member_with_default ("zoom", CargoWrite.Constants.DEFAULT_ZOOM);

        // Make sure the values are nothing crazy
        if (zoom < CargoWrite.Constants.ZOOM_MIN)        { zoom = CargoWrite.Constants.ZOOM_MIN;}
        else if (zoom > CargoWrite.Constants.ZOOM_MAX)   { zoom = CargoWrite.Constants.ZOOM_MAX;}

        width       = (int)node.get_int_member_with_default ("width", CargoWrite.Constants.DEFAULT_WIDTH);
        height      = (int)node.get_int_member_with_default ("height", CargoWrite.Constants.DEFAULT_HEIGHT);
    }

    /*************************************************/
    /**
    * Used for storing NoteData inside disk storage
    */
    public Json.Object to_json () {
        var builder = new Json.Builder ();

		// Lets fkin gooo
        builder.begin_object ();
        builder.set_member_name ("title");
        builder.add_string_value (title);
        builder.set_member_name ("color");
        builder.add_int_value (theme);
        builder.set_member_name ("content");
        builder.add_string_value (content);
        builder.set_member_name ("monospace");
        builder.add_boolean_value (monospace);
		builder.set_member_name ("zoom");
        builder.add_int_value (zoom);
        builder.set_member_name ("width");
        builder.add_int_value (width);
        builder.set_member_name ("height");
        builder.add_int_value (height);
        builder.end_object ();

        return builder.get_root ().get_object ();
    }
}

using Gtk;

class MainWindow : Window
{
    private const int WINDOW_WIDTH = 400;
    private const int WINDOW_HEIGHT = 500;

    private UIManager ui_manager = new UIManager();
    private Entry search_entry;
    private VBox vbox_right;
    private CustomVBox custom_vbox;
    private VBox services_internal_vbox;

    private Entry username_entry;
    private Entry password_entry;

    private ListStore listmodel;
    private TreeModelFilter filter;

    public IdentitiesManager identities_manager;

    private MoonshotServer ipc_server;

    private IdCard default_id_card;
    private Queue<IdentityRequest> request_queue;

    private enum Columns
    {
        IDCARD_COL,
        LOGO_COL,
        ISSUER_COL,
        USERNAME_COL,
        PASSWORD_COL,
        N_COLUMNS
    }

    private const string layout =
"
<menubar name='MenuBar'>
        <menu name='FileMenu' action='FileMenuAction'>
            <menuitem name='AddIdCard' action='AddIdCardAction' />
            <separator />
            <menuitem name='Quit' action='QuitAction' />
        </menu>

        <menu name='HelpMenu' action='HelpMenuAction'>
             <menuitem name='About' action='AboutAction' />
        </menu>
</menubar>
";

    public MainWindow()
    {
        request_queue = new Queue<IdentityRequest>();

        this.title = "Moonshoot";
        this.set_position (WindowPosition.CENTER);
        set_default_size (WINDOW_WIDTH, WINDOW_HEIGHT);

        build_ui();
        setup_identities_list();
        load_id_cards();
        connect_signals();
        init_ipc_server();
    }

    private bool visible_func (TreeModel model, TreeIter iter)
    {
        string issuer;
        string search_text;
        string issuer_casefold;
        string search_text_casefold;

        model.get (iter,
                   Columns.ISSUER_COL, out issuer);
        search_text = this.search_entry.get_text ();

        if (issuer == null || search_text == null)
            return false;

        issuer_casefold = issuer.casefold ();
        search_text_casefold = search_text.casefold ();

        if (issuer_casefold.contains (search_text_casefold))
            return true;

        return false;
    }

    private void setup_identities_list ()
    {
       this.listmodel = new ListStore (Columns.N_COLUMNS, typeof (IdCard),
                                                          typeof (Gdk.Pixbuf),
                                                          typeof (string),
                                                          typeof (string),
                                                          typeof (string));
      this.filter = new TreeModelFilter (listmodel, null);

      filter.set_visible_func (visible_func);
    }

    private void search_entry_icon_press_cb (EntryIconPosition pos, Gdk.Event event)
    {
	if (pos == EntryIconPosition.PRIMARY)
        {
            print ("Search entry icon pressed\n");
        }
        else
        {
            this.search_entry.set_text ("");
        }
    }

    private void search_entry_text_changed_cb ()
    {
        this.filter.refilter ();
        redraw_id_card_widgets ();

        var has_text = this.search_entry.get_text_length () > 0;
        this.search_entry.set_icon_sensitive (EntryIconPosition.PRIMARY, has_text);
        this.search_entry.set_icon_sensitive (EntryIconPosition.SECONDARY, has_text);

        this.vbox_right.set_visible (false);
        this.resize (WINDOW_WIDTH, WINDOW_HEIGHT);
    }

    private bool search_entry_key_press_event_cb (Gdk.EventKey e)
    {
        if(Gdk.keyval_name(e.keyval) == "Escape")
           this.search_entry.set_text("");

        // Continue processing this event, since the
        // text entry functionality needs to see it too.
        return false;
    }

    private void load_id_cards ()
    {
        this.identities_manager = new IdentitiesManager ();

        foreach (IdCard id_card in identities_manager.id_card_list)
        {
            add_id_card_data (id_card);
            add_id_card_widget (id_card);
        }

        this.default_id_card = identities_manager.id_card_list.data;
    }

    private void fill_details (IdCardWidget id_card_widget)
    {
       var id_card = id_card_widget.id_card;
       this.username_entry.set_text (id_card.username);
       this.password_entry.set_text (id_card.password ?? "");

       var children = this.services_internal_vbox.get_children ();
       foreach (var hbox in children)
           hbox.destroy();
       fill_services_vbox (id_card_widget.id_card);
    }

    private void show_details (IdCard id_card)
    {
       this.vbox_right.set_visible (!vbox_right.get_visible ());

       if (this.vbox_right.get_visible () == false)
       {
           this.resize (WINDOW_WIDTH, WINDOW_HEIGHT);
       }
    }

    private void details_identity_cb (IdCardWidget id_card_widget)
    {
       fill_details (id_card_widget);
       show_details (id_card_widget.id_card);
    }

    private IdCard get_id_card_data (AddIdentityDialog dialog)
    {
        var id_card = new IdCard ();

        id_card.issuer = dialog.issuer;
        if (id_card.issuer == "")
            id_card.issuer = "Issuer";
        id_card.username = dialog.username;
        id_card.password = dialog.password;
        id_card.pixbuf = find_icon ("avatar-default", 48);
        id_card.services = {};

        return id_card;
    }

    private void add_id_card_data (IdCard id_card)
    {
        TreeIter iter;

        this.listmodel.append (out iter);
        listmodel.set (iter,
                       Columns.IDCARD_COL, id_card,
                       Columns.LOGO_COL, id_card.pixbuf,
                       Columns.ISSUER_COL, id_card.issuer,
                       Columns.USERNAME_COL, id_card.username,
                       Columns.PASSWORD_COL, id_card.password);
    }

    private void remove_id_card_data (IdCard id_card)
    {
        TreeIter iter;
        string issuer;

        if (listmodel.get_iter_first (out iter))
        {
            do
            {
                listmodel.get (iter,
                               Columns.ISSUER_COL, out issuer);

                if (id_card.issuer == issuer)
                {
                    listmodel.remove (iter);
                    break;
                }
            }
            while (listmodel.iter_next (ref iter));
        }
    }

    private void add_id_card_widget (IdCard id_card)
    {
        var id_card_widget = new IdCardWidget (id_card);

        this.custom_vbox.add_id_card_widget (id_card_widget);

        id_card_widget.details_id.connect (details_identity_cb);
        id_card_widget.remove_id.connect (remove_identity_cb);
        id_card_widget.send_id.connect ((w) => send_identity_cb (w.id_card));
        id_card_widget.expanded.connect (this.custom_vbox.receive_expanded_event);
        id_card_widget.expanded.connect (fill_details);
    }

    private void add_identity (AddIdentityDialog dialog)
    {
        insert_id_card (get_id_card_data (dialog));
    }
    
    public void insert_id_card (IdCard id_card)
    {    
        this.identities_manager.id_card_list.prepend (id_card);
        this.identities_manager.store_id_cards ();

        add_id_card_data (id_card);
        add_id_card_widget (id_card);
    }

    private void add_identity_cb ()
    {
        var dialog = new AddIdentityDialog ();
        var result = dialog.run ();

        switch (result) {
        case ResponseType.OK:
            add_identity (dialog);
            break;
        default:
            break;
        }
        dialog.destroy ();
    }

    private void remove_id_card_widget (IdCardWidget id_card_widget)
    {
        remove_id_card_data (id_card_widget.id_card);

        this.custom_vbox.remove_id_card_widget (id_card_widget);
    }

    private void remove_identity (IdCardWidget id_card_widget)
    {
        var id_card = id_card_widget.id_card;

        this.identities_manager.id_card_list.remove (id_card);
        this.identities_manager.store_id_cards ();

        remove_id_card_widget (id_card_widget);
    }

    private void redraw_id_card_widgets ()
    {
        TreeIter iter;
        IdCard id_card;

        var children = this.custom_vbox.get_children ();
        foreach (var id_card_widget in children)
            id_card_widget.destroy();

        if (filter.get_iter_first (out iter))
        {
            do
            {
                filter.get (iter,
                            Columns.IDCARD_COL, out id_card);

                add_id_card_widget (id_card);
            }
            while (filter.iter_next (ref iter));
        }
    }

    private void remove_identity_cb (IdCardWidget id_card_widget)
    {
        var id_card = id_card_widget.id_card;

        var dialog = new MessageDialog (null,
                                        DialogFlags.DESTROY_WITH_PARENT,
                                        MessageType.INFO,
                                        Gtk.ButtonsType.YES_NO,
                                        _("Are you sure you want to delete %s ID Card?"), id_card.issuer);
        var result = dialog.run ();
        switch (result) {
        case ResponseType.YES:
            remove_identity (id_card_widget);
            break;
        default:
            break;
        }
        dialog.destroy ();
    }

    public void select_identity (IdentityRequest request)
    {
        IdCard identity = null;

        this.request_queue.push_tail (request);

        if (request.select_default)
        {
            identity = this.default_id_card;
        }

        /* Automatic service matching rules can go here */

        if (identity == null)
        {
            // Resort to manual selection
            this.show ();
        }
        else
        {
            // Send back the identity (we can't directly run the
            // callback because we may be being called from a 'yield')
            Idle.add (() => { send_identity_cb (identity); return false; });
            return;
        }
    }

    public void send_identity_cb (IdCard identity)
    {
        return_if_fail (request_queue.length > 0);

        var request = this.request_queue.pop_head ();
        bool reset_password = false;

        if (identity.password == null)
        {
            var dialog = new AddPasswordDialog ();
            var result = dialog.run ();

            switch (result) {
            case ResponseType.OK:
                identity.password = dialog.password;
                reset_password = ! dialog.remember;
                break;
            default:
                identity = null;
                break;
            }

            dialog.destroy ();
        }

        if (this.request_queue.is_empty())
            this.hide ();

        if (identity != null)
            this.default_id_card = identity;

        request.return_identity (identity);

        if (reset_password)
            identity.password = null;
    }

    private void label_make_bold (Label label)
    {
        var font_desc = new Pango.FontDescription ();

        font_desc.set_weight (Pango.Weight.BOLD);

        /* This will only affect the weight of the font, the rest is
         * from the current state of the widget, which comes from the
         * theme or user prefs, since the font desc only has the
         * weight flag turned on.
         */
        label.modify_font (font_desc);
    }

    private void fill_services_vbox (IdCard id_card)
    {
        int i = 0;
        var n_columns = id_card.services.length;

        var services_table = new Table (n_columns, 2, false);
        services_table.set_col_spacings (10);
        services_table.set_row_spacings (10);
        this.services_internal_vbox.add (services_table);

        foreach (string service in id_card.services)
        {
            var label = new Label (service);
            label.set_alignment (0, (float) 0.5);
#if VALA_0_12
            var remove_button = new Button.from_stock (Stock.REMOVE);
#else
            var remove_button = new Button.from_stock (STOCK_REMOVE);
#endif
            services_table.attach_defaults (label, 0, 1, i, i+1);
            services_table.attach_defaults (remove_button, 1, 2, i, i+1);
            i++;
        }
        this.services_internal_vbox.show_all ();
    }

    private void on_about_action ()
    {
        string[] authors = {
            "Javier Jardón <jjardon@codethink.co.uk>",
            "Sam Thursfield <samthursfield@codethink.co.uk>",
            "Alberto Ruiz <alberto.ruiz@codethink.co.uk>",
            null
        };

        string copyright = "Copyright 2011 JANET";

        string license =
"""
Copyright (c) 2011, JANET(UK)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

3. Neither the name of JANET(UK) nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.
""";

        Gtk.show_about_dialog (this,
            "comments", _("Moonshot project UI"),
            "copyright", copyright,
            "website", "http://www.project-moonshot.org/",
            "license", license,
            "website-label", _("Visit the Moonshot project web site"),
            "authors", authors,
            "translator-credits", _("translator-credits"),
            null
        );
    }

    private Gtk.ActionEntry[] create_actions() {
        Gtk.ActionEntry[] actions = new Gtk.ActionEntry[0];

        Gtk.ActionEntry filemenu = { "FileMenuAction",
                                     null,
                                     N_("_File"),
                                     null, null, null };
        actions += filemenu;
        Gtk.ActionEntry add = { "AddIdCardAction",
#if VALA_0_12
                                Stock.ADD,
#else
                                STOCK_ADD,
#endif
                                N_("Add ID Card"),
                                null,
                                N_("Add a new ID Card"),
                                add_identity_cb };
        actions += add;
        Gtk.ActionEntry quit = { "QuitAction",
#if VALA_0_12
                                 Stock.QUIT,
#else
                                 STOCK_QUIT,
#endif
                                 N_("Quit"),
                                 "<control>Q",
                                 N_("Quit the application"),
                                 Gtk.main_quit };
        actions += quit;

        Gtk.ActionEntry helpmenu = { "HelpMenuAction",
                                     null,
                                     N_("_Help"),
                                     null, null, null };
        actions += helpmenu;
        Gtk.ActionEntry about = { "AboutAction",
#if VALA_0_12
                                  Stock.ABOUT,
#else
                                  STOCK_ABOUT,
#endif
                                  N_("About"),
                                  null,
                                  N_("About this application"),
                                  on_about_action };
        actions += about;

        return actions;
    }


    private void create_ui_manager ()
    {
        Gtk.ActionGroup action_group = new Gtk.ActionGroup ("GeneralActionGroup");
        action_group.add_actions (create_actions (), this);
        ui_manager.insert_action_group (action_group, 0);
        try
        {
            ui_manager.add_ui_from_string (layout, -1);
        }
        catch (Error e)
        {
            stderr.printf ("%s\n", e.message);
        }
        ui_manager.ensure_update ();
    }

    private void build_ui()
    {
        create_ui_manager ();

        this.search_entry = new Entry();

        set_atk_name_description (search_entry, _("Search entry"), _("Search for a specific ID Card"));
        this.search_entry.set_icon_from_pixbuf (EntryIconPosition.PRIMARY,
                                                find_icon_sized ("edit-find-symbolic", Gtk.IconSize.MENU));
        this.search_entry.set_icon_tooltip_text (EntryIconPosition.PRIMARY,
                                                 _("Search identity or service"));
        this.search_entry.set_icon_sensitive (EntryIconPosition.PRIMARY, false);

        this.search_entry.set_icon_from_pixbuf (EntryIconPosition.SECONDARY,
                                                find_icon_sized ("edit-clear-symbolic", Gtk.IconSize.MENU));
        this.search_entry.set_icon_tooltip_text (EntryIconPosition.SECONDARY,
                                                 _("Clear the current search"));
        this.search_entry.set_icon_sensitive (EntryIconPosition.SECONDARY, false);


        this.search_entry.icon_press.connect (search_entry_icon_press_cb);
        this.search_entry.notify["text"].connect (search_entry_text_changed_cb);
        this.search_entry.key_press_event.connect(search_entry_key_press_event_cb);

        this.custom_vbox = new CustomVBox (false, 6);

        var viewport = new Viewport (null, null);
        viewport.set_border_width (6);
        viewport.set_shadow_type (ShadowType.NONE);
        viewport.add (custom_vbox);
        var scroll = new ScrolledWindow (null, null);
        scroll.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
        scroll.set_shadow_type (ShadowType.IN);
        scroll.add_with_viewport (viewport);

        var vbox_left = new VBox (false, 0);
        vbox_left.pack_start (search_entry, false, false, 6);
        vbox_left.pack_start (scroll, true, true, 0);
        vbox_left.set_size_request (WINDOW_WIDTH, 0);

        var login_vbox_title = new Label (_("Login: "));
        label_make_bold (login_vbox_title);
        login_vbox_title.set_alignment (0, (float) 0.5);
        var username_label = new Label (_("Username:"));
        username_label.set_alignment (1, (float) 0.5);
        this.username_entry = new Entry ();
        var password_label = new Label (_("Password:"));
        password_label.set_alignment (1, (float) 0.5);
        this.password_entry = new Entry ();
        password_entry.set_invisible_char ('*');
        password_entry.set_visibility (false);
        var remember_checkbutton = new CheckButton.with_label (_("Remember password"));
        var login_table = new Table (3, 3, false);
        login_table.set_col_spacings (10);
        login_table.set_row_spacings (10);
        login_table.attach_defaults (username_label, 0, 1, 0, 1);
        login_table.attach_defaults (username_entry, 1, 2, 0, 1);
        login_table.attach_defaults (password_label, 0, 1, 1, 2);
        login_table.attach_defaults (password_entry, 1, 2, 1, 2);
        login_table.attach_defaults (remember_checkbutton,  1, 2, 2, 3);
        var login_vbox_alignment = new Alignment (0, 0, 0, 0);
        login_vbox_alignment.set_padding (0, 0, 12, 0);
        login_vbox_alignment.add (login_table);
        var login_vbox = new VBox (false, 6);
        login_vbox.pack_start (login_vbox_title, false, true, 0);
        login_vbox.pack_start (login_vbox_alignment, false, true, 0);

        var services_vbox_title = new Label (_("Services:"));
        label_make_bold (services_vbox_title);
        services_vbox_title.set_alignment (0, (float) 0.5);
        var services_vbox_alignment = new Alignment (0, 0, 0, 0);
        services_vbox_alignment.set_padding (0, 0, 12, 0);
        this.services_internal_vbox = new VBox (true, 6);
        services_vbox_alignment.add (services_internal_vbox);
        var services_vbox = new VBox (false, 6);
        services_vbox.pack_start (services_vbox_title, false, true, 0);
        services_vbox.pack_start (services_vbox_alignment, false, true, 0);

        this.vbox_right = new VBox (false, 18);
        vbox_right.pack_start (login_vbox, false, true, 0);
        vbox_right.pack_start (services_vbox, false, true, 0);

        var hbox = new HBox (false, 12);
        hbox.pack_start (vbox_left, false, false, 0);
        hbox.pack_start (vbox_right, false, false, 0);

        var main_vbox = new VBox (false, 0);
        main_vbox.set_border_width (12);
        var menubar = this.ui_manager.get_widget ("/MenuBar");
        main_vbox.pack_start (menubar, false, false, 0);
        main_vbox.pack_start (hbox, true, true, 0);
        add (main_vbox);

        main_vbox.show_all();
        this.vbox_right.hide ();
    }

    private void set_atk_name_description (Widget widget, string name, string description)
    {
       var atk_widget = widget.get_accessible ();

       atk_widget.set_name (name);
       atk_widget.set_description (description);
    }

    private void connect_signals()
    {
        this.destroy.connect (Gtk.main_quit);
    }

    private void init_ipc_server ()
    {
#if IPC_MSRPC
        /* Errors will currently be sent via g_log - ie. to an
         * obtrusive message box, on Windows
         */
        this.ipc_server = MoonshotServer.get_instance ();
        MoonshotServer.start (this);
#else
        try {
            var conn = DBus.Bus.get (DBus.BusType.SESSION);
            dynamic DBus.Object bus = conn.get_object ("org.freedesktop.DBus",
                                                       "/org/freedesktop/DBus",
                                                       "org.freedesktop.DBus");

            // try to register service in session bus
            uint reply = bus.request_name ("org.janet.Moonshot", (uint) 0);
            assert (reply == DBus.RequestNameReply.PRIMARY_OWNER);

            this.ipc_server = new MoonshotServer (this);
            conn.register_object ("/org/janet/moonshot", ipc_server);

        }
        catch (DBus.Error e)
        {
            stderr.printf ("%s\n", e.message);
        }
#endif
    }

    public static int main(string[] args)
    {
        Gtk.init(ref args);

#if OS_WIN32
        // Force specific theme settings on Windows without requiring a gtkrc file
        Gtk.Settings settings = Gtk.Settings.get_default ();
        settings.set_string_property ("gtk-theme-name", "ms-windows", "moonshot");
        settings.set_long_property ("gtk-menu-images", 0, "moonshot");
#endif

        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        var window = new MainWindow();
        window.show ();

        Gtk.main();

        return 0;
    }
}

class IdentitiesManager : Object {

    public SList<IdCard> id_card_list;

    private const string FILE_NAME = "identities.txt";

    public IdentitiesManager ()
    {
        id_card_list = new SList<IdCard>();
        var key_file = new KeyFile ();

        var path = get_data_dir ();
        var filename = Path.build_filename (path, FILE_NAME);

        try
        {
            key_file.load_from_file (filename, KeyFileFlags.NONE);
        }
        catch (Error e)
        {
            stdout.printf("Error: %s\n", e.message);
            return;
        }

        var identities_uris = key_file.get_groups ();
        foreach (string identity in identities_uris)
        {
            try
            {
                IdCard id_card = new IdCard ();

                id_card.issuer = key_file.get_string (identity, "Issuer");
                id_card.username = key_file.get_string (identity, "Username");
                id_card.password = key_file.get_string (identity, "Password");
                id_card.services = key_file.get_string_list (identity, "Services");
                id_card.display_name = key_file.get_string (identity, "DisplayName");
                id_card.pixbuf = find_icon ("avatar-default", 48);

                id_card_list.prepend (id_card);
            }
            catch (Error e)
            {
                stdout.printf ("Error:  %s\n", e.message);
            }
        }
    }

    public void store_id_cards ()
    {
        var key_file = new KeyFile ();

        foreach (IdCard id_card in this.id_card_list)
        {
            /*string[] rules_patterns = new string[id_card.rules.length];
            string[] rules_always_conf = new string[id_card.rules.length];
            
            for (int i=0; i<id_card.rules.length; i++)
            {
              rules_patterns[i] = id_card.rules[i].pattern;
              rules_always_conf[i] = id_card.rules[i].always_confirm;
            }
            */
            key_file.set_string (id_card.display_name, "Issuer", id_card.issuer ?? "");
            key_file.set_string (id_card.display_name, "DisplayName", id_card.display_name ?? "");
            key_file.set_string (id_card.display_name, "Username", id_card.username ?? "");
            key_file.set_string (id_card.display_name, "Password", id_card.password ?? "");
            key_file.set_string_list (id_card.display_name, "Services", id_card.services ?? {});
            /*
            if (id_card.rules.length > 0)
            {
              key_file.set_string_list (id_card.display_name, "Rules-Patterns", rules_patterns);
              key_file.set_string_list (id_card.display_name, "Rules-AlwaysConfirm", rules_always_conf);
            }
            // Trust anchor 
            key_file.set_string (id_card.display_name, "CA-Cert", id_card.trust_anchor.ca_cert ?? "");
            key_file.set_string (id_card.display_name, "Subject", id_card.trust_anchor.subject ?? "");
            key_file.set_string (id_card.display_name, "SubjectAlt", id_card.trust_anchor.subject_alt ?? "");
            key_file.set_string (id_card.display_name, "ServerCert", id_card.trust_anchor.server_cert ?? "");
            */
        }

        var text = key_file.to_data (null);

        try
        {
            var path = get_data_dir ();
            var filename = Path.build_filename (path, FILE_NAME);
            FileUtils.set_contents (filename, text, -1);
        }
        catch (Error e)
        {
            stdout.printf ("Error:  %s\n", e.message);
        }
    }

    private string get_data_dir()
    {
        string path;

        path = Path.build_filename (Environment.get_user_data_dir (),
                                    Config.PACKAGE_TARNAME);
        if (!FileUtils.test (path, FileTest.EXISTS))
        {
            DirUtils.create (path, 0700);
        }

        return path;
    }
}

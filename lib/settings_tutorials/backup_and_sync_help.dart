import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../project_resources/project_colors.dart';

class BackupAndSyncdHelp extends StatelessWidget {
  const BackupAndSyncdHelp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(
        builder: (context, swapper, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Backup And Sync Help Page'),
            ),
            body: ListView(
              children: [
                Divider(
                  height: 1.0,
                  thickness: 0.5,
                  color: Color(swapper.isColorSeed),
                ),
                const ListTile(
                  title: Text(
                      "This guide should help you clear up any confusion about how the backup and sync function works."),
                ),
                Divider(
                  height: 1.0,
                  thickness: 0.5,
                  color: Color(swapper.isColorSeed),
                ),
                const ListTile(
                  title: Text(
                    "How to Activate",
                  ),
                  subtitle: Text(
                      'To turn on Backup & Sync for this app, you\'ll need to hit the Sign in to Drive Button on the login screen. \r\n'
                          ' Once you do that, you\'ll then need to select a gmail account and approve permissions. Select all permissions that are unchecked because the application needs to be able to write to the application\'s designated directory for storing your journal in the cloud.\r\n'),
                ),
                Divider(
                  height: 1.0,
                  thickness: 0.5,
                  color: Color(swapper.isColorSeed),
                ),
                const ListTile(
                  title: Text('Data Security'),
                  subtitle: Text(
                      'The application encrypts your passwords and other important pieces of information using RSA encryption. The keys are stored in your Google Drive account in the same folder as your Journal and related files. You can accesss this folder in Google drive so you can back up your journal to your computer as well. '
                          'However, don\'t let your GMail account get hacked or else there\'s a risk of your data possibly being compromised..\r\n'

                          ),
                ),
                Divider(
                  height: 1.0,
                  thickness: 0.5,
                  color: Color(swapper.isColorSeed),
                ),
                const ListTile(
                  title: Text('Updating journals on multiple devices'),
                  subtitle: Text(
                      'There is a risk of data being mismatched if you have the journal opened on two devices at the same time if they\'re linked to the same account. Best practices include updating one journal, exiting to the login screen, then allowing the app to upload the journal itself so it can update the backup in your Drive Account.\r\n'
                  ),
                ),
              ],
            ),
          );});
  }
}

import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TutorialHelpScreen extends StatelessWidget {
  const TutorialHelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Help Guide"),
        ),
        body: ListView(
          children: [
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            ListTile(
              iconColor: Color(swapper.isColorSeed),
              title: const Text(
                  'Creating a new journal entry, or editing an existing entry'),
              onTap: () {
                Navigator.pushNamed(context, '/composehelp');
              },
            ),
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            ListTile(
              title: const Text('How to use the dashboard feature'),
              onTap: () {
                Navigator.pushNamed(context, '/dashboardhelp');
              },
            ),
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            ListTile(
              title: const Text('How to use sorting and filtering features'),
              onTap: () {
                Navigator.pushNamed(context, '/searchhelp');
              },
            ),
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            ListTile(
              title: const Text('How Backup and sync works'),
              onTap: () {
                Navigator.pushNamed(context, '/backuphelp');
              },
            ),
          ],
        ),
      );
    });
  }
}

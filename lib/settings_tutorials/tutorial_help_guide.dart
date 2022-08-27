import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TutorialHelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(
        builder: (context, ThemeSwap themeNotifier, child) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help Guide"),
      ),
      body: ListView(
        children: [
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(themeNotifier.isColorSeed),
          ),
          ListTile(
            iconColor: Color(themeNotifier.isColorSeed),
            title: Text(
                'Creating a new journal entry, or editing an existing entry'),
            onTap: () {
              Navigator.pushNamed(context, '/composehelp');
            },
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(themeNotifier.isColorSeed),
          ),
          ListTile(
            title: Text('How to use the dashboard feature'),
            onTap: () {
              Navigator.pushNamed(context, '/dashboardhelp');
            },
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(themeNotifier.isColorSeed),
          ),
          ListTile(
            title: Text('How to use sorting and filtering features'),
            onTap: () {
              Navigator.pushNamed(context, '/searchhelp');
            },
          ),
        ],
      ),
    );});
  }
}

import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:flutter/material.dart';

class TutorialHelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help Guide"),
      ),
      body: ListView(
        children: [
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          ListTile(
            iconColor: AppColors.mainAppColor,
            title: Text(
                'Creating a new journal entry, or editing an existing entry'),
            onTap: () {
              Navigator.pushNamed(context, '/composehelp');
            },
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
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
            color: AppColors.mainAppColor,
          ),
          ListTile(
            title: Text('How to use sorting and filtering features'),
            onTap: () {
              Navigator.pushNamed(context, '/searchhelp');
            },
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:adhd_journal_flutter/settings_link_page/link_tile_class.dart';
import 'package:adhd_journal_flutter/splash_screendart.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../project_colors.dart';

class HelpfulLinksWidget extends StatelessWidget {
  Divider headerDivider = Divider(
    height: 2.0,
    thickness: 1.5,
    color: AppColors.mainAppColor,
  );

  HelpfulLinksWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
   return Scaffold(appBar: AppBar(title: const Text("Resources"),leading:IconButton(icon: backArrowIcon,onPressed: (){Navigator.pop(context);},),),
     body:
         CustomScrollView(
           slivers: [
             SliverList(delegate: SliverChildListDelegate([
                ListTile(title: const Text("Helpful Websites",style: TextStyle(fontWeight: FontWeight.bold),),leading: Icon(Icons.web_asset,color: AppColors.mainAppColor,),),
               headerDivider
             ]),
             ),
             SliverList(delegate: SliverChildBuilderDelegate((BuildContext context,int index){
               return Card(child:ListTile(style:ListTileStyle.list,title: linkArray[index].title,onTap: (){
                 _launchURL(linkArray[index].url);
               },enableFeedback: true,),elevation: 2.0,borderOnForeground: true,
                 shape: RoundedRectangleBorder(
                     side: BorderSide(color: AppColors.mainAppColor, width: 1.0),
                     borderRadius: BorderRadius.circular(10)),);
             },childCount: linkArray.length,
             ),
             ),
             SliverList(delegate: SliverChildListDelegate([
               headerDivider,
              ListTile(title: const Text("Video resources",style: TextStyle(fontWeight: FontWeight.bold),),leading: Icon(Icons.play_circle_outlined,color: AppColors.mainAppColor,),),
               headerDivider,
             ]),
             ),
             SliverList(delegate: SliverChildBuilderDelegate((BuildContext context,int index){
               return Card(child:ListTile(style:ListTileStyle.list,title: youtube_LinksArray[index].title,onTap: (){
    _launchURL(youtube_LinksArray[index].url);
    },enableFeedback: true,),elevation: 2.0,borderOnForeground: true,
    shape: RoundedRectangleBorder(
    side: BorderSide(color: AppColors.mainAppColor, width: 1.0),
    borderRadius: BorderRadius.circular(10)),);
    },childCount: youtube_LinksArray.length,
             ),
             ),
           ],
         ),
   );

  }


  //This launches the URL Links in the application.
  void _launchURL(Uri url) async{
    if(Platform.isIOS){
    if(!await launchUrl(url,mode:LaunchMode.inAppWebView)) throw 'Failed to launch $url';
    }
    else{
      if(!await launchUrl(url)) throw 'Failed to launch $url';
    }
  }


}
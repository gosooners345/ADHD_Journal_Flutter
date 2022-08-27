import 'dart:io';

import 'package:adhd_journal_flutter/settings_link_page/link_tile_class.dart';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../project_resources/project_colors.dart';

class HelpfulLinksWidget extends StatelessWidget {
  //final Divider Divider(


  HelpfulLinksWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(
        builder: (context, ThemeSwap themeNotifier, child) {
   return Scaffold(appBar: AppBar(title: const Text("Resources"),leading:IconButton(icon: backArrowIcon,onPressed: (){Navigator.pop(context);},),),
     body:
         // General resources
         CustomScrollView(
           slivers: [
             SliverList(delegate: SliverChildListDelegate([
                ListTile(title: const Text("Helpful Websites",style: TextStyle(fontWeight: FontWeight.bold),),leading: Icon(Icons.web_asset,color: Color(themeNotifier.isColorSeed),),),
          Divider(
          height: 2.0,
          thickness: 1.5,
          color: Color(themeNotifier.isColorSeed),
          )
             ]),
             ),

             SliverList(delegate: SliverChildBuilderDelegate((BuildContext context,int index){
               return Card(elevation: 2.0,borderOnForeground: true,
                 shape: RoundedRectangleBorder(
                     side: BorderSide(color: Color(themeNotifier.isColorSeed), width: 1.0),
                     borderRadius: BorderRadius.circular(10)),child:ListTile(style:ListTileStyle.list,title: linkArray[index].title,onTap: (){
                 _launchURL(linkArray[index].url);
               },enableFeedback: true,),);
             },childCount: linkArray.length,
             ),
             ),
             // Youtube links
             SliverList(delegate: SliverChildListDelegate([
               Divider(
    height: 2.0,
    thickness: 1.5,
    color: Color(themeNotifier.isColorSeed),
  ),
              ListTile(title: const Text("Video resources",style: TextStyle(fontWeight: FontWeight.bold),),leading: Icon(Icons.play_circle_outlined,color: Color(themeNotifier.isColorSeed),),),
               Divider(
    height: 2.0,
    thickness: 1.5,
    color: Color(themeNotifier.isColorSeed),
  ),
             ]),
             ),
             SliverList(delegate: SliverChildBuilderDelegate((BuildContext context,int index){
               return Card(elevation: 2.0,borderOnForeground: true,
    shape: RoundedRectangleBorder(
    side: BorderSide(color: Color(themeNotifier.isColorSeed), width: 1.0),
    borderRadius: BorderRadius.circular(10)),child:ListTile(style:ListTileStyle.list,title: youtube_LinksArray[index].title,onTap: (){
    _launchURL(youtube_LinksArray[index].url);
    },enableFeedback: true,),);
    },childCount: youtube_LinksArray.length,
             ),
             ),
             //Podcasts
       /*      SliverList(delegate: SliverChildListDelegate([Divider(
    height: 2.0,
    thickness: 1.5,
    color: Color(themeNotifier.isColorSeed),
  ),ListTile(title: Text("Podcasts",style: TextStyle(fontWeight: FontWeight.bold),),leading: Icon(Icons.play_circle_outlined,color: Color(themeNotifier.isColorSeed), )),Divider(
    height: 2.0,
    thickness: 1.5,
    color: Color(themeNotifier.isColorSeed),
  ),
    ],),),
           SliverList(delegate: SliverChildBuilderDelegate((BuildContext context, int index){
             return Card(elevation: 2.0,borderOnForeground: true,
             shape: RoundedRectangleBorder(side: BorderSide(color: Color(themeNotifier.isColorSeed),width: 1.0),
                 borderRadius: BorderRadius.circular(10)),child: ListView.builder(itemBuilder: (BuildContext context, int index2){
                   return ListTile(style: ListTileStyle.list,title: podcast_LinksArray[index].serviceTitles[index2],
                     onTap:(){_launchURL(podcast_LinksArray[index].urlLinks[index2]);},);
                 })
            );

           }),)*/

           ],
         ),
   );});

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
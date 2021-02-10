import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:predixinote/types/constants.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageView extends StatefulWidget {
  final String title;
  final int initialIndex;
  final List<String> urllist;

  const ImageView({Key key, this.initialIndex, this.urllist, this.title})
      : super(key: key);

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {

  int currentIndex;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIndex = widget.initialIndex;
  }


  @override
  Widget build(BuildContext context) {

    final cachemgr=DefaultCacheManager();
    var image = new CachedNetworkImage(
      cacheManager:cachemgr,
      imageUrl: widget.urllist[currentIndex],
      imageBuilder: (context, imageProvider) => Container(
        height: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: PhotoView(
          imageProvider: imageProvider,
        ),
      ),
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "IMG$currentIndex",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
              icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          elevation: 2,
          backgroundColor: appBarBackgroundColor,
          actions: [
            IconButton(
                icon: Icon(Icons.share),
                onPressed: () async {
                  Share.shareFiles([(await image.cacheManager.getFileFromCache(widget.urllist[currentIndex])).file.path]);
                })
          ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            image,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  iconSize: 48,
                  color: Colors.white,
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => prev(),
                ),
                IconButton(
                  iconSize: 48,
                  color: Colors.white,
                  splashColor: Colors.white10,
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () => next(),
                ),
              ],
            )
          ],
        ));
  }

  void next() {
    setState(() {
      currentIndex++;

      if (currentIndex == widget.urllist.length) {
        currentIndex = 0;
      }
    });
  }

  void prev() {
    setState(() {
      currentIndex--;
      if (currentIndex < 0) {
        currentIndex = widget.urllist.length - 1;
      }
    });
  }
}

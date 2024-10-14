import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../functionalities/words.dart';




class WallPaper extends StatefulWidget {
  final String eng;
  final String kor;
  final String explain;

  const WallPaper({
    Key? key,
    required this.eng,
    required this.kor,
    required this.explain
  }) : super(key: key);

  @override
  _WallPaperState createState() => _WallPaperState();
}

class _WallPaperState extends State<WallPaper> {
  double _verticalOffset = 0.0;
  final GlobalKey _captureKey = GlobalKey(); // Key for capturing the widget
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double appBarHeight = AppBar().preferredSize.height;
    double systemNavBarHeight = MediaQuery.of(context).padding.bottom;

    return SafeArea(child: AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Words.app_bar_color,
    ),
      child:Scaffold(
  backgroundColor: Words.app_background_color,
      appBar: AppBar(
        backgroundColor: Words.app_bar_color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _takeScreenShotAndSaveToGallery();
              final snackBar = SnackBar(
                content: Text("Image saved to Gallery"),
                duration:
                Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context)
                  .showSnackBar(snackBar);
            },
            child: Text(
              'Save to Gallery',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),

        ],
      ),
      body: LayoutBuilder(

        builder: (context, constraints) {

          // Calculate the height of the scrollable area
          double scrollableHeight =
              constraints.maxHeight / 2 - appBarHeight - systemNavBarHeight-32;
          return GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                // Update vertical offset and clamp within the scrollable height
                _verticalOffset = (_verticalOffset + details.delta.dy)
                    .clamp(-scrollableHeight, scrollableHeight);
              });
            },
            child: RepaintBoundary(
              key: _captureKey,
              child: Container(
                color: Words.app_background_color,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child:Stack(

                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Transform.translate(
                          offset: Offset(0, _verticalOffset),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            color: Colors.transparent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 8.0),
                                Text(
                                    widget.eng,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,
                                      color: Colors.black,)
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                    widget.kor,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16,
                                      color: Colors.black,)
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                    widget.explain,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16,
                                      color: Colors.black,)
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )


              )

            ),
          );
        },
      ),

    )
    )
    );
  }

  Future<void> _takeScreenShotAndSaveToGallery() async {
    try {
      final boundary = _captureKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      // Save the image to a temporary file
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/screenshot.png';
      final imgFile = File(path);
      await imgFile.writeAsBytes(pngBytes!);

      // Save the image to gallery
      final result = await ImageGallerySaver.saveFile(path);

      if (result != null && result['isSuccess'] == true) {
        print('Screenshot saved to gallery.');
      } else {
        print('Failed to save screenshot to gallery.');
      }
    } catch (e) {
      print('Error taking screenshot: $e');
    }
  }


}

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';


class FullImageScreen extends StatelessWidget {
  final File imageFile;
  const FullImageScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Image", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15,top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () async {
                    bool confirm = await _showConfirmDialog(context);
                    if (confirm) {
                      if (await imageFile.exists()) {
                        await imageFile.delete();
                        Navigator.pop(context, true); // Signal deletion
                      }
                    }
                  },
                  icon: const Icon(Icons.delete,color: Colors.white),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                ),
                IconButton(
                  onPressed: () {
                    Share.shareXFiles([XFile(imageFile.path)],
                        text: "Check out this image!");
                  },
                  icon: const Icon(Icons.share,color: Colors.white,),
                ),
                IconButton(
                  onPressed: () async {
                    var stat = await imageFile.stat();
                    String size =
                        "${(stat.size / 1024).toStringAsFixed(2)} KB";
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Image info"),
                          content: Text(
                              "Image saved in:\n${imageFile.path}\n\nSize: $size"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.info,color: Colors.white,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete photo?'),
            content: const Text('Are you sure you want to delete this photo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

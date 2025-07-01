import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera_app/screen/fullScreen.dart';

class GalleryScreen extends StatefulWidget {
  final List<File> images;

  const GalleryScreen({super.key, required this.images});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late List<File> images;

  @override
  void initState() {
    super.initState();
    images = List.from(widget.images); // Make a local copy to modify
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallery",
        style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: images.isEmpty
          ? const Center(
              child: Text(
                'No images available',
                style: TextStyle(color: Colors.white),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FullImageScreen(imageFile: images[index]),
                      ),
                    );

                    if (result == true) {
                      // Photo was deleted, remove and refresh UI
                      setState(() {
                        images.removeAt(index);
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue,
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 2),
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(8),
                  child: Image.file(
                    images[index],
                    fit: BoxFit.cover,
                  ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

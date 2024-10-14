// ignore_for_file: avoid_print, prefer_const_constructors

// Author: Selam Biru
// Edited by: Ben Sutter
// Description: This screen lets the user see local files marked as signficant objects
//              The user can also take a new photo or upload from local external storage

import 'dart:io';

import 'package:cogniopenapp/src/utils/directory_manager.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cogniopenapp/src/camera_manager.dart';
import 'package:cogniopenapp/src/data_service.dart';

class SignificantObjectScreen extends StatefulWidget {
  const SignificantObjectScreen({super.key});

  @override
  State<SignificantObjectScreen> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<SignificantObjectScreen> {
  final imagePicker = ImagePicker();

  final ImagePicker _picker = ImagePicker();
  Future imagePickerMethodfromcamera() async {
    await _picker
        .pickImage(source: ImageSource.camera)
        .then((XFile? recordedimage) {
      if (recordedimage != null) {
        //   setState(() {
        //   firstbuttontext = 'saving in progress...';
        //  });
        GallerySaver.saveImage(recordedimage.path).then((path) {
          setState(() {
            //   firstbuttontext = 'image saved!';
          });
        });
      }
    });
    showSnackBar("Photo captured successfully", Duration(milliseconds: 700));
  }

  Future imagePickerMethodfromgallery() async {
    final String timestamp = DateTime.now().toString();
    final String sanitizedTimestamp = timestamp.replaceAll(' ', '_');
    final String fileName =
        '$sanitizedTimestamp.jpg'; // Use the determined file extension

    final String fullPath =
        '${DirectoryManager.instance.significantObjectsDirectory.path}/$fileName';

    await _picker
        .pickImage(source: ImageSource.gallery)
        .then((XFile? recordedimage) async {
      if (recordedimage != null) {
        // Copy the image to the specified location
        File sourceFile = File(recordedimage.path);
        File destinationFile = File(fullPath);

        try {
          await sourceFile.copy(destinationFile.path);
          // You can now use the 'destinationFile' for further operations if needed.
          // Print the path of the saved image
          print('Image saved at: ${destinationFile.path}');
          await DataService.instance.addPhoto(photoFile: destinationFile);
        } catch (e) {
          print('Error while copying the image: $e');
        }
      }
    });
    showSnackBar("Image Uploaded Succesfully", Duration(milliseconds: 700));
  }

  bool isImageSelected = false;
  late File imageFile;

  late Future _futureGetPath;
  List<dynamic> listImagePath = <dynamic>[];
  var _permissionStatus;

  @override
  void initState() {
    super.initState();
    _listenForPermissionStatus();
    // Declaring Future object inside initState() method
    // prevents multiple calls inside stateful widget
    _futureGetPath = _getPath();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Transparent background
      child: Column(
        children: [
          // Custom AppBar with a transparent background and white content
          Padding(
            padding: const EdgeInsets.only(top: 40.0), // Adjust for status bar padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/app_icon.png', // Replace this with your icon's path
                  fit: BoxFit.contain,
                  height: 32, // Adjust the size as needed
                  color: Colors.white, // Make the icon white
                ),
                const SizedBox(width: 10), // Spacing between the icon and title
                const Text(
                  'CogniOpen',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white), // Title in white
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              takePicture();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, // Button text color in white
                              backgroundColor: Colors.transparent, // Transparent button background
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0), // Square border
                              ),
                            ),
                            key: const Key("TakePictureButtonKey"),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Icon(Icons.camera, size: 40, color: Colors.white), // Icon in white
                                SizedBox(height: 8.0),
                                Text('Camera', style: TextStyle(color: Colors.white)), // Text in white
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              imagePickerMethodfromgallery();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, // Button text color in white
                              backgroundColor: Colors.transparent, // Transparent button background
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0), // Square border
                              ),
                            ),
                            key: const Key("UploadFromGalleryButtonKey"),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Icon(Icons.upload_file, size: 40, color: Colors.white), // Icon in white
                                SizedBox(height: 8.0),
                                Text('Upload Image', style: TextStyle(color: Colors.white)), // Text in white
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FutureBuilder(
                  future: _futureGetPath,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      Directory directory =
                          DirectoryManager.instance.significantObjectsDirectory;
                      if (_permissionStatus) _fetchFiles(directory);
                      return const Text(""); // Keep this as is
                    } else {
                      return const Text(
                        "Loading",
                        style: TextStyle(color: Colors.white), // Text in white
                      );
                    }
                  },
                ),
                const Divider(
                  color: Colors.white,
                  height: 25,
                  thickness: 2,
                  indent: 15,
                  endIndent: 15,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Significant Objects",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white, // Text in white
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.white,
                  height: 25,
                  thickness: 2,
                  indent: 15,
                  endIndent: 15,
                ),
                SizedBox(
                  height: 5000,
                  child: GridView.count(
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                    children: _getListImg(listImagePath),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Future<void> takePicture() async {
    await CameraManager()
        .capturePhoto(DirectoryManager.instance.significantObjectsDirectory);
  }

  void _listenForPermissionStatus() async {
    final status = await Permission.storage.request().isGranted;
    // setState() triggers build again
    setState(() => _permissionStatus = status);
  }

  Future<String> _getPath() {
    return ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_PICTURES);
  }

  _fetchFiles(Directory dir) {
    List<dynamic> listImage = <dynamic>[];
    dir.list().forEach((element) {
      RegExp regExp =
          RegExp(".(gif|jpe?g|tiff?|png|webp|bmp)", caseSensitive: false);
      // Only add in List if path is an image
      if (regExp.hasMatch('$element')) listImage.add(element);
      setState(() {
        listImagePath = listImage;
      });
    });
  }

  List<Widget> _getListImg(List<dynamic> listImagePath) {
    List<Widget> listImages = <Widget>[];
    for (var imagePath in listImagePath) {
      listImages.add(
        Container(
          padding: const EdgeInsets.all(8),
          child: Image.file(imagePath, fit: BoxFit.cover),
        ),
      );
    }
    return listImages;
  }

  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(content: Text(snackText), duration: d);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

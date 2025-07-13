import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:tourbuddy/services/database.dart';
import 'package:tourbuddy/services/shared_pref.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String? name, image;

  getthesharedpref() async {
    name = await SharedpreferenceHelper().getUserDisplayName();
    image = await SharedpreferenceHelper().getUserImage();
    setState(() {});
  }

  @override
  void initState() {
    getthesharedpref();
    super.initState();
  }

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  TextEditingController placenamecontroller = TextEditingController();
  TextEditingController citynamecontroller = TextEditingController();
  TextEditingController captioncontroller = TextEditingController();

  Future<void> uploadPost() async {
    if (selectedImage != null &&
        placenamecontroller.text.isNotEmpty &&
        citynamecontroller.text.isNotEmpty &&
        captioncontroller.text.isNotEmpty) {

      // Check if user is signed in
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "You need to be signed in to upload posts",
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            )
        ));
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        String addId = randomAlphaNumeric(10);

        Reference firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child("blogImage")
            .child(addId);

        final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

        var downloadUrl = await (await task).ref.getDownloadURL();
        Map<String, dynamic> addPost = {
          "Image": downloadUrl,
          "PlaceName": placenamecontroller.text,
          "CityName": citynamecontroller.text,
          "Caption": captioncontroller.text,
          "UserName": name,
          "UserImage": image,
          "Like": ["username"],
          "Timestamp": DateTime.now().millisecondsSinceEpoch,
        };

        await DatabaseMethods().addPost(addPost, addId);

        // Close loading dialog
        Navigator.pop(context);

        // Clear form
        selectedImage = null;
        placenamecontroller.clear();
        citynamecontroller.clear();
        captioncontroller.clear();
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Post has been Uploaded Successfully!",
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            )
        ));

        // Optionally navigate back
        // Navigator.pop(context);
      } catch (e) {
        // Close loading dialog
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Error uploading post: ${e.toString()}",
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            )
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Please fill all fields and select an image",
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          )
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 40.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(30)
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.white,
                          )
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4.5,
                  ),
                  Text(
                    "Add Post",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Expanded(
                child: Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)
                    ),
                    child: Container(
                      padding: EdgeInsets.only(left: 20.0, right: 10.0, top: 30.0),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(186, 250, 247, 247),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)
                          )
                      ),
                      width: MediaQuery.of(context).size.width,
                      // Added SingleChildScrollView here to fix overflow
                      child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              selectedImage != null
                                  ? Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    selectedImage!,
                                    height: 180,
                                    width: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                                  : Center(
                                child: GestureDetector(
                                  onTap: (){
                                    getImage();
                                  },
                                  child: Container(
                                    height: 180,
                                    width: 180,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black45,
                                            width: 2.0
                                        ),
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Icon(Icons.camera_alt_outlined),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                "Place Name",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 20.0),
                                decoration: BoxDecoration(
                                    color: Color(0xFFececf8),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: TextField(
                                  controller: placenamecontroller,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter Place Name"
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                "City Name",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 20.0),
                                decoration: BoxDecoration(
                                    color: Color(0xFFececf8),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: TextField(
                                  controller: citynamecontroller,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter City Name"
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                "Caption",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 20.0),
                                decoration: BoxDecoration(
                                    color: Color(0xFFececf8),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: TextField(
                                  controller: captioncontroller,
                                  maxLines: 6,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter Caption...."
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              GestureDetector(
                                onTap: uploadPost,
                                child: Center(
                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width / 2,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Post",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Add padding at the bottom for better scrolling experience
                              SizedBox(height: 30),
                            ]
                        ),
                      ),
                    )
                )
            )
          ],
        ),
      ),
    );
  }
}
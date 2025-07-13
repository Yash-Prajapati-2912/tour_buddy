import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourbuddy/pages/comment.dart';
import 'package:tourbuddy/services/database.dart';
import 'package:tourbuddy/services/shared_pref.dart';

class PostPlace extends StatefulWidget {
  String place;
  PostPlace({required this.place});

  @override
  State<PostPlace> createState() => _PostPlaceState();
}

class _PostPlaceState extends State<PostPlace> {
  String? name, image, id;

  getthesharedpref() async {
    name = await SharedpreferenceHelper().getUserDisplayName();
    image = await SharedpreferenceHelper().getUserImage();
    id = await SharedpreferenceHelper().getUserId();
    setState(() {});
  }
  Stream? placeStream;

  getontheload() async {
    await getthesharedpref();
    placeStream = await DatabaseMethods().getPostsPlace(widget.place);
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  Widget allPosts() {
    return StreamBuilder(
        stream: placeStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(), // Add this
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];

                return Container(
                  margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
                  child: Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, left: 10.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.network(
                                    ds["UserImage"],
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                  width: 15.0,
                                ),
                                Text(
                                  ds["UserName"],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Image.network(ds["Image"]),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                ),
                                Text(
                                  // ignore: prefer_interpolation_to_compose_strings
                                  " " +
                                      ds["PlaceName"] +
                                      " , " +
                                      ds["CityName"],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              ds["Caption"],
                              style: TextStyle(
                                  color: Color.fromARGB(179, 0, 0, 0),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Row(
                              children: [
                                ds["Like"].contains(id)
                                    ? Icon(
                                  Icons.favorite,
                                  color: Colors.red,size: 30.0,
                                )
                                    : GestureDetector(
                                  onTap: () async {
                                    await DatabaseMethods().addLike(ds.id, id!);
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.favorite_outline,
                                    color: Colors.black54,
                                    size: 30.0,
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  "Like",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  width: 30.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => CommentPage(userimage: image!, username: name!, postid: ds.id)));
                                  },
                                  child: Icon(
                                    Icons.comment_outlined,
                                    color: Colors.black54,
                                    size: 28.0,
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  "Comment",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              })
              : Center(
            child: CircularProgressIndicator(), // Show loading indicator when no data
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                            borderRadius: BorderRadius.circular(30)),
                        child: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.white,
                        )),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4,
                ),
                Text(
                  widget.place,
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0,),
          Expanded(
              child: Material(
                  elevation: 3.0,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                  ),
                  child: Container(
                    padding: EdgeInsets.only(top: 10.0),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(186, 250, 247, 247),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30)
                        )
                    ),
                    // Directly use allPosts() without wrapping it in another Column
                    child: allPosts(),
                  )
              )
          )
        ],
      ),
    );
  }
}
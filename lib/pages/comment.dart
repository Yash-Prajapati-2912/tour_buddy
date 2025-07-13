import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourbuddy/services/database.dart';

class CommentPage extends StatefulWidget {
  String username, userimage, postid;
  CommentPage(
      {required this.userimage, required this.username, required this.postid});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TextEditingController commentcontroller = new TextEditingController();
  Stream<QuerySnapshot>? commentStream;
  bool isLoading = true;

  getontheload() async {
    setState(() {
      isLoading = true;
    });

    try {
      commentStream = await DatabaseMethods().getComments(widget.postid);
      print("Comment stream loaded: ${commentStream != null}");
    } catch (e) {
      print("Error loading comments: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  Widget allComments() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    print("Comment stream is null? ${commentStream == null}");

    return StreamBuilder<QuerySnapshot>(
        stream: commentStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          print("Connection state: ${snapshot.connectionState}");
          print("Has error: ${snapshot.hasError}");
          if (snapshot.hasError) print("Error: ${snapshot.error}");
          print("Has data: ${snapshot.hasData}");
          if (snapshot.hasData) print("Docs count: ${snapshot.data!.docs.length}");

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No comments yet", style: TextStyle(fontSize: 16)));
          }

          return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var ds = snapshot.data!.docs[index];
                print("Comment document: ${ds.id}, data: ${ds.data()}");

                return Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              ds["UserImage"],
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 70,
                                  width: 70,
                                  color: Colors.grey,
                                  child: Icon(Icons.person, size: 50),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ds["UserName"],
                                  style: TextStyle(
                                      color: const Color.fromARGB(169, 0, 0, 0),
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                Text(
                                  ds["Comment"],
                                  style: TextStyle(
                                      color: Color.fromARGB(230, 0, 0, 0),
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
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
                    width: MediaQuery.of(context).size.width / 7,
                  ),
                  Text(
                    "Add Comment",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold),
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
                        topRight: Radius.circular(30)),
                    child: Container(
                        padding:
                        EdgeInsets.only(left: 20.0, right: 10.0, top: 30.0),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(186, 250, 247, 247),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Expanded(
                              child: allComments(),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(left: 20.0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.black45, width: 2.0),
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      child: TextField(
                                        controller: commentcontroller,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Write a Comment..."),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      if (commentcontroller.text.isNotEmpty) {
                                        Map<String, dynamic> addComment = {
                                          "UserImage": widget.userimage,
                                          "UserName": widget.username,
                                          "Comment": commentcontroller.text,
                                          "timestamp": FieldValue.serverTimestamp(),
                                        };

                                        print("Adding comment: $addComment to post ${widget.postid}");

                                        await DatabaseMethods()
                                            .addComment(addComment, widget.postid);
                                        commentcontroller.text = "";

                                        // Refresh the comments
                                        getontheload();
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      child: Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 30.0,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                    )
                )
            )
          ],
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourbuddy/pages/add_page.dart';
import 'package:tourbuddy/pages/comment.dart';
import 'package:tourbuddy/pages/post_place.dart';
import 'package:tourbuddy/pages/top_places.dart';
import 'package:tourbuddy/services/database.dart';
import 'package:tourbuddy/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? name, image, id;
  TextEditingController searchcontroller = TextEditingController();
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = "";

  Future<void> getthesharedpref() async {
    try {
      name = await SharedpreferenceHelper().getUserDisplayName();
      image = await SharedpreferenceHelper().getUserImage();
      id = await SharedpreferenceHelper().getUserId();
      setState(() {});
    } catch (e) {
      print("Error getting shared preferences: $e");
      setState(() {
        hasError = true;
        errorMessage = "Failed to load user data";
      });
    }
  }

  Stream<QuerySnapshot>? postStream;

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> getontheload() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      bool isConnected = await checkInternetConnectivity();
      if (!isConnected) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = "No internet connection. Please check your connection and try again.";
        });
        return;
      }

      await getthesharedpref();

      if (mounted) {
        DatabaseMethods dbMethods = DatabaseMethods();
        postStream = dbMethods.getPosts();
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = "Failed to load data. Please try again later.";
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  bool search = false;
  bool isSearchingCity = false;

  var queryResultSet = [];
  var tempSearchStore = [];
  var citySearchResults = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
        citySearchResults = [];
        search = false;
        isSearchingCity = false;
      });
      return;
    }

    setState(() {
      search = true;
    });

    // Check if this is a city search or location search
    if (value.toLowerCase().startsWith("city:") || value.contains(" ")) {
      // This is likely a city search
      isSearchingCity = true;
      String citySearchTerm = value.toLowerCase().startsWith("city:")
          ? value.substring(5).trim()
          : value.trim();

      if (citySearchTerm.isNotEmpty) {
        // Search for posts with this city
        DatabaseMethods().searchCities(citySearchTerm).then((QuerySnapshot docs) {
          setState(() {
            citySearchResults = docs.docs.map((doc) => doc.data()).toList();
          });
        });
      }
    } else {
      // Regular location search
      isSearchingCity = false;
      var capitalizedValue = value.substring(0, 1).toUpperCase() + value.substring(1);

      if (queryResultSet.isEmpty && value.length == 1) {
        DatabaseMethods().search(value).then((QuerySnapshot docs) {
          for (int i = 0; i < docs.docs.length; ++i) {
            queryResultSet.add(docs.docs[i].data());
          }
        });
      } else {
        tempSearchStore = [];
        queryResultSet.forEach((element) {
          if (element['Name'].startsWith(capitalizedValue)) {
            setState(() {
              tempSearchStore.add(element);
            });
          }
        });
      }
    }
  }

  Widget allPosts() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(child: Text(errorMessage));
    }

    return StreamBuilder<QuerySnapshot>(
        stream: postStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading posts: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No posts available"));
          }

          return ListView.builder(
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data!.docs[index];
                return buildPostCard(ds);
              }
          );
        }
    );
  }

  Widget buildPostCard(dynamic data) {
    // Handle both DocumentSnapshot and Map data types
    Map<String, dynamic> postData;
    String postId;

    if (data is DocumentSnapshot) {
      postData = data.data() as Map<String, dynamic>;
      postId = data.id;
    } else {
      postData = data as Map<String, dynamic>;
      postId = postData['id'] ?? 'unknown'; // Use a default if id is missing
    }

    return Container(
      margin: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
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
                        postData["UserImage"] ?? "https://via.placeholder.com/50",
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 50,
                            width: 50,
                            color: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      child: Text(
                        postData["UserName"] ?? "Unknown User",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              if (postData.containsKey("Image") && postData["Image"] != null)
                Image.network(
                  postData["Image"],
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print("Error loading image: $error");
                    return Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: Center(child: Icon(Icons.image_not_supported, size: 50)),
                    );
                  },
                ),
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
                    Expanded(
                      child: Text(
                        " " + (postData["PlaceName"] ?? "Unknown") + " , " + (postData["CityName"] ?? "Unknown"),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              if (postData.containsKey("Caption"))
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(
                    postData["Caption"] ?? "",
                    style: TextStyle(
                        color: Color.fromARGB(179, 0, 0, 0),
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    (postData["Like"] is List && id != null && (postData["Like"] as List).contains(id))
                        ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 30.0,
                    )
                        : GestureDetector(
                      onTap: () async {
                        if (id != null) {
                          try {
                            // Only attempt to add like if we have a valid post ID
                            if (data is DocumentSnapshot) {
                              await DatabaseMethods().addLike(postId, id!);
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Cannot like this post in search results"))
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Failed to like post"))
                            );
                          }
                        }
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
                        if (image != null && name != null && data is DocumentSnapshot) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CommentPage(
                                          userimage: image!,
                                          username: name!,
                                          postid: postId)));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Cannot comment on this post in search results"))
                          );
                        }
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
  }

  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await SharedpreferenceHelper().clearPreferences();
      // Navigate to login page or whatever is appropriate
    } catch (e) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to sign out"))
      );
    }
  }

  Future<void> retryLoading() async {
    await getontheload();
  }

  // Widget to display city search results
  Widget _buildCitySearchResults() {
    if (citySearchResults.isEmpty) {
      return Center(child: Text("No posts found for this city"));
    }

    return ListView.builder(
        padding: EdgeInsets.only(top: 10.0),
        itemCount: citySearchResults.length,
        itemBuilder: (context, index) {
          var postData = citySearchResults[index];
          return buildPostCard(postData);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top banner and search bar section - Fixed height
            Container(
              height: MediaQuery.of(context).size.height / 2.7,
              child: Stack(
                children: [
                  // Background image
                  Image.asset(
                    "images/home.png",
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.5,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 2.5,
                        color: Colors.blue[200],
                      );
                    },
                  ),

                  // Top navigation row
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, right: 20.0, left: 20.0),
                    child: Row(
                      children: [
                        // Exit button
                        GestureDetector(
                          onTap: signOut,
                          child: Material(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(
                                Icons.exit_to_app,
                                color: Colors.red,
                                size: 30.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        // Top places button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TopPlaces()));
                          },
                          child: Material(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Image.asset(
                                "images/pin.png",
                                height: 30,
                                width: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.location_on, color: Colors.blue, size: 40);
                                },
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddPage()));
                          },
                          child: Material(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(
                                Icons.add,
                                color: Colors.blue,
                                size: 30.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Material(
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(60),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: image != null
                                ? Image.network(
                              image!,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.grey,
                                  child: Icon(Icons.person, color: Colors.white),
                                );
                              },
                            )
                                : Image.asset(
                              "images/boy.jpg",
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.grey,
                                  child: Icon(Icons.person, color: Colors.white),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // App title and subtitle
                  Padding(
                    padding: const EdgeInsets.only(top: 120.0, left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TourBuddy",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Lato',
                              fontSize: 60.0,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "Travel Community App",
                          style: TextStyle(
                              color: Color.fromARGB(205, 255, 255, 255),
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  // Search bar - Updated with enhanced hint text
                  Positioned(
                    bottom: 0,
                    left: 30,
                    right: 30,
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1.5),
                            borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          controller: searchcontroller,
                          onChanged: (value) {
                            initiateSearch(value);
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search place or city name (e.g. Mumbai)",
                              suffixIcon: Icon(Icons.search)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 10),

            // Content section - Scrollable
            Expanded(
              child: hasError
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMessage,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: retryLoading,
                      child: Text("Retry"),
                    )
                  ],
                ),
              )
                  : search
                  ? isSearchingCity
                  ? _buildCitySearchResults() // Show city search results
                  : ListView(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  children: tempSearchStore.map<Widget>((element) {
                    return buildResultCard(element);
                  }).toList())
                  : SingleChildScrollView(
                child: allPosts(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PostPlace(place: data["Name"].toLowerCase())));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Material(
          elevation: 3.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.only(left: 20.0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 100,
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      data["Image"] ?? "https://via.placeholder.com/70",
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 70,
                          width: 70,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, color: Colors.grey[600]),
                        );
                      },
                    )),
                SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["Name"] ?? "Unknown Location",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 22.0,
                            fontFamily: 'Poppins'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 20.0),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(60)),
                  child: Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.white,
                    size: 25.0,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:tourbuddy/pages/post_place.dart';

class TopPlaces extends StatefulWidget {
  const TopPlaces({super.key});

  @override
  State<TopPlaces> createState() => _TopPlacesState();
}

class _TopPlacesState extends State<TopPlaces> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                // Changed to better position the elements
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: (){
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
                  // Using Flexible with a centered Text instead of fixed SizedBox
                  Flexible(
                    child: Center(
                      child: Text(
                        "Top Places",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                child: Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPlaceItem(
                                context,
                                "Dubai",
                                "images/dubai.jpg"
                            ),
                            _buildPlaceItem(
                                context,
                                "India",
                                "images/india.jpg"
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPlaceItem(
                                context,
                                "Mexico",
                                "images/mexico.jpg"
                            ),
                            _buildPlaceItem(
                                context,
                                "France",
                                "images/france.jpg"
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPlaceItem(
                                context,
                                "New York",
                                "images/newyork.jpg"
                            ),
                            _buildPlaceItem(
                                context,
                                "Bali",
                                "images/bali.jpg"
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Extracted method to build place items with proper sizing
  Widget _buildPlaceItem(BuildContext context, String placeName, String imagePath) {
    // Calculate width based on screen size with padding
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screenWidth - 50) / 2; // Accounting for padding and space between items

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PostPlace(place: placeName.toLowerCase())));
      },
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imagePath,
              height: 300,
              width: itemWidth,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 50,
              width: itemWidth,
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: Center(
                child: Text(
                  placeName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontFamily: 'Pacifico',
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
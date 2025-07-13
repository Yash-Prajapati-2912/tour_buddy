import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    try {
      return await _firestore.collection("users").doc(id).set(userInfoMap);
    } catch (e) {
      print("Error adding user details: $e");
      throw e;
    }
  }

  Future<QuerySnapshot> getUserbyEmail(String email) async {
    try {
      return await _firestore
          .collection("users")
          .where("Email", isEqualTo: email)
          .get();
    } catch (e) {
      print("Error getting user by email: $e");
      throw e;
    }
  }

  Future<void> addPost(Map<String, dynamic> userInfoMap, String id) async {
    try {
      // Create search keys for better searching
      if (userInfoMap.containsKey("CityName") && userInfoMap["CityName"] != null) {
        // Create city search keys - add the city name in uppercase to the post data
        userInfoMap["CitySearchKey"] = userInfoMap["CityName"].toString().toUpperCase();
      }

      return await _firestore.collection("Posts").doc(id).set(userInfoMap);
    } catch (e) {
      print("Error adding post: $e");
      throw e;
    }
  }

  Stream<QuerySnapshot> getPosts() {
    try {
      return _firestore
          .collection("Posts")
          .orderBy("Timestamp", descending: true)
          .snapshots();
    } catch (e) {
      print("Error getting posts: $e");
      throw e;
    }
  }

  Future<void> addLike(String id, String userid) async {
    try {
      return await _firestore.collection("Posts").doc(id).update({
        'Like': FieldValue.arrayUnion([userid])
      });
    } catch (e) {
      print("Error adding like: $e");
      throw e;
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> addComment(Map<String, dynamic> userInfoMap, String id) async {
    try {
      print("Adding comment to Firestore: $userInfoMap");
      return await _firestore
          .collection("Posts")
          .doc(id)
          .collection("Comment")
          .add(userInfoMap);
    } catch (e) {
      print("Error adding comment: $e");
      throw e;
    }
  }

  Stream<QuerySnapshot> getComments(String id) {
    try {
      print("Getting comments for post: $id");
      return _firestore
          .collection("Posts")
          .doc(id)
          .collection("Comment")
          .orderBy("timestamp", descending: true)  // Changed from "Timestamp" to "timestamp" to match field name
          .snapshots();
    } catch (e) {
      print("Error getting comments: $e");
      throw e;
    }
  }

  Stream<QuerySnapshot> getPostsPlace(String place) {
    try {
      return _firestore
          .collection("Posts")
          .where("CityName", isEqualTo: place)
          .snapshots();
    } catch (e) {
      print("Error getting posts by place: $e");
      throw e;
    }
  }

  // Updated search method to search by city names in Posts collection
  Future<QuerySnapshot> searchCities(String cityName) async {
    try {
      String searchTerm = cityName.toUpperCase();

      return await _firestore
          .collection("Posts")
          .where("CitySearchKey", isGreaterThanOrEqualTo: searchTerm)
          .where("CitySearchKey", isLessThan: searchTerm + 'z')
          .get();
    } catch (e) {
      print("Error searching cities: $e");
      throw e;
    }
  }

  // Keep the original search method for locations
  Future<QuerySnapshot> search(String updatedname) async {
    try {
      return await _firestore
          .collection("Location")
          .where("SearchKey", isEqualTo: updatedname.substring(0, 1).toUpperCase())
          .get();
    } catch (e) {
      print("Error searching: $e");
      throw e;
    }
  }
}
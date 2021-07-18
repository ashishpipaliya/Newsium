import 'package:cloud_firestore/cloud_firestore.dart';

String get collectionName => 'inshorts';

class FirestorePath {
  static Query categoryWiseQuery({required String? category}) =>
      FirebaseFirestore.instance
          .collection(collectionName)
          .where('category', isEqualTo: category!.toLowerCase())
          .orderBy('created_at', descending: true);

  static Query get allNews => FirebaseFirestore.instance
      .collection(collectionName)
      .where('category', isEqualTo: 'trending')
      .orderBy('created_at', descending: true);
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'notificationservice.dart';
//
// class StudentNotificationListener extends StatelessWidget {
//   const StudentNotificationListener({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final _firestore = FirebaseFirestore.instance;
//     final currentUser = FirebaseAuth.instance.currentUser;
//
//     if (currentUser == null) return SizedBox(); // No user logged in
//
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .collection('leave_requests')
//           .where('userId', isEqualTo: currentUser.uid)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return SizedBox();
//
//         for (var doc in snapshot.data!.docs) {
//           var data = doc.data() as Map<String, dynamic>;
//           if (data.containsKey('notificationMessage') &&
//               data['notificationMessage'] != null) {
//             // Show local notification
//             NotificationService.showNotification(
//               "Leave Request Update",
//               data['notificationMessage'],
//             );
//
//             // Clear the notification message so it doesn't repeat
//             _firestore.collection('leave_requests').doc(doc.id).update({
//               'notificationMessage': null,
//             });
//           }
//         }
//
//         return SizedBox();
//       },
//     );
//   }
// }

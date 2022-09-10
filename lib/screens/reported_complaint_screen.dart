import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ReportedComplaintScreen extends StatelessWidget {
  const ReportedComplaintScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _reportedCompliants = FirebaseFirestore.instance
        .collection('reportedComplaints')
        .orderBy("imgUID", descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Reported Complaints'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        physics: const BouncingScrollPhysics(),
        child: StreamBuilder(
            stream: _reportedCompliants,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (streamSnapshot.connectionState ==
                      ConnectionState.active ||
                  streamSnapshot.connectionState == ConnectionState.done) {
                if (streamSnapshot.hasError) {
                  return const Center(
                    child: Text('Something got error'),
                  );
                } else if (streamSnapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No Complaints'),
                  );
                } else if (streamSnapshot.hasData) {
                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (context, index) {
                      return const Divider(
                        thickness: 2,
                      );
                    },
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];

                      return Container(
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 10,
                          right: 10,
                        ),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        documentSnapshot['userProfile'],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        documentSnapshot['userName'],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on),
                                    Expanded(
                                      child: Text(
                                        documentSnapshot['address'],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Category: ${documentSnapshot['category']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Report: ${documentSnapshot['reportedcategory']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                documentSnapshot['details'] != null
                                    ? Text(documentSnapshot['details'])
                                    : const SizedBox.shrink(),
                                const SizedBox(
                                  height: 10,
                                ),
                                Image.network(
                                  documentSnapshot['imgURL'],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    _PostButton(
                                      color: Colors.green,
                                      icon: Icons.check,
                                      text: 'Approve',
                                      ontap: () {
                                        approveComplaint(documentSnapshot);
                                      },
                                    ),
                                    _PostButton(
                                        color: Colors.red,
                                        icon: Icons.close,
                                        text: 'Reject',
                                        ontap: () {
                                          rejectComplaint(streamSnapshot,
                                              documentSnapshot, index);
                                        }),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('No Complaints'),
                  );
                }
              } else {
                return Center(
                  child: Text(streamSnapshot.connectionState.toString()),
                );
              }
            }),
      ),
    );
  }
}

Future approveComplaint(DocumentSnapshot documentSnapshot) async {
  await FirebaseFirestore.instance
      .collection('complaints')
      .doc(documentSnapshot.id)
      .set(
    {
      'email': documentSnapshot['email'],
      'imgUID': documentSnapshot['imgUID'],
      'imgURL': documentSnapshot['imgURL'],
      'address': documentSnapshot['address'],
      'details': documentSnapshot['details'],
      'category': documentSnapshot['category'],
      'lat': documentSnapshot['lat'],
      'long': documentSnapshot['long'],
      'status': documentSnapshot['status'],
      'userUID': documentSnapshot['userUID'],
      'userName': documentSnapshot['userName'],
      'userProfile': documentSnapshot['userProfile'],
      'vote': documentSnapshot['vote'],
      'votedUser': documentSnapshot['votedUser'],
      'homeFilter': documentSnapshot['homeFilter'],
      'track': documentSnapshot['track'],
    },
  );

  await FirebaseFirestore.instance
      .collection('reportedComplaints')
      .doc(documentSnapshot.id)
      .delete();
}

Future rejectComplaint(AsyncSnapshot<QuerySnapshot> streamSnapshot,
    DocumentSnapshot documentSnapshot, int index) async {
  final imgURL = documentSnapshot['imgURL'];

  await FirebaseStorage.instance.refFromURL(imgURL).delete();

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    transaction.delete(streamSnapshot.data!.docs[index].reference);
  });
}

class _PostButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback ontap;
  final Color color;

  const _PostButton(
      {required this.icon,
      required this.text,
      required this.ontap,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: ontap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  text,
                  style: TextStyle(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

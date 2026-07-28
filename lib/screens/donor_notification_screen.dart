import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorNotificationScreen extends StatelessWidget {

final String donorId;

const DonorNotificationScreen({
super.key,
required this.donorId,
});


Future<void> acceptRequest(
String requestId,
BuildContext context,
) async {

try {

DocumentSnapshot donorSnapshot =
await FirebaseFirestore.instance
.collection("donors")
.doc(donorId)
.get();


final donorData =
donorSnapshot.data()
as Map<String, dynamic>;


DocumentSnapshot requestSnapshot =
await FirebaseFirestore.instance
.collection("blood_requests")
.doc(requestId)
.get();


final requestData =
requestSnapshot.data()
as Map<String, dynamic>;


String patientId =
requestData["userId"];


await FirebaseFirestore.instance
.collection("notifications")
.doc(donorId)
.collection("requests")
.doc(requestId)
.update({

"status": "Accepted",

"donorName":
donorData["name"],

"donorPhone":
donorData["phone"],

"acceptedAt":
Timestamp.now(),

});


await FirebaseFirestore.instance
.collection("blood_requests")
.doc(requestId)
.update({

"status":
"Donor Found",

"donorId":
donorId,

"donorName":
donorData["name"],

"donorPhone":
donorData["phone"],

"acceptedAt":
Timestamp.now(),

});


await FirebaseFirestore.instance
.collection("user_notifications")
.doc(patientId)
.collection("requests")
.doc(requestId)
.set({

"message":
"Your blood request has been accepted",

"donorName":
donorData["name"],

"donorPhone":
donorData["phone"],

"status":
"Donor Found",

"isRead":
false,

"createdAt":
Timestamp.now(),

});


await FirebaseFirestore.instance
.collection("donors")
.doc(donorId)
.update({

"available":
false,

});


ScaffoldMessenger.of(context)
.showSnackBar(

const SnackBar(

content:
Text("Request Accepted"),

backgroundColor:
Colors.green,

),

);


} catch (e) {


ScaffoldMessenger.of(context)
.showSnackBar(

SnackBar(

content:
Text("Error: $e"),

backgroundColor:
Colors.red,

),

);

}

}



Future<void> rejectRequest(
String requestId,
BuildContext context,
) async {

try {

await FirebaseFirestore.instance
.collection("notifications")
.doc(donorId)
.collection("requests")
.doc(requestId)
.update({

"status":
"Rejected",

});


ScaffoldMessenger.of(context)
.showSnackBar(

const SnackBar(

content:
Text("Request Rejected"),

),

);


} catch (e) {


ScaffoldMessenger.of(context)
.showSnackBar(

SnackBar(

content:
Text("Error: $e"),

backgroundColor:
Colors.red,

),

);

}

}



Future<void> showConfirmationDialog(
BuildContext context,
String title,
String message,
VoidCallback onConfirm,
) async {

showDialog(

context: context,

builder: (context) {

return AlertDialog(

shape:
RoundedRectangleBorder(

borderRadius:
BorderRadius.circular(20),

),


title:
Text(

title,

style:
const TextStyle(

fontWeight:
FontWeight.bold,

),

),


content:
Text(message),


actions: [

TextButton(

onPressed: () {

Navigator.pop(context);

},

child:
const Text(
"Cancel",
),

),


ElevatedButton(

onPressed: () {

Navigator.pop(context);

onConfirm();

},


style:
ElevatedButton.styleFrom(

backgroundColor:
Colors.redAccent,

),


child:
const Text(

"Confirm",

style:
TextStyle(

color:
Colors.white,

),

),

),

],

);

},

);

}
@override
Widget build(BuildContext context) {

return Scaffold(

backgroundColor:
const Color(0xffF7F9FC),


appBar: AppBar(

elevation:
0,

backgroundColor:
Colors.redAccent,


title:
const Text(

"Blood Requests",

style:
TextStyle(

fontWeight:
FontWeight.bold,

),

),

),



body:
StreamBuilder<QuerySnapshot>(

stream:
FirebaseFirestore.instance

.collection("notifications")

.doc(donorId)

.collection("requests")

.orderBy(

"createdAt",

descending:
true,

)

.snapshots(),



builder:
(context, snapshot) {


if (snapshot.connectionState ==
ConnectionState.waiting) {


return const Center(

child:
CircularProgressIndicator(),

);

}



if (!snapshot.hasData ||
snapshot.data!.docs.isEmpty) {


return const Center(

child:
Text(

"No blood requests available",

style:
TextStyle(

fontSize:
18,

),

),

);

}



return ListView.builder(

padding:
const EdgeInsets.all(15),


itemCount:
snapshot.data!.docs.length,


itemBuilder:
(context, index) {


var request =
snapshot.data!.docs[index];


var data =
request.data()
as Map<String, dynamic>;



String status =
data["status"] ??
"Pending";



return Container(

margin:
const EdgeInsets.only(
bottom: 18
),



decoration:
BoxDecoration(

color:
Colors.white,


borderRadius:
BorderRadius.circular(
20
),



boxShadow: [

BoxShadow(

color:
Colors.grey.withOpacity(
0.15
),

blurRadius:
10,

spreadRadius:
2,

),

],

),



child:
Padding(

padding:
const EdgeInsets.all(18),



child:
Column(

crossAxisAlignment:
CrossAxisAlignment.start,



children: [


Row(

mainAxisAlignment:
MainAxisAlignment.spaceBetween,


children: [


const Text(

"🚨 Emergency Request",

style:
TextStyle(

fontSize:
18,

fontWeight:
FontWeight.bold,

color:
Colors.red,

),

),



Container(

padding:
const EdgeInsets.symmetric(

horizontal:
12,

vertical:
6,

),


decoration:
BoxDecoration(

color:

status ==
"Pending"

? Colors.orange

: Colors.green,


borderRadius:
BorderRadius.circular(
20
),

),



child:
Text(

status,

style:
const TextStyle(

color:
Colors.white,

fontWeight:
FontWeight.bold,

fontSize:
12,

),

),

),


],

),



const SizedBox(
height:
18,
),



Row(

children: [


Container(

padding:
const EdgeInsets.all(
12
),


decoration:
BoxDecoration(

color:
Colors.red.withOpacity(
0.1
),


borderRadius:
BorderRadius.circular(
12
),

),


child:
Text(

data["bloodGroup"] ??
"",


style:
const TextStyle(

color:
Colors.red,

fontWeight:
FontWeight.bold,

fontSize:
18,

),

),

),



const SizedBox(
width:
15,
),



Text(

"${data["units"]} Units Required",

style:
const TextStyle(

fontWeight:
FontWeight.bold,

fontSize:
16,

),

),

],

),



const SizedBox(
height:
18,
),



buildInfoRow(

Icons.person,

"Patient",

data["patientName"],

),



buildInfoRow(

Icons.local_hospital,

"Hospital",

data["hospital"],

),



buildInfoRow(

Icons.location_on,

"Location",

data["location"],

),



buildInfoRow(

Icons.warning,

"Emergency",

data["emergencyLevel"],

),



const SizedBox(
height:
20,
),
  if (status == "Pending")

    Row(

      children: [


        Expanded(

          child:
          ElevatedButton(

            onPressed: () {

              showConfirmationDialog(

                context,

                "Accept Request?",

                "Are you sure you want to accept this blood donation request?",

                    () {

                  acceptRequest(

                    request.id,

                    context,

                  );

                },

              );

            },


            style:
            ElevatedButton.styleFrom(

              backgroundColor:
              Colors.green,


              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(
                    12
                ),

              ),

            ),


            child:
            const Text(

              "Accept",

              style:
              TextStyle(

                color:
                Colors.white,

              ),

            ),

          ),

        ),



        const SizedBox(
          width:
          12,
        ),



        Expanded(

          child:
          ElevatedButton(

            onPressed: () {

              showConfirmationDialog(

                context,

                "Reject Request?",

                "Are you sure you want to reject this blood donation request?",

                    () {

                  rejectRequest(

                    request.id,

                    context,

                  );

                },

              );

            },


            style:
            ElevatedButton.styleFrom(

              backgroundColor:
              Colors.red,


              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(
                    12
                ),

              ),

            ),


            child:
            const Text(

              "Reject",

              style:
              TextStyle(

                color:
                Colors.white,

              ),

            ),

          ),

        ),

      ],

    ),


],

),

),

);

},

);

},

),

);

}



Widget buildInfoRow(

    IconData icon,

    String title,

    dynamic value,

    ) {


  return Padding(

    padding:
    const EdgeInsets.only(

      bottom:
      10,

    ),


    child:
    Row(

      children: [


        Icon(

          icon,

          color:
          Colors.redAccent,

          size:
          22,

        ),



        const SizedBox(

          width:
          10,

        ),



        Text(

          "$title: ",

          style:
          const TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),



        Expanded(

          child:
          Text(

            value?.toString() ?? "",


            style:
            TextStyle(

              color:
              Colors.grey[700],

            ),

          ),

        ),

      ],

    ),

  );

}

}
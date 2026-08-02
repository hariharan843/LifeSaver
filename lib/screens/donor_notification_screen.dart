import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';


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


if(!donorSnapshot.exists){
return;
}


final donorData =
donorSnapshot.data()
as Map<String,dynamic>;




DocumentSnapshot requestSnapshot =
await FirebaseFirestore.instance
.collection("blood_requests")
.doc(requestId)
.get();



if(!requestSnapshot.exists){
return;
}



final requestData =
requestSnapshot.data()
as Map<String,dynamic>;




// Stop donor accepting after organisation handled

if(requestData["status"] ==
"Organisation Handling"){


ScaffoldMessenger.of(context)
.showSnackBar(

const SnackBar(

content:
Text(
"This request is already handled by an organisation",
),

backgroundColor:
Colors.orange,

),

);


return;

}





String patientId =
requestData["userId"];












// Update blood request

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







// Remove request from other donors

final allDonorNotifications =
await FirebaseFirestore.instance
.collection("notifications")
.get();



for(var donor in allDonorNotifications.docs){


if(donor.id != donorId){


await FirebaseFirestore.instance
.collection("notifications")
.doc(donor.id)
.collection("requests")
.doc(requestId)
.delete()
.catchError((_) {});


}


}







// Notify patient

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








// Make donor unavailable

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
Text(
"Request Accepted",
),

backgroundColor:
Colors.green,

),

);



}

catch(e){


ScaffoldMessenger.of(context)
.showSnackBar(

SnackBar(

content:
Text(
"Error: $e",
),

backgroundColor:
Colors.red,

),

);


}

}
Future<void> completeDonation(
    String requestId,
    BuildContext context,
    ) async {

  try {

    // Make donor available again
    await FirebaseFirestore.instance
        .collection("donors")
        .doc(donorId)
        .update({
      "available": true,
    });

    // Get patient ID first
    final requestSnapshot = await FirebaseFirestore.instance
        .collection("blood_requests")
        .doc(requestId)
        .get();

    String? patientId;

    if (requestSnapshot.exists) {
      final requestData =
      requestSnapshot.data() as Map<String, dynamic>;

      patientId = requestData["userId"];
    }

// Update blood request status
    await FirebaseFirestore.instance
        .collection("blood_requests")
        .doc(requestId)
        .update({
      "status": "Completed",
      "completedAt": Timestamp.now(),
    });

// Notify patient
    if (patientId != null) {
      await FirebaseFirestore.instance
          .collection("user_notifications")
          .doc(patientId)
          .collection("requests")
          .doc(requestId)
          .set({
        "message": "Your blood donation has been completed successfully.",
        "status": "Completed",
        "isRead": false,
        "createdAt": Timestamp.now(),
      });
    }

    // Remove notification from donor
    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(donorId)
        .collection("requests")
        .doc(requestId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Donation completed successfully"),
        backgroundColor: Colors.green,
      ),
    );

  } catch (e) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
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
      .delete();





ScaffoldMessenger.of(context)
.showSnackBar(

const SnackBar(

content:
Text(
"Request Rejected",
),

),

);



}


catch(e){


ScaffoldMessenger.of(context)
.showSnackBar(

SnackBar(

content:
Text(
"Error: $e",
),

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

builder:(context){


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




actions:[


TextButton(

onPressed:(){

Navigator.pop(context);

},

child:
const Text(
"Cancel",
),

),





ElevatedButton(

onPressed:(){

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
        descending: true,
      )
          .snapshots(),




      builder:
          (context,snapshot){



        if(snapshot.connectionState ==
            ConnectionState.waiting){


          return const Center(

            child:
            CircularProgressIndicator(),

          );

        }






        if(!snapshot.hasData ||
            snapshot.data!.docs.isEmpty){


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
              (context,index){



            var request =
            snapshot.data!.docs[index];



            var data =
            request.data()
            as Map<String,dynamic>;




return StreamBuilder<DocumentSnapshot>(

stream: FirebaseFirestore.instance
.collection("blood_requests")
.doc(request.id)
.snapshots(),

builder: (context, requestSnapshot) {

if (requestSnapshot.connectionState ==
ConnectionState.waiting) {

return const SizedBox();
}

if (!requestSnapshot.hasData ||
!requestSnapshot.data!.exists) {

return const SizedBox();
}

final bloodRequest =
requestSnapshot.data!.data()
as Map<String, dynamic>;

String status =
bloodRequest["status"] ?? "Pending";





            return Container(


              margin:
              const EdgeInsets.only(

                bottom:
                18,

              ),



              decoration:
              BoxDecoration(

                color:
                Colors.white,


                borderRadius:
                BorderRadius.circular(20),


                boxShadow:[


                  BoxShadow(

                    color:
                    Colors.grey.withOpacity(0.15),

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





                  children:[




                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,


                      children:[



                        const Text(

                          "Blood Request",

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

                                ?

                            Colors.orange

                                :

                            Colors.green,


                            borderRadius:
                            BorderRadius.circular(20),

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





                    buildInfoRow(

                      Icons.person,

                      "Patient",

                      data["patientName"],

                    ),





                    buildInfoRow(

                      Icons.bloodtype,

                      "Blood Group",

                      data["bloodGroup"],

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





                    const SizedBox(

                      height:
                      15,

                    ),






                    // Organisation handled message

                    if(status ==
                        "Organisation Handling")

                      Container(

                        width:
                        double.infinity,


                        padding:
                        const EdgeInsets.all(12),


                        decoration:
                        BoxDecoration(

                          color:
                          Colors.orange.shade50,

                          borderRadius:
                          BorderRadius.circular(12),

                        ),



                        child:
                        const Text(

                          "This request has been taken by an organisation. You cannot accept this request now.",


                          style:
                          TextStyle(

                            color:
                            Colors.orange,

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),


                      ),







                    // Patient phone after donor acceptance

                    if(status == "Donor Found")

                      Column(

                        children:[


                          const SizedBox(

                            height:
                            15,

                          ),



                          Row(

                            children:[


                              Expanded(

                                child:
                                Text(

                                  "Patient Contact: ${bloodRequest["phone"] ?? "N/A"}",

                                  style:
                                  const TextStyle(

                                    color:
                                    Colors.green,

                                    fontWeight:
                                    FontWeight.bold,

                                  ),

                                ),

                              ),





                              ElevatedButton.icon(

                                onPressed:() async{


                                  final Uri callUri =
                                  Uri(

                                    scheme:
                                    "tel",

                                    path:
                                    bloodRequest["phone"],

                                  );



                                  if(await canLaunchUrl(callUri)){

                                    await launchUrl(callUri);

                                  }


                                },


                                icon:
                                const Icon(
                                  Icons.call,
                                ),


                                label:
                                const Text(
                                  "CALL",
                                ),


                                style:
                                ElevatedButton.styleFrom(

                                  backgroundColor:
                                  Colors.green,

                                  foregroundColor:
                                  Colors.white,

                                ),

                              ),



                            ],


                          ),
                          const SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                completeDonation(request.id, context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text(
                                "COMPLETE DONATION",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),


                        ],


                      )







                    // Accept Reject buttons only pending

                    else if(status ==
                        "Pending")

                      Column(

                        children:[



                          const SizedBox(

                            height:
                            15,

                          ),



                          Row(

                            children:[



                              Expanded(

                                child:
                                ElevatedButton(

                                  onPressed:(){


                                    showConfirmationDialog(

                                      context,

                                      "Accept Request?",

                                      "Are you sure you want to accept this request?",


                                          (){

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

                                  onPressed:(){


                                    showConfirmationDialog(

                                      context,

                                      "Reject Request?",

                                      "Are you sure you want to reject this request?",


                                          (){

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




                  ],


                ),


              ),


            );
}, // StreamBuilder builder

); // StreamBuilder

              }, // ListView itemBuilder

        ); // ListView.builder

          }, // Outer StreamBuilder builder

    )
  );


  }



Widget buildInfoRow(

    IconData icon,

    String title,

    dynamic value,

    ){



  return Padding(

    padding:
    const EdgeInsets.only(

      bottom:
      10,

    ),



    child:
    Row(


      children:[



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
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';


class OrganisationBloodRequestsScreen extends StatefulWidget {

  const OrganisationBloodRequestsScreen({
    super.key,
  });


  @override
  State<OrganisationBloodRequestsScreen> createState() =>
      _OrganisationBloodRequestsScreenState();

}



class _OrganisationBloodRequestsScreenState
    extends State<OrganisationBloodRequestsScreen> {
  String? selectedDonorId;


String? organisationLocation;

bool loading = true;



@override
void initState(){

super.initState();

loadOrganisationLocation();

}




Future<void> loadOrganisationLocation() async {


final user =
FirebaseAuth.instance.currentUser;



if(user == null){
return;
}




DocumentSnapshot snapshot =
await FirebaseFirestore.instance
.collection("organisations")
.doc(user.uid)
.get();




setState(() {


if(snapshot.exists){

organisationLocation =
snapshot["location"];

}


loading = false;


});


}
Future<void> showSelectDonorDialog(
    String requestId,
    ) async {

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  final donors = await FirebaseFirestore.instance
      .collection("donors")
      .where(
    "organisationId",
    isEqualTo: user.uid,
  )
      .where(
    "available",
    isEqualTo: true,
  )
      .get();

  showDialog(
    context: context,
    builder: (context) {

      return AlertDialog(

        title: const Text(
          "Select Donor",
        ),

        content: SizedBox(
          width: double.maxFinite,
          height: 300,

          child: ListView.builder(

            itemCount: donors.docs.length,

            itemBuilder: (context, index) {

              final donor =
              donors.docs[index];

              final data =
              donor.data();

              return RadioListTile<String>(

                value: donor.id,

                groupValue: selectedDonorId,

                onChanged: (value) {

                  setState(() {

                    selectedDonorId = value;

                  });

                  Navigator.pop(context);

                  showSelectDonorDialog(requestId);

                },

                title: Text(
                  data["name"],
                ),

                subtitle: Text(
                  "${data["bloodGroup"]} • ${data["phone"]}",
                ),

              );

            },

          ),

        ),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(context);

            },

            child: const Text(
              "Cancel",
            ),

          ),

          ElevatedButton(

            onPressed: selectedDonorId == null
                ? null
                : () async {

              final donorDoc = await FirebaseFirestore.instance
                  .collection("donors")
                  .doc(selectedDonorId)
                  .get();

              final donorData =
              donorDoc.data() as Map<String, dynamic>;
              donorData["donorId"] = donorDoc.id;

              Navigator.pop(context);

              await handleRequest(
                requestId,
                donorData,
              );

            },

            child: const Text(
              "ASSIGN DONOR",
            ),

          ),

        ],

      );

    },

  );

}
  Future<void> showDonorAssignedDialog(
      String donorName,
      String donorPhone,
      ) async {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: const Text(
            "✅ Donor Assigned Successfully",
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Donor: $donorName",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Phone: $donorPhone",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Please contact the donor and ask them to reach the hospital.",
              ),

            ],
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

              },

              child: const Text("OK"),

            ),

            ElevatedButton.icon(

              onPressed: () async {

                final Uri callUri = Uri(
                  scheme: "tel",
                  path: donorPhone,
                );

                if (await canLaunchUrl(callUri)) {
                  await launchUrl(callUri);
                }

              },

              icon: const Icon(Icons.call),

              label: const Text("CALL DONOR"),

            ),

          ],

        );

      },

    );

  }




  Future<void> handleRequest(
      String requestId,
      Map<String, dynamic> donorData,
      ) async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final organisationSnapshot = await FirebaseFirestore.instance
        .collection("organisations")
        .doc(user.uid)
        .get();

    if (!organisationSnapshot.exists) return;

    final organisationData =
    organisationSnapshot.data() as Map<String, dynamic>;
    final selectedDonorId =
    donorData["donorId"];
    final selectedDonorName = donorData["name"];
    final selectedDonorPhone = donorData["phone"];

    await FirebaseFirestore.instance
        .collection("blood_requests")
        .doc(requestId)
        .update({
      "status": "Organisation Handling",

      "organisationId": user.uid,
      "organisationName": organisationData["organisationName"],

      "donorId": selectedDonorId,
      "donorName": selectedDonorName,
      "donorPhone": selectedDonorPhone,

      "acceptedAt": Timestamp.now(),
    });
    final requestSnapshot = await FirebaseFirestore.instance
        .collection("blood_requests")
        .doc(requestId)
        .get();

    final requestData =
    requestSnapshot.data() as Map<String, dynamic>;



    await showDonorAssignedDialog(
      selectedDonorName,
      selectedDonorPhone,
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  Future<void> showCompleteDonationDialog(
      String requestId,
      ) async {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Complete Donation",
          ),

          content: const Text(
            "Are you sure the donor has successfully donated blood?",
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

              },

              child: const Text(
                "Cancel",
              ),

            ),

            ElevatedButton(

              onPressed: () async {

                Navigator.pop(context);

                await completeDonation(
                  requestId,
                );

              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),

              child: const Text(
                "Complete",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

            ),

          ],

        );

      },

    );

  }
Future<void> completeDonation(
String requestId
) async {


try {



// Read the blood request first

  final requestSnapshot =
  await FirebaseFirestore.instance
      .collection("blood_requests")
      .doc(requestId)
      .get();

  String? donorId;

  if (requestSnapshot.exists) {
    final requestData =
    requestSnapshot.data() as Map<String, dynamic>;

    donorId = requestData["donorId"];
  }

// Make donor available again

  if (donorId != null) {
    await FirebaseFirestore.instance
        .collection("donors")
        .doc(donorId)
        .update({
      "available": true,
    });
  }

  await FirebaseFirestore.instance
      .collection("blood_requests")
      .doc(requestId)
      .delete();
  final requestData =
  requestSnapshot.data() as Map<String, dynamic>;

  await FirebaseFirestore.instance
      .collection("user_notifications")
      .doc(requestData["userId"])
      .collection("requests")
      .doc(requestId)
      .set({

    "message":
    "Your blood donation has been completed successfully.",

    "status":
    "Completed",

    "isRead":
    false,

    "createdAt":
    Timestamp.now(),

  });










ScaffoldMessenger.of(context)
.showSnackBar(


const SnackBar(


content:
Text(
"Donation completed"
),



backgroundColor:
Colors.blue,



),


);



}



catch(e){


ScaffoldMessenger.of(context)
.showSnackBar(



SnackBar(


content:
Text(
e.toString()
),



backgroundColor:
Colors.red,



),



);


}


}






  Widget buildInfoRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),

        ],
      ),
    );
  }

@override
Widget build(BuildContext context) {


return Scaffold(


backgroundColor:
const Color(0xffF4F8FC),




appBar:
AppBar(


title:
const Text(


"Blood Requests",


style:
TextStyle(

fontWeight:
FontWeight.bold,

),


),




centerTitle:
true,



backgroundColor:
const Color(0xffD32F2F),



),






body:


loading

?

const Center(

child:
CircularProgressIndicator(),

)

:


organisationLocation == null


?

const Center(


child:
Text(

"Organisation location not found",

style:
TextStyle(

fontSize:
18,

fontWeight:
FontWeight.bold,

),

),


)


:


StreamBuilder<QuerySnapshot>(


stream:

FirebaseFirestore.instance
.collection("blood_requests")
.where(
"location",
isEqualTo:
organisationLocation,
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

fontWeight:
FontWeight.bold,

),

),

);


}




return ListView.builder(

padding:
const EdgeInsets.all(20),


itemCount:
snapshot.data!.docs.length,


itemBuilder:
(context,index){


final request =
snapshot.data!.docs[index];


final data =
request.data()
as Map<String,dynamic>;



String status =
data["status"] ??
"Pending";
String displayStatus = status;

if (status == "Organisation Handling") {
  displayStatus = "Assigned";
}
// Hide requests handled by another organisation

if(status == "Organisation Handling" &&
    data["organisationId"] !=
        FirebaseAuth.instance.currentUser!.uid){

  return const SizedBox();

}





return Card(


  elevation:
  3,


  margin:
  const EdgeInsets.only(
    bottom: 15,
  ),



  shape:
  RoundedRectangleBorder(


    borderRadius:
    BorderRadius.circular(18),


  ),




  child:
  Padding(


    padding:
    const EdgeInsets.all(15),



    child:
    Column(


      crossAxisAlignment:
      CrossAxisAlignment.start,



      children:[




        Row(

          children: [

            Expanded(

              child: Text(

                "Blood Request",

                style: TextStyle(

                  fontSize: 20,

                  fontWeight: FontWeight.bold,

                  color: Colors.red.shade700,

                ),

              ),

            ),

            Container(

              padding: const EdgeInsets.symmetric(

                horizontal: 12,

                vertical: 6,

              ),

              decoration: BoxDecoration(

                color:

                status == "Pending"

                    ? Colors.orange

                    : status == "Organisation Handling"

                    ? Colors.blue

                    : Colors.green,

                borderRadius:
                BorderRadius.circular(20),

              ),

              child: Text(

                displayStatus,

                style: const TextStyle(

                  color: Colors.white,

                  fontWeight: FontWeight.bold,

                  fontSize: 12,

                ),

              ),

            ),

          ],

        ),
        const SizedBox(height: 20),

        buildInfoRow(
          "Patient Name",
          data["patientName"] ?? "N/A",
        ),

        buildInfoRow(
          "Blood Group",
          data["bloodGroup"] ?? "N/A",
        ),

        buildInfoRow(
          "Units Required",
          data["units"]?.toString() ?? "N/A",
        ),

        buildInfoRow(
          "Hospital",
          data["hospital"] ?? "N/A",
        ),

        buildInfoRow(
          "Location",
          data["location"] ?? "N/A",
        ),

        const SizedBox(height: 10),
        if (data["organisationName"] != null) ...[

          const SizedBox(height: 15),

          buildInfoRow(
            "Handled By",
            data["organisationName"] ?? "N/A",
          ),

        ],





        const SizedBox(
          height:15,
        ),
        if (data["donorName"] != null) ...[

          const SizedBox(height: 15),

          const Divider(),

          const Text(
            "Assigned Donor",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          buildInfoRow(
            "Name",
            data["donorName"] ?? "N/A",
          ),

          buildInfoRow(
            "Phone",
            data["donorPhone"] ?? "N/A",
          ),

          const SizedBox(height: 10),

          if (data["donorPhone"] != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {

                  final Uri callUri = Uri(
                    scheme: "tel",
                    path: data["donorPhone"],
                  );

                  if (await canLaunchUrl(callUri)) {
                    await launchUrl(callUri);
                  }

                },
                icon: const Icon(Icons.call),
                label: const Text("CALL DONOR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

        ],






        // Show patient contact only after organisation handles


        if (status == "Organisation Handling") ...[

          const SizedBox(height: 15),

          const Divider(),

          const Text(
            "Patient Contact",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          buildInfoRow(
            "Phone",
            data["phone"] ?? "N/A",
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {

                final Uri callUri = Uri(
                  scheme: "tel",
                  path: data["phone"],
                );

                if (await canLaunchUrl(callUri)) {
                  await launchUrl(callUri);
                }

              },

              icon: const Icon(Icons.call),

              label: const Text("CALL PATIENT"),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),

        ]




        else


          Container(


            padding:
            const EdgeInsets.all(10),



            decoration:
            BoxDecoration(


              color:
              Colors.orange.shade50,



              borderRadius:
              BorderRadius.circular(10),



            ),




            child:
            const Text(



              "Patient contact details will be shared after accepting this request.",



              style:
              TextStyle(


                color:
                Colors.orange,



              ),


            ),


          ),








        const SizedBox(
          height:15,
        ),







        // HANDLE REQUEST button


        if(status ==
            "Pending")

          SizedBox(


            width:
            double.infinity,



            child:
            ElevatedButton(



              onPressed: () {

                showSelectDonorDialog(
                    request.id
                );

              },


              style:
              ElevatedButton.styleFrom(


                backgroundColor:
                Colors.green,


              ),




              child:
              const Text(


                "HANDLE REQUEST",



                style:
                TextStyle(


                  color:
                  Colors.white,


                ),


              ),



            ),



          ),








        // COMPLETE DONATION button


        if(status ==
            "Organisation Handling")

          SizedBox(


            width:
            double.infinity,



            child:
            ElevatedButton(

              onPressed: () {

                showCompleteDonationDialog(
                    request.id
                );

              },



              style:
              ElevatedButton.styleFrom(


                backgroundColor:
                Colors.blue,


              ),




              child:
              const Text(



                "COMPLETE DONATION",



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



  ),



);



},



);



},



),



);


}


}
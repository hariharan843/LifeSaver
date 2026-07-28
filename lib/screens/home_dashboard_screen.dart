import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/emergency_card.dart';
import '../widgets/blood_profile_card.dart';
import '../widgets/service_card.dart';
import 'blood_request_screen.dart';
import 'donor_selection_screen.dart';
import 'donor_registration_screen.dart';
import 'organisations_registration_screen.dart';
import 'profile_screen.dart';
import 'donor_notification_screen.dart';
import 'notifications_screen.dart';
import 'patient_request_screen.dart';
import 'login_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState
    extends State<HomeDashboardScreen> {

Future<void> logoutUser() async {
await FirebaseAuth.instance.signOut();

if (!mounted) return;

Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) =>
const LoginScreen(),
),
);
}


Future<String> getUserName() async {
String uid =
FirebaseAuth.instance.currentUser!.uid;

DocumentSnapshot snapshot =
await FirebaseFirestore.instance
.collection("users")
.doc(uid)
.get();

if (snapshot.exists) {

Map<String, dynamic> data =
snapshot.data()
as Map<String, dynamic>;

return data["name"] ?? "User";
}

return "User";
}


Future<DocumentSnapshot> getDonorDetails() async {

String uid =
FirebaseAuth.instance.currentUser!.uid;

return await FirebaseFirestore.instance
.collection("donors")
.doc(uid)
.get();

}


Widget notificationIcon({
required Widget icon,
required Stream<QuerySnapshot> stream,
required VoidCallback onTap,
}) {

return StreamBuilder<QuerySnapshot>(

stream: stream,

builder: (context, snapshot) {

final count =
snapshot.hasData
? snapshot.data!.docs.length
: 0;


return Stack(

clipBehavior: Clip.none,

children: [

IconButton(
onPressed: onTap,
icon: icon,
),


if (count > 0)

Positioned(

right: 4,

top: 4,

child: Container(

padding:
const EdgeInsets.symmetric(
horizontal: 5,
vertical: 2,
),

constraints:
const BoxConstraints(
minWidth: 18,
minHeight: 18,
),


decoration:
const BoxDecoration(

color: Colors.red,

shape:
BoxShape.circle,

),


alignment:
Alignment.center,


child: Text(

count > 99
? "99+"
: "$count",

style:
const TextStyle(

color:
Colors.white,

fontSize:
10,

fontWeight:
FontWeight.bold,

),

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

String userId =
FirebaseAuth.instance.currentUser!.uid;


return Scaffold(

backgroundColor:
const Color(0xffF4F8FC),


  appBar: AppBar(

    elevation: 0,

    backgroundColor:
    const Color(0xffD32F2F),


    shape: const RoundedRectangleBorder(

      borderRadius: BorderRadius.vertical(

        bottom: Radius.circular(25),

      ),

    ),


    title: Row(

      children: [

        Container(

          padding:
          const EdgeInsets.all(8),

          decoration:
          BoxDecoration(

            color:
            Colors.white.withOpacity(0.2),

            shape:
            BoxShape.circle,

          ),

          child:
          const Icon(

            Icons.favorite,

            color:
            Colors.white,

            size:
            22,

          ),

        ),


        const SizedBox(width: 10),


        const Text(

          "LifeSaver",

          style:
          TextStyle(

            fontSize:
            22,

            fontWeight:
            FontWeight.bold,

            color:
            Colors.white,

          ),

        ),

      ],

    ),


    actions: [

      notificationIcon(

        icon:
        const Icon(

          Icons.bloodtype,

          color:
          Colors.white,

        ),


        stream:
        FirebaseFirestore.instance
            .collection("notifications")
            .doc(userId)
            .collection("requests")
            .where(
          "status",
          isEqualTo: "Pending",
        )
            .snapshots(),


        onTap: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (context) =>
                  DonorNotificationScreen(

                    donorId: userId,

                  ),

            ),

          );

        },

      ),



      notificationIcon(

        icon:
        const Icon(

          Icons.notifications,

          color:
          Colors.white,

        ),


        stream:
        FirebaseFirestore.instance
            .collection("user_notifications")
            .doc(userId)
            .collection("requests")
            .where(
          "status",
          isEqualTo: "Donor Found",
        )
            .where(
          "isRead",
          isEqualTo: false,
        )
            .snapshots(),


        onTap: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (context) =>
              const NotificationsScreen(),

            ),

          );

        },

      ),



      IconButton(

        onPressed:
        logoutUser,


        icon:
        const Icon(

          Icons.logout,

          color:
          Colors.white,

        ),

      ),


    ],

  ),
body:
SingleChildScrollView(

padding:
const EdgeInsets.all(20),


child:
Column(

crossAxisAlignment:
CrossAxisAlignment.start,


children: [


FutureBuilder<String>(

future:
getUserName(),


builder:
(context, snapshot) {


return Text(

"Welcome ${snapshot.data ?? "User"}",


style:
const TextStyle(

fontSize:
28,

fontWeight:
FontWeight.bold,

),

);

},

),



const SizedBox(
height: 8,
),



const Text(

"Emergency blood support when you need it most.",


style:
TextStyle(

fontSize:
16,

color:
Color(0xff546E7A),

),

),



const SizedBox(
height: 20,
),



  FutureBuilder<DocumentSnapshot>(

    future:
    getDonorDetails(),


    builder:
        (context, snapshot) {


      if (!snapshot.hasData ||
          !snapshot.data!.exists) {

        return const SizedBox();

      }


      Map<String, dynamic> data =
      snapshot.data!.data()
      as Map<String, dynamic>;



      return BloodProfileCard(

        bloodGroup:
        data["bloodGroup"] ?? "N/A",


        location:
        data["location"] ?? "Unknown",


        available:
        data["available"] == true,

      );

    },

  ),

const SizedBox(
height: 25,
),



  EmergencyCard(

    onTap: () {

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (context) =>
          const BloodRequestScreen(),

        ),

      );

    },

  ),
const SizedBox(
height: 30,
),



  const Text(
    "Quick Services",
    style: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(height: 18),

  Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 190,
          child: ServiceCard(
            icon: Icons.volunteer_activism,
            title: "Become Donor",
            subtitle: "Register to donate blood",
            color: const Color(0xff2E7D32),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const DonorSelectionScreen(),
                ),
              );
            },
          ),
        ),
      ),

      const SizedBox(width: 15),

      Expanded(
        child: SizedBox(
          height: 190,
          child: ServiceCard(
            icon: Icons.assignment,
            title: "My Requests",
            subtitle: "Track your blood requests",
            color: const Color(0xffEF6C00),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const PatientRequestScreen(),
                ),
              );
            },
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 15),

  SizedBox(
    width: double.infinity,
    height: 190,
    child: ServiceCard(
      icon: Icons.person,
      title: "Profile",
      subtitle: "Manage your account",
      color: const Color(0xff6A1B9A),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
            const ProfileScreen(),
          ),
        );
      },
    ),
  ),

  const SizedBox(height: 30),



  const Text(

    "Recent Activity",

    style:
    TextStyle(

      fontSize: 21,

      fontWeight: FontWeight.bold,

    ),

  ),


  const SizedBox(
    height: 12,
  ),


  StreamBuilder<QuerySnapshot>(

    stream:
    FirebaseFirestore.instance
        .collection("activities")
        .where(
      "userId",
      isEqualTo: userId,
    )
        .orderBy(
      "createdAt",
      descending: true,
    )
        .limit(3)
        .snapshots(),


    builder:
        (context, snapshot) {


      if(!snapshot.hasData ||
          snapshot.data!.docs.isEmpty){

        return Card(

          elevation: 3,

          color:
          Colors.white,


          shape:
          RoundedRectangleBorder(

            borderRadius:
            BorderRadius.circular(18),

          ),


          child:
          const ListTile(

            leading:
            Icon(

              Icons.info_outline,

              color:
              Color(0xffD32F2F),

            ),


            title:
            Text(

              "No recent activity",

              style:
              TextStyle(

                fontWeight:
                FontWeight.bold,

              ),

            ),


            subtitle:
            Text(

              "Your blood requests and donations will appear here.",

            ),

          ),

        );

      }



      return Column(

        children:

        snapshot.data!.docs.map((doc){


          Map<String,dynamic> data =
          doc.data()
          as Map<String,dynamic>;


          return Card(

            elevation: 3,

            margin:
            const EdgeInsets.only(
              bottom: 12,
            ),


            color:
            Colors.white,


            shape:
            RoundedRectangleBorder(

              borderRadius:
              BorderRadius.circular(18),

            ),


            child:
            ListTile(


              leading:
              Container(

                padding:
                const EdgeInsets.all(10),

                decoration:
                BoxDecoration(

                  color:
                  const Color(0xffFFCDD2),

                  borderRadius:
                  BorderRadius.circular(12),

                ),

                child:
                const Icon(

                  Icons.bloodtype,

                  color:
                  Color(0xffD32F2F),

                ),

              ),



              title:
              Text(

                "${data["title"]} Activity",

                style:
                const TextStyle(

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              subtitle:
              Text(
                "${data["description"] ?? ""}\n"
                    "Status: ${data["status"] ?? "Pending"}",
              ),
              trailing:
              Icon(

                data["status"] == "Completed"
                    ? Icons.check_circle
                    : Icons.access_time,

                color:
                data["status"] == "Completed"
                    ? Colors.green
                    : Colors.orange,

              ),


            ),

          );


        }).toList(),

      );


    },
  ),
],

),

),
  bottomNavigationBar:
  BottomNavigationBar(

    currentIndex:
    0,


    selectedItemColor:
    const Color(0xffD32F2F),


    unselectedItemColor:
    Colors.grey,


    backgroundColor:
    Colors.white,


    items:
    const [

      BottomNavigationBarItem(

        icon:
        Icon(
          Icons.home,
        ),

        label:
        "Home",

      ),
      BottomNavigationBarItem(

        icon:
        Icon(
          Icons.person,
        ),

        label:
        "Profile",

      ),

    ],

  ),

);

}

}
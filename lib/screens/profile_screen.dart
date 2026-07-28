import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_donor_profile_screen.dart';
import 'edit_user_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
bool isDonorAvailable = false;
bool isDonor = false;

final String uid = FirebaseAuth.instance.currentUser!.uid;

Future<DocumentSnapshot> getUserData() async {
return await FirebaseFirestore.instance
.collection("users")
.doc(uid)
.get();
}

Future<DocumentSnapshot> getDonorData() async {
return await FirebaseFirestore.instance
.collection("donors")
.doc(uid)
.get();
}

Future<void> updateAvailability(bool value) async {
setState(() {
isDonorAvailable = value;
});

await FirebaseFirestore.instance
.collection("donors")
.doc(uid)
.update({
"available": value,
});
}

void showAvailabilityDialog(bool value) {
showDialog(
context: context,
builder: (context) {
return AlertDialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
),
title: Text(
value
? "Enable Availability?"
: "Disable Availability?",
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
content: Text(
value
? "You will start receiving blood requests from patients."
: "You will stop receiving blood requests.",
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text("Cancel"),
),
ElevatedButton(
onPressed: () {
Navigator.pop(context);
updateAvailability(value);
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
),
child: const Text(
"Confirm",
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
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xffF7F9FC),
appBar: AppBar(
elevation: 0,
backgroundColor: Colors.redAccent,
title: const Text(
"My Profile",
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),
body: FutureBuilder(
future: Future.wait([
getUserData(),
getDonorData(),
]),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (!snapshot.hasData) {
return const Center(
child: Text(
"No profile data found",
),
);
}

List<DocumentSnapshot> data =
snapshot.data as List<DocumentSnapshot>;

DocumentSnapshot userSnapshot = data[0];
DocumentSnapshot donorSnapshot = data[1];

Map<String, dynamic> userData =
userSnapshot.data() as Map<String, dynamic>? ?? {};

Map<String, dynamic> donorData =
donorSnapshot.data() as Map<String, dynamic>? ?? {};

isDonor = donorSnapshot.exists;
isDonorAvailable =
donorData["available"] ?? false;

return SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
children: [

Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [
Colors.redAccent,
Colors.red,
],
),
borderRadius:
BorderRadius.circular(25),
),
child: Column(
children: [

const CircleAvatar(
radius: 45,
backgroundColor: Colors.white,
child: Icon(
Icons.person,
size: 55,
color: Colors.red,
),
),

const SizedBox(height: 15),

Text(
userData["name"] ?? "User",
style: const TextStyle(
color: Colors.white,
fontSize: 24,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

if (isDonor)
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 15,
vertical: 6,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(20),
),
child: const Text(
"🩸 Blood Donor",
style: TextStyle(
color: Colors.red,
fontWeight:
FontWeight.bold,
),
),
),
],
),
),

const SizedBox(height: 25),

profileCard(
Icons.email,
"Email",
userData["email"] ??
"Not available",
),

profileCard(
Icons.phone,
"Phone Number",
userData["phone"] ??
"Not available",
),

if (isDonor) ...[

const SizedBox(height: 10),

const Align(
alignment: Alignment.centerLeft,
child: Text(
"Donor Information",
style: TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(height: 10),

profileCard(
Icons.bloodtype,
"Blood Group",
donorData["bloodGroup"] ??
"Not available",
),

profileCard(
Icons.location_on,
"Location",
donorData["location"] ??
"Not available",
),

profileCard(
Icons.calendar_today,
"Last Donation Date",
donorData["lastDonationDate"] ??
"Not available",
),

Card(
elevation: 3,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),
child: SwitchListTile(
title: const Text(
"Available for Donation",
style: TextStyle(
fontWeight:
FontWeight.bold,
),
),
value: isDonorAvailable,
activeColor: Colors.red,
onChanged:
showAvailabilityDialog,
),
),
],
  const SizedBox(height: 25),

  SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const EditUserProfileScreen(),
          ),
        );
      },
      child: const Text(
        "EDIT PERSONAL PROFILE",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),

  if (isDonor) ...[

    const SizedBox(height: 15),

    SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const EditDonorProfileScreen(),
            ),
          );
        },
        child: const Text(
          "EDIT DONOR PROFILE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),

  ],

  const SizedBox(height: 20),

],
),
);
},
),
);
}


Widget profileCard(
    IconData icon,
    String title,
    String value,
    ) {

  return Card(
    elevation: 3,
    margin: const EdgeInsets.only(
      bottom: 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius:
      BorderRadius.circular(15),
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor:
        Colors.red.shade100,
        child: Icon(
          icon,
          color: Colors.red,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: Colors.grey[700],
        ),
      ),
    ),
  );
}
}
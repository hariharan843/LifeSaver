import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({super.key});

  @override
  State<BloodRequestScreen> createState() =>
      _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
String selectedBloodGroup = "A+";


final TextEditingController nameController =
TextEditingController();
final TextEditingController ageController =
TextEditingController();
final TextEditingController hospitalController =
TextEditingController();
final TextEditingController locationController =
TextEditingController();
final TextEditingController phoneController =
TextEditingController();
final TextEditingController unitsController =
TextEditingController();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

Future<void> submitRequest() async {
try {
DocumentReference requestRef =
await _firestore.collection("blood_requests").add({
"userId": FirebaseAuth.instance.currentUser!.uid,
"patientName": nameController.text.trim(),
"age": ageController.text.trim(),
"bloodGroup": selectedBloodGroup,
"units": unitsController.text.trim(),
"hospital": hospitalController.text.trim(),
"location": locationController.text.trim(),
"phone": phoneController.text.trim(),
"status": "Pending",
"createdAt": Timestamp.now(),
});

print("Blood request created: ${requestRef.id}");
await _firestore
    .collection("activities")
    .add({

  "userId":
  FirebaseAuth.instance.currentUser!.uid,

  "title":
  "Blood Request Created",

  "description":
  "${selectedBloodGroup} blood request created for ${hospitalController.text.trim()}",

  "type":
  "REQUEST",

  "status":
  "Pending",

  "relatedRequestId":
  requestRef.id,
  "createdAt":
  Timestamp.now(),

});

QuerySnapshot donorsSnapshot = await _firestore
.collection("donors")
.where(
"bloodGroup",
isEqualTo: selectedBloodGroup,
)
.where(
"available",
isEqualTo: true,
)
.get();

print(
"Matching blood group donors: ${donorsSnapshot.docs.length}");

for (var donor in donorsSnapshot.docs) {
final data =
donor.data() as Map<String, dynamic>;

print(
"Checking donor location: ${data["location"]}");

if (data["location"]
.toString()
.toLowerCase()
.contains(
locationController.text
.trim()
.toLowerCase(),
)) {
print("Location matched");

await _firestore
    .collection("notifications")
    .doc(donor.id)
    .collection("requests")
    .doc(requestRef.id)
    .set({
  "requestId": requestRef.id,
  "patientName": nameController.text.trim(),
  "bloodGroup": selectedBloodGroup,
  "hospital": hospitalController.text.trim(),
  "location": locationController.text.trim(),
  "phone": phoneController.text.trim(),
  "units": unitsController.text.trim(),
  "isRead": false,
  "createdAt": Timestamp.now(),
});

print(
"Notification created for donor: ${donor.id}");
}
}

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content:
Text("Blood Request Submitted Successfully"),
backgroundColor: Colors.green,
),
);
} catch (e) {
print("Error: $e");

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("Error: $e"),
backgroundColor: Colors.red,
),
);
}
}
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xffF7F9FC),

appBar: AppBar(
elevation: 0,
backgroundColor: Colors.redAccent,
title: const Text(
"Blood Request",
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),

body: SingleChildScrollView(
padding: const EdgeInsets.all(20),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

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
BorderRadius.circular(20),
),

child: const Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Icon(
Icons.bloodtype,
color: Colors.white,
size: 45,
),

SizedBox(height: 10),

Text(
"Emergency Blood Request 🚨",
style: TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight:
FontWeight.bold,
),
),

SizedBox(height: 5),

Text(
"Provide patient details to connect with donors quickly.",
style: TextStyle(
color: Colors.white70,
fontSize: 14,
),
),

],
),
),

const SizedBox(height: 25),

buildField(
controller: nameController,
label: "Patient Name",
icon: Icons.person,
),

buildField(
controller: ageController,
label: "Patient Age",
icon: Icons.calendar_today,
keyboard: TextInputType.number,
),

DropdownButtonFormField<String>(
value: selectedBloodGroup,

decoration:
inputDecoration(
"Blood Group Required",
).copyWith(
prefixIcon:
const Icon(
Icons.bloodtype,
),
),

items: [
"A+",
"A-",
"B+",
"B-",
"O+",
"O-",
"AB+",
"AB-",
].map((group) {

return DropdownMenuItem(
value: group,
child: Text(group),
);

}).toList(),

onChanged: (value) {

setState(() {
selectedBloodGroup = value!;
});

},
),

const SizedBox(height: 15),

buildField(
controller: unitsController,
label: "Units Required",
icon: Icons.bloodtype,
keyboard:
TextInputType.number,
),

buildField(
controller: hospitalController,
label: "Hospital Name",
icon: Icons.local_hospital,
),

buildField(
controller: locationController,
label: "Hospital Location",
icon: Icons.location_on,
),

buildField(
controller: phoneController,
label: "Contact Number",
icon: Icons.phone,
keyboard:
TextInputType.phone,
),


const SizedBox(height: 30),

SizedBox(
width: double.infinity,
height: 55,

child: ElevatedButton.icon(

onPressed: submitRequest,

icon:
const Icon(
Icons.send,
),

label:
const Text(
"SUBMIT REQUEST",
style: TextStyle(
fontSize: 17,
fontWeight:
FontWeight.bold,
),
),

style:
ElevatedButton.styleFrom(

backgroundColor:
Colors.redAccent,

foregroundColor:
Colors.white,

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),

),
),
),
],
),
),
);
}
Widget buildField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboard =
      TextInputType.text,
}) {
  return Padding(
    padding:
    const EdgeInsets.only(bottom: 15),

    child: TextField(
      controller: controller,
      keyboardType: keyboard,

      decoration:
      inputDecoration(label).copyWith(
        prefixIcon:
        Icon(icon),
      ),
    ),
  );
}


InputDecoration inputDecoration(
    String label) {
  return InputDecoration(
    labelText: label,

    filled: true,

    fillColor:
    Colors.white,

    border:
    OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(15),

      borderSide:
      BorderSide.none,
    ),

    enabledBorder:
    OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(15),

      borderSide:
      BorderSide(
        color:
        Colors.grey.shade300,
      ),
    ),

    focusedBorder:
    OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(15),

      borderSide:
      const BorderSide(
        color:
        Colors.redAccent,
        width:
        2,
      ),
    ),
  );
}
@override
void dispose() {
  nameController.dispose();
  ageController.dispose();
  hospitalController.dispose();
  locationController.dispose();
  phoneController.dispose();
  unitsController.dispose();
  super.dispose();
}
}
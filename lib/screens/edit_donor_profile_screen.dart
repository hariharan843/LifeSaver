import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDonorProfileScreen extends StatefulWidget {
  const EditDonorProfileScreen({super.key});

  @override
  State<EditDonorProfileScreen> createState() => _EditDonorProfileScreenState();
}

class _EditDonorProfileScreenState extends State<EditDonorProfileScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final lastDonationController = TextEditingController();

  String? selectedGender;
  String? selectedBloodGroup;
  bool available = true;

  final genders = [
    "Male",
    "Female",
    "Other",
  ];

  final bloodGroups = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
  ];

  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadDonorData();
  }

  Future<void> loadDonorData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("donors")
        .doc(uid)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data =
      snapshot.data() as Map<String, dynamic>;

      setState(() {
        nameController.text = data["name"] ?? "";
        ageController.text = data["age"] ?? "";
        phoneController.text = data["phone"] ?? "";
        locationController.text = data["location"] ?? "";
        lastDonationController.text =
            data["lastDonationDate"] ?? "";

        selectedGender = data["gender"];
        selectedBloodGroup = data["bloodGroup"];
        available = data["available"] ?? true;
      });
    }
  }

  Future<void> updateDonorProfile() async {
    await FirebaseFirestore.instance
        .collection("donors")
        .doc(uid)
        .update({
      "name": nameController.text.trim(),
      "age": ageController.text.trim(),
      "phone": phoneController.text.trim(),
      "location": locationController.text.trim(),
      "lastDonationDate":
      lastDonationController.text.trim(),
      "gender": selectedGender,
      "bloodGroup": selectedBloodGroup,
      "available": available,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Donor profile updated successfully"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Donor Profile"),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Age",
                prefixIcon: Icon(Icons.cake),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: const InputDecoration(
                labelText: "Gender",
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: genders.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedBloodGroup,
              decoration: const InputDecoration(
                labelText: "Blood Group",
                prefixIcon: Icon(Icons.bloodtype),
              ),
              items: bloodGroups.map((group) {
                return DropdownMenuItem(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBloodGroup = value;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
                prefixIcon: Icon(Icons.location_on),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: lastDonationController,
              decoration: const InputDecoration(
                labelText: "Last Donation Date",
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),

            SwitchListTile(
              title: const Text(
                "Available for Donation",
              ),
              value: available,
              activeColor: Colors.red,
              onChanged: (value) {
                setState(() {
                  available = value;
                });
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: updateDonorProfile,
                child: const Text(
                  "SAVE CHANGES",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
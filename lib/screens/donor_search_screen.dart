import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorSearchScreen extends StatefulWidget {
  const DonorSearchScreen({super.key});

  @override
  State<DonorSearchScreen> createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  String selectedBloodGroup = "A+";
  final TextEditingController locationController = TextEditingController();
  List<QueryDocumentSnapshot> donors = [];
  bool isLoading = false;

  final List<String> bloodGroups = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-"
  ];

  Future<void> callDonor(String phone) async {
    final Uri url = Uri(
      scheme: "tel",
      path: phone,
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot open phone dialer"),
        ),
      );
    }
  }

  Future<void> searchDonors() async {
    setState(() {
      isLoading = true;
      donors.clear();
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
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

      List<QueryDocumentSnapshot> filteredDonors = [];

      for (var donor in snapshot.docs) {
        final data = donor.data() as Map<String, dynamic>;

        if (data["location"]
            .toString()
            .toLowerCase()
            .contains(
          locationController.text.trim().toLowerCase(),
        )) {
          filteredDonors.add(donor);
        }
      }

      setState(() {
        donors = filteredDonors;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Blood Donors"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Search Nearby Donors 🩸",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height:25),
            DropdownButtonFormField<String>(
              value: selectedBloodGroup,
              decoration: InputDecoration(
                labelText:"Select Blood Group",
                border:OutlineInputBorder(
                  borderRadius:BorderRadius.circular(12),
                ),
              ),
              items:bloodGroups.map((group){
                return DropdownMenuItem(
                  value:group,
                  child:Text(group),
                );
              }).toList(),
              onChanged:(value){
                setState(() {
                  selectedBloodGroup=value!;
                });
              },
            ),
            const SizedBox(height:20),
            TextField(
              controller:locationController,
              decoration:InputDecoration(
                labelText:"Enter Location",
                prefixIcon:const Icon(Icons.location_on),
                border:OutlineInputBorder(
                  borderRadius:BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height:25),
            SizedBox(
              width:double.infinity,
              height:55,
              child:ElevatedButton(
                onPressed:searchDonors,
                style:ElevatedButton.styleFrom(
                  backgroundColor:Colors.red,
                ),
                child:const Text(
                  "SEARCH DONORS",
                  style:TextStyle(
                    color:Colors.white,
                    fontSize:18,
                  ),
                ),
              ),
            ),
            const SizedBox(height:25),
            const Text(
              "Available Donors",
              style:TextStyle(
                fontSize:20,
                fontWeight:FontWeight.bold,
              ),
            ),
            const SizedBox(height:15),
            if(isLoading)
              const Center(
                child:CircularProgressIndicator(),
              ),
            Expanded(
              child:donors.isEmpty
                  ? const Center(
                child:Text(
                  "No donors found",
                  style:TextStyle(fontSize:18),
                ),
              )
                  : ListView.builder(
                itemCount:donors.length,
                itemBuilder:(context,index){
                  final data =
                  donors[index].data()
                  as Map<String,dynamic>;

                  return Card(
                    elevation:5,
                    child:ListTile(
                      leading:const Icon(
                        Icons.person,
                        color:Colors.red,
                        size:35,
                      ),
                      title:Text(
                        data["name"] ?? "Unknown",
                        style:const TextStyle(
                          fontWeight:FontWeight.bold,
                        ),
                      ),
                      subtitle:Text(
                        "Blood Group: ${data["bloodGroup"]}\n"
                            "Location: ${data["location"]}\n"
                            "Phone: ${data["phone"]}",
                      ),
                      trailing:ElevatedButton(
                        onPressed:(){
                          callDonor(
                            data["phone"],
                          );
                        },
                        child:const Text("Call"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientRequestScreen extends StatelessWidget {
  const PatientRequestScreen({super.key});

  Future<void> callDonor(String phone) async {
    final Uri url = Uri.parse("tel:$phone");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
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
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Requests"),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("blood_requests")
            .where("userId", isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Requests Found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final request = snapshot.data!.docs[index];
              final data = request.data() as Map<String, dynamic>;

              final String status = data["status"] ?? "Pending";

              return Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Blood Request",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),

                      const SizedBox(height: 15),

                      buildInfoRow(
                        "Patient Name",
                        data["patientName"] ?? "N/A",
                      ),

                      buildInfoRow(
                        "Blood Group",
                        data["bloodGroup"] ?? "N/A",
                      ),

                      buildInfoRow(
                        "Hospital",
                        data["hospital"] ?? "N/A",
                      ),

                      buildInfoRow(
                        "Location",
                        data["location"] ?? "N/A",
                      ),

                      buildInfoRow(
                        "Units Required",
                        data["units"]?.toString() ?? "N/A",
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Status: $status",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == "Completed"
                              ? Colors.green
                              : status == "Pending"
                              ? Colors.orange
                              : Colors.blue,
                        ),
                      ),

                      if (data["organisationName"] != null) ...[
                        const SizedBox(height: 15),

                        const Text(
                          "Handled By",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          data["organisationName"],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      if (status == "Donor Found" ||
                          status == "Completed") ...[
                        const Divider(height: 30),

                        const Text(
                          "Donor Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        buildInfoRow(
                          "Name",
                          data["donorName"] ?? "Not Available",
                        ),

                        buildInfoRow(
                          "Phone",
                          data["donorPhone"] ?? "Not Available",
                        ),

                        const SizedBox(height: 10),

                        if (data["donorPhone"] != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                callDonor(data["donorPhone"]);
                              },
                              icon: const Icon(Icons.phone),
                              label: const Text("Call Donor"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
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
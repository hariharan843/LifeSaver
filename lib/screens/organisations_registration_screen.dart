import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class OrganisationRegistrationScreen extends StatefulWidget {

  final String organisationType;

  const OrganisationRegistrationScreen({
    super.key,
    required this.organisationType,
  });


  @override
  State<OrganisationRegistrationScreen> createState() =>
      _OrganisationRegistrationScreenState();
}



class _OrganisationRegistrationScreenState
    extends State<OrganisationRegistrationScreen> {


  final TextEditingController coordinatorNameController =
  TextEditingController();

  final TextEditingController organisationNameController =
  TextEditingController();

  final TextEditingController designationController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController locationController =
  TextEditingController();


  bool available = true;



  @override
  void dispose() {

    coordinatorNameController.dispose();
    organisationNameController.dispose();
    designationController.dispose();
    phoneController.dispose();
    emailController.dispose();
    locationController.dispose();

    super.dispose();
  }





  Future<void> saveOrganisationProfile() async {


    if (coordinatorNameController.text.isEmpty ||
        organisationNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        locationController.text.isEmpty) {


      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),

      );

      return;
    }



    try {


      final user = FirebaseAuth.instance.currentUser;


      if (user == null) {
        return;
      }



      final organisationRef =
      FirebaseFirestore.instance
          .collection("organisations")
          .doc(user.uid);


      final organisationSnapshot =
      await organisationRef.get();


      if (organisationSnapshot.exists) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(
            content: Text(
                "Organisation profile already exists"),
            backgroundColor: Colors.orange,
          ),

        );

        return;
      }


      await organisationRef.set({
        "ownerUid": user.uid,


        "organisationType": widget.organisationType,


        "name":
        coordinatorNameController.text.trim(),


        "organisationName":
        organisationNameController.text.trim(),


        "designation":
        designationController.text.trim(),


        "phone":
        phoneController.text.trim(),


        "email":
        emailController.text.trim(),


        "location":
        locationController.text.trim(),


        "available":
        available,


        "createdAt":
        Timestamp.now(),


      });




      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text(
              "Organisation profile saved successfully"),
          backgroundColor: Colors.green,
        ),

      );


      Navigator.pop(context);



    } catch(e) {


      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),

      );

    }

  }





  Widget buildTextField(
      String label,
      IconData icon,
      TextEditingController controller,
      ) {


    return TextField(

      controller: controller,

      decoration: InputDecoration(

        labelText: label,

        prefixIcon: Icon(icon),

        border: OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(12),

        ),

      ),

    );

  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: Text(
          "${widget.organisationType} Coordinator",
        ),

        backgroundColor: Colors.red,

      ),



      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),


        child: Column(

          children: [



            buildTextField(
              "Coordinator Name",
              Icons.person,
              coordinatorNameController,
            ),


            const SizedBox(height:15),



            buildTextField(
              "Organisation Name",
              Icons.business,
              organisationNameController,
            ),



            const SizedBox(height:15),



            buildTextField(
              "Designation / Role",
              Icons.badge,
              designationController,
            ),



            const SizedBox(height:15),



            buildTextField(
              "Phone Number",
              Icons.phone,
              phoneController,
            ),



            const SizedBox(height:15),



            buildTextField(
              "Email",
              Icons.email,
              emailController,
            ),



            const SizedBox(height:15),



            buildTextField(
              "Location",
              Icons.location_on,
              locationController,
            ),




            SwitchListTile(

              title: const Text(
                "Available for Blood Requests",
              ),


              value: available,


              onChanged: (value) {

                setState(() {

                  available = value;

                });

              },

            ),




            const SizedBox(height:25),




            SizedBox(

              width: double.infinity,

              height:55,


              child: ElevatedButton(


                onPressed: saveOrganisationProfile,


                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.red,

                ),



                child: const Text(

                  "SAVE PROFILE",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize:18,

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
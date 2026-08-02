import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class OrganisationAddDonorScreen extends StatefulWidget {

  const OrganisationAddDonorScreen({super.key});


  @override
  State<OrganisationAddDonorScreen> createState() =>
      _OrganisationAddDonorScreenState();

}



class _OrganisationAddDonorScreenState
    extends State<OrganisationAddDonorScreen> {


  final TextEditingController nameController =
  TextEditingController();


  final TextEditingController ageController =
  TextEditingController();


  final TextEditingController phoneController =
  TextEditingController();


  final TextEditingController bloodGroupController =
  TextEditingController();


  final TextEditingController locationController =
  TextEditingController();



  bool available = true;



  @override
  void dispose() {

    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    bloodGroupController.dispose();
    locationController.dispose();

    super.dispose();

  }




  Future<void> saveDonor() async {


    final user =
        FirebaseAuth.instance.currentUser;


    if(user == null) return;



    if(nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        bloodGroupController.text.isEmpty ||
        locationController.text.isEmpty){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text("Please fill all required fields"),

          backgroundColor:
          Colors.red,

        ),

      );


      return;

    }




    try{


      DocumentReference donorRef =
      FirebaseFirestore.instance
          .collection("donors")
          .doc();




      await donorRef.set({


        "donorId":
        donorRef.id,


        "name":
        nameController.text.trim(),


        "age":
        ageController.text.trim(),


        "phone":
        phoneController.text.trim(),


        "bloodGroup":
        bloodGroupController.text.trim(),


        "location":
        locationController.text.trim(),


        "available":
        available,



        // Organisation details

        "donorType":
        "Organisation",



        "organisationId":
        user.uid,



        "createdAt":
        Timestamp.now(),


      });





      ScaffoldMessenger.of(context)
          .showSnackBar(


        const SnackBar(

          content:
          Text("Donor added successfully"),

          backgroundColor:
          Colors.green,

        ),


      );



      Navigator.pop(context);



    }catch(e){


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







  Widget buildField(

      String label,

      IconData icon,

      TextEditingController controller,

      ){

    return TextField(

      controller:
      controller,


      decoration:
      InputDecoration(

        labelText:
        label,


        prefixIcon:
        Icon(icon),


        border:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(12),

        ),

      ),

    );

  }







  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar:
      AppBar(

        title:
        const Text(

          "Add Donor",

        ),


        backgroundColor:
        Colors.red,

        centerTitle:
        true,

      ),




      body:
      SingleChildScrollView(


        padding:
        const EdgeInsets.all(20),



        child:
        Column(


          children: [



            buildField(

              "Donor Name",

              Icons.person,

              nameController,

            ),



            const SizedBox(height:15),



            buildField(

              "Age",

              Icons.calendar_today,

              ageController,

            ),



            const SizedBox(height:15),



            buildField(

              "Phone Number",

              Icons.phone,

              phoneController,

            ),



            const SizedBox(height:15),



            buildField(

              "Blood Group",

              Icons.bloodtype,

              bloodGroupController,

            ),



            const SizedBox(height:15),



            buildField(

              "Location",

              Icons.location_on,

              locationController,

            ),




            SwitchListTile(

              title:
              const Text(
                "Available for donation",
              ),


              value:
              available,


              onChanged:
                  (value){

                setState(() {

                  available =
                      value;

                });

              },


            ),




            const SizedBox(height:25),





            SizedBox(

              width:
              double.infinity,


              height:
              55,


              child:
              ElevatedButton(


                onPressed:
                saveDonor,


                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.red,

                ),



                child:
                const Text(

                  "SAVE DONOR",

                  style:
                  TextStyle(

                    color:
                    Colors.white,

                    fontSize:
                    18,

                    fontWeight:
                    FontWeight.bold,

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
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'organisation_add_donor_screen.dart';
import 'organisation_donor_view_screen.dart';
import 'organisation_blood_requests_screen.dart';


class OrganisationDashboardScreen extends StatefulWidget {

  const OrganisationDashboardScreen({super.key});


  @override
  State<OrganisationDashboardScreen> createState() =>
      _OrganisationDashboardScreenState();

}



class _OrganisationDashboardScreenState
    extends State<OrganisationDashboardScreen> {


  Map<String, dynamic>? organisationData;



  @override
  void initState() {

    super.initState();

    loadOrganisation();

  }





  Future<void> loadOrganisation() async {


    final user =
        FirebaseAuth.instance.currentUser;


    if(user == null) return;



    final snapshot =

    await FirebaseFirestore.instance
        .collection("organisations")
        .doc(user.uid)
        .get();



    if(snapshot.exists){


      setState(() {

        organisationData =
            snapshot.data();

      });


    }


  }
  Future<int> getTotalDonors() async {

    final user =
        FirebaseAuth.instance.currentUser;


    if(user == null){
      return 0;
    }



    QuerySnapshot snapshot =

    await FirebaseFirestore.instance
        .collection("donors")
        .where(
      "organisationId",
      isEqualTo: user.uid,
    )
        .get();



    return snapshot.docs.length;

  }





  Future<int> getAvailableDonors() async {

    final user =
        FirebaseAuth.instance.currentUser;


    if(user == null){
      return 0;
    }



    QuerySnapshot snapshot =

    await FirebaseFirestore.instance
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



    return snapshot.docs.length;

  }







  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor:
      const Color(0xffF4F8FC),



      appBar: AppBar(


        title:
        const Text(

          "Organisation Dashboard",

          style: TextStyle(

            fontWeight: FontWeight.bold,

          ),

        ),


        centerTitle: true,


        backgroundColor:
        const Color(0xffD32F2F),


        elevation: 0,


        shape:
        const RoundedRectangleBorder(

          borderRadius:
          BorderRadius.vertical(

            bottom:
            Radius.circular(25),

          ),

        ),


      ),





      body:

      organisationData == null


          ?

      const Center(

        child:
        CircularProgressIndicator(),

      )


          :


      SingleChildScrollView(


        padding:
        const EdgeInsets.all(20),



        child:
        Column(


          crossAxisAlignment:
          CrossAxisAlignment.start,



          children: [



            organisationProfileCard(),



            const SizedBox(
              height:25,
            ),



            const Text(

              "Organisation Statistics",

              style:
              TextStyle(

                fontSize:21,

                fontWeight:
                FontWeight.bold,

              ),

            ),



            const SizedBox(
              height:15,
            ),



            FutureBuilder(

              future: Future.wait([

                getTotalDonors(),

                getAvailableDonors(),

              ]),


              builder: (context, snapshot) {


                if(!snapshot.hasData){

                  return const Center(

                    child:
                    CircularProgressIndicator(),

                  );

                }



                return Row(

                  children: [


                    Expanded(

                      child:
                      statisticCard(

                        "Total Donors",

                        snapshot.data![0].toString(),

                        Icons.people,

                      ),

                    ),



                    const SizedBox(

                      width:15,

                    ),



                    Expanded(

                      child:
                      statisticCard(

                        "Available",

                        snapshot.data![1].toString(),

                        Icons.bloodtype,

                      ),

                    ),



                  ],

                );


              },

            ),



            const SizedBox(
              height:30,
            ),




            const Text(

              "Quick Actions",

              style:
              TextStyle(

                fontSize:21,

                fontWeight:
                FontWeight.bold,

              ),

            ),



            const SizedBox(
              height:15,
            ),





            GridView.count(


              shrinkWrap:
              true,


              physics:
              const NeverScrollableScrollPhysics(),



              crossAxisCount:
              2,



              crossAxisSpacing:
              15,



              mainAxisSpacing:
              15,



              children: [



                dashboardCard(

                  Icons.person_add,

                  "Add Donor",

                      () {


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                        const OrganisationAddDonorScreen(),

                      ),

                    );


                  },

                ),





                dashboardCard(

                  Icons.people,

                  "View Donors",

                      () {


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                        const OrganisationDonorsScreen(),

                      ),

                    );


                  },

                ),

                dashboardCard(

                  Icons.bloodtype,

                  "Blood Requests",

                      () {


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                        const OrganisationBloodRequestsScreen(),

                      ),

                    );


                  },

                ),




                dashboardCard(

                  Icons.settings,

                  "Manage Organisation",

                      () {


                    // Manage organisation navigation later


                  },

                ),



              ],



            ),



          ],


        ),


      ),


    );


  }









  Widget organisationProfileCard(){


    return Card(


      elevation:4,


      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(18),

      ),



      child:
      Padding(

        padding:
        const EdgeInsets.all(20),



        child:
        Column(


          crossAxisAlignment:
          CrossAxisAlignment.start,



          children: [



            Text(


              organisationData!["organisationName"]
                  ??
                  "Organisation",



              style:
              const TextStyle(

                fontSize:23,

                fontWeight:
                FontWeight.bold,

              ),


            ),



            const SizedBox(
              height:10,
            ),




            Text(


              organisationData!["organisationType"]
                  ??
                  "Organisation Type",



              style:
              const TextStyle(

                color:
                Colors.grey,

                fontSize:16,

              ),


            ),




            const SizedBox(
              height:10,
            ),




            Text(


              "Location: ${organisationData!["location"] ?? "Not Available"}",



              style:
              const TextStyle(

                fontSize:15,

              ),


            ),



          ],


        ),


      ),


    );


  }









  Widget statisticCard(

      String title,

      String value,

      IconData icon,

      ){


    return Card(


      elevation:3,


      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(15),

      ),



      child:
      Padding(


        padding:
        const EdgeInsets.all(15),



        child:
        Column(


          children: [



            Icon(

              icon,

              size:35,

              color:
              Colors.red,

            ),



            const SizedBox(
              height:8,
            ),



            Text(

              value,

              style:
              const TextStyle(

                fontSize:22,

                fontWeight:
                FontWeight.bold,

              ),

            ),



            Text(

              title,

            ),



          ],


        ),


      ),


    );


  }









  Widget dashboardCard(

      IconData icon,

      String title,

      VoidCallback onTap,

      ){


    return Card(


      elevation:3,


      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(15),

      ),



      child:
      InkWell(


        borderRadius:
        BorderRadius.circular(15),


        onTap:
        onTap,



        child:
        Column(


          mainAxisAlignment:
          MainAxisAlignment.center,



          children: [



            Icon(

              icon,

              size:40,

              color:
              Colors.red,

            ),



            const SizedBox(
              height:10,
            ),



            Text(

              title,

              textAlign:
              TextAlign.center,


              style:
              const TextStyle(

                fontWeight:
                FontWeight.w500,

              ),


            ),



          ],


        ),


      ),


    );


  }



}
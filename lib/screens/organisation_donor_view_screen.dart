import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class OrganisationDonorsScreen extends StatelessWidget {

  const OrganisationDonorsScreen({super.key});


  @override
  Widget build(BuildContext context) {


    final user =
        FirebaseAuth.instance.currentUser;



    return Scaffold(


      backgroundColor:
      const Color(0xffF4F8FC),



      appBar: AppBar(


        title:
        const Text(

          "Organisation Donors",

          style: TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),


        centerTitle: true,


        backgroundColor:
        const Color(0xffD32F2F),


      ),




      body:

      user == null

          ?

      const Center(

        child:
        Text("User not found"),

      )


          :

      StreamBuilder<QuerySnapshot>(


        stream:

        FirebaseFirestore.instance
            .collection("donors")
            .where(
          "organisationId",
          isEqualTo: user.uid,
        )
            .snapshots(),



        builder:
            (context, snapshot) {



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

                "No donors added yet",

                style:
                TextStyle(

                  fontSize:18,

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



              Map<String,dynamic> donor =

              snapshot.data!.docs[index].data()
              as Map<String,dynamic>;





              return Card(


                elevation:
                3,


                margin:
                const EdgeInsets.only(
                  bottom:15,
                ),



                shape:
                RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(15),

                ),



                child:
                ListTile(



                  leading:
                  CircleAvatar(

                    backgroundColor:
                    Colors.red.shade100,


                    child:
                    const Icon(

                      Icons.bloodtype,

                      color:
                      Colors.red,

                    ),

                  ),





                  title:
                  Text(


                    donor["name"] ??
                        "Unknown",



                    style:
                    const TextStyle(

                      fontWeight:
                      FontWeight.bold,

                    ),


                  ),





                  subtitle:
                  Column(


                    crossAxisAlignment:
                    CrossAxisAlignment.start,



                    children: [



                      Text(

                        "Blood Group: ${donor["bloodGroup"] ?? "N/A"}",

                      ),



                      Text(

                        "Location: ${donor["location"] ?? "N/A"}",

                      ),



                      Text(

                        "Phone: ${donor["phone"] ?? "N/A"}",

                      ),



                    ],


                  ),





                  trailing:

                  Icon(

                    donor["available"] == true

                        ?

                    Icons.check_circle

                        :

                    Icons.cancel,


                    color:

                    donor["available"] == true

                        ?

                    Colors.green

                        :

                    Colors.grey,


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
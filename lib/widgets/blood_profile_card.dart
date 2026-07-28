import 'package:flutter/material.dart';

class BloodProfileCard extends StatelessWidget {

  final String bloodGroup;
  final String location;
  final bool available;

  const BloodProfileCard({

    super.key,

    required this.bloodGroup,

    required this.location,

    required this.available,

  });


  @override
  Widget build(BuildContext context) {


    return Container(

      padding: const EdgeInsets.all(22),


      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(25),


        boxShadow: [

          BoxShadow(

            color:
            Colors.grey.withOpacity(0.15),

            blurRadius: 15,

            offset:
            const Offset(0,8),

          ),

        ],

      ),


      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,


        children: [


          Row(

            children: [


              Container(

                padding:
                const EdgeInsets.all(12),


                decoration:
                BoxDecoration(

                  color:
                  const Color(0xffffebee),

                  borderRadius:
                  BorderRadius.circular(15),

                ),


                child:
                const Icon(

                  Icons.bloodtype,

                  color:
                  Color(0xffD32F2F),

                  size:30,

                ),

              ),


              const SizedBox(width:15),


              const Text(

                "Blood Profile",

                style:
                TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),

            ],

          ),



          const SizedBox(height:20),



          Center(

            child: Text(

              bloodGroup,

              style:
              const TextStyle(

                fontSize:45,

                fontWeight:
                FontWeight.bold,

                color:
                Color(0xffC62828),

              ),

            ),

          ),



          const SizedBox(height:15),



          Row(

            children: [


              const Icon(

                Icons.location_on,

                color:
                Colors.grey,

                size:20,

              ),


              const SizedBox(width:8),


              Text(

                location,

                style:
                const TextStyle(

                  fontSize:16,

                ),

              ),

            ],

          ),



          const SizedBox(height:12),



          Container(

            padding:
            const EdgeInsets.symmetric(

              horizontal:12,

              vertical:6,

            ),


            decoration:
            BoxDecoration(

              color: available
                  ? Colors.green.shade50
                  : Colors.red.shade50,


              borderRadius:
              BorderRadius.circular(20),

            ),


            child: Text(

              available
                  ? "🟢 Available"
                  : "🔴 Not Available",


              style:
              TextStyle(

                color: available
                    ? Colors.green
                    : Colors.red,


                fontWeight:
                FontWeight.bold,

              ),

            ),

          ),

        ],

      ),

    );

  }

}
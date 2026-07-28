import 'package:flutter/material.dart';

class EmergencyCard extends StatelessWidget {

  final VoidCallback onTap;

  const EmergencyCard({
    super.key,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(

        gradient: const LinearGradient(

          colors: [

            Color(0xffD32F2F),
            Color(0xff8E0000),

          ],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

        ),

        borderRadius: BorderRadius.circular(25),

        boxShadow: [

          BoxShadow(

            color: Colors.red.withOpacity(0.3),

            blurRadius: 15,

            offset: const Offset(0, 8),

          ),

        ],

      ),


      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [


          const Icon(

            Icons.bloodtype,

            color: Colors.white,

            size: 45,

          ),


          const SizedBox(height: 15),


          const Text(

            "Emergency Blood Support",

            style: TextStyle(

              color: Colors.white,

              fontSize: 22,

              fontWeight: FontWeight.bold,

            ),

          ),


          const SizedBox(height: 8),


          const Text(

            "Find matching donors instantly",

            style: TextStyle(

              color: Colors.white70,

              fontSize: 15,

            ),

          ),


          const SizedBox(height: 20),


          SizedBox(

            width: double.infinity,


            child: ElevatedButton(

              onPressed: onTap,


              style: ElevatedButton.styleFrom(

                backgroundColor: Colors.white,

                foregroundColor: Color(0xffD32F2F),


                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(15),

                ),

              ),


              child: const Text(

                "Request Blood Now",

                style: TextStyle(

                  fontWeight: FontWeight.bold,

                  fontSize: 16,

                ),

              ),

            ),

          ),

        ],

      ),

    );

  }

}
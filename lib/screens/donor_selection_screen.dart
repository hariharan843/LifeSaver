import 'package:flutter/material.dart';
import 'donor_registration_screen.dart';
import 'organisations_registration_screen.dart';
class DonorSelectionScreen extends StatelessWidget {
  const DonorSelectionScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Select Donor Type"),
        backgroundColor: const Color(0xffD32F2F),
        centerTitle: true,
      ),


      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Choose your donor category",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),


            const SizedBox(height:20),


            donorCard(
              context,
              Icons.person,
              "Individual Donor",
              "Register as a personal blood donor",
            ),


            donorCard(
              context,
              Icons.school,
              "Educational Institution",
              "Colleges and schools",
            ),


            donorCard(
              context,
              Icons.volunteer_activism,
              "Trust / NGO",
              "Blood donation organizations",
            ),


            donorCard(
              context,
              Icons.business,
              "Corporate Company",
              "Company based donors",
            ),


            donorCard(
              context,
              Icons.account_balance,
              "Government Organization",
              "Government departments",
            ),

          ],

        ),

      ),

    );
  }




  Widget donorCard(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      ) {


    return Card(

      elevation:4,

      margin: const EdgeInsets.only(bottom:15),


      child: ListTile(


        leading: CircleAvatar(

          backgroundColor:
          const Color(0xffD32F2F),

          child: Icon(
            icon,
            color: Colors.white,
          ),

        ),


        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),


        subtitle: Text(subtitle),


        trailing: const Icon(
          Icons.arrow_forward_ios,
          size:18,
        ),



        onTap: () {


          if(title == "Individual Donor") {


            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) =>
                const DonorRegistrationScreen(
                  donorType: "Individual",
                ),

              ),

            );


          }

          else {


            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) =>
                    OrganisationRegistrationScreen(
                      organisationType: title,
                    ),

              ),

            );


          }


        },


      ),


    );


  }

}
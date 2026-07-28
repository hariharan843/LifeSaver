import 'package:flutter/material.dart';

class RequestTimeline extends StatelessWidget {
  final String status;

  const RequestTimeline({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      "Pending",
      "Matching Donors",
      "Donor Found",
      "Donor On The Way",
      "Blood Donated",
      "Completed",
    ];

    int currentStep = steps.indexOf(status);
    if (currentStep == -1) currentStep = 0;

    return Column(
      children: List.generate(steps.length, (index) {
        bool completed = index <= currentStep;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: completed ? Colors.green : Colors.grey,
                ),
                if (index != steps.length - 1)
                  Container(
                    width: 2,
                    height: 35,
                    color: completed
                        ? Colors.green
                        : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                steps[index],
                style: TextStyle(
                  fontWeight: completed
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color:
                  completed ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
import 'package:flutter/material.dart';


class TaskCard extends StatelessWidget
{
  final String title;
  final String description;
  final Color colour;
  
  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.colour,
  });


  @override
  Widget build (BuildContext context)
  {
    return Card(
      color: colour,
      shadowColor: colour,
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              title,
              style: const TextStyle(
                color: Color.fromRGBO(0, 0, 0, 1),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
              ),
            ),

            Text(
              description,
              style: const TextStyle(
                color: Color.fromRGBO(0, 0, 0, 1),
                fontSize: 15,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),


          ],
        ),
      ),
    );
  }
}
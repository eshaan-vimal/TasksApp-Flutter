import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend/core/constants/utils.dart';


class DateSelector extends StatefulWidget
{
  final DateTime selectedDate;
  final Function(DateTime) onTap;


  const DateSelector ({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  State<DateSelector> createState () => _DateSelectorState ();
}


class _DateSelectorState extends State<DateSelector>
{
  int weekOffset = 0;


  @override
  Widget build (BuildContext context)
  {
    final weekDates = getWeekDates(weekOffset);
    final month = DateFormat('MMMM').format(weekDates[3]);

    return Column(
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            
            IconButton(
              onPressed: () {
                setState(() {
                  weekOffset--;
                });
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
        
            Text(
              month.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
        
            IconButton(
              onPressed: () {
                setState(() {
                  weekOffset++;
                });
              }, 
              icon: const Icon(Icons.arrow_forward_ios),
            ),
        
          ],
        ),

        SizedBox(
          height: 100,
          child: ListView.builder(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            itemCount: weekDates.length,
            itemBuilder: (context, index) {

              final date = DateFormat('d').format(weekDates[index]);
              final day = DateFormat('E').format(weekDates[index]);

              final isSelected = (
                DateFormat('d').format(widget.selectedDate) == DateFormat('d').format(weekDates[index]) &&
                widget.selectedDate.month == weekDates[index].month &&
                widget.selectedDate.year == weekDates[index].year
              );

              return GestureDetector(
                onTap: () => widget.onTap(weekDates[index]),
                child: SizedBox(
                  width: 85,
                  child: Card(
                    color: isSelected ? const Color.fromRGBO(255, 87, 34, 1) : null,
                    margin: const EdgeInsets.all(5.0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.5,
                        color: isSelected ? const Color.fromRGBO(255, 87, 34, 1) : const Color.fromRGBO(189, 189, 189, 1),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color.fromRGBO(255, 255, 255, 1) : null,
                            ),
                          ),
                          const Spacer(),
                
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: isSelected ? const Color.fromRGBO(255, 255, 255, 0.702) : null,
                            ),
                          ),
                
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
        ),

      ],
    );
  }
}
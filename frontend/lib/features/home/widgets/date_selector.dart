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
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color.fromRGBO(255, 255, 255, 0.702),
              ),
            ),
        
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  firstDate: DateTime.now(), 
                  lastDate: DateTime.now().add(Duration(days: 90)),
                );
                setState(() {
                  if (date != null)
                  {
                    widget.onTap(date);
                    weekOffset = getWeekOffset(date);
                  }
                });
              },
              child: Text(
                month.toUpperCase(),
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 0, 127),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.5,
                ),
              ),
            ),
        
            IconButton(
              onPressed: () {
                setState(() {
                  weekOffset++;
                });
              }, 
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Color.fromRGBO(255, 255, 255, 0.702),
              ),
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
                    elevation: 1.5,
                    color: isSelected ? const Color(0xFF00FF9C) : null,
                    shadowColor: const Color(0xFF00FF9C),
                    margin: const EdgeInsets.all(5.0),
                    shape: RoundedRectangleBorder(
                      // side: BorderSide(
                      //   width: 1,
                      //   color: const Color(0xFF00FF9C),
                      // ),
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
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              color: isSelected ? const Color.fromRGBO(0, 0, 0, 1) : null,
                            ),
                          ),
                          const Spacer(),
                
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              letterSpacing: 1.5,
                              color: isSelected ? const Color.fromRGBO(0, 0, 0, 1) : null,
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
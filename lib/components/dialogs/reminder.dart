import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/database/reminder.dart';
import 'package:kanji_memory_hint/notification/notifier.dart';
import 'package:kanji_memory_hint/theme.dart';
import 'package:quiver/testing/time.dart';

class ReminderDialog extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  Set<int> selected = {};
  TimeOfDay time = TimeOfDay.now();
  var reminder;

  bool loaded = false;

  @override
  void initState() {
    super.initState();
    reminder = Notifier.current();
  }

  void onDayTap(int day) {
    setState(() {
      if(selected.contains(day)) {
        selected.remove(day);
      } else {
        selected.add(day);
      }
    });
  }

  void onTimeSelect(BuildContext context) async {
    var selectedTime = await showTimePicker(
      context: context, 
      initialTime: time
    );

    if(selectedTime != null && time != selectedTime){
      print("here");
      setState(() {
        time = selectedTime;
      });
    }
  }

  void setNotification() async {
    Notifier.createNotifier(time, selected);
    Navigator.of(context).pop();
  }


  Widget reminderContent(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 1, child: Text("Reminder", style: Theme.of(context).textTheme.headline5,)),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(flex: 1, child: Text("Every:")),
              Expanded(
                flex: 3,
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 1, 
                    child: _DayWidget( 
                      initial: "S",
                      day: DateTime.sunday,
                      onTap: onDayTap,
                      isSelected: selected.contains(DateTime.sunday),
                    ),
                  ),
                  Flexible(
                    flex: 1, 
                    child: _DayWidget( 
                      initial: "M",
                      day: DateTime.monday,
                      onTap: onDayTap,
                      isSelected: selected.contains(DateTime.monday),
                    ),
                  ),
                  Flexible(
                    flex: 1, 
                    child: _DayWidget( 
                      initial: "T",
                      day: DateTime.tuesday,
                      onTap: onDayTap,
                      isSelected: selected.contains(DateTime.tuesday),
                    ),
                  ),
                  Flexible(
                    flex: 1, 
                    child: _DayWidget( 
                      initial: "W",
                      day: DateTime.wednesday,
                      onTap: onDayTap,
                      isSelected: selected.contains(DateTime.wednesday),
                    ),
                  ),
                  Flexible(
                    flex: 1, 
                    child: _DayWidget( 
                      initial: "T",
                      day: DateTime.thursday,
                      onTap: onDayTap,
                      isSelected: selected.contains(DateTime.thursday),
                    ),
                  ),
                  Flexible(
                    flex: 1, 
                    child: _DayWidget( 
                      initial: "F",
                      day: DateTime.friday,
                      onTap: onDayTap,
                      isSelected: selected.contains(DateTime.friday),
                    ),
                  ),
                  Flexible(
                    flex: 1, 
                    child: _DayWidget( 
                      initial: "S",
                      day: DateTime.saturday,
                      onTap: onDayTap,
                      isSelected: selected.contains(DateTime.saturday),
                    ),
                  ),
                ],
              )
              )
            ],
          )
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.only(top: 0),
            child: Column(
              children: [
                Expanded(flex:1, child: Text("At:")),
                Flexible(
                  flex: 3,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide.none
                    ),
                    child: Text(
                      time.format(context),
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onPressed: ()  {
                      onTimeSelect(context);
                    },
                  )
                )
              ],
            )
          ),
        )
      ],
    );
  }

  Widget buttons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: TextButton(
              child:  Text("Set",   
                  style: TextStyle(
                    color: Colors.black
                  ),
              ),
              onPressed: setNotification,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                side: BorderSide(
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.zero
                )
              ),
            )
          )
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: TextButton(
              child: Text("Cancel",
                style: TextStyle(
                  color: AppColors.primary
                ),
              ),
              onPressed: (){
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.wrong,
                side: BorderSide(
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.zero
                )
              ),
            )
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: AppColors.primary,
      shape: const BeveledRectangleBorder(
        side: BorderSide(width: 1)
      ),

      child: Container(
        width: size.width*.75,
        height: size.width*.7,
        padding: const EdgeInsets.all(6),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
            ),
            borderRadius: const BorderRadius.all(Radius.zero)
          ),
          child: FutureBuilder(
            future: reminder,
            builder: (context, AsyncSnapshot<Reminder?> snapshot) {

              if(snapshot.hasData && !loaded){
                print("set selected from db");
                selected = snapshot.data!.days;
                time = snapshot.data!.time;
                loaded =  true;
              }

              return Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: reminderContent(context)
                  ),
                  Expanded(
                    flex: 1,
                    child: buttons(context),
                  )
                ],
              );
            },
          )
        ),
      ),
    );
  }
}

class _DayWidget extends StatelessWidget {
  final String initial;
  final int day;
  final Function(int) onTap;
  final bool isSelected;

  const _DayWidget({
    Key? key, 
    required this.initial, 
    required this.onTap, 
    required this.isSelected, 
    required this.day
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = (day == DateTime.sunday) ? AppColors.wrong : Colors.black;
    print("is selected ${isSelected}");
    return TextButton( 
      child: Text(
        initial,
        style: TextStyle(
          shadows: [
            Shadow(
              color: textColor,
              offset: Offset(0, -4))
            ],
          color: Colors.transparent,
          decoration: isSelected ? TextDecoration.underline : null,
          decorationThickness: isSelected ? 3 : null,
          decorationColor: isSelected ? Colors.black : null,
          fontSize: 19,
          fontWeight:  FontWeight.bold
        ),
      ),
      onPressed: (){
        onTap(day);
      },
      style: TextButton.styleFrom(
        side: isSelected ? null : BorderSide.none,
      )
    );
  }

  
}
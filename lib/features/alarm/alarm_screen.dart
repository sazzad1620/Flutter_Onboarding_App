import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common_widgets/gradient_container.dart';
import 'alarm_provider.dart';
import 'package:intl/intl.dart';

class AlarmScreen extends StatelessWidget {
  final String selectedLocation;

  const AlarmScreen({super.key, required this.selectedLocation});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlarmProvider()..setLocation(selectedLocation),
      child: Scaffold(
        body: GradientContainer(
          child: SafeArea(
            child: Consumer<AlarmProvider>(
              builder: (context, provider, _) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30),

                          // Selected Location
                          Text(
                            provider.selectedLocation ?? "Selected Location",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 12),

                          // Location TextField
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(32, 26, 67, 1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/images/locationLogo2.png",
                                  height: 25,
                                  width: 25,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Add your location",
                                      hintStyle: TextStyle(
                                        color: const Color.fromARGB(
                                          150,
                                          255,
                                          255,
                                          255,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 25),

                          // Alarms Section
                          Text(
                            "Alarms",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 12),

                          // Alarm List
                          Expanded(
                            child: provider.alarms.isEmpty
                                ? Center(
                                    child: Text(
                                      "No alarms set yet",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: provider.alarms.length,
                                    itemBuilder: (context, index) {
                                      DateTime alarm = provider.alarms[index];
                                      bool isToggled = provider.toggles[index];

                                      String formattedTime = DateFormat.jm()
                                          .format(alarm);
                                      String formattedDate = DateFormat(
                                        "EEE dd MMM yyyy",
                                      ).format(alarm);

                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 7,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 22,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(32, 26, 67, 1),
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Alarm Time
                                            Text(
                                              formattedTime,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),

                                            Spacer(),

                                            // Alarm Date
                                            Text(
                                              formattedDate,
                                              style: TextStyle(
                                                color: const Color.fromARGB(
                                                  175,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                                fontSize: 16,
                                              ),
                                            ),

                                            SizedBox(width: 16),

                                            // Toggle Switch
                                            GestureDetector(
                                              onTap: () {
                                                provider.toggleAlarm(index);
                                              },
                                              child: AnimatedContainer(
                                                duration: Duration(
                                                  milliseconds: 200,
                                                ),
                                                width: 50,
                                                height: 24,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isToggled
                                                      ? Color.fromRGBO(
                                                          82,
                                                          0,
                                                          255,
                                                          1,
                                                        ) // On: purple
                                                      : Colors
                                                            .white, // Off: white with low opacity
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Align(
                                                  alignment: isToggled
                                                      ? Alignment.centerRight
                                                      : Alignment.centerLeft,
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      color: isToggled
                                                          ? Colors
                                                                .white // On: white circle
                                                          : Colors
                                                                .black, // Off: black circle
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // Add Alarm Button
                    Positioned(
                      bottom: 80,
                      right: 16,
                      child: GestureDetector(
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            DateTime now = DateTime.now();
                            DateTime alarmTime = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            if (alarmTime.isBefore(now)) {
                              alarmTime = alarmTime.add(Duration(days: 1));
                            }
                            Provider.of<AlarmProvider>(
                              context,
                              listen: false,
                            ).addAlarm(alarmTime);
                          }
                        },
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(82, 0, 255, 1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add, color: Colors.white, size: 32),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

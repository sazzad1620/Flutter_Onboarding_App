import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common_widgets/gradient_container.dart';
import 'alarm_provider.dart';
import 'alarm_model.dart';
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
                          const SizedBox(height: 30),

                          // Selected Location
                          Text(
                            provider.selectedLocation ?? "Selected Location",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Location TextField
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(32, 26, 67, 1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/images/locationLogo2.png",
                                  height: 25,
                                  width: 25,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: TextField(
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Add your location",
                                      hintStyle: TextStyle(
                                        color: Color.fromARGB(
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

                          const SizedBox(height: 25),

                          // Alarms Section
                          const Text(
                            "Alarms",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Alarm List
                          Expanded(
                            child: provider.alarms.isEmpty
                                ? const Center(
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
                                      AlarmModel alarm = provider.alarms[index];

                                      String formattedTime = DateFormat.jm()
                                          .format(alarm.time);
                                      String formattedDate = DateFormat(
                                        "EEE dd MMM yyyy",
                                      ).format(alarm.time);

                                      return Dismissible(
                                        key: ValueKey(alarm.time.toString()),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.only(
                                            right: 20,
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                        onDismissed: (_) {
                                          provider.deleteAlarm(index);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Alarm deleted"),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 7,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 22,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                              32,
                                              26,
                                              67,
                                              1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // Alarm Time
                                              Text(
                                                formattedTime,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                              ),

                                              const Spacer(),

                                              // Alarm Date
                                              Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                    175,
                                                    255,
                                                    255,
                                                    255,
                                                  ),
                                                  fontSize: 16,
                                                ),
                                              ),

                                              const SizedBox(width: 16),

                                              // Toggle Switch
                                              GestureDetector(
                                                onTap: () {
                                                  provider.toggleAlarm(index);
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  width: 50,
                                                  height: 24,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: alarm.isEnabled
                                                        ? const Color.fromRGBO(
                                                            82,
                                                            0,
                                                            255,
                                                            1,
                                                          )
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Align(
                                                    alignment: alarm.isEnabled
                                                        ? Alignment.centerRight
                                                        : Alignment.centerLeft,
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: alarm.isEnabled
                                                            ? Colors.white
                                                            : Colors.black,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
                              alarmTime = alarmTime.add(
                                const Duration(days: 1),
                              );
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
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(82, 0, 255, 1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 32,
                          ),
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

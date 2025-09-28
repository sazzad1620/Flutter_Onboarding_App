import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common_widgets/gradient_container.dart';
import '../alarm/alarm_screen.dart';
import 'location_provider.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocationProvider(),
      builder: (context, child) {
        return Scaffold(
          body: GradientContainer(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    Text(
                      "Welcome! Your Smart Travel Alarm",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 31,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 15),
                    // Paragraph
                    Text(
                      "Stay on schedule and enjoy every moment of your journey.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(height: 30),
                    // Image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Image.asset(
                        'assets/images/location.png',
                        width: double.infinity,
                        height: 325,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 45),
                    // Use Current Location Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          final locationProvider =
                              Provider.of<LocationProvider>(
                                context,
                                listen: false,
                              );
                          // Fetch location
                          await locationProvider.fetchLocation();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: const Color.fromARGB(100, 255, 255, 255),
                            width: 1,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Use Current Location",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 8),
                            Image.asset(
                              "assets/images/locationLogo.png",
                              height: 25,
                              width: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Home Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final locationProvider =
                              Provider.of<LocationProvider>(
                                context,
                                listen: false,
                              );

                          // Fetch location if not fetched
                          if (locationProvider.currentAddress == null) {
                            await locationProvider.fetchLocation();
                          }

                          String location =
                              locationProvider.currentAddress ??
                              "Unknown Location";

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AlarmScreen(selectedLocation: location),
                            ),
                          );
                        },
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(82, 0, 255, 1),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              shadowColor: Colors.transparent,
                            ).copyWith(
                              overlayColor: MaterialStateProperty.all(
                                Colors.transparent,
                              ),
                            ),
                        child: Text("Home", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

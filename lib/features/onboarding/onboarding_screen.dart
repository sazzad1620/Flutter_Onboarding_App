import 'package:flutter/material.dart';
import '../location/location_screen.dart';
import '../../common_widgets/gradient_container.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pagesData = [
    {
      'image': 'assets/images/onboarding1.png',
      'title': "Discover the world, one journey at a time.",
      'paragraph':
          "From hidden gems to iconic destinations, we make travel simple, inspiring, and unforgettable. Start your next adventure today.",
    },
    {
      'image': 'assets/images/onboarding2.png',
      'title': "Explore new horizons, one step at a time.",
      'paragraph':
          "Every trip holds a story waiting to be lived. Let us guide you to experiences that inspire, connect, and last a lifetime.",
    },
    {
      'image': 'assets/images/onboarding3.png',
      'title': "See the beauty, one journey at a time.",
      'paragraph':
          "Travel made simple and exciting—discover places you’ll love and moments you’ll never forget.",
    },
  ];

  void _nextPage() {
    if (_currentIndex < _pagesData.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LocationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: _pagesData.length,
              itemBuilder: (context, index) {
                final page = _pagesData[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //image at top
                    Stack(
                      children: [
                        Image.asset(
                          page['image']!,
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                        ),
                        // Skip button
                        Positioned(
                          top: 65,
                          right: 20,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LocationScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 14),

                    // Text container for heading & paragraph
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // heading
                          Text(
                            page['title']!,
                            style: TextStyle(
                              fontSize: 31,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 14),

                          // Paragraph text
                          Text(
                            page['paragraph']!,
                            style: TextStyle(
                              fontSize: 14.5,
                              color: Colors.white,
                            ),
                          ),

                          // Extra space only for 3rd page
                          if (index == 2) SizedBox(height: 20),

                          SizedBox(height: 32),

                          // Dot indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pagesData.length,
                              (dotIndex) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 6),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _currentIndex == dotIndex
                                      ? Color.fromRGBO(82, 0, 255, 1)
                                      : Color.fromRGBO(186, 153, 255, 0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 32),

                          // Next button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(82, 0, 255, 1),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Text(
                                "Next",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

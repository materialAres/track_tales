import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/list_page.dart';
import 'package:flutter_application_1/widgets/bottom_navigation_icon.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const BookTrackerApp());
}

// Main application widget
class BookTrackerApp extends StatelessWidget {
  const BookTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track Tales',
      theme: ThemeData(
        textTheme: GoogleFonts.caveatTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// The main screen of the application
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const Color widgetBackgroundColor = Color(0xFFF8EDDF);
  static const Color textColor = Color(0xFF7A7166);
  static const Color iconColor = Color(0xFFC3BBAF);
  static const Color iconTextColor = Color(0xFF6F655B);

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Color(0xFFFBF5E9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: Column(
            // Center the content vertically
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'My favourite pick',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),

              // Image container
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widgetBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  'assets/icons/add.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 50),

              // "My number one quote" Title
              const Text(
                'My number one quote',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),

              // Text field for the quote
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: widgetBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type here...',
                    hintStyle: TextStyle(
                      color: iconColor,
                      fontSize: 24,
                    ),
                    border: InputBorder.none, // Hide the default border
                  ),
                ),
              ),

              // Spacer to push the bottom navigation to the bottom
              const Spacer(),

              // Bottom navigation icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BottomNavigationIcon(
                    imagePath: 'assets/icons/list.png',
                    label: 'List',
                    iconColor: iconTextColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ListPage()),
                      );
                    },
                  ),
                  BottomNavigationIcon(
                    imagePath: 'assets/icons/add_book.png',
                    label: 'Add book',
                    iconColor: iconTextColor,
                    isAddButton: true,
                    onTap: () {
                      // Future navigation to add-book page can go here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add Book tapped')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:milk_calculator/screens/farmerRegistrationScreen.dart';
import 'package:milk_calculator/screens/milk_calculation_screen.dart';
import 'package:milk_calculator/screens/transportation_screen.dart';
import 'package:milk_calculator/screens/past_entries_screen.dart';
import 'package:flutter/services.dart'; // Import for exiting the app
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Milky Cloud',
      theme: ThemeData(primarySwatch: Colors.green),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('dd MM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                "Milky Cloud",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              currentDate, // Display the current date
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade900,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              if (value == _titles.length) {
                SystemNavigator.pop(); // Exit the app when "Exit App" is selected
              } else {
                _navigateToScreen(context, value);
              }
            },
            icon: Icon(Icons.menu, color: Colors.white),
            itemBuilder: (context) {
              return List.generate(_titles.length + 1, (index) {
                if (index == _titles.length) {
                  return PopupMenuItem<int>(value: index, child: Text("Exit App"));
                } else {
                  return PopupMenuItem<int>(
                    value: index,
                    child: Text(_titles[index]),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: Container(  // Wrap the body with a Container for the background gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.green.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(  // Center the entire body
          child: Padding(
            padding: EdgeInsets.all(20),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              shrinkWrap: true,  // Prevents the GridView from taking up all space
              itemBuilder: (context, index) {
                return _buildGlassmorphicCard(
                  context,
                  _titles[index],
                  _icons[index],
                  _screens[index],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container( // Use a container with gradient background for the text
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.green.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Text(
          "© Madhav Vedpathak 2025 | All Rights Reserved | Private License",
          style: TextStyle(
            fontSize: 10,
            color: Colors.white,
            fontStyle: FontStyle.italic,
            shadows: [Shadow(color: Colors.blue, blurRadius: 20)],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCard(BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.white),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _screens[index]),
    );
  }
}

final List<String> _titles = [
  "Milk Collection",
  "Show Past Collection",
  "Add Farmer",
  "Cost Estimation",
];

final List<IconData> _icons = [
  Icons.local_drink_rounded,
  Icons.local_drink_rounded,
  Icons.pets_rounded,
  Icons.local_shipping_rounded,
];

final List<Widget> _screens = [
  MilkCalculationScreen(),
  PastEntriesScreen(),
  FarmerRegistrationScreen(),
  TransportationScreen(),
];

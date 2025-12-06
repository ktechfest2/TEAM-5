import 'package:aurion_hotel/_components/color.dart';
import 'package:aurion_hotel/_logik/Ui_bridges/splash_screen_to.dart';
import 'package:aurion_hotel/main_codes/HotelHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
    with TickerProviderStateMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<String> selectedPreferences = [];
  bool saving = false;

  late TabController _tabController;

  final Map<String, List<Map<String, String>>> categories = {
    'Rooms': [
      {'title': 'Modern', 'image': 'assets/prefs/home/1.jpeg'},
      {'title': 'Open Space', 'image': 'assets/prefs/home/2.jpeg'},
      {'title': 'Swimming pool', 'image': 'assets/prefs/home/3.jpeg'},
      {'title': 'Nature', 'image': 'assets/prefs/home/4.jpeg'},
      {'title': 'Urban', 'image': 'assets/prefs/home/5.jpeg'},
      {'title': 'Roof Garden', 'image': 'assets/prefs/home/6.jpeg'},
      // add more...
    ],
    'Hobbies': [
      {'title': 'Voice over', 'image': 'assets/prefs/hobbies/1.jpeg'},
      {'title': 'Reading', 'image': 'assets/prefs/hobbies/2.jpeg'},
      {'title': 'Photography', 'image': 'assets/prefs/hobbies/3.jpeg'},
      {'title': 'Music', 'image': 'assets/prefs/hobbies/4.jpeg'},
      {'title': 'Gym', 'image': 'assets/prefs/hobbies/5.jpeg'},
      {'title': 'Painting', 'image': 'assets/prefs/hobbies/6.jpeg'},
      {'title': 'Singing', 'image': 'assets/prefs/hobbies/7.jpeg'},

      // add more...
    ], 
    'Decor': [
      {'title': 'Neon', 'image': 'assets/prefs/decor/1.jpeg'},
      {'title': 'Gold', 'image': 'assets/prefs/decor/2.jpeg'},
      {'title': 'Luxury', 'image': 'assets/prefs/decor/3.jpeg'},
      {'title': 'Vintage', 'image': 'assets/prefs/decor/4.jpeg'},
      {'title': 'Roof Top', 'image': 'assets/prefs/decor/5.jpeg'},
      {'title': 'Hallways', 'image': 'assets/prefs/decor/6.jpeg'},
      {'title': 'Classical', 'image': 'assets/prefs/decor/7.jpeg'},
      {'title': 'Historical', 'image': 'assets/prefs/decor/8.jpeg'},
      {'title': 'Outdoors', 'image': 'assets/prefs/decor/9.jpeg'},
      // // add more...
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.keys.length, vsync: this);
  }

  void togglePreference(String preference) {
    setState(() {
      if (selectedPreferences.contains(preference)) {
        selectedPreferences.remove(preference);
      } else {
        selectedPreferences.add(preference);
      }
    });
  }

  Future<void> savePreferences() async {
    setState(() => saving = true);
    try {
      final user = auth.currentUser;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).update({
          'preferences': selectedPreferences,
        });
      }

      // Navigate to the next screen or show a success message with push replacement
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SplashScreenTo(
            screen: HotelHomeScreen(),
          ),
        ),
      );
    } catch (e) {
      print('Error saving preferences: $e');
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 800
        ? 4
        : width > 500
            ? 3
            : 2;

    return Scaffold(
      backgroundColor: auxColor3,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('Select Your Preferences',
            style: TextStyle(color: auxColor3)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${selectedPreferences.length} selected',
                style: const TextStyle(
                    color: auxColor, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: auxColor,
            labelColor: auxColor,
            unselectedLabelColor: auxColor2,
            tabs: categories.keys.map((e) => Tab(text: e)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      final item = entry.value[index];
                      final isSelected =
                          selectedPreferences.contains(item['title']);
                      return GestureDetector(
                        onTap: () => togglePreference(item['title']!),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? auxColor
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: AssetImage(item['image']!),
                                  fit: BoxFit.cover,
                                  colorFilter: isSelected
                                      ? ColorFilter.mode(
                                          mainColor.withOpacity(0.5),
                                          BlendMode.darken)
                                      : null,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.check_circle,
                                      color: auxColor, size: 24),
                                ),
                              ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: mainColor.withOpacity(0.7),
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16)),
                                ),
                                child: Text(
                                  item['title']!,
                                  style: const TextStyle(
                                      color: auxColor3,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: width * 0.5,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedPreferences.isEmpty || saving
                    ? null
                    : savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: auxColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 6,
                ),
                child: saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: mainColor,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Save Preferences',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: mainColor),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

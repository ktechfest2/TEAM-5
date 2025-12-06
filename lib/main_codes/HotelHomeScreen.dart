import 'package:aurion_hotel/_components/color.dart';
import 'package:aurion_hotel/_logik/Ui_bridges/splash_screen_to.dart';
import 'package:aurion_hotel/main_codes/onboarding_screens/onboardingview.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'hotel_pages/home_page.dart';
import 'hotel_pages/bookings_page.dart';
import 'hotel_pages/services_page.dart';
import 'hotel_pages/chat_page.dart';
import 'hotel_pages/profile_page.dart';

class HotelHomeScreen extends StatefulWidget {
  const HotelHomeScreen({super.key});

  @override
  State<HotelHomeScreen> createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen> {
  late String secretPin;
  bool pinGenerated = false;
  bool showPin = false;
  int currentPageIndex = 0;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  Map<int, bool> isHovered = {};

  final List<Map<String, dynamic>> services = [
    {
      "name": "Dry Cleaning",
      "icon": Icons.local_laundry_service,
      "color": Color(0xFF6C5CE7)
    },
    {
      "name": "Room Service",
      "icon": Icons.room_service,
      "color": Color(0xFFF39C12)
    },
    {"name": "Spa & Wellness", "icon": Icons.spa, "color": Color(0xFF1ABC9C)},
    {"name": "Concierge", "icon": Icons.person_3, "color": Color(0xFFE74C3C)},
    {
      "name": "Restaurant",
      "icon": Icons.restaurant,
      "color": Color(0xFF27AE60)
    },
    {
      "name": "Parking",
      "icon": Icons.directions_car,
      "color": Color(0xFF2980B9)
    },
  ];

  final List<NavItem> navItems = [
    NavItem(icon: Icons.home, label: "Home", index: 0),
    NavItem(icon: Icons.bed, label: "Bookings", index: 1),
    NavItem(icon: Icons.room_service, label: "Services", index: 2),
    NavItem(icon: Icons.chat, label: "Chat", index: 3),
    NavItem(icon: Icons.person, label: "Profile", index: 4),
  ];

  @override
  void initState() {
    super.initState();
    _initializeSecretPin();
    for (var item in navItems) {
      isHovered[item.index] = false;
    }
  }

  Future<void> _initializeSecretPin() async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);
    final doc = await userDoc.get();

    if (!doc.exists || !doc.data()!.containsKey('secretPin')) {
      secretPin = _generateSecretPin();
      await userDoc.set({'secretPin': secretPin}, SetOptions(merge: true));
    } else {
      secretPin = doc['secretPin'];
    }

    setState(() => pinGenerated = true);
  }

  String _generateSecretPin() {
    return (Random().nextInt(9000) + 1000).toString();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: auxColor3,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 900;
            final isMobile = constraints.maxWidth < 600;

            return Row(
              children: [
                if (isDesktop) _buildSideNav(),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopAppBar(isMobile),
                      Expanded(
                        child: pinGenerated
                            ? _buildPageContent(isMobile)
                            : Center(child: CircularProgressIndicator()),
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSideNav() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: mainColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              'assets/logo2.png', // Add your logo here
              height: 80,
              width: 80,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                return _buildNavItem(item);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: auxColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                //launch oretty alert dialog to confirm logout
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          //firebase logout
                          // FirebaseAuth.instance.signOut();
                          //navigate to onboarding page;;  with push replacement
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SplashScreenTo(
                                    screen: const Onboardingview())),
                          );
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                "Logout",
                style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavItem item) {
    final bool selected = currentPageIndex == item.index;
    final bool hovered = isHovered[item.index] ?? false;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered[item.index] = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered[item.index] = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            currentPageIndex = item.index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? auxColor
                : hovered
                    ? auxColor.withOpacity(0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: selected
                    ? mainColor
                    : hovered
                        ? auxColor
                        : auxColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                item.label,
                style: TextStyle(
                  color: selected
                      ? mainColor
                      : hovered
                          ? auxColor
                          : auxColor,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppBar(bool isMobile) {
    return Container(
      color: mainColor,
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.hotel, color: auxColor, size: 32),
              const SizedBox(width: 12),
              Text(
                "Enjoy your Luxury Stay!",
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: auxColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: auxColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: auxColor, width: 1.5),
            ),
            child: Row(
              children: [
                Text(
                  "PIN: ${showPin ? secretPin : '****'}",
                  style: TextStyle(
                    color: auxColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => showPin = !showPin),
                    child: Icon(
                      showPin ? Icons.visibility : Icons.visibility_off,
                      color: auxColor,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(bool isMobile) {
    final pages = [
      HotelHomePage(isMobile: isMobile, secretPin: secretPin),
      BookingsPage(
        isMobile: isMobile,
        userId: currentUserId,
      ),
      ServicesPage(isMobile: isMobile),
      ChatPage(isMobile: isMobile),
      ProfilePage(isMobile: isMobile),
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Builder(
        key: ValueKey(currentPageIndex),
        builder: (_) {
          try {
            return pages[currentPageIndex];
          } catch (e) {
            return Center(
              child: Text("Error loading page: $e",
                  style: TextStyle(color: Colors.red)),
            );
          }
        },
      ),
    );
  }

  // Widget _buildHomePage(bool isMobile) {
  //   final isTablet = MediaQuery.of(context).size.width >= 600 &&
  //       MediaQuery.of(context).size.width < 1200;
  //   return SingleChildScrollView(
  //     child: Padding(
  //       padding: EdgeInsets.symmetric(
  //           horizontal: isMobile ? 16 : (isTablet ? 24 : 32), vertical: 20),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           _buildWelcomeBanner(isMobile),
  //           const SizedBox(height: 28),
  //           _buildSecretPinCard(isMobile),
  //           const SizedBox(height: 28),
  //           _buildRoomBookingCard(isMobile),
  //           const SizedBox(height: 28),
  //           _buildSectionHeader("Premium Services", isMobile),
  //           const SizedBox(height: 12),
  //           _buildServicesGrid(isMobile, isTablet),
  //           const SizedBox(height: 28),
  //           _buildSectionHeader("Your Bookings", isMobile),
  //           const SizedBox(height: 12),
  //           _buildBookingHistory(isMobile),
  //           const SizedBox(height: 28),
  //           _buildSectionHeader("Personalized Suggestions", isMobile),
  //           const SizedBox(height: 12),
  //           _buildSuggestions(isMobile, isTablet),
  //           const SizedBox(height: 40),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBookingsPage(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bed, size: 80, color: auxColor),
          const SizedBox(height: 20),
          Text("Bookings Page",
              style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildServicesPage(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.room_service, size: 80, color: auxColor),
          const SizedBox(height: 20),
          Text("Services Page",
              style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildChatPage(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat, size: 80, color: auxColor),
          const SizedBox(height: 20),
          Text("Chat Page", style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildProfilePage(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80, color: auxColor),
          const SizedBox(height: 20),
          Text("Profile Page",
              style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }

  // // Keep all existing build methods...
  // Widget _buildWelcomeBanner(bool isMobile) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //           colors: [mainColor, auxColor2],
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight),
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //             color: mainColor.withOpacity(0.3),
  //             blurRadius: 12,
  //             offset: const Offset(0, 4))
  //       ],
  //     ),
  //     padding: EdgeInsets.all(isMobile ? 20 : 28),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text("Welcome Back!",
  //             style: TextStyle(
  //                 fontSize: isMobile ? 28 : 36,
  //                 fontWeight: FontWeight.bold,
  //                 color: auxColor,
  //                 letterSpacing: 0.5)),
  //         const SizedBox(height: 8),
  //         Text(
  //             "Your luxury experience awaits. Manage bookings and explore exclusive services.",
  //             style: TextStyle(
  //                 fontSize: isMobile ? 14 : 16,
  //                 color: auxColor3.withOpacity(0.9),
  //                 height: 1.5)),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildSecretPinCard(bool isMobile) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: auxColor, width: 2),
  //       boxShadow: [
  //         BoxShadow(
  //             color: auxColor.withOpacity(0.15),
  //             blurRadius: 10,
  //             offset: const Offset(0, 4))
  //       ],
  //     ),
  //     padding: EdgeInsets.all(isMobile ? 16 : 20),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //               color: auxColor.withOpacity(0.1), shape: BoxShape.circle),
  //           child: Icon(Icons.lock_open,
  //               color: auxColor, size: isMobile ? 24 : 32),
  //         ),
  //         const SizedBox(width: 16),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text("Your Secret Access PIN",
  //                   style: TextStyle(
  //                       fontSize: isMobile ? 12 : 14,
  //                       color: mainColor.withOpacity(0.6),
  //                       fontWeight: FontWeight.w500)),
  //               const SizedBox(height: 4),
  //               Text(secretPin,
  //                   style: TextStyle(
  //                       fontSize: isMobile ? 24 : 32,
  //                       fontWeight: FontWeight.bold,
  //                       color: auxColor,
  //                       letterSpacing: 2)),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildRoomBookingCard(bool isMobile) {
  //   return Container(
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(16),
  //         boxShadow: [
  //           BoxShadow(
  //               color: Colors.black.withOpacity(0.08),
  //               blurRadius: 12,
  //               offset: const Offset(0, 4))
  //         ]),
  //     padding: EdgeInsets.all(isMobile ? 16 : 20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(children: [
  //           Icon(Icons.bed, color: auxColor, size: 28),
  //           const SizedBox(width: 12),
  //           Text("Room Details",
  //               style: TextStyle(
  //                   fontSize: isMobile ? 18 : 22,
  //                   fontWeight: FontWeight.bold,
  //                   color: mainColor))
  //         ]),
  //         const SizedBox(height: 16),
  //         _buildBookingField("Check-in", "Dec 20, 2024", Icons.calendar_today),
  //         const SizedBox(height: 12),
  //         _buildBookingField("Check-out", "Dec 25, 2024", Icons.calendar_today),
  //         const SizedBox(height: 12),
  //         _buildBookingField(
  //             "Room Type", "Deluxe Suite", Icons.door_front_door),
  //         const SizedBox(height: 16),
  //         SizedBox(
  //           width: double.infinity,
  //           child: ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //                 backgroundColor: auxColor,
  //                 padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12))),
  //             onPressed: () {},
  //             child: Text("Modify Booking",
  //                 style: TextStyle(
  //                     fontSize: isMobile ? 16 : 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: mainColor,
  //                     letterSpacing: 0.5)),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildBookingField(String label, String value, IconData icon) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //     decoration: BoxDecoration(
  //         color: auxColor3,
  //         borderRadius: BorderRadius.circular(8),
  //         border: Border.all(color: mainColor.withOpacity(0.2))),
  //     child: Row(
  //       children: [
  //         Icon(icon, color: auxColor, size: 20),
  //         const SizedBox(width: 12),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(label,
  //                 style: TextStyle(
  //                     fontSize: 12,
  //                     color: mainColor.withOpacity(0.6),
  //                     fontWeight: FontWeight.w500)),
  //             Text(value,
  //                 style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.bold,
  //                     color: mainColor)),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildServicesGrid(bool isMobile, bool isTablet) {
  //   int crossCount = isMobile ? 2 : (isTablet ? 3 : 6);
  //   return GridView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: crossCount,
  //         crossAxisSpacing: 12,
  //         mainAxisSpacing: 12),
  //     itemCount: services.length,
  //     itemBuilder: (context, index) =>
  //         _buildServiceCard(services[index], isMobile),
  //   );
  // }

  // Widget _buildServiceCard(Map<String, dynamic> service, bool isMobile) {
  //   return GestureDetector(
  //     onTap: () {},
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(
  //               color: service['color'].withOpacity(0.2),
  //               blurRadius: 10,
  //               offset: const Offset(0, 4))
  //         ],
  //         border:
  //             Border.all(color: service['color'].withOpacity(0.3), width: 1.5),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //                 color: service['color'].withOpacity(0.1),
  //                 shape: BoxShape.circle),
  //             child: Icon(service['icon'],
  //                 color: service['color'], size: isMobile ? 32 : 40),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(service['name'],
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                   fontSize: isMobile ? 12 : 14,
  //                   fontWeight: FontWeight.bold,
  //                   color: mainColor)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildBookingHistory(bool isMobile) {
  //   return Container(
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)
  //         ]),
  //     child: ListView.separated(
  //       shrinkWrap: true,
  //       physics: const NeverScrollableScrollPhysics(),
  //       itemCount: 3,
  //       separatorBuilder: (_, __) =>
  //           Divider(color: mainColor.withOpacity(0.1), height: 0),
  //       itemBuilder: (context, index) {
  //         return Padding(
  //           padding: EdgeInsets.all(isMobile ? 12 : 16),
  //           child: Row(
  //             children: [
  //               Icon(Icons.check_circle, color: auxColor, size: 28),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text("Booking #${1000 + index}",
  //                         style: TextStyle(
  //                             fontSize: isMobile ? 14 : 16,
  //                             fontWeight: FontWeight.bold,
  //                             color: mainColor)),
  //                     const SizedBox(height: 4),
  //                     Text("Dec ${20 + index} - Dec ${25 + index}, 2024",
  //                         style: TextStyle(
  //                             fontSize: isMobile ? 12 : 14,
  //                             color: mainColor.withOpacity(0.6))),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget _buildSuggestions(bool isMobile, bool isTablet) {
  //   final suggestions = [
  //     {"name": "Spa Relaxation Package", "icon": Icons.spa},
  //     {"name": "Fine Dining Reservation", "icon": Icons.restaurant},
  //     {"name": "Airport Transfer", "icon": Icons.flight},
  //   ];

  //   return GridView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
  //       crossAxisSpacing: 16,
  //       mainAxisSpacing: 16,
  //       childAspectRatio: isMobile ? 1.2 : 1,
  //     ),
  //     itemCount: suggestions.length,
  //     itemBuilder: (context, index) {
  //       final suggestion = suggestions[index];
  //       return Container(
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //               colors: [auxColor.withOpacity(0.8), auxColor2],
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight),
  //           borderRadius: BorderRadius.circular(12),
  //           boxShadow: [
  //             BoxShadow(
  //                 color: auxColor.withOpacity(0.2),
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 2))
  //           ],
  //         ),
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(suggestion['icon'] as IconData,
  //                 color: Colors.white, size: isMobile ? 32 : 40),
  //             const SizedBox(height: 12),
  //             Text(suggestion['name'] as String,
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                     fontSize: isMobile ? 14 : 16,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.white)),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _buildSectionHeader(String title, bool isMobile) {
  //   return Text(title,
  //       style: TextStyle(
  //           fontSize: isMobile ? 20 : 26,
  //           fontWeight: FontWeight.bold,
  //           color: mainColor,
  //           letterSpacing: 0.5));
  // }
}

class NavItem {
  final IconData icon;
  final String label;
  final int index;

  NavItem({required this.icon, required this.label, required this.index});
}

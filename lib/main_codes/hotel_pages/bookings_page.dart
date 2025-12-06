import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aurion_hotel/_components/color.dart';
import 'package:aurion_hotel/_logik/notification_services.dart';

class BookingsPage extends StatefulWidget {
  final String userId;
  final bool isMobile;
  const BookingsPage({required this.userId, Key? key, required this.isMobile})
      : super(key: key);

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String? selectedRoomId;

  // FILTERS
  String searchQuery = '';
  String? roomTypeFilter;
  String priceSort = 'none';
  bool showAvailableOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              Color(0xFFF8F9FA),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilters(),
              Expanded(child: _buildRoomsList()),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- FILTERS UI --------------------
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search rooms...",
                filled: true,
                fillColor: Colors.grey[200],
                hintStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: mainColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: auxColor, width: 2),
                ),
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: roomTypeFilter,
              hint: const Text("Room Type",
                  style: TextStyle(color: Colors.black)),
              items: ['Economy', 'Standard', 'Luxury']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => roomTypeFilter = v),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: priceSort,
              items: const [
                DropdownMenuItem(value: 'none', child: Text('None')),
                DropdownMenuItem(value: 'asc', child: Text('Low → High')),
                DropdownMenuItem(value: 'desc', child: Text('High → Low')),
              ],
              onChanged: (v) => setState(() => priceSort = v!),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              const Text("Available Only", style: TextStyle(color: mainColor)),
              Switch(
                value: showAvailableOnly,
                onChanged: (v) => setState(() => showAvailableOnly = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- ROOM GRID -------------------
  Widget _buildRoomsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> rooms = snapshot.data!.docs;

        // FILTER
        rooms = rooms.where((doc) {
          final data = doc.data()! as Map<String, dynamic>;

          final matchesSearch = data['title']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

          final matchesType = roomTypeFilter == null
              ? true
              : data['roomType'].toString().toLowerCase() ==
                  roomTypeFilter!.toLowerCase();

          final matchesAvailability =
              showAvailableOnly ? (data['occupied'] == false) : true;

          return matchesSearch && matchesType && matchesAvailability;
        }).toList();

        // SORT PRICE
        if (priceSort != 'none') {
          rooms.sort((a, b) {
            final aPrice = (a['pricePerDay'] ?? 0).toDouble();
            final bPrice = (b['pricePerDay'] ?? 0).toDouble();
            return priceSort == 'asc'
                ? aPrice.compareTo(bPrice)
                : bPrice.compareTo(aPrice);
          });
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rooms.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final room = rooms[index];
            final data = room.data()! as Map<String, dynamic>;

            final isSelected = selectedRoomId == room.id;
            final price = (data['pricePerDay'] ?? 0);
            final formattedPrice = price
                .toString()
                .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ",");

            return GestureDetector(
              onTap: () {
                if (data['occupied'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Room currently occupied"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                setState(() => selectedRoomId = room.id);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: Colors.green, width: 3)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        data['photoUrl'] ??
                            "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black87,
                            Colors.black54,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['title'] ?? "",
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text("₦$formattedPrice / day",
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF27AE60),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- BOOK NOW BUTTON -------------------
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: auxColor,
            minimumSize: const Size(220, 55),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: selectedRoomId == null
              ? null
              : () => _openBookingDialog(selectedRoomId!),
          child: Text("Book Now",
              style: TextStyle(
                  color: mainColor, fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('Book a Room',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: mainColor)),
          const Spacer(),
        ],
      ),
    );
  }

  // ------------------- BOOKING DIALOG -------------------
  void _openBookingDialog(String roomId) {
    DateTime? startDate;
    int stayDays = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: auxColor3,
            title: const Text("Book Room",
                style: TextStyle(
                    fontSize: 20,
                    color: mainColor,
                    fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // PICK DATE
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => startDate = picked);
                    }
                  },
                  child: Text(startDate == null
                      ? "Select Start Date"
                      : "Start: ${startDate!.toString().split(' ')[0]}"),
                ),
                const SizedBox(height: 12),

                // DURATION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Days:", style: TextStyle(color: Colors.black)),
                    DropdownButton<int>(
                      value: stayDays,
                      items: List.generate(30, (i) => i + 1)
                          .map((d) => DropdownMenuItem(
                              value: d, child: Text("$d days")))
                          .toList(),
                      onChanged: (v) => setState(() => stayDays = v!),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: mainColor)),
              ),
              ElevatedButton(
                onPressed: startDate == null
                    ? null
                    : () async {
                        Navigator.pop(context);
                        await createBooking(
                            userId: widget.userId,
                            roomId: roomId,
                            startDate: startDate!,
                            stayDays: stayDays);
                      },
                style: ElevatedButton.styleFrom(backgroundColor: auxColor),
                child: const Text("Confirm Booking",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  // ------------------- CREATE BOOKING -------------------
  Future<void> createBooking({
    required String userId,
    required String roomId,
    required DateTime startDate,
    required int stayDays,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final endDate = startDate.add(Duration(days: stayDays));

    await firestore.collection("bookings").add({
      "userId": userId,
      "roomBooked": roomId,
      "startDate": Timestamp.fromDate(startDate),
      "endDate": Timestamp.fromDate(endDate),
      "durationDays": stayDays,
      "createdAt": FieldValue.serverTimestamp(),
      "status": "confirmed",
      "paymentStatus": "pending"
    });

    // Mark room as occupied
    await firestore.collection("rooms").doc(roomId).update({"occupied": true});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Booking Successful!"), backgroundColor: Colors.green),
    );

    await createNotification(
      title: "New Booking",
      message: "Room $roomId has been booked.",
      type: "book",
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:aurion_hotel/_components/color.dart';
// import 'package:aurion_hotel/_logik/notification_services.dart';

// class BookingsPage extends StatefulWidget {
//   final String userId;
//   final bool isMobile;
//   const BookingsPage({required this.userId, Key? key, required this.isMobile})
//       : super(key: key);

//   @override
//   _BookingsPageState createState() => _BookingsPageState();
// }

// class _BookingsPageState extends State<BookingsPage> {
//   String? selectedRoomId;
//   List<Map<String, dynamic>> selectedRoomBookedRanges = [];

//   // FILTER STATE
//   String searchQuery = '';
//   String? roomTypeFilter; // 'Economy' | 'Standard' | 'Luxury'
//   String priceSort = 'none'; // 'asc' | 'desc' | 'none'
//   bool showAvailableOnly = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.bottomRight,
//             end: Alignment.topLeft,
//             colors: [
//               Color(0xFFF8F9FA),
//               Colors.white,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildHeader(),
//               _buildFilters(),
//               Expanded(child: _buildRoomsList()),
//               _buildBottomBar(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilters() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "Search rooms...",
//                 filled: true,
//                 fillColor: Colors.grey[200],
//                 //the text in the search box should be black an dvisible
//                 hintStyle: const TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide(color: mainColor.withOpacity(0.3)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide(color: auxColor, width: 2),
//                 ),
//               ),
//               onChanged: (v) => setState(() => searchQuery = v),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: DropdownButtonFormField<String>(
//               value: roomTypeFilter,
//               hint: const Text("Room Type",
//                   style: TextStyle(color: Colors.black)),
//               items: ['Economy', 'Standard', 'Luxury']
//                   .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                   .toList(),
//               onChanged: (v) => setState(() => roomTypeFilter = v),
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.grey[200],
//                 hintStyle: const TextStyle(color: Colors.black),
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: DropdownButtonFormField<String>(
//               value: priceSort,
//               items: [
//                 DropdownMenuItem(
//                     value: 'none',
//                     child: Text('None',
//                         style: TextStyle(color: Colors.grey[400]))),
//                 DropdownMenuItem(
//                     value: 'asc',
//                     child: Text('Low → High',
//                         style: TextStyle(color: Colors.grey[400]))),
//                 DropdownMenuItem(
//                     value: 'desc',
//                     child: Text('High → Low',
//                         style: TextStyle(color: Colors.grey[400]))),
//               ],
//               onChanged: (v) => setState(() => priceSort = v!),
//               hint: const Text("Price"),
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.grey[200],
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Flexible(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 const Text("Available Only",
//                     style: TextStyle(color: mainColor)),
//                 Switch(
//                   value: showAvailableOnly,
//                   onChanged: (v) => setState(() => showAvailableOnly = v),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRoomsList() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text("No rooms available."));
//         }

//         List<QueryDocumentSnapshot> rooms = snapshot.data!.docs;

//         // FILTER
//         rooms = rooms.where((doc) {
//           final data = doc.data()! as Map<String, dynamic>;
//           final matchesSearch = data['title']
//               .toString()
//               .toLowerCase()
//               .contains(searchQuery.toLowerCase());
//           final matchesType = roomTypeFilter == null
//               ? true
//               : data['roomType'].toString().toLowerCase() ==
//                   roomTypeFilter!.toLowerCase();
//           final matchesAvailability =
//               showAvailableOnly ? (data['cleaningStatus'] == 'cleaned') : true;
//           return matchesSearch && matchesType && matchesAvailability;
//         }).toList();

//         // SORT
//         if (priceSort != 'none') {
//           rooms.sort((a, b) {
//             final aPrice = (a['pricePerDay'] ?? 0).toDouble();
//             final bPrice = (b['pricePerDay'] ?? 0).toDouble();
//             return priceSort == 'asc'
//                 ? aPrice.compareTo(bPrice)
//                 : bPrice.compareTo(aPrice);
//           });
//         }

//         return GridView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: rooms.length,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//             childAspectRatio: 1,
//           ),
//           itemBuilder: (context, index) {
//             final room = rooms[index];
//             final data = room.data()! as Map<String, dynamic>;
//             final isSelected = selectedRoomId == room.id;
//             final price = int.parse((data['pricePerDay'] ?? 0).toString());
//             final formattedPrice = price.toString().replaceAllMapped(
//                   RegExp(r'\B(?=(\d{3})+(?!\d))'),
//                   (match) => ',',
//                 );
//             final features =
//                 (data['features'] as List<dynamic>?)?.take(2).toList() ?? [];

//             return GestureDetector(
//               onTap: () => _onSelectRoom(room.id, data['bookedRanges'] ?? []),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 6,
//                       offset: const Offset(0, 3),
//                     )
//                   ],
//                   border: isSelected
//                       ? Border.all(color: Colors.green, width: 3)
//                       : null,
//                 ),
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     // Photo as background
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         data['photoUrl'] ??
//                             'https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     // Overlay gradient
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         gradient: LinearGradient(
//                           begin: Alignment.bottomCenter,
//                           end: Alignment.topCenter,
//                           colors: [
//                             Colors.black87,
//                             Colors.black54,
//                             Colors.transparent,
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Price and title at bottom
//                     Positioned(
//                       bottom: 8,
//                       left: 8,
//                       right: 8,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             data['title'] ?? '',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             '₦$formattedPrice per day',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF27AE60),
//                             ),
//                           ),
//                           if (features.isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 4),
//                               child: Text(
//                                 features.join(' • '),
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.white70,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildBottomBar() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: Colors.grey[200],
//       child: Center(
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: auxColor,
//             minimumSize: const Size(220, 55), // Bigger button
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(18),
//             ),
//           ),
//           onPressed: selectedRoomId == null
//               ? null
//               : () => _openBookingDialog(
//                     selectedRoomId!,
//                     selectedRoomBookedRanges,
//                   ),
//           child: Text(
//             'Book Now',
//             style: TextStyle(
//               color: mainColor,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _onSelectRoom(String roomId, List<dynamic> bookedRanges) {
//     setState(() {
//       selectedRoomId = selectedRoomId == roomId ? null : roomId;
//       selectedRoomBookedRanges =
//           bookedRanges.map((e) => Map<String, dynamic>.from(e)).toList();
//     });
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Text('Book a Room',
//               style: TextStyle(
//                   fontSize: 28, fontWeight: FontWeight.bold, color: mainColor)),
//           const Spacer(),
//         ],
//       ),
//     );
//   }

//   // Keep _openBookingDialog, _isDayAvailable, createBooking as in your original code
//   void _openBookingDialog(
//       String roomId, List<Map<String, dynamic>> bookedRanges) {
//     DateTime? startDate;
//     DateTime? endDate;
//     final effectsController = TextEditingController();
//     List<String> personalEffects = [];

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(builder: (context, setState) {
//           return AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             backgroundColor: auxColor3,
//             title: const Text("Book Room",
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: mainColor)),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // PERSONAL EFFECTS INPUT
//                   TextField(
//                     controller: effectsController,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       hintText: "Add a personal effect",
//                       hintStyle: TextStyle(color: Colors.black),
//                       suffixIcon: IconButton(
//                         icon: const Icon(
//                           Icons.add,
//                           color: mainColor,
//                         ),
//                         onPressed: () {
//                           if (effectsController.text.trim().isNotEmpty) {
//                             setState(() {
//                               personalEffects
//                                   .add(effectsController.text.trim());
//                               effectsController.clear();
//                             });
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 6,
//                     children: personalEffects.map((e) {
//                       return Chip(
//                         label: Text(e),
//                         onDeleted: () {
//                           setState(() => personalEffects.remove(e));
//                         },
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 20),
//                   // START DATE PICKER
//                   ElevatedButton(
//                     onPressed: () async {
//                       final picked = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime.now(),
//                         lastDate: DateTime.now().add(const Duration(days: 365)),
//                         selectableDayPredicate: (day) {
//                           return _isDayAvailable(day, bookedRanges);
//                         },
//                       );
//                       if (picked != null) {
//                         setState(() => startDate = picked);
//                       }
//                     },
//                     child: Text(
//                         startDate == null
//                             ? "Select Start Date"
//                             : "Start: ${startDate!.toString().split(' ')[0]}",
//                         selectionColor: mainColor,
//                         style: TextStyle(
//                           color: Colors.black,
//                         )),
//                   ),
//                   const SizedBox(height: 12),
//                   // END DATE PICKER
//                   ElevatedButton(
//                     onPressed: startDate == null
//                         ? null
//                         : () async {
//                             final picked = await showDatePicker(
//                               context: context,
//                               initialDate:
//                                   startDate!.add(const Duration(days: 1)),
//                               firstDate: startDate!,
//                               lastDate:
//                                   DateTime.now().add(const Duration(days: 365)),
//                               selectableDayPredicate: (day) {
//                                 if (day.isBefore(startDate!)) return false;
//                                 return _isDayAvailable(day, bookedRanges);
//                               },
//                             );
//                             if (picked != null) {
//                               setState(() => endDate = picked);
//                             }
//                           },
//                     child: Text(
//                       endDate == null
//                           ? "Select End Date"
//                           : "End: ${endDate!.toString().split(' ')[0]}",
//                       selectionColor: mainColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("Cancel", style: TextStyle(color: mainColor)),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: auxColor),
//                 onPressed: (startDate == null || endDate == null)
//                     ? null
//                     : () async {
//                         Navigator.pop(context);
//                         await createBooking(
//                           userId: widget.userId,
//                           roomId: roomId,
//                           start: startDate!,
//                           end: endDate!,
//                           personalEffects: personalEffects,
//                         );
//                       },
//                 child: const Text("Confirm Booking",
//                     style: TextStyle(color: Colors.white)),
//               )
//             ],
//           );
//         });
//       },
//     );
//   }

//   bool _isDayAvailable(DateTime day, List<Map<String, dynamic>> bookedRanges) {
//     for (final r in bookedRanges) {
//       final start = (r['start'] as Timestamp).toDate();
//       final end = (r['end'] as Timestamp).toDate();
//       if (!day.isBefore(start) && !day.isAfter(end)) {
//         return false;
//       }
//     }
//     return true;
//   }

//   // Widget _buildHeader() {
//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//   //     child: Row(
//   //       children: [
//   //         Text('Book a Room',
//   //             style: TextStyle(
//   //                 fontSize: 28, fontWeight: FontWeight.bold, color: mainColor)),
//   //         const Spacer(),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Future<void> createBooking({
//     required String userId,
//     required String roomId,
//     required DateTime start,
//     required DateTime end,
//     required List<String> personalEffects,
//   }) async {
//     final firestore = FirebaseFirestore.instance;
//     final roomRef = firestore.collection('rooms').doc(roomId);

//     await firestore.runTransaction((tx) async {
//       final snap = await tx.get(roomRef);
//       final data = snap.data()!;
//       final bookedRanges =
//           List<Map<String, dynamic>>.from(data['bookedRanges'] ?? []);

//       // OVERLAP CHECK
//       for (final r in bookedRanges) {
//         final s = (r['start'] as Timestamp).toDate();
//         final e = (r['end'] as Timestamp).toDate();
//         if (start.isBefore(e) && s.isBefore(end)) {
//           throw Exception("Selected date range is unavailable.");
//         }
//       }

//       // CREATE BOOKING DOCUMENT
//       final bookingRef = firestore.collection('bookings').doc();
//       tx.set(bookingRef, {
//         'bookId': bookingRef.id,
//         'userId': userId,
//         'roomBooked': roomId,
//         'startDate': Timestamp.fromDate(start),
//         'endDate': Timestamp.fromDate(end),
//         'personalEffects': personalEffects,
//         'paymentStatus': 'pending',
//         'status': 'confirmed',
//         'createdAt': FieldValue.serverTimestamp(),
//         'events': [
//           {
//             'type': 'booking',
//             'step': 'placed',
//             'done': true,
//             'ts': FieldValue.serverTimestamp(),
//             'by': userId
//           }
//         ],
//         'checkinSummary': {},
//         'checkoutSummary': {},
//       });

//       // UPDATE ROOM bookedRanges
//       bookedRanges.add({
//         'start': Timestamp.fromDate(start),
//         'end': Timestamp.fromDate(end),
//       });

//       tx.update(roomRef, {'bookedRanges': bookedRanges});
//     });
//     // prompt a success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Booking successful!'),
//         backgroundColor: Colors.green,
//       ),
//     );

//     // SEND NOTIFICATION
//     await createNotification(
//       title: "New Room Booking",
//       message: "A user booked room $roomId",
//       type: "book",
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:aurion_hotel/_components/color.dart';
// import 'package:aurion_hotel/_logik/notification_services.dart';

// class BookingsPage extends StatefulWidget {
//   final String userId;
//   final bool isMobile;
//   const BookingsPage({required this.userId, Key? key, required this.isMobile})
//       : super(key: key);
//   @override
//   _BookingsPageState createState() => _BookingsPageState();
// }

// class _BookingsPageState extends State<BookingsPage> {
//   String? selectedRoomId;
//   List<Map<String, dynamic>> selectedRoomBookedRanges = [];

//   // --- FILTER STATE ---
//   String searchQuery = '';
//   String? roomTypeFilter; // 'Economy' | 'Standard' | 'Luxury'
//   String priceSort = 'none'; // 'asc' | 'desc' | 'none'
//   bool showAvailableOnly = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.bottomRight,
//             end: Alignment.topLeft,
//             colors: [
//               Color(0xFFF8F9FA),
//               Color.fromARGB(255, 255, 255, 255),
//               Color.fromARGB(255, 255, 255, 255),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildHeader(),

//               // --- Filters Row ---
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Row(
//                   children: [
//                     // Search Field
//                     Expanded(
//                       child: TextField(
//                         decoration: InputDecoration(
//                           hintText: "Enter a room name..",
//                           hintStyle: TextStyle(
//                             color: Colors.grey[600],
//                             fontStyle: FontStyle.italic,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           filled: true,
//                           fillColor: Colors.grey[200],
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 16, horizontal: 20),
//                           prefixIcon:
//                               const Icon(Icons.search, color: Colors.grey),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(
//                                 color: mainColor.withOpacity(0.3), width: 1.5),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(color: auxColor, width: 2.5),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                         onChanged: (v) => setState(() => searchQuery = v),
//                       ),
//                     ),
//                     const SizedBox(width: 8),

//                     // Room Type Filter
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: roomTypeFilter,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.grey[200],
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 16, horizontal: 16),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(
//                                 color: mainColor.withOpacity(0.3), width: 1.5),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(color: auxColor, width: 2.5),
//                           ),
//                         ),
//                         hint: const Text(
//                           'Room Type',
//                           style: TextStyle(
//                               color: Colors.grey, fontWeight: FontWeight.w500),
//                         ),
//                         icon: const Icon(Icons.arrow_drop_down,
//                             color: Colors.grey),
//                         items: ['Economy', 'Standard', 'Luxury']
//                             .map((type) => DropdownMenuItem(
//                                   value: type,
//                                   child: Text(type),
//                                 ))
//                             .toList(),
//                         onChanged: (v) => setState(() => roomTypeFilter = v),
//                         style:
//                             const TextStyle(color: Colors.black, fontSize: 16),
//                         dropdownColor: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(width: 8),

//                     // Price Sort
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: priceSort,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.grey[200],
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 16, horizontal: 16),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(
//                                 color: mainColor.withOpacity(0.3), width: 1.5),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(color: auxColor, width: 2.5),
//                           ),
//                         ),
//                         hint: const Text(
//                           'Price',
//                           style: TextStyle(
//                               color: Colors.grey, fontWeight: FontWeight.w500),
//                         ),
//                         icon: const Icon(Icons.arrow_drop_down,
//                             color: Colors.grey),
//                         items: const [
//                           DropdownMenuItem(value: 'none', child: Text('None')),
//                           DropdownMenuItem(
//                               value: 'asc', child: Text('Low → High')),
//                           DropdownMenuItem(
//                               value: 'desc', child: Text('High → Low')),
//                         ],
//                         onChanged: (v) => setState(() => priceSort = v!),
//                         style:
//                             const TextStyle(color: Colors.black, fontSize: 16),
//                         dropdownColor: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(width: 8),

//                     // Availability Toggle
//                     Flexible(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           const Text(
//                             "Available Only",
//                             style: TextStyle(color: mainColor),
//                           ),
//                           Switch(
//                             value: showAvailableOnly,
//                             onChanged: (v) =>
//                                 setState(() => showAvailableOnly = v),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Spacer(),

//               // Bottom booking bar
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 color: Colors.transparent,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         decoration: InputDecoration(
//                           hintText: "Enter a room name..",
//                           hintStyle: TextStyle(
//                             color: Colors.grey[600],
//                             fontStyle: FontStyle.italic,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           filled: true,
//                           fillColor: Colors.grey[200],
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 16, horizontal: 20),
//                           prefixIcon:
//                               const Icon(Icons.search, color: Colors.grey),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(
//                                 color: mainColor.withOpacity(0.3), width: 1.5),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(color: auxColor, width: 2.5),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                         onChanged: (v) => setState(() {/* store duration */}),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     ElevatedButton(

//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: auxColor,
//                         foregroundColor: auxColor,
                        
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 16, horizontal: 24),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         elevation: 6,
//                         shadowColor: auxColor.withOpacity(0.5),
//                         textStyle: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       onPressed: selectedRoomId == null
//                           ? null
//                           : () => _openBookingDialog(
//                               selectedRoomId!, selectedRoomBookedRanges),
//                       child: Text(
//                         'Book Now',
//                         style: TextStyle(color: mainColor),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _openBookingDialog(
//       String roomId, List<Map<String, dynamic>> bookedRanges) {
//     DateTime? startDate;
//     DateTime? endDate;
//     final effectsController = TextEditingController();
//     List<String> personalEffects = [];

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(builder: (context, setState) {
//           return AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             backgroundColor: auxColor3,
//             title: const Text("Book Room",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // PERSONAL EFFECTS INPUT
//                   TextField(
//                     controller: effectsController,
//                     decoration: InputDecoration(
//                       hintText: "Add a personal effect",
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.add),
//                         onPressed: () {
//                           if (effectsController.text.trim().isNotEmpty) {
//                             setState(() {
//                               personalEffects
//                                   .add(effectsController.text.trim());
//                               effectsController.clear();
//                             });
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 6,
//                     children: personalEffects.map((e) {
//                       return Chip(
//                         label: Text(e),
//                         onDeleted: () {
//                           setState(() => personalEffects.remove(e));
//                         },
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 20),
//                   // START DATE PICKER
//                   ElevatedButton(
//                     onPressed: () async {
//                       final picked = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime.now(),
//                         lastDate: DateTime.now().add(const Duration(days: 365)),
//                         selectableDayPredicate: (day) {
//                           return _isDayAvailable(day, bookedRanges);
//                         },
//                       );
//                       if (picked != null) {
//                         setState(() => startDate = picked);
//                       }
//                     },
//                     child: Text(startDate == null
//                         ? "Select Start Date"
//                         : "Start: ${startDate!.toString().split(' ')[0]}"),
//                   ),
//                   const SizedBox(height: 12),
//                   // END DATE PICKER
//                   ElevatedButton(
//                     onPressed: startDate == null
//                         ? null
//                         : () async {
//                             final picked = await showDatePicker(
//                               context: context,
//                               initialDate:
//                                   startDate!.add(const Duration(days: 1)),
//                               firstDate: startDate!,
//                               lastDate:
//                                   DateTime.now().add(const Duration(days: 365)),
//                               selectableDayPredicate: (day) {
//                                 if (day.isBefore(startDate!)) return false;
//                                 return _isDayAvailable(day, bookedRanges);
//                               },
//                             );
//                             if (picked != null) {
//                               setState(() => endDate = picked);
//                             }
//                           },
//                     child: Text(endDate == null
//                         ? "Select End Date"
//                         : "End: ${endDate!.toString().split(' ')[0]}"),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("Cancel"),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: auxColor),
//                 onPressed: (startDate == null || endDate == null)
//                     ? null
//                     : () async {
//                         Navigator.pop(context);
//                         await createBooking(
//                           userId: widget.userId,
//                           roomId: roomId,
//                           start: startDate!,
//                           end: endDate!,
//                           personalEffects: personalEffects,
//                         );
//                       },
//                 child: const Text("Confirm Booking"),
//               )
//             ],
//           );
//         });
//       },
//     );
//   }

//   bool _isDayAvailable(DateTime day, List<Map<String, dynamic>> bookedRanges) {
//     for (final r in bookedRanges) {
//       final start = (r['start'] as Timestamp).toDate();
//       final end = (r['end'] as Timestamp).toDate();
//       if (!day.isBefore(start) && !day.isAfter(end)) {
//         return false;
//       }
//     }
//     return true;
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Text('Book a Room',
//               style: TextStyle(
//                   fontSize: 28, fontWeight: FontWeight.bold, color: mainColor)),
//           const Spacer(),
//         ],
//       ),
//     );
//   }

//   void _onSelectRoom(String roomId) {
//     setState(() {
//       selectedRoomId = selectedRoomId == roomId ? null : roomId;
//     });
//   }

//   Future<void> createBooking({
//     required String userId,
//     required String roomId,
//     required DateTime start,
//     required DateTime end,
//     required List<String> personalEffects,
//   }) async {
//     final firestore = FirebaseFirestore.instance;
//     final roomRef = firestore.collection('rooms').doc(roomId);

//     await firestore.runTransaction((tx) async {
//       final snap = await tx.get(roomRef);
//       final data = snap.data()!;
//       final bookedRanges =
//           List<Map<String, dynamic>>.from(data['bookedRanges'] ?? []);

//       // OVERLAP CHECK
//       for (final r in bookedRanges) {
//         final s = (r['start'] as Timestamp).toDate();
//         final e = (r['end'] as Timestamp).toDate();
//         if (start.isBefore(e) && s.isBefore(end)) {
//           throw Exception("Selected date range is unavailable.");
//         }
//       }

//       // CREATE BOOKING DOCUMENT
//       final bookingRef = firestore.collection('bookings').doc();
//       tx.set(bookingRef, {
//         'bookId': bookingRef.id,
//         'userId': userId,
//         'roomBooked': roomId,
//         'startDate': Timestamp.fromDate(start),
//         'endDate': Timestamp.fromDate(end),
//         'personalEffects': personalEffects,
//         'paymentStatus': 'pending',
//         'status': 'confirmed',
//         'createdAt': FieldValue.serverTimestamp(),
//         'events': [
//           {
//             'type': 'booking',
//             'step': 'placed',
//             'done': true,
//             'ts': FieldValue.serverTimestamp(),
//             'by': userId
//           }
//         ],
//         'checkinSummary': {},
//         'checkoutSummary': {},
//       });

//       // UPDATE ROOM bookedRanges
//       bookedRanges.add({
//         'start': Timestamp.fromDate(start),
//         'end': Timestamp.fromDate(end),
//       });

//       tx.update(roomRef, {'bookedRanges': bookedRanges});
//     });

//     // SEND NOTIFICATION
//     await createNotification(
//       title: "New Room Booking",
//       message: "A user booked room $roomId",
//       type: "book",
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:aurion_hotel/_components/color.dart';
// import 'package:aurion_hotel/_logik/notification_services.dart';

// class BookingsPage extends StatefulWidget {
//   final String userId;
//   final bool isMobile;
//   const BookingsPage({required this.userId, Key? key, required this.isMobile})
//       : super(key: key);
//   @override
//   _BookingsPageState createState() => _BookingsPageState();
// }

// class _BookingsPageState extends State<BookingsPage> {
//   String? selectedRoomId;
//   List selectedRoomBookedRanges = [];

//   // --- FILTER STATE ---
//   String searchQuery = '';
//   String? roomTypeFilter; // 'Economy' | 'Standard' | 'Luxury'
//   String priceSort = 'none'; // 'asc' | 'desc' | 'none'
//   bool showAvailableOnly = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           // subtle gradient background
//           gradient: LinearGradient(
//             begin: Alignment.bottomRight,
//             end: Alignment.topLeft,
//             colors: [
//               Color(0xFFF8F9FA),
//               Color.fromARGB(255, 255, 255, 255),
//               Color.fromARGB(255, 255, 255, 255)
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildHeader(),
//               // --- Filters Row ---
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Row(
//                   children: [
//                     // Search Field
//                     Expanded(
//                       child: TextField(
//                         decoration: InputDecoration(
//                           hintText: "Enter a room name..",
//                           hintStyle: TextStyle(
//                             color: Colors.grey[600],
//                             fontStyle: FontStyle.italic,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           filled: true,
//                           fillColor: Colors
//                               .grey[200], // subtle contrast on white background
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 16, horizontal: 20),
//                           prefixIcon:
//                               const Icon(Icons.search, color: Colors.grey),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(
//                                 color: mainColor.withOpacity(0.3), width: 1.5),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(color: auxColor, width: 2.5),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide.none,
//                           ),
//                           // optional: subtle shadow effect
//                           // floatingLabelBehavior: FloatingLabelBehavior.auto,
//                         ),
//                         onChanged: (v) => setState(() => searchQuery = v),
//                       ),
//                     ),
//                     const SizedBox(width: 8),

//                     // Room Type Filter
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: roomTypeFilter,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.grey[200],
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 16, horizontal: 16),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(
//                                 color: mainColor.withOpacity(0.3), width: 1.5),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(color: auxColor, width: 2.5),
//                           ),
//                         ),
//                         hint: const Text(
//                           'Room Type',
//                           style: TextStyle(
//                               color: Colors.grey, fontWeight: FontWeight.w500),
//                         ),
//                         icon: const Icon(Icons.arrow_drop_down,
//                             color: Colors.grey),
//                         items: ['Economy', 'Standard', 'Luxury']
//                             .map((type) => DropdownMenuItem(
//                                   value: type,
//                                   child: Text(type),
//                                 ))
//                             .toList(),
//                         onChanged: (v) => setState(() => roomTypeFilter = v),
//                         style:
//                             const TextStyle(color: Colors.black, fontSize: 16),
//                         dropdownColor: Colors.white,
//                       ),
//                     ),

//                     const SizedBox(width: 8),

//                     // Price Sort
//                     DropdownButtonFormField<String>(
//                       value: priceSort,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors
//                             .grey[200], // subtle contrast on white background
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 16, horizontal: 16),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           borderSide: BorderSide(
//                               color: mainColor.withOpacity(0.3), width: 1.5),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           borderSide: BorderSide(color: auxColor, width: 2.5),
//                         ),
//                       ),
//                       hint: const Text(
//                         'Price',
//                         style: TextStyle(
//                             color: Colors.grey, fontWeight: FontWeight.w500),
//                       ),
//                       icon:
//                           const Icon(Icons.arrow_drop_down, color: Colors.grey),
//                       items: const [
//                         DropdownMenuItem(value: 'none', child: Text('None')),
//                         DropdownMenuItem(
//                             value: 'asc', child: Text('Low → High')),
//                         DropdownMenuItem(
//                             value: 'desc', child: Text('High → Low')),
//                       ],
//                       onChanged: (v) => setState(() => priceSort = v!),
//                       style: const TextStyle(color: Colors.black, fontSize: 16),
//                       dropdownColor: Colors.white, // dropdown list background
//                     ),
//                     const SizedBox(width: 8),

//                     // Availability Toggle
//                     Row(
//                       children: [
//                         const Text("Available Only"),
//                         Switch(
//                           value: showAvailableOnly,
//                           onChanged: (v) =>
//                               setState(() => showAvailableOnly = v),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Bottom booking bar
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 color: Colors.transparent,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         decoration: InputDecoration(
//                           hintText: "Enter a room name..",
//                           hintStyle: TextStyle(
//                             color: Colors.grey[600],
//                             fontStyle: FontStyle.italic,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           filled: true,
//                           fillColor: Colors
//                               .grey[200], // subtle contrast on white background
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 16, horizontal: 20),
//                           prefixIcon:
//                               const Icon(Icons.search, color: Colors.grey),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(
//                                 color: mainColor.withOpacity(0.3), width: 1.5),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(color: auxColor, width: 2.5),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide.none,
//                           ),
//                           // optional: subtle shadow effect
//                           // floatingLabelBehavior: FloatingLabelBehavior.auto,
//                         ),
//                         onChanged: (v) => setState(() {/* store duration */}),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: auxColor,
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 16, horizontal: 24),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                               16), // smoother, modern corners
//                         ),
//                         elevation: 6, // subtle shadow for depth
//                         shadowColor: auxColor.withOpacity(0.5),
//                         textStyle: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       onPressed: selectedRoomId == null
//                           ? null
//                           : () => _openBookingDialog(
//                               selectedRoomId!, selectedRoomBookedRanges),
//                       child: const Text(
//                         'Book Now',
//                         style: TextStyle(color: mainColor),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _openBookingDialog(String roomId, List bookedRanges) {
//     DateTime? startDate;
//     DateTime? endDate;
//     final effectsController = TextEditingController();
//     List<String> personalEffects = [];

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16)),
//               backgroundColor: auxColor3,
//               title: const Text("Book Room",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // PERSONAL EFFECTS INPUT
//                   TextField(
//                     controller: effectsController,
//                     decoration: InputDecoration(
//                       hintText: "Add a personal effect",
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.add),
//                         onPressed: () {
//                           if (effectsController.text.trim().isNotEmpty) {
//                             setState(() {
//                               personalEffects
//                                   .add(effectsController.text.trim());
//                               effectsController.clear();
//                             });
//                           }
//                         },
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   Wrap(
//                     spacing: 6,
//                     children: personalEffects.map((e) {
//                       return Chip(
//                         label: Text(e),
//                         onDeleted: () {
//                           setState(() => personalEffects.remove(e));
//                         },
//                       );
//                     }).toList(),
//                   ),

//                   const SizedBox(height: 20),

//                   // START DATE PICKER
//                   ElevatedButton(
//                     onPressed: () async {
//                       final picked = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime.now(),
//                         lastDate: DateTime.now().add(const Duration(days: 365)),
//                         selectableDayPredicate: (day) {
//                           return _isDayAvailable(day, bookedRanges);
//                         },
//                       );
//                       if (picked != null) {
//                         setState(() => startDate = picked);
//                       }
//                     },
//                     child: Text(startDate == null
//                         ? "Select Start Date"
//                         : "Start: ${startDate!.toString().split(' ')[0]}"),
//                   ),

//                   const SizedBox(height: 12),

//                   // END DATE PICKER
//                   ElevatedButton(
//                     onPressed: startDate == null
//                         ? null
//                         : () async {
//                             final picked = await showDatePicker(
//                               context: context,
//                               initialDate:
//                                   startDate!.add(const Duration(days: 1)),
//                               firstDate: startDate!,
//                               lastDate:
//                                   DateTime.now().add(const Duration(days: 365)),
//                               selectableDayPredicate: (day) {
//                                 if (day.isBefore(startDate!)) return false;
//                                 return _isDayAvailable(day, bookedRanges);
//                               },
//                             );
//                             if (picked != null) {
//                               setState(() => endDate = picked);
//                             }
//                           },
//                     child: Text(endDate == null
//                         ? "Select End Date"
//                         : "End: ${endDate!.toString().split(' ')[0]}"),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Cancel"),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(backgroundColor: auxColor),
//                   onPressed: (startDate == null || endDate == null)
//                       ? null
//                       : () async {
//                           Navigator.pop(context);
//                           await createBooking(
//                             userId: widget.userId,
//                             roomId: roomId,
//                             start: startDate!,
//                             end: endDate!,
//                             personalEffects: personalEffects,
//                           );
//                         },
//                   child: const Text("Confirm Booking"),
//                 )
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   bool _isDayAvailable(DateTime day, List bookedRanges) {
//     for (final r in bookedRanges) {
//       final start = (r['start'] as Timestamp).toDate();
//       final end = (r['end'] as Timestamp).toDate();

//       if (!day.isBefore(start) && !day.isAfter(end)) {
//         return false; // day blocked
//       }
//     }
//     return true; // day free
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Text('Rooms',
//               style: TextStyle(
//                   fontSize: 28, fontWeight: FontWeight.bold, color: mainColor)),
//           const Spacer(),
//         ],
//       ),
//     );
//   }

//   void _onSelectRoom(String roomId) {
//     setState(() {
//       selectedRoomId = selectedRoomId == roomId ? null : roomId;
//     });
//   }

//   Future<void> createBooking({
//     required String userId,
//     required String roomId,
//     required DateTime start,
//     required DateTime end,
//     required List<String> personalEffects,
//   }) async {
//     final firestore = FirebaseFirestore.instance;
//     final roomRef = firestore.collection('rooms').doc(roomId);

//     await firestore.runTransaction((tx) async {
//       final snap = await tx.get(roomRef);
//       final data = snap.data()!;
//       final bookedRanges = List.from(data['bookedRanges'] ?? []);

//       // OVERLAP CHECK
//       for (final r in bookedRanges) {
//         final s = (r['start'] as Timestamp).toDate();
//         final e = (r['end'] as Timestamp).toDate();
//         if (start.isBefore(e) && s.isBefore(end)) {
//           throw Exception("Selected date range is unavailable.");
//         }
//       }

//       // CREATE BOOKING DOCUMENT
//       final bookingRef = firestore.collection('bookings').doc();
//       tx.set(bookingRef, {
//         'bookId': bookingRef.id,
//         'userId': userId,
//         'roomBooked': roomId,
//         'startDate': Timestamp.fromDate(start),
//         'endDate': Timestamp.fromDate(end),
//         'personalEffects': personalEffects,
//         'paymentStatus': 'pending',
//         'status': 'confirmed',
//         'createdAt': FieldValue.serverTimestamp(),
//         'events': [
//           {
//             'type': 'booking',
//             'step': 'placed',
//             'done': true,
//             'ts': FieldValue.serverTimestamp(),
//             'by': userId
//           }
//         ],
//         'checkinSummary': {},
//         'checkoutSummary': {},
//       });

//       // UPDATE ROOM bookedRanges
//       bookedRanges.add({
//         'start': Timestamp.fromDate(start),
//         'end': Timestamp.fromDate(end),
//       });

//       tx.update(roomRef, {'bookedRanges': bookedRanges});
//     });

//     // SEND NOTIFICATION
//     await createNotification(
//       title: "New Room Booking",
//       message: "A user booked room $roomId",
//       type: "book",
//     );
//   }
// }


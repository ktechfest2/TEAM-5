import 'package:flutter/material.dart';
import 'package:aurion_hotel/_components/color.dart';

class HotelHomePage extends StatelessWidget {
  final bool isMobile;
  final String secretPin;

  const HotelHomePage({
    super.key,
    required this.isMobile,
    required this.secretPin,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : (isTablet ? 24 : 32), vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(),
            const SizedBox(height: 28),
            _buildSecretPinCard(),
            const SizedBox(height: 28),
            _buildRoomBookingCard(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [mainColor, auxColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: mainColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome Back!",
              style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: auxColor)),
          const SizedBox(height: 8),
          Text("Your luxury experience awaits.",
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: auxColor3.withOpacity(0.9),
              )),
        ],
      ),
    );
  }

  Widget _buildSecretPinCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: auxColor, width: 2),
        boxShadow: [
          BoxShadow(
              color: auxColor.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: auxColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.lock_open,
                color: auxColor, size: isMobile ? 24 : 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Secret Access PIN",
                    style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: mainColor.withOpacity(0.6))),
                const SizedBox(height: 4),
                Text(secretPin,
                    style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: auxColor,
                        letterSpacing: 2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomBookingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ]),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.bed, color: auxColor, size: 28),
            const SizedBox(width: 12),
            Text("Room Details",
                style: TextStyle(
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: mainColor))
          ]),
          const SizedBox(height: 16),
          _buildBookingField("Check-in", "Dec 20, 2024", Icons.calendar_today),
          const SizedBox(height: 12),
          _buildBookingField("Check-out", "Dec 25, 2024", Icons.calendar_today),
          const SizedBox(height: 12),
          _buildBookingField(
              "Room Type", "Deluxe Suite", Icons.door_front_door),
        ],
      ),
    );
  }

  Widget _buildBookingField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: auxColor3,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: mainColor.withOpacity(0.2))),
      child: Row(
        children: [
          Icon(icon, color: auxColor, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: mainColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: mainColor)),
            ],
          ),
        ],
      ),
    );
  }
}

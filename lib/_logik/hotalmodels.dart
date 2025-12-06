class Room {
  final String id;
  final String title;
  final String roomType;
  final double pricePerDay;
  final bool occupied;
  final List<String> features;
  final String? photoUrl;
  Room(
      {required this.id,
      required this.title,
      required this.roomType,
      required this.pricePerDay,
      required this.occupied,
      required this.features,
      this.photoUrl});
}

class Booking {
  final String id;
  final String userId;
  final String roomBooked;
  final String duration;
  final List<String> personalEffect;
  final String paymentStatus;
  final String status;
  Booking(
      {required this.id,
      required this.userId,
      required this.roomBooked,
      required this.duration,
      required this.personalEffect,
      this.paymentStatus = 'pending',
      this.status = 'pending'});
}

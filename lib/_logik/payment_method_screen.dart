// import 'package:farmket/main_codes/_buyers/_buyers_logik/debit_card_screen.dart';
// import 'package:flutter/material.dart';

// class PaymentMethodScreen extends StatefulWidget {
//   const PaymentMethodScreen({super.key});

//   @override
//   State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
// }

// class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
//   int? selectedIndex;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Payment Method",
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//         leading: IconButton(
//           icon:
//               const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: Column(
//         children: [
//           // Divider below AppBar
//           Divider(height: 2, color: Colors.grey.shade300, thickness: 2),

//           const SizedBox(height: 20),

//           // Section Title
//           Container(
//             alignment: Alignment.centerLeft,
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: const Text(
//               "Choose your payment method",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Payment Options
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               children: [
//                 PaymentOptionCard(
//                   icon: Icons.credit_card,
//                   title: "Credit / Debit Card",
//                   color: Colors.blue,
//                   isSelected: selectedIndex == 0,
//                   onTap: () {
//                     setState(() => selectedIndex = 0);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const DebitCardScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 PaymentOptionCard(
//                   icon: Icons.account_balance_wallet,
//                   title: "PayPal",
//                   color: Colors.indigo,
//                   isSelected: selectedIndex == 1,
//                   onTap: () {
//                     setState(() => selectedIndex = 1);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const PayPalScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 PaymentOptionCard(
//                   icon: Icons.account_balance,
//                   title: "Bank Transfer",
//                   color: Colors.purple,
//                   isSelected: selectedIndex == 2,
//                   onTap: () {},
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class PaymentOptionCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final Color color;
//   final VoidCallback onTap;
//   final bool isSelected;

//   const PaymentOptionCard({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.color,
//     required this.onTap,
//     required this.isSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(16),
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isSelected ? Colors.green : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(16),
//           color: Colors.white,
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: color, size: 28),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             Icon(Icons.arrow_forward_ios_rounded,
//                 size: 18, color: isSelected ? Colors.green : Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }
// }

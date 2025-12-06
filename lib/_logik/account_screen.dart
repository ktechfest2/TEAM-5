import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final _formKey = GlobalKey<FormState>();

  // Editable fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String? profilePicUrl;

  Future<void> loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        bioController.text = data['bio'] ?? '';
        addressController.text = data['state'] ?? '';
        profilePicUrl = data['picture'];
      });
    }
  }

  Future<void> updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Changes"),
          content: const Text("Are you sure you want to save these changes?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text("Yes, Save"),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'bio': bioController.text.trim(),
          'state': addressController.text.trim(),
          'picture': profilePicUrl ?? '',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      }
    }
  }

  final List<String> _states = [
    "FCT - Abuja",
    "Abia",
    "Adamawa",
    "Akwa Ibom",
    "Anambra",
    "Bauchi",
    "Bayelsa",
    "Benue",
    "Borno",
    "Cross River",
    "Delta",
    "Ebonyi",
    "Edo",
    "Ekiti",
    "Enugu",
    "Gombe",
    "Imo",
    "Jigawa",
    "Kaduna",
    "Kano",
    "Katsina",
    "Kebbi",
    "Kogi",
    "Kwara",
    "Lagos",
    "Nasarawa",
    "Niger",
    "Ogun",
    "Ondo",
    "Osun",
    "Oyo",
    "Plateau",
    "Rivers",
    "Sokoto",
    "Taraba",
    "Yobe",
    "Zamfara",
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          profilePicUrl != null && profilePicUrl!.isNotEmpty
                              ? NetworkImage(profilePicUrl!)
                              : const AssetImage("assets/default_avatar.png")
                                  as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          // TODO: implement image picker & upload to Firebase Storage
                        },
                        child: CircleAvatar(
                          backgroundColor:
                              isDark ? Colors.tealAccent : Colors.teal,
                          radius: 18,
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: "Full Name", prefixIcon: Icon(Icons.person)),
                validator: (val) => val!.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: "Email", prefixIcon: Icon(Icons.email)),
                validator: (val) => val!.isEmpty ? "Enter your email" : null,
              ),
              const SizedBox(height: 12),

              // Bio
              TextFormField(
                controller: bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: "Bio", prefixIcon: Icon(Icons.info_outline)),
              ),
              const SizedBox(height: 12),

// address
              DropdownButtonFormField<String>(
                value: addressController.text.isNotEmpty
                    ? addressController.text
                    : null,
                items: _states.map((state) {
                  return DropdownMenuItem(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    addressController.text = val!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Address (State)",
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? "Please select your state"
                    : null,
              ),

              const SizedBox(height: 20),

              // Save Button
              ElevatedButton.icon(
                onPressed: updateProfile,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
              ),

              const SizedBox(height: 30),

              // Non-editable info
// Inside your build (replace the old Column of Texts)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "Account Details",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Role
                      _infoCard(Icons.badge, "Role", data['role']),
                      _infoCard(Icons.flag, "Country", data['country']),
                      _infoCard(
                          Icons.calendar_today,
                          "Registered",
                          data['registeredAt']
                              .toDate()
                              .toString()
                              .split(" ")
                              .first),
                      _infoCard(Icons.shopping_bag, "Total Orders",
                          "${data['totalorders']}"),
                      _infoCard(Icons.attach_money, "Total Sales",
                          "₦${data['totalsales']}"),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.teal.withOpacity(0.15),
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

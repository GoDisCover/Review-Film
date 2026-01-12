import 'package:flutter/material.dart';
import 'package:review_film/sqlite/database_helper.dart';
import 'package:review_film/sqlite/json/users.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String userEmail;

  const ProfilePage({super.key, required this.userEmail});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
final db = DatabaseHelper();
  
  // State variables
  Users? _currentUser; // Holds the full user object
  String _name = "";
  String _email = "";
  String _password = ""; // We need this to re-save the user object
  int _reviews = 0; // Placeholder until you have a Review table
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- 1. FETCH DATA FROM SQLITE ---
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    // Fetch user details using the email passed from the previous page
    Users? user = await db.getUserDetail(widget.userEmail);

    if (mounted) {
      setState(() {
        if (user != null) {
          _currentUser = user;
          _name = user.name ?? "No Name";
          _email = user.email!;
          _password = user.password!;
        }
        _isLoading = false;
      });
    }
  }

  // --- 2. UPDATE DATA IN SQLITE ---
  Future<void> _editProfile() async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameCtrl = TextEditingController(text: _name);
    
    // Note: We usually don't allow editing Email easily as it's the unique ID.
    // For this example, we will make Email read-only.
    final TextEditingController emailCtrl = TextEditingController(text: _email);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email (Read-only)'),
                readOnly: true, // Prevent changing email for safety
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // 1. Create updated user object
                Users updatedUser = Users(
                  id: _currentUser?.id, // Keep the same ID
                  name: nameCtrl.text.trim(),
                  email: _email, // Keep original email
                  password: _password, // Keep original password
                );

                // 2. Call Database Update
                await db.updateUser(updatedUser);

                // 3. Update Local State
                setState(() {
                  _name = nameCtrl.text.trim();
                });
                
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully in Database')),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    List<String> parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6D2C4),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          decoration: BoxDecoration(
            color: const Color(0xFF4F4A3F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.grey[300],
                child: Text(
                  _name.isNotEmpty
                      ? _name.split(' ').map((s) => s[0]).take(2).join()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _name,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(_email, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C776A),
                  ),
                  onPressed: _editProfile,
                  child: const Text('Edit Profile'),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: _confirmLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:review_film/model/film_model.dart';
import 'package:review_film/sqlite/database_helper.dart';

class DetailScreen extends StatefulWidget {
  final Film film;
  final String userEmail;

  const DetailScreen({
    super.key,
    required this.film,
    required this.userEmail,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  double _userRating = 0.0;
  double _globalRating = 0.0;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      double uRating = await _dbHelper.getSpecificUserRating(widget.userEmail, widget.film.namaFilm);
      double gRating = await _dbHelper.getGlobalRating(widget.film.namaFilm);

      if (mounted) {
        setState(() {
          _userRating = uRating;
          _globalRating = gRating;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  Future<void> _saveRating(double newRating) async {
    try {
      // Simpan ke database
      await _dbHelper.updateUserRating(widget.userEmail, widget.film.namaFilm, newRating);
      // Refresh tampilan
      await _loadAllData();

      // Tampilkan notifikasi sukses (Opsional)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating saved successfully!')),
        );
      }
    } catch (e) {
      // Tampilkan jika ada error (misal masalah database)
      print("Error saving rating: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  void _showEditRatingDialog() {
    final TextEditingController ratingController = TextEditingController(
      text: _userRating > 0 ? _userRating.toString() : "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFE3E0D4),
          title: const Text("Edit Rating", style: TextStyle(color: Color(0xFF5B584E))),
          content: TextField(
            controller: ratingController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: "Enter rating (0.0 - 5.0)", // UBAH HINT TEXT
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B584E)),
              onPressed: () {
                final double? value = double.tryParse(ratingController.text);
                // UBAH VALIDASI: Maksimal 5.0
                if (value != null && value >= 0 && value <= 5.0) {
                  _saveRating(value);
                  Navigator.pop(context);
                } else {
                  // Beri peringatan jika input salah
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a number between 0 and 5')),
                  );
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFE3E0D4);
    const Color darkColor = Color(0xFF5B584E);
    const Color ratingBoxColor = Color(0xFF4C4940);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: darkColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.film.namaFilm,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- INFO ATAS ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 140,
                      height: 210,
                      color: Colors.grey,
                      child: Image.network(
                        widget.film.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 50, color: Colors.white70);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRatingBox(
                            "Global Rating...",
                            _globalRating.toStringAsFixed(1),
                            darkColor,
                            ratingBoxColor
                        ),
                        const SizedBox(height: 16),
                        _buildRatingBox(
                          "Your Rating",
                          _userRating > 0 ? _userRating.toString() : "-",
                          darkColor,
                          ratingBoxColor,
                          showEdit: true,
                          onEditTap: _showEditRatingDialog,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- DETAIL BAWAH ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                decoration: const BoxDecoration(
                  color: darkColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Synopsis",
                        style: TextStyle(color: Color(0xFFE3E0D4), fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.film.description,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Information",
                        style: TextStyle(color: Color(0xFFE3E0D4), fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow("Genre:", widget.film.genre.join(", ")),
                      _buildInfoRow("Duration:", "23 min."),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBox(
      String label, String rating, Color labelColor, Color boxColor,
      {bool showEdit = false, VoidCallback? onEditTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: labelColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Color(0xffF8F3CE), size: 28),
              const SizedBox(width: 10),
              Text(
                rating,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (showEdit)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: GestureDetector(
              onTap: onEditTap,
              child: Text(
                "Edit Rating",
                style: TextStyle(
                  color: labelColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: const TextStyle(color: Color(0xFFE3E0D4), fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
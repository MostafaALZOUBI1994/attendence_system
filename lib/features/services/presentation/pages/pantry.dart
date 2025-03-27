import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/constants.dart';

class PantryRequestScreen extends StatefulWidget {
  const PantryRequestScreen({super.key});

  @override
  State<PantryRequestScreen> createState() => _PantryRequestScreenState();
}

class _PantryRequestScreenState extends State<PantryRequestScreen> {
  final TextEditingController _specialRequestController = TextEditingController();
  String? _selectedDrink;

  final List<Map<String, dynamic>> _drinks = [
    {"name": "Arabic Coffee", "icon": Icons.local_cafe},
    {"name": "Turkish Coffee", "icon": Icons.coffee},
    {"name": "Karak Tea", "icon": Icons.emoji_food_beverage},
    {"name": "Green Tea", "icon": Icons.local_drink},
    {"name": "Espresso", "icon": Icons.coffee_maker},
    {"name": "Latte", "icon": Icons.emoji_food_beverage_outlined},
    {"name": "Cappuccino", "icon": Icons.coffee_outlined},
    {"name": "Black Tea", "icon": Icons.emoji_food_beverage_sharp},
  ];

  void _submitRequest() {
    if (_selectedDrink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a drink")),
      );
      return;
    }
    String specialRequest = _specialRequestController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Your request for $_selectedDrink has been sent!\nSpecial Request: ${specialRequest.isEmpty ? 'None' : specialRequest}"),
      ),
    );
    _specialRequestController.clear();
    setState(() => _selectedDrink = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: primaryColor
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Pantry Request",
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Choose your drink",
                        style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: _drinks.map((drink) => _buildDrinkOption(drink)).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Special Request",
                        style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _specialRequestController,
                        decoration: InputDecoration(
                          hintText: "E.g. Add more sugar, without milk...",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text("Submit Request", style: GoogleFonts.lato(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrinkOption(Map<String, dynamic> drink) {
    return GestureDetector(
      onTap: () => setState(() => _selectedDrink = drink["name"]),
      child: Chip(
        avatar: Icon(drink["icon"], color: _selectedDrink == drink["name"] ? Colors.white : Colors.black),
        label: Text(drink["name"], style: GoogleFonts.lato(fontSize: 14, color: _selectedDrink == drink["name"] ? Colors.white : Colors.black)),
        backgroundColor: _selectedDrink == drink["name"] ? primaryColor : Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

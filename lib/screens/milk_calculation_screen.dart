import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MilkCalculationScreen extends StatefulWidget {
  @override
  _MilkCalculationScreenState createState() => _MilkCalculationScreenState();
}

class _MilkCalculationScreenState extends State<MilkCalculationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _clrController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _amtController = TextEditingController();
  final TextEditingController _snfController = TextEditingController();

  String selectedTime = "";
  String selectedAnimal = "";
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  bool _isSaveButtonEnabled = false;
  String? selectedFarmerId;
  List<Map<String, String>> farmerList = [];

  @override
  void initState() {
    super.initState();
    _fetchFarmers();
  }

  Future<void> _fetchFarmers() async {
    await Firebase.initializeApp();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('farmers').get();

    List<Map<String, String>> farmers = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        'id': data['id']?.toString() ?? '', // Fetch farmer's actual ID from Firestore
        'name': data['name']?.toString() ?? '',
        'animalType': data.containsKey('animalType') ? data['animalType'].toString() : 'Cow', // Default to Cow if missing
      };
    }).toList();

    setState(() {
      farmerList = farmers;
    });

    print(farmerList); // Debugging: Check if correct data is fetched
  }





  void calculateValues() {
    double qty = double.tryParse(_qtyController.text) ?? 0;
    double fat = double.tryParse(_fatController.text) ?? 0;
    double clr = double.tryParse(_clrController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;

    double snf = (clr / 4 + (0.25 * fat) + 0.25);
    double amt = qty * rate;

    setState(() {
      _snfController.text = snf.toStringAsFixed(2);
      _amtController.text = amt.toStringAsFixed(2);
      _checkFormValidation();
    });
  }

  void _checkFormValidation() {
    setState(() {
      _isSaveButtonEnabled = selectedFarmerId != null &&
          _nameController.text.isNotEmpty &&
          _qtyController.text.isNotEmpty &&
          _fatController.text.isNotEmpty &&
          _clrController.text.isNotEmpty &&
          _rateController.text.isNotEmpty &&
          selectedTime.isNotEmpty &&
          selectedAnimal.isNotEmpty;
    });
  }

  void _resetFields() {
    setState(() {
      selectedFarmerId = null;
      _nameController.clear();
      _qtyController.clear();
      _fatController.clear();
      _clrController.clear();
      _rateController.clear();
      _amtController.clear();
      _snfController.clear();
      selectedTime = "";
      selectedAnimal = "";
      _isSaveButtonEnabled = false;
    });
  }

  void _saveData() async {
    if (!_isSaveButtonEnabled) return;

    await FirebaseFirestore.instance.collection('milkDetails').add({
      'id': selectedFarmerId,
      'name': _nameController.text,
      'time': selectedTime,
      'animal': selectedAnimal,
      'qty': double.tryParse(_qtyController.text) ?? 0,
      'fat': double.tryParse(_fatController.text) ?? 0,
      'clr': double.tryParse(_clrController.text) ?? 0,
      'rate': double.tryParse(_rateController.text) ?? 0,
      'snf': double.tryParse(_snfController.text) ?? 0,
      'amt': double.tryParse(_amtController.text) ?? 0,
      'date': currentDate,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data saved successfully!")),
    );

    _resetFields();
  }

  Widget _buildTitleText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
        ),
      ),
    );
  }


  Widget _buildInputField(TextEditingController controller, String label,
      {bool readOnly = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: TextInputType.text,
        onChanged: (value) {
          _checkFormValidation();
          if (onChanged != null) onChanged(value);
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green, width: 2)),
        ),
      ),
    );
  }


  Widget _buildToggleIconButton(IconData icon, String label, {required bool isTime}) {
    bool isSelected = isTime ? (selectedTime == label) : (selectedAnimal == label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isTime) {
            selectedTime = label;
          } else {
            selectedAnimal = label;
          }
          _checkFormValidation();
        });
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.green : Colors.transparent, // Highlight selected icon
                width: 3,
              ),
            ),
            padding: EdgeInsets.all(8), // Add some padding inside the border
            child: Icon(icon, size: 50, color: isSelected ? Colors.green : Colors.grey),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildButton(String text, IconData icon, Color color,
      {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Milk Collection', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleText('Date: $currentDate'),
              _buildDropdownField(),
              _buildInputField(_nameController, 'Name', readOnly: true),
              SizedBox(height: 15),
              _buildTitleText('Select Time'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToggleIconButton(
                      Icons.wb_sunny, "Morning", isTime: true),
                  _buildToggleIconButton(
                      Icons.nightlight_round, "Afternoon", isTime: true),
                ],
              ),
              SizedBox(height: 15),
              _buildTitleText('Select Cow/Buffalo'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToggleIconButton(Icons.pets, "Cow", isTime: false),
                  _buildToggleIconButton(
                      Icons.pets_sharp, "Buffalo", isTime: false),
                ],
              ),
              SizedBox(height: 15),
              _buildInputField(
                  _qtyController, 'QTY', onChanged: (_) => calculateValues()),
              _buildInputField(
                  _fatController, 'FAT', onChanged: (_) => calculateValues()),
              _buildInputField(
                  _clrController, 'CLR', onChanged: (_) => calculateValues()),
              _buildInputField(
                  _rateController, 'Rate', onChanged: (_) => calculateValues()),
              _buildInputField(_snfController, 'SNF', readOnly: true),
              _buildInputField(_amtController, 'Amount', readOnly: true),
              SizedBox(height: 20),
              _buildButton('Save Data', Icons.save, Colors.green[700]!,
                  onPressed: _saveData),
              SizedBox(height: 10),
              _buildButton('Reset', Icons.refresh, Colors.red[700]!,
                  onPressed: _resetFields),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.green[50],
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: selectedFarmerId,
        onChanged: (String? newValue) {
          setState(() {
            selectedFarmerId = newValue;
            Map<String, String> selectedFarmer = farmerList.firstWhere((farmer) => farmer['id'] == newValue);

            // Set the Name field
            _nameController.text = selectedFarmer['name']!;

            // Auto-select Cow/Buffalo based on animalType
            selectedAnimal = selectedFarmer['animalType'] ?? 'Cow';

            _checkFormValidation();
          });
        },
        items: farmerList.map((farmer) {
          return DropdownMenuItem<String>(
            value: farmer['id'],
            child: Text('${farmer['id']} - ${farmer['name']}'),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Select Farmer ID',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

}

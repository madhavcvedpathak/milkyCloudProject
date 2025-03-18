import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  @override
  _FarmerRegistrationScreenState createState() => _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  String _selectedAnimalType = ''; // Holds selected animal type (Cow/Buffalo)
  bool _isRegisterButtonEnabled = false;

  void _checkFormValidation() {
    setState(() {
      _isRegisterButtonEnabled =
          _idController.text.isNotEmpty &&
              _nameController.text.isNotEmpty &&
              _mobileController.text.isNotEmpty &&
              _selectedAnimalType.isNotEmpty;
    });
  }

  Future<void> _registerFarmer() async {
    String farmerId = _idController.text.trim();

    // Check if the ID already exists
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('farmers')
        .where('id', isEqualTo: farmerId)
        .get();

    if (query.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Farmer ID already exists!")),
      );
      return;
    }

    FirebaseFirestore.instance.collection('farmers').add({
      'id': farmerId,
      'name': _nameController.text,
      'mobile': _mobileController.text,
      'animalType': _selectedAnimalType,
    }).then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Farmer registered successfully!")));
      _resetFields();
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to register: $error')));
    });
  }

  void _resetFields() {
    setState(() {
      _idController.clear();
      _nameController.clear();
      _mobileController.clear();
      _selectedAnimalType = '';
      _isRegisterButtonEnabled = false;
    });
  }

  void _navigateToShowFarmersScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShowFarmersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farmer Registration', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(_idController, 'Farmer ID', keyboardType: TextInputType.number),
              _buildInputField(_nameController, 'Farmer Name'),
              _buildInputField(_mobileController, 'Mobile Number', keyboardType: TextInputType.phone),
              SizedBox(height: 10),
              _buildAnimalSelection(),
              SizedBox(height: 20),
              _buildButton('Register', Icons.person_add, Colors.green[700]!, onPressed: _isRegisterButtonEnabled ? _registerFarmer : null),
              SizedBox(height: 10),
              _buildButton('Reset', Icons.refresh, Colors.red[700]!, onPressed: _resetFields),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.green[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToShowFarmersScreen,
        icon: Icon(Icons.list),
        label: Text("Show Farmers"),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: label == "Mobile Number" ? 10 : null, // Limit to 10 digits for mobile number
        onChanged: (value) => _checkFormValidation(),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green, width: 2)),
          counterText: "", // Hides character counter below input field
        ),
      ),
    );
  }


  Widget _buildAnimalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Cow/Buffalo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAnimalButton("Cow", Icons.pets, Colors.brown),
            _buildAnimalButton("Buffalo", Icons.pets, Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimalButton(String type, IconData icon, Color color) {
    bool isSelected = _selectedAnimalType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnimalType = type;
        });
        _checkFormValidation();
      },
      child: Container(
        width: 120,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color),
            SizedBox(width: 8),
            Text(type, style: TextStyle(fontSize: 16, color: isSelected ? Colors.white : color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, Color color, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class ShowFarmersScreen extends StatelessWidget {
  void _navigateToEditFarmer(BuildContext context, DocumentSnapshot document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFarmerScreen(document: document),
      ),
    );
  }

  void _deleteFarmer(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remove Farmer"),
        content: Text("Are you sure you want to remove this farmer?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('farmers').doc(docId).delete();
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registered Farmers", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('farmers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No farmers registered yet."));
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String animalType = data.containsKey('animalType') ? data['animalType'] : 'Not Specified';

              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text("ID: ${data['id']}", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${data['name']}"),
                      Text("Mobile: ${data['mobile']}"),
                      Text("CM/BM: $animalType"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToEditFarmer(context, document),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFarmer(context, document.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class EditFarmerScreen extends StatefulWidget {
  final DocumentSnapshot document;
  EditFarmerScreen({required this.document});

  @override
  _EditFarmerScreenState createState() => _EditFarmerScreenState();
}

class _EditFarmerScreenState extends State<EditFarmerScreen> {
  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController mobileController;
  late String animalType;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController(text: widget.document['id']);
    nameController = TextEditingController(text: widget.document['name']);
    mobileController = TextEditingController(text: widget.document['mobile']);
    animalType = widget.document['animalType'] ?? 'Not Specified';
  }

  void _updateFarmer() {
    FirebaseFirestore.instance.collection('farmers').doc(widget.document.id).update({
      'id': idController.text,
      'name': nameController.text,
      'mobile': mobileController.text,
      'animalType': animalType,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Farmer updated successfully!")));
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed: $error")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Farmer", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green[700]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(idController, "Farmer ID", TextInputType.number),
            _buildTextField(nameController, "Farmer Name"),
            _buildTextField(mobileController, "Mobile Number", TextInputType.phone, 10),
            _buildAnimalSelection(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateFarmer,
              child: Text("Update", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType type = TextInputType.text, int? maxLength]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildAnimalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child:
        Text("Select CM/BM :", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAnimalButton("Cow", Icons.pets, Colors.brown),
            _buildAnimalButton("Buffalo", Icons.pets, Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimalButton(String type, IconData icon, Color color) {
    bool isSelected = animalType == type;
    return GestureDetector(
      onTap: () => setState(() => animalType = type),
      child: Container(
        width: 120,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(child: Text(type, style: TextStyle(fontSize: 16, color: isSelected ? Colors.white : color))),
      ),
    );
  }
}






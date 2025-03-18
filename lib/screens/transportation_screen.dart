import 'package:flutter/material.dart';
import 'package:milk_calculator/models/transportation.dart';

class TransportationScreen extends StatefulWidget {
  @override
  _TransportationScreenState createState() => _TransportationScreenState();
}

class _TransportationScreenState extends State<TransportationScreen> {
  final TextEditingController farmNameController = TextEditingController();
  final TextEditingController milkPriceController = TextEditingController();
  final TextEditingController litresPerDayController = TextEditingController();
  final TextEditingController tankerCapacityController = TextEditingController();
  final TextEditingController totalKMController = TextEditingController();
  final TextEditingController ratePerKMController = TextEditingController();
  final TextEditingController dailyAllowanceController = TextEditingController();
  final TextEditingController dailyWageController = TextEditingController();
  final TextEditingController testingCostController = TextEditingController();
  final TextEditingController otherCostController = TextEditingController();

  void calculate() {
    try {
      double milkPrice = double.parse(milkPriceController.text);
      double litresPerDay = double.parse(litresPerDayController.text);
      double tankerCapacity = double.parse(tankerCapacityController.text);
      double totalKM = double.parse(totalKMController.text);
      double ratePerKM = double.parse(ratePerKMController.text);
      double dailyAllowance = double.parse(dailyAllowanceController.text);
      double dailyWage = double.parse(dailyWageController.text);
      double testingCost = double.parse(testingCostController.text);
      double otherCost = double.parse(otherCostController.text);

      if (litresPerDay == 0 || totalKM == 0) {
        showErrorDialog("Litres per Day and Total KMs must be greater than 0.");
        return;
      }

      final transport = TransportationCost(
        farmName: farmNameController.text,
        milkPrice: milkPrice,
        litresPerDay: litresPerDay,
        tankerCapacity: tankerCapacity,
        totalKMs: totalKM,
        ratePerKM: ratePerKM,
        dailyAllowance: dailyAllowance,
        dailyWage: dailyWage,
        testingCost: testingCost,
        otherCost: otherCost,
      );

      showResultDialog(transport);
    } catch (e) {
      showErrorDialog("Invalid input. Please enter valid numbers.");
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Error", style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void showResultDialog(TransportationCost transport) {
    String result = "Overheads: ₹${transport.overheads.toStringAsFixed(2)} INR\n"
        "Landed Cost: ₹${transport.landedCost.toStringAsFixed(2)} INR\n"
        "Transportation Cost: ₹${transport.transportationCost.toStringAsFixed(2)} INR\n"
        "TPT/Litre Cost: ₹${transport.tptPerLitre.toStringAsFixed(2)} INR\n"
        "Total Cost: ₹${transport.totalCost.toStringAsFixed(2)} INR";

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        backgroundColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 20),
              Text(
                "Transportation Cost",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                result,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Close", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transport Cost Estimation", style: TextStyle(fontSize: 16, color: Colors.white)),
        backgroundColor: Colors.green.shade900,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(farmNameController, "Farm Name", TextInputType.text),
              _buildTextField(milkPriceController, "Milk Price (₹/L)", TextInputType.number),
              _buildTextField(litresPerDayController, "Litres per Day", TextInputType.number),
              _buildTextField(tankerCapacityController, "Tanker Capacity (L)", TextInputType.number),
              _buildTextField(totalKMController, "Total KMs", TextInputType.number),
              _buildTextField(ratePerKMController, "Rate per KM (₹/KM)", TextInputType.number),
              _buildTextField(dailyAllowanceController, "Daily Allowance (₹)", TextInputType.number),
              _buildTextField(dailyWageController, "Daily Wage (₹)", TextInputType.number),
              _buildTextField(testingCostController, "Testing Cost (₹)", TextInputType.number),
              _buildTextField(otherCostController, "Other Cost (₹)", TextInputType.number),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text("Calculate", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 16, color: Colors.green.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          filled: true,
          fillColor: Colors.green.shade50,
        ),
      ),
    );
  }
}

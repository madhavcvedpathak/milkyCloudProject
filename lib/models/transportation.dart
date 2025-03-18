class TransportationCost {
  final String farmName;
  final double milkPrice;        // Milk price per litre in INR
  final double litresPerDay;     // Litres of milk per day
  final double tankerCapacity;   // Tanker capacity in litres
  final double totalKMs;         // Total kilometres travelled in a day
  final double ratePerKM;        // Rate per km in INR
  final double dailyAllowance;   // Daily allowance in INR
  final double dailyWage;        // Daily wage in INR
  final double testingCost;      // Testing cost in INR
  final double otherCost;        // Other costs in INR

  TransportationCost({
    required this.farmName,
    required this.milkPrice,
    required this.litresPerDay,
    required this.tankerCapacity,
    required this.totalKMs,
    required this.ratePerKM,
    required this.dailyAllowance,
    required this.dailyWage,
    required this.testingCost,
    this.otherCost = 0.0,
  });

  double get overheads => dailyAllowance + dailyWage + testingCost + otherCost;
  double get landedCost => litresPerDay * milkPrice;  // Total cost of milk in INR
  double get transportationCost => totalKMs * ratePerKM; // Transportation cost in INR
  double get tptPerLitre => transportationCost / litresPerDay;  // Cost per litre of milk in INR
  double get totalCost => landedCost + transportationCost + overheads;  // Total cost in INR
}

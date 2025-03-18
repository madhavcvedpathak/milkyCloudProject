class DMCowWeight {
  final double cowWeight;
  final double dmPercentage;

  DMCowWeight({required this.cowWeight, required this.dmPercentage});

  double get totalDMIntake => (dmPercentage / 100) * cowWeight;
}
enum MachineType { washer, dryer }

class MachineItem {
  final String id;
  final String name;
  final int count;
  final String tier; // e.g. PLUS+, STANDARD
  final MachineType type;
  final bool isAvailable;

  const MachineItem({
    required this.id,
    required this.name,
    required this.count,
    required this.tier,
    required this.type,
    this.isAvailable = true,
  });
}

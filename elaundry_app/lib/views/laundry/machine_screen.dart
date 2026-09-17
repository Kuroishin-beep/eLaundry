import 'package:flutter/material.dart';
import '../../shared/widgets/search_filter_bar.dart';
import '../../core/themes/theme.dart';
import '../../models/machine_model.dart';
import '../../shared/widgets/laundry_navigation_fab.dart';
import 'new_machine_screen.dart';

class MachinesScreen extends StatefulWidget {
  const MachinesScreen({super.key});

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<MachineItem> _machines = [
    const MachineItem(
      id: '1',
      name: 'LG Titan Washer',
      count: 5,
      tier: 'PLUS+',
      type: MachineType.washer,
    ),
    const MachineItem(
      id: '2',
      name: 'LG Titan Dryer',
      count: 5,
      tier: 'PLUS+',
      type: MachineType.dryer,
    ),
    const MachineItem(
      id: '3',
      name: 'LG Giant Dryer',
      count: 5,
      tier: 'STANDARD',
      type: MachineType.dryer,
    ),
    const MachineItem(
      id: '4',
      name: 'LG Giant Washer',
      count: 5,
      tier: 'STANDARD',
      type: MachineType.washer,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MachineItem> get _filteredMachines {
    return _machines.where((m) {
      final matchesSearch = m.name.toLowerCase().contains(
        _searchController.text.toLowerCase().trim(),
      );
      if (_selectedFilter == 'Washers') {
        return matchesSearch && m.type == MachineType.washer;
      }
      if (_selectedFilter == 'Dryers') {
        return matchesSearch && m.type == MachineType.dryer;
      }
      return matchesSearch;
    }).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Machines',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary[900],
                  ),
                ),
                const SizedBox(height: 16),
                ...['All', 'Washers', 'Dryers'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      filter,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.secondary[800],
                      ),
                    ),
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                            )
                            : null,
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                      Navigator.of(context).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigateToAddMachine() async {
    final newMachine = await Navigator.of(context).push<MachineItem>(
      MaterialPageRoute(builder: (context) => const NewMachineScreen()),
    );

    if (newMachine != null) {
      setState(() {
        _machines.add(newMachine);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral[400],
      appBar: AppBar(
        title: Text(
          'Machines',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary[900],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const LaundryNavigationFab(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Combined Capsule Search & Filter Bar
                CapsuleSearchFilterBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  onFilterTap: _showFilterSheet,
                  hintText: 'Search machines...',
                ),

                const SizedBox(height: 16),

                // Action Bar (Filter status + Add Machine)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Active filter chip indicator
                    if (_selectedFilter != 'All')
                      Chip(
                        label: Text(
                          _selectedFilter,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        deleteIcon: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        onDeleted:
                            () => setState(() => _selectedFilter = 'All'),
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )
                    else
                      const SizedBox.shrink(),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _navigateToAddMachine,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Add Machine',
                        style: TextStyle(
                          fontSize: 13,
                          // fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Machine Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredMachines.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final item = _filteredMachines[index];
                    return _MachineCard(item: item);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  final MachineItem item;

  const _MachineCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isWasher = item.type == MachineType.washer;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral[500]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphic Card Preview
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.neutral[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color:
                            isWasher
                                ? AppColors.primary[300]!
                                : AppColors.warning[300]!,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isWasher
                            ? Icons.local_laundry_service_rounded
                            : Icons.wb_sunny_rounded,
                        size: 32,
                        color:
                            isWasher
                                ? AppColors.primary[600]
                                : AppColors.warning[600],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title & Count
          Text(
            '${item.name} (${item.count})',
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF2D2E2E)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Tier Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.tier,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

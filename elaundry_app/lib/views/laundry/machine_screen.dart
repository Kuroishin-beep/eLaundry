import 'package:flutter/material.dart';

import '../../controllers/machine_controller.dart';
import '../../core/themes/theme.dart';
import '../../models/machine_model.dart';
import '../../shared/empty_states.dart';
import '../../shared/laundry_navigation_fab.dart';
import '../../shared/search_filter_bar.dart';
import 'machine_card.dart';
import 'machine_details_screen.dart';
import 'new_machine_screen.dart';

class MachinesScreen extends StatefulWidget {
  const MachinesScreen({super.key});

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  final MachineController _machineController = MachineController();
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  late final Stream<List<MachineItem>> _machinesStream;

  @override
  void initState() {
    super.initState();
    _machinesStream = _machineController.watchMachines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openMachineDetails(MachineItem machine) async {
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        builder: (context) => MachineDetailsScreen(machine: machine),
      ),
    );
    if (!mounted || result == null) return;

    try {
      if (result == 'deleted') {
        await _machineController.deleteMachine(machine.id);
        if (mounted) {
          _showMachineSnackBar('Machine deleted.');
        }
      } else if (result is MachineItem) {
        await _machineController.updateMachine(result);
        if (mounted) {
          _showMachineSnackBar('Machine updated.');
        }
      }
    } catch (error) {
      if (mounted) {
        _showMachineSnackBar('Unable to update machine: $error');
      }
    }
  }

  List<MachineItem> _filteredMachines(List<MachineItem> machines) {
    return machines.where((m) {
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
    try {
      final newMachine = await Navigator.of(context).push<MachineItem>(
        MaterialPageRoute(builder: (context) => const NewMachineScreen()),
      );

      if (newMachine != null) {
        await _machineController.createMachine(newMachine);
        if (mounted) {
          _showMachineSnackBar(
            'Machine successfully created!',
            backgroundColor: AppColors.primary[500],
          );
        }
      }
    } catch (error) {
      if (mounted) {
        _showMachineSnackBar('Unable to save machine: $error');
      }
    }
  }

  void _showMachineSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
                StreamBuilder<List<MachineItem>>(
                  stream: _machinesStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Column(
                        children: [
                          _buildMachineActionBar(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Unable to load machines: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.secondary[600]),
                            ),
                          ),
                        ],
                      );
                    }
                    if (!snapshot.hasData) {
                      return Column(
                        children: [
                          _buildMachineActionBar(),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ],
                      );
                    }

                    final allMachines = snapshot.data!;
                    final machines = _filteredMachines(snapshot.data!);
                    if (machines.isEmpty) {
                      final hasNoMachines = allMachines.isEmpty;
                      return Column(
                        children: [
                          if (!hasNoMachines) _buildMachineActionBar(),
                          SizedBox(
                            height: 420,
                            child: Center(
                              child: EmptyState(
                                icon: Icons.local_laundry_service_outlined,
                                title:
                                    hasNoMachines
                                        ? 'No Machines Yet'
                                        : 'No Matching Machines',
                                description:
                                    hasNoMachines
                                        ? 'Add a machine to start managing your laundry equipment.'
                                        : 'Try changing your search or filter.',
                                actionLabel:
                                    hasNoMachines ? 'Add Machine' : null,
                                onAction:
                                    hasNoMachines
                                        ? _navigateToAddMachine
                                        : null,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _buildMachineActionBar(),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: machines.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.78,
                              ),
                          itemBuilder:
                              (context, index) => MachineCard(
                                item: machines[index],
                                onTap:
                                    () => _openMachineDetails(machines[index]),
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMachineActionBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_selectedFilter != 'All')
              Chip(
                label: Text(
                  _selectedFilter,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                deleteIcon: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                onDeleted: () => setState(() => _selectedFilter = 'All'),
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
              label: const Text('Add Machine', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/hidden/hidden_provider.dart';
import '../shared/models/place.dart';
import '../shared/widgets/cards.dart';

class HiddenPlacesScreen extends StatelessWidget {
  const HiddenPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HiddenSpotsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Hidden Gems'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () => _showFilters(context, provider),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search hidden spots...',
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) => provider.setSearchQuery(value),
                ),
              ),
              // Filter chips
              _buildFilterChips(context, provider),
              // Results
              Expanded(
                child: provider.filteredSpots.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.filteredSpots.length,
                        itemBuilder: (context, index) {
                          final spot = provider.filteredSpots[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HiddenSpotCard(spot: spot),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(BuildContext context, HiddenSpotsProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // District filter
          if (provider.districts.isNotEmpty) ...[
            _FilterChipGroup(
              label: 'District',
              selected: provider.selectedDistrict,
              options: ['All', ...provider.districts],
              onChanged: (value) => provider.setDistrict(value == 'All' ? '' : value),
            ),
            const SizedBox(width: 8),
          ],
          // Difficulty filter
          _FilterChipGroup(
            label: 'Difficulty',
            selected: provider.selectedDifficulty,
            options: ['All', ...provider.difficulties],
            onChanged: (value) => provider.setDifficulty(value == 'All' ? '' : value),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hidden spots found',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.read<HiddenSpotsProvider>().clearFilters(),
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context, HiddenSpotsProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(provider: provider),
    );
  }
}

class _FilterChipGroup extends StatelessWidget {
  final String label;
  final String selected;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _FilterChipGroup({
    required this.label,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = (selected == option) || (selected.isEmpty && option == 'All');
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onChanged(option),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final HiddenSpotsProvider provider;

  const _FilterBottomSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.headlineMedium),
              TextButton(
                onPressed: () {
                  provider.clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (provider.districts.isNotEmpty) ...[
            Text('District', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['All', ...provider.districts].map((d) {
                final selected = provider.selectedDistrict == d || (d == 'All' && provider.selectedDistrict.isEmpty);
                return FilterChip(
                  label: Text(d),
                  selected: selected,
                  onSelected: (_) => provider.setDistrict(d == 'All' ? '' : d),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          Text('Difficulty', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['All', ...provider.difficulties].map((d) {
              final selected = provider.selectedDifficulty == d || (d == 'All' && provider.selectedDifficulty.isEmpty);
              return FilterChip(
                label: Text(d),
                selected: selected,
                onSelected: (_) => provider.setDifficulty(d == 'All' ? '' : d),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
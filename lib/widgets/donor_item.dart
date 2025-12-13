import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/localization.dart';

/// Donor list item widget
class DonorItem extends StatelessWidget {
  final String name;
  final String bloodGroup;
  final double distanceKm;
  final String city;
  final bool isAvailable;
  final String phone;
  final String lastDonation;
  final VoidCallback? onContact;

  const DonorItem({
    super.key,
    required this.name,
    required this.bloodGroup,
    required this.distanceKm,
    required this.city,
    required this.isAvailable,
    required this.phone,
    required this.lastDonation,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).cardTheme.shape is RoundedRectangleBorder 
              ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).side.color 
              : AppTheme.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '$city • ${distanceKm.toStringAsFixed(1)} ${Localization.get('km')} ${Localization.get('away')}',
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  Localization.get(isAvailable ? 'available' : 'notAvailable'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isAvailable ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bloodtype,
                      size: 18,
                      color: AppTheme.primaryRed,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bloodGroup,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${Localization.get('lastDonation')}: $lastDonation',
                  style: AppTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (onContact != null)
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onContact,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          Localization.get('contact'),
                          style: AppTheme.buttonText.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}


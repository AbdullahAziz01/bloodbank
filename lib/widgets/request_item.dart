import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/localization.dart';

/// Blood request item widget
class RequestItem extends StatelessWidget {
  final String name;
  final String bloodGroup;
  final int units;
  final double distanceKm;
  final String city;
  final String urgency;
  final String hospital;
  final String note;
  final String timeAgo;
  final String status;
  final VoidCallback? onContact;

  const RequestItem({
    super.key,
    required this.name,
    required this.bloodGroup,
    required this.units,
    required this.distanceKm,
    required this.city,
    required this.urgency,
    required this.hospital,
    required this.note,
    required this.timeAgo,
    this.status = 'active',
    this.onContact,
  });

  Color _getUrgencyColor(String urgency) {
    if (status == 'solved') return Colors.green;
    
    switch (urgency.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _getUrgencyColor(urgency);
    final isSolved = status == 'solved';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSolved ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[200]) : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSolved 
              ? Colors.grey 
              : (Theme.of(context).cardTheme.shape is RoundedRectangleBorder 
                  ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).side.color 
                  : AppTheme.borderColor),
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
                  color: (isSolved ? Colors.grey : AppTheme.primaryRed).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSolved ? Icons.check_circle : Icons.local_hospital,
                  color: isSolved ? Colors.grey : AppTheme.primaryRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSolved ? '$hospital (SOLVED)' : hospital,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: isSolved ? Colors.grey[600] : null,
                        decoration: isSolved ? TextDecoration.lineThrough : null,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
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
                  color: urgencyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSolved ? 'SOLVED' : Localization.get(urgency.toLowerCase()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: urgencyColor,
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
                      '$bloodGroup • $units ${Localization.get('units')}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                timeAgo,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.black 
                    : AppTheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (onContact != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Container(
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          Localization.get('contact'),
                          style: AppTheme.buttonText.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


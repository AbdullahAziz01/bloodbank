import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/localization.dart';

/// Role selection card for Donor/Recipient
class RoleCard extends StatefulWidget {
  final String role;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.role,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: _isPressed
                ? AppTheme.primaryGradient
                : LinearGradient(
                    colors: [AppTheme.cardBackground, AppTheme.cardBackground],
                  ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isPressed
                  ? Colors.transparent
                  : AppTheme.borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? AppTheme.gradientStart.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isPressed ? 20 : 10,
                offset: Offset(0, _isPressed ? 8 : 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isPressed
                      ? Colors.white.withOpacity(0.2)
                      : AppTheme.primaryRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 48,
                  color: _isPressed ? Colors.white : AppTheme.primaryRed,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                Localization.get(widget.role),
                style: AppTheme.heading3.copyWith(
                  color: _isPressed ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Localization.get(widget.description),
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(
                  color: _isPressed
                      ? Colors.white.withOpacity(0.9)
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


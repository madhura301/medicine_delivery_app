// File: lib/widgets/step_progress_indicator.dart
import 'package:flutter/material.dart';
import 'package:pharmaish/core/theme/app_theme.dart';

/// Model class to define each step
class StepItem {
  final String label;
  final IconData icon;

  const StepItem({
    required this.label,
    required this.icon,
  });
}

/// Reusable Step Progress Indicator Widget
class StepProgressIndicator extends StatelessWidget {
  final List<StepItem> steps;
  final int currentStep;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? connectorColor;
  final double indicatorSize;
  final double connectorHeight;
  final TextStyle? activeTextStyle;
  final TextStyle? inactiveTextStyle;

  const StepProgressIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
    this.activeColor,
    this.inactiveColor,
    this.connectorColor,
    this.indicatorSize = 40,
    this.connectorHeight = 2,
    this.activeTextStyle,
    this.inactiveTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final activeClr = activeColor ?? AppTheme.primaryColor;
    final inactiveClr = inactiveColor ?? Colors.grey.shade300;
    final connectorClr = connectorColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: activeClr,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildStepItems(activeClr, inactiveClr, connectorClr),
      ),
    );
  }

  List<Widget> _buildStepItems(
      Color activeClr, Color inactiveClr, Color connectorClr) {
    List<Widget> widgets = [];

    for (int i = 0; i < steps.length; i++) {
      // Add step indicator
      widgets.add(_buildStepIndicator(i, steps[i], activeClr, inactiveClr));

      // Add connector between steps (except after last step)
      if (i < steps.length - 1) {
        widgets.add(_buildStepConnector(i, connectorClr));
      }
    }

    return widgets;
  }

  Widget _buildStepIndicator(
      int step, StepItem stepItem, Color activeClr, Color inactiveClr) {
    final isActive = step == currentStep;
    final isCompleted = step < currentStep;

    return Column(
      children: [
        Container(
          width: indicatorSize,
          height: indicatorSize,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.white
                : isActive
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : stepItem.icon,
            color: activeClr,
            size: indicatorSize / 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stepItem.label,
          style: activeTextStyle ??
              TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step, Color connectorClr) {
    return Container(
      width: 40,
      height: connectorHeight,
      color: step < currentStep
          ? connectorClr
          : connectorClr.withValues(alpha: 0.3),
      margin: const EdgeInsets.only(bottom: 16),
    );
  }
}

/// Alternative flat style progress indicator (for pharmacist registration)
class FlatStepProgressIndicator extends StatelessWidget {
  final List<StepItem> steps;
  final int currentStep;
  final Color? activeColor;
  final Color? inactiveColor;

  const FlatStepProgressIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeClr = activeColor ?? AppTheme.primaryColor;
    final inactiveClr = inactiveColor ?? Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _buildFlatStepItems(activeClr, inactiveClr),
      ),
    );
  }

  List<Widget> _buildFlatStepItems(Color activeClr, Color inactiveClr) {
    List<Widget> widgets = [];

    for (int i = 0; i < steps.length; i++) {
      widgets.add(_buildFlatStepIndicator(i, steps[i], activeClr, inactiveClr));
      
      if (i < steps.length - 1) {
        widgets.add(Expanded(child: _buildFlatConnector(i, activeClr, inactiveClr)));
      }
    }

    return widgets;
  }

  Widget _buildFlatStepIndicator(
      int step, StepItem stepItem, Color activeClr, Color inactiveClr) {
    bool isActive = currentStep >= step;
    bool isCurrent = currentStep == step;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? activeClr : inactiveClr,
            border: Border.all(
              color: isCurrent ? activeClr : inactiveClr,
              width: 2,
            ),
          ),
          child: Center(
            child: isActive && currentStep > step
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          stepItem.label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? activeClr : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFlatConnector(int step, Color activeClr, Color inactiveClr) {
    bool isCompleted = currentStep > step;
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      color: isCompleted ? activeClr : inactiveClr,
    );
  }
}
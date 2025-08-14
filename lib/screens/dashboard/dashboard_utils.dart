import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'package:corn_addiction/models/urge_log_model.dart';
import 'package:corn_addiction/services/auth_service.dart';
import 'package:corn_addiction/core/constants/app_text_styles.dart';
import 'package:corn_addiction/widgets/common_widgets.dart';

class DashboardUtils {
  static Color getUrgeIntensityColor(double intensity) {
    if (intensity <= 3) {
      return Colors.green;
    } else if (intensity <= 7) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  static UrgeIntensity convertDoubleToUrgeIntensity(double intensity) {
    if (intensity <= 3) {
      return UrgeIntensity.low;
    } else if (intensity <= 7) {
      return UrgeIntensity.medium;
    } else if (intensity <= 9) {
      return UrgeIntensity.high;
    } else {
      return UrgeIntensity.extreme;
    }
  }

  static void showLogUrgeBottomSheet(BuildContext context) {
    double urgeIntensity = 5.0;
    bool didRelapse = false;
    TextEditingController notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Log an Urge',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'How strong is your urge? (1-10)',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('1', style: AppTextStyles.bodyMedium),
                      Expanded(
                        child: Slider(
                          value: urgeIntensity,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: getUrgeIntensityColor(urgeIntensity),
                          label: urgeIntensity.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              urgeIntensity = value;
                            });
                          },
                        ),
                      ),
                      Text('10', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: Text(
                      'I relapsed',
                      style: AppTextStyles.bodyLarge,
                    ),
                    value: didRelapse,
                    onChanged: (value) {
                      setState(() {
                        didRelapse = value ?? false;
                      });
                    },
                    activeColor: Colors.red,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'What triggered this urge?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      PrimaryButton(
                        text: 'Save',
                        isFullWidth: false,
                        onPressed: () async {
                          Navigator.pop(context);

                          final authService = AuthService();
                          final urge = UrgeLogModel(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            userId: authService.currentUser!.uid,
                            timestamp: DateTime.now(),
                            intensity:
                                convertDoubleToUrgeIntensity(urgeIntensity),
                            wasResisted: !didRelapse,
                            notes: notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim(),
                          );

                          // TODO: Save urge to database
                          // await database.addUrgeLog(urge);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

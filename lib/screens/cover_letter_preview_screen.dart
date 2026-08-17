import 'package:flutter/material.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/models/cover_letter_model.dart';
import 'package:cv_ganerator/widgets/app_widgets.dart';
import 'package:cv_ganerator/widgets/common_widgets.dart';

class CoverLetterPreviewScreen extends StatelessWidget {
  final CoverLetter letter;

  const CoverLetterPreviewScreen({
    required this.letter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: 'Cover Letter'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: CustomCard(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                letter.companyName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXSmall),
              Text(
                letter.jobTitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Divider(color: AppTheme.borderColor),
              const SizedBox(height: AppDimensions.paddingMedium),
              SelectableText(
                letter.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

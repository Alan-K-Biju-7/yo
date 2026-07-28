import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_shell.dart';
import '../../data/reference_data.dart';

class AcademicDocumentsPage extends StatelessWidget {
  const AcademicDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Academic/Semester',
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(17, 7, 17, 28),
        itemCount: ReferenceData.documents.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.picture_as_pdf,
                      color: AppColors.accent,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 19),
                  Expanded(
                    child: Text(
                      ReferenceData.documents[index],
                      style: const TextStyle(fontSize: 20, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

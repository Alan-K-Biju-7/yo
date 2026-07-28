import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_shell.dart';
import '../../data/reference_data.dart';

class InternalMarkPage extends StatefulWidget {
  const InternalMarkPage({super.key});

  @override
  State<InternalMarkPage> createState() => _InternalMarkPageState();
}

class _InternalMarkPageState extends State<InternalMarkPage> {
  static const _classCodes = ['2026S3CS-C', '2026S2CS-C', '2025S1CS-C'];

  String _classCode = _classCodes.first;
  String? _examType;

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Internal Mark',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _OutlinedDropdown(
            label: 'Select Class Code',
            value: _classCode,
            options: _classCodes,
            onChanged: (value) {
              setState(() {
                _classCode = value;
                _examType = null;
              });
            },
          ),
          const SizedBox(height: 17),
          _OutlinedDropdown(
            label: 'Select Exam Type',
            value: _examType,
            options: ReferenceData.examTypes,
            onChanged: (value) => setState(() => _examType = value),
          ),
        ],
      ),
    );
  }
}

class _OutlinedDropdown extends StatelessWidget {
  const _OutlinedDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: MediaQuery.sizeOf(context).height * .78,
      icon: const Icon(Icons.arrow_drop_down, size: 30),
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.purple, fontSize: 17),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: value == null ? AppColors.purple : const Color(0xFF6F6A70),
            width: value == null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.purple, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      selectedItemBuilder: (context) => [
        for (final option in options)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              option,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      items: [
        for (final option in options)
          DropdownMenuItem<String>(
            value: option,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                option,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}

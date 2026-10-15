import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';

class InspectionRecord {
  final String id;
  final String fieldBlock;
  final String dateString;
  final String imageFileName;
  final String note;

  const InspectionRecord({
    required this.id,
    required this.fieldBlock,
    required this.dateString,
    required this.imageFileName,
    required this.note,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<InspectionRecord> _records = [
    const InspectionRecord(
      id: 'ST-004',
      fieldBlock: 'Block 2 • Upper Nilgiris',
      dateString: 'Today, 08:30 AM',
      imageFileName: 'tender_flush_scan_01.jpg',
      note: 'Routine morning flush quality inspection.',
    ),
    const InspectionRecord(
      id: 'ST-003',
      fieldBlock: 'Block 7 • Valley Depression',
      dateString: 'Yesterday, 04:15 PM',
      imageFileName: 'leaf_underside_sample.jpg',
      note: 'Monitored shaded canopy following high humidity.',
    ),
    const InspectionRecord(
      id: 'ST-002',
      fieldBlock: 'Block 1 • Seedling Nursery',
      dateString: '2 days ago, 11:00 AM',
      imageFileName: 'nursery_leaf_check.jpg',
      note: 'Pre-transplant foliar inspection.',
    ),
  ];

  void _clearRecords() {
    setState(() {
      _records.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final lang = langCtrl.currentLanguage;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.historyTitle(lang),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.historySubtitle(lang),
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (_records.isNotEmpty)
                IconButton(
                  key: const Key('clear_history_icon_button'),
                  tooltip: AppStrings.btnClearHistory(lang),
                  icon: const Icon(Icons.delete_sweep_outlined, color: AppTheme.alertRed),
                  onPressed: _clearRecords,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Milestone notice card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.creamLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.creamDark),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sync_disabled,
                  color: AppTheme.forestGreenLight,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.historyNotice(lang),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textDark,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (_records.isEmpty)
            _buildEmptyState(context, lang)
          else
            ..._records.map((r) => _buildRecordCard(context, r, lang)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.creamLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.creamDark),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.history,
            size: 48,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            lang == AppLanguage.ta ? 'பதிவுகள் எதுவும் இல்லை' : 'No inspection records yet',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lang == AppLanguage.ta
                ? 'இலை பகுப்பாய்வு மூலம் புதிய படங்களை சேர்க்கவும்'
                : 'Captured leaf photos will appear here once saved',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    InspectionRecord record,
    AppLanguage lang,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  record.id,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.forestGreen,
                  ),
                ),
                const SizedBox(width: 8),
                const Spacer(),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.warningAmber.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      AppStrings.statusPendingModel(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.warningAmber,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    record.fieldBlock,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    record.dateString,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              record.note,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

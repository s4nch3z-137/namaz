import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/prayer_record.dart';
import '../providers/prayer_provider.dart';
import '../l10n/kurdish_strings.dart';

class PrayerLoggerDialog extends StatefulWidget {
  final String prayerName;
  final PrayerRecord? existingRecord;
  final PrayerProvider provider;

  const PrayerLoggerDialog({
    Key? key,
    required this.prayerName,
    this.existingRecord,
    required this.provider,
  }) : super(key: key);

  @override
  _PrayerLoggerDialogState createState() => _PrayerLoggerDialogState();
}

class _PrayerLoggerDialogState extends State<PrayerLoggerDialog> {
  PrayerStatus? _selectedStatus;
  bool _sunnahBefore = false;
  bool _sunnahAfter = false;
  bool _jamaah = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      _selectedStatus = widget.existingRecord!.status;
      _sunnahBefore = widget.existingRecord!.sunnahBefore;
      _sunnahAfter = widget.existingRecord!.sunnahAfter;
      _jamaah = widget.existingRecord!.jamaah;
    }
  }

  bool get _hasSunnahBefore =>
      ['Fajr', 'Dhuhr', 'Asr'].contains(widget.prayerName);

  bool get _hasSunnahAfter =>
      ['Dhuhr', 'Maghrib', 'Isha'].contains(widget.prayerName);

  bool get _isAlreadyLogged => widget.existingRecord != null;

  Color _getThemeColor() {
    if (_selectedStatus == PrayerStatus.missed) return Colors.redAccent.shade700;
    if (_selectedStatus == PrayerStatus.prayedGoldenTime ||
        _selectedStatus == PrayerStatus.late) {
      if (_sunnahBefore || _sunnahAfter || _jamaah) return Colors.cyanAccent.shade400;
      return Colors.greenAccent.shade400;
    }
    return Colors.white24;
  }

  LinearGradient _getBackgroundGradient() {
    if (_selectedStatus == PrayerStatus.missed) {
      return const LinearGradient(
        colors: [Color(0xFF2C0B0E), Color(0xFF000000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (_selectedStatus == PrayerStatus.prayedGoldenTime ||
        _selectedStatus == PrayerStatus.late) {
      if (_sunnahBefore || _sunnahAfter || _jamaah) {
        return const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
    }
    return const LinearGradient(
      colors: [Color(0xFF1A213D), Color(0xFF141A31)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl,

      child: Container(
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${KS.logPrayerTitle} — ${KS.prayerNameKu(widget.prayerName)}',
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                // Already logged notice
                if (_isAlreadyLogged) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: const Text(
                      '⚠️ پێشتر تۆماری کراوە — گۆڕینی تۆمار کاریگەری لەسەر زنجیرە نییە',

                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                // Status buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statusButton(PrayerStatus.prayedGoldenTime, KS.goldenTime, '⭐'),
                    _statusButton(PrayerStatus.late, KS.late, '⏰'),
                    _statusButton(PrayerStatus.missed, KS.missed, '✗'),
                  ],
                ),

                if (_selectedStatus == PrayerStatus.prayedGoldenTime ||
                    _selectedStatus == PrayerStatus.late) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getThemeColor().withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          KS.extraDeeds,

                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        if (_hasSunnahBefore)
                          _buildCheckbox(KS.sunnahBefore, _sunnahBefore,
                              (val) => setState(() => _sunnahBefore = val!)),
                        if (_hasSunnahAfter)
                          _buildCheckbox(KS.sunnahAfter, _sunnahAfter,
                              (val) => setState(() => _sunnahAfter = val!)),
                        _buildCheckbox(KS.prayedInJamaah, _jamaah,
                            (val) => setState(() => _jamaah = val!)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getThemeColor(),
                    foregroundColor: _selectedStatus == PrayerStatus.missed
                        ? Colors.white
                        : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    shadowColor: _getThemeColor().withOpacity(0.5),
                  ),
                  onPressed: _selectedStatus == null
                      ? null
                      : () async {
                          await widget.provider.logPrayer(
                            widget.prayerName,
                            _selectedStatus!,
                            sunnahBefore: _sunnahBefore,
                            sunnahAfter: _sunnahAfter,
                            jamaah: _jamaah,
                          );
                          if (mounted) Navigator.pop(context);
                        },
                  child: Text(
                    KS.sealRecord,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusButton(PrayerStatus status, String label, String emoji) {
    bool isSelected = _selectedStatus == status;
    Color color;
    if (status == PrayerStatus.missed) color = Colors.redAccent;
    else if (status == PrayerStatus.late) color = Colors.orangeAccent;
    else color = Colors.greenAccent;

    return InkWell(
      onTap: () => setState(() {
        _selectedStatus = status;
        if (status == PrayerStatus.missed) {
          _sunnahBefore = false;
          _sunnahAfter = false;
          _jamaah = false;
        }
      }),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.25) : color.withOpacity(0.05),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,

              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(
      String title, bool value, ValueChanged<bool?> onChanged) {
    return Theme(
      data: ThemeData(unselectedWidgetColor: Colors.white54),
      child: CheckboxListTile(
        title: Text(title,

            style: const TextStyle(color: Colors.white, fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeColor: _getThemeColor(),
        checkColor: Colors.black,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
      ),
    );
  }
}

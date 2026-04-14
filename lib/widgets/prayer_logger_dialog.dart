import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/prayer_record.dart';
import '../providers/prayer_provider.dart';

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

  bool get _hasSunnahBefore {
    return ['Fajr', 'Dhuhr', 'Asr'].contains(widget.prayerName);
  }

  bool get _hasSunnahAfter {
    return ['Dhuhr', 'Maghrib', 'Isha'].contains(widget.prayerName);
  }

  Color _getThemeColor() {
    if (_selectedStatus == PrayerStatus.missed) {
      return Colors.redAccent.shade700;
    } else if (_selectedStatus == PrayerStatus.prayedGoldenTime ||
        _selectedStatus == PrayerStatus.late) {
      if (_sunnahBefore || _sunnahAfter || _jamaah) {
        return Colors.cyanAccent.shade400; // Divine Blue
      }
      return Colors.greenAccent.shade400; // Standard Accepted
    }
    return Colors.white24; // Pending
  }

  LinearGradient _getBackgroundGradient() {
    if (_selectedStatus == PrayerStatus.missed) {
      return const LinearGradient(
        colors: [Color(0xFF2C0B0E), Color(0xFF000000)], // Demonic Black/Red
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (_selectedStatus == PrayerStatus.prayedGoldenTime ||
        _selectedStatus == PrayerStatus.late) {
      if (_sunnahBefore || _sunnahAfter || _jamaah) {
        return const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], // Divine Heavenly Theme
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
    }
    // Default blue theme
    return const LinearGradient(
      colors: [Color(0xFF1A213D), Color(0xFF141A31)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(
                "Log ${widget.prayerName} Prayer",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  _statusButton(PrayerStatus.prayedGoldenTime, "Golden time"),
                  _statusButton(PrayerStatus.late, "Late"),
                  _statusButton(PrayerStatus.missed, "Missed"),
                ],
              ),
              
              if (_selectedStatus == PrayerStatus.prayedGoldenTime || _selectedStatus == PrayerStatus.late) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getThemeColor().withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Extra Deeds Rewards",
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      if (_hasSunnahBefore)
                        _buildCheckbox("Sunnah Before", _sunnahBefore, (val) {
                          setState(() => _sunnahBefore = val!);
                        }),
                      if (_hasSunnahAfter)
                        _buildCheckbox("Sunnah After", _sunnahAfter, (val) {
                          setState(() => _sunnahAfter = val!);
                        }),
                      _buildCheckbox("Prayed in Jama'ah (Mosque)", _jamaah, (val) {
                        setState(() => _jamaah = val!);
                      }),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getThemeColor(),
                  foregroundColor: _selectedStatus == PrayerStatus.missed ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 10,
                  shadowColor: _getThemeColor().withOpacity(0.5),
                ),
                onPressed: _selectedStatus == null ? null : () async {
                  await widget.provider.logPrayer(
                    widget.prayerName,
                    _selectedStatus!,
                    sunnahBefore: _sunnahBefore,
                    sunnahAfter: _sunnahAfter,
                    jamaah: _jamaah,
                  );
                  if (mounted) Navigator.pop(context);
                },
                child: const Text(
                  "Seal the Record",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusButton(PrayerStatus status, String label) {
    bool isSelected = _selectedStatus == status;
    Color color;
    if (status == PrayerStatus.missed) color = Colors.redAccent;
    else if (status == PrayerStatus.late) color = Colors.orangeAccent;
    else color = Colors.greenAccent;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
          if (status == PrayerStatus.missed) {
            _sunnahBefore = false;
            _sunnahAfter = false;
            _jamaah = false;
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : color.withOpacity(0.05),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, ValueChanged<bool?> onChanged) {
    return Theme(
      data: ThemeData(unselectedWidgetColor: Colors.white54),
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
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

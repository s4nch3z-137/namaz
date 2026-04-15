import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../l10n/kurdish_strings.dart';

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final TextEditingController _controller = TextEditingController();
  List<_CityResult> _results = [];
  bool _isSearching = false;
  String? _errorMsg;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() {
      _isSearching = true;
      _errorMsg = null;
    });
    try {
      final locations = await locationFromAddress(query);
      final results = <_CityResult>[];
      for (final loc in locations.take(5)) {
        final placemarks = await placemarkFromCoordinates(
            loc.latitude, loc.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final city = p.locality ??
              p.subAdministrativeArea ??
              p.administrativeArea ??
              '';
          final country = p.country ?? '';
          final label =
              [if (city.isNotEmpty) city, if (country.isNotEmpty) country]
                  .join(', ');
          results.add(_CityResult(
            label: label.isNotEmpty ? label : query,
            lat: loc.latitude,
            lng: loc.longitude,
          ));
        }
      }
      setState(() {
        _results = results;
        if (results.isEmpty) _errorMsg = KS.noCitiesFound;
      });
    } catch (e) {
      setState(() => _errorMsg = KS.searchFailed);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectCity(_CityResult city) async {
    final provider = Provider.of<PrayerProvider>(context, listen: false);
    Navigator.pop(context);
    await provider.setManualLocation(city.lat, city.lng, city.label);
  }

  void _useGPS() async {
    final provider = Provider.of<PrayerProvider>(context, listen: false);
    Navigator.pop(context);
    await provider.resetToGPS();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();
    return Directionality(textDirection: TextDirection.rtl,

      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A2340),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 20,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              KS.changeLocation,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              provider.isManualLocation
                  ? '${KS.manualLocation}: ${provider.cityName}'
                  : '${KS.gpsLocation}: ${provider.cityName}',

              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 18),
            // Search field
            TextField(
              controller: _controller,
              textDirection: TextDirection.rtl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: KS.searchCityHint,
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFFD4AF37)),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: _search,
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: _useGPS,
              icon: const Icon(Icons.my_location, color: Color(0xFFD4AF37), size: 18),
              label: Text(
                KS.useGPS,

                style: const TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
            if (_errorMsg != null) ...[
              const SizedBox(height: 6),
              Text(
                _errorMsg!,

                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(color: Colors.white12),
              ..._results.map((city) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on,
                        color: Color(0xFFD4AF37), size: 20),
                    title: Text(
                      city.label,

                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    subtitle: Text(
                      '${city.lat.toStringAsFixed(3)}, ${city.lng.toStringAsFixed(3)}',

                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
                    onTap: () => _selectCity(city),
                  )),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CityResult {
  final String label;
  final double lat;
  final double lng;
  const _CityResult(
      {required this.label, required this.lat, required this.lng});
}

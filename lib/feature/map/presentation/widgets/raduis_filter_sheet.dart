import 'package:flutter/material.dart';

class RadiusFilterSheet extends StatefulWidget {
  final int initialRadiusMeter;
  final ValueChanged<int> onApply;

  const RadiusFilterSheet({
    super.key,
    required this.initialRadiusMeter,
    required this.onApply,
  });

  static Future<void> show(
      BuildContext context, {
        required int initialRadiusMeter,
        required ValueChanged<int> onApply,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RadiusFilterSheet(
        initialRadiusMeter: initialRadiusMeter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<RadiusFilterSheet> createState() => _RadiusFilterSheetState();
}

class _RadiusFilterSheetState extends State<RadiusFilterSheet> {
  late double _radius; // মিটারে, slider double লাগবে তাই double রাখা
  late TextEditingController _textCtrl;

  static const double _minRadius = 100;   // 100 m
  static const double _maxRadius = 20000; // 20,000 m = 20 km

  @override
  void initState() {
    super.initState();
    _radius = widget.initialRadiusMeter.toDouble().clamp(_minRadius, _maxRadius);
    _textCtrl = TextEditingController(text: _radius.round().toString());
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _updateRadius(double value) {
    setState(() {
      _radius = value.clamp(_minRadius, _maxRadius);
      _textCtrl.text = _radius.round().toString();
    });
  }

  void _onTextChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      setState(() {
        _radius = parsed.clamp(_minRadius, _maxRadius);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── drag handle ─────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // ── title row ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Search Radius',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Icon(Icons.tune, color: const Color(0xFF185FA5)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Show parking spots within this distance',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // ── radius value badge + manual input ──────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F1FB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: _textCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF185FA5),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: _onTextChanged,
                        ),
                      ),
                      const Text(
                        ' m',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF185FA5),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _quickChip(500),
                const SizedBox(width: 8),
                _quickChip(1000),
                const SizedBox(width: 8),
                _quickChip(5000),
              ],
            ),
            const SizedBox(height: 12),

            // ── slider ──────────────────────────────────
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF185FA5),
                inactiveTrackColor: const Color(0xFFE6F1FB),
                thumbColor: const Color(0xFF185FA5),
                overlayColor: const Color(0xFF185FA5).withOpacity(0.15),
                trackHeight: 4,
              ),
              child: Slider(
                value: _radius,
                min: _minRadius,
                max: _maxRadius,
                onChanged: _updateRadius,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_minRadius.toInt()} m',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  Text('${(_maxRadius / 1000).toInt()} km',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── apply button ────────────────────────────
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF185FA5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onApply(_radius.round());
              },
              child: Text(
                'Apply (${_radius.round()} m)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(int meterValue) {
    final bool selected = _radius.round() == meterValue;
    final String label = meterValue >= 1000
        ? '${(meterValue / 1000).toStringAsFixed(meterValue % 1000 == 0 ? 0 : 1)} km'
        : '$meterValue m';
    return GestureDetector(
      onTap: () => _updateRadius(meterValue.toDouble()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF185FA5) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
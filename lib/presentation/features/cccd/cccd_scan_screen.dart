import 'package:flutter/material.dart';
import 'package:identity_frontend/core/themes/app_colors.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Dữ liệu CCCD parse từ QR chip thẻ CCCD.
/// Format: id|cccd|name|dob|gender|address|issueDate
/// VD: 010203002750|063602622|Đặng Minh Phương|20042003|Nam|Thôn Nà Phát, Phúc Khánh, Bảo Yên, Lào Cai|08052024
class CccdData {
  final String id;
  final String cccdNumber;
  final String name;
  final String dateOfBirth; // YYYY-MM-DD
  final String gender; // MALE | FEMALE
  final String address;
  final String issueDate; // YYYY

  const CccdData({
    required this.id,
    required this.cccdNumber,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.issueDate,
  });

  static CccdData? tryParse(String raw) {
    final parts = raw.split('|');
    if (parts.length < 7) return null;
    final id = parts[0].trim();
    final cccd = parts[1].trim();
    final name = parts[2].trim();
    final dobRaw = parts[3].trim(); // ddMMyyyy or ddMMyyyyHHmm
    final genderRaw = parts[4].trim();
    final address = parts[5].trim();
    final issueDateRaw = parts[6].trim(); // ddMMyyyy

    if (cccd.isEmpty || name.isEmpty || dobRaw.length < 8) return null;

    // Parse DOB: ddMMyyyy
    final dob = _parseDate(dobRaw);
    if (dob == null) return null;

    // Parse issue year
    String issueYear = '';
    if (issueDateRaw.length >= 8) {
      issueYear = issueDateRaw.substring(4, 8);
    }

    final gender = genderRaw.toLowerCase().contains('nữ') ||
            genderRaw.toLowerCase() == 'female' ||
            genderRaw == '1'
        ? 'FEMALE'
        : 'MALE';

    return CccdData(
      id: id,
      cccdNumber: cccd,
      name: name,
      dateOfBirth: dob,
      gender: gender,
      address: address,
      issueDate: issueYear,
    );
  }

  static String? _parseDate(String raw) {
    // ddMMyyyy (length 8) or ddMMyyyyHHmmss
    if (raw.length < 8) return null;
    final day = raw.substring(0, 2);
    final month = raw.substring(2, 4);
    final year = raw.substring(4, 8);
    final d = int.tryParse(day);
    final m = int.tryParse(month);
    final y = int.tryParse(year);
    if (d == null || m == null || y == null) return null;
    if (d < 1 || d > 31 || m < 1 || m > 12 || y < 1900) return null;
    return '$year-${month.padLeft(2, '0')}-${day.padLeft(2, '0')}';
  }
}

/// Màn hình quét QR chip thẻ CCCD.
///
/// Dùng chung cho onboarding và profile setup.
/// Kết quả trả về qua [onScanned] hoặc [onSkip].
class CccdScanScreen extends StatefulWidget {
  /// Được gọi khi quét thành công.
  final void Function(CccdData data) onScanned;

  /// Được gọi khi người dùng nhấn Skip.
  final VoidCallback onSkip;

  const CccdScanScreen({
    super.key,
    required this.onScanned,
    required this.onSkip,
  });

  @override
  State<CccdScanScreen> createState() => _CccdScanScreenState();
}

class _CccdScanScreenState extends State<CccdScanScreen> {
  late final MobileScannerController _ctrl;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = MobileScannerController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    final data = CccdData.tryParse(raw);
    if (data == null) {
      // Không phải QR CCCD hợp lệ — bỏ qua và tiếp tục quét
      return;
    }

    setState(() => _processing = true);
    await _ctrl.stop();
    if (!mounted) return;
    widget.onScanned(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: AppLocalizations.of(context)!.cccdBack,
        ),
        actions: [
          TextButton(
            onPressed: widget.onSkip,
            child: Text(
              AppLocalizations.of(context)!.cccdSkip,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
          ),

          // Dimmed overlay with viewfinder cutout
          _ScanOverlay(),

          // Bottom instruction panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.credit_card_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.cccdTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.cccdInstruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: widget.onSkip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white30),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(AppLocalizations.of(context)!.cccdManualInput),
                  ),
                ],
              ),
            ),
          ),

          if (_processing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const boxSize = 260.0;
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      final left = (w - boxSize) / 2;
      final top = (h - boxSize) / 2 - 60;

      return Stack(
        children: [
          // Dark overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _OverlayPainter(
                cutoutRect: Rect.fromLTWH(left, top, boxSize, boxSize),
              ),
            ),
          ),
          // Viewfinder border
          Positioned(
            left: left,
            top: top,
            width: boxSize,
            height: boxSize,
            child: _ViewfinderBorder(),
          ),
        ],
      );
    });
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect cutoutRect;
  const _OverlayPainter({required this.cutoutRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final full = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(full)
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.cutoutRect != cutoutRect;
}

class _ViewfinderBorder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CornerPainter());
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const r = 12.0;
    const len = 28.0;

    void corner(double x, double y, double dx, double dy) {
      canvas.drawLine(Offset(x + dx * r, y), Offset(x + dx * (r + len), y), paint);
      canvas.drawLine(Offset(x, y + dy * r), Offset(x, y + dy * (r + len)), paint);
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(x + dx * r, y + dy * r), width: r * 2, height: r * 2),
        dx == 1 && dy == 1
            ? 3.14159
            : dx == -1 && dy == 1
                ? 3.14159 * 1.5
                : dx == 1 && dy == -1
                    ? 3.14159 * 0.5
                    : 0,
        3.14159 * 0.5,
        false,
        paint,
      );
    }

    corner(0, 0, 1, 1);
    corner(size.width, 0, -1, 1);
    corner(0, size.height, 1, -1);
    corner(size.width, size.height, -1, -1);
  }

  @override
  bool shouldRepaint(_CornerPainter _) => false;
}

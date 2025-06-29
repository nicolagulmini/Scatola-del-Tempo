import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(
    const MaterialApp(
      home: ClockWallpaper(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class ClockWallpaper extends StatefulWidget {
  const ClockWallpaper({Key? key}) : super(key: key);

  @override
  State<ClockWallpaper> createState() => _ClockWallpaperState();
}

class MenuButtons extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final void Function(int index) onSelect;

  const MenuButtons({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(options.length, (index) {
        return _MenuButton(
          label: options[index],
          isSelected: selectedIndex == index,
          onTap: () => onSelect(index),
        );
      }),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white24
                : isHovered
                ? Colors.white12
                : Colors.black.withAlpha(10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.robotoMono(
              color: Colors.white,
              fontSize: 10,

              fontWeight: widget.isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _ClockWallpaperState extends State<ClockWallpaper> {
  late Timer _timer;
  late String _time;
  int selectedIndex = 0;
  late Timer _cityTimer;
  final List<Map<String, dynamic>> _citiesN = [
    {'name': 'Napoli', 'offset': 2},
    {'name': 'New York', 'offset': -4},
    {'name': 'Nuova Delhi', 'offset': 5.5},
    {'name': 'Nizza', 'offset': 2},
  ];
  String _cityName = 'Napoli';
  DateTime _cityTime = DateTime.now().toUtc().add(const Duration(hours: 2));

  void _updateCity() {
    final random =
        _citiesN[DateTime.now().millisecondsSinceEpoch % _citiesN.length];
    final utcNow = DateTime.now().toUtc();
    setState(() {
      _cityName = random['name'];
      final offset = random['offset'];
      final duration = Duration(
        hours: offset.floor(),
        minutes: ((offset % 1) * 60).round(),
      );
      _cityTime = utcNow.add(duration);
    });
  }

  @override
  void initState() {
    super.initState();
    _updateTime();
    _updateCity();
    _cityTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _updateCity(),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final utcNow = now.toUtc();

    setState(() {
      _time =
          "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";

      final city = _citiesN.firstWhere(
        (c) => c['name'] == _cityName,
        orElse: () => _citiesN[0],
      );
      final offset = city['offset'];
      final duration = Duration(
        hours: offset.floor(),
        minutes: ((offset % 1) * 60).round(),
      );
      _cityTime = utcNow.add(duration);
    });
  }

  Widget _buildContent() {
    final now = DateTime.now();

    switch (selectedIndex) {
      case 0:
        return Text(
          _time,
          style: GoogleFonts.robotoMono(fontSize: 48, color: Colors.white),
        );
      case 1:
        return Text(
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
          style: GoogleFonts.robotoMono(fontSize: 48, color: Colors.white),
        );
      case 2:
        return Text(
          "${now.hour.toString().padLeft(2, '0')}",
          style: GoogleFonts.robotoMono(fontSize: 48, color: Colors.white),
        );
      case 3:
        final now = DateTime.now();
        final hour = now.hour;
        final minute = now.minute;
        final time =
            hour +
            (minute / 60); 

        String message;

        if (time >= 0 && time < 6) {
          message = "Spuntino di mezzanotte";
        } else if (time >= 6 && time < 11) {
          message = "Colazione";
        } else if (time >= 11.5 && time <= 14) {
          message = "Ora di pranzo";
        } else if (time > 14 && time <= 17.5) {
          message = "Merenda";
        } else if (time >= 19.5 && time <= 21.5) {
          message = "Ora di cena";
        } else {
          message = "Nessun pasto in programma";
        }
        return Center(
          child: Text(
            message,
            style: GoogleFonts.robotoMono(fontSize: 20, color: Colors.white),
          ),
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$_cityName: ${_cityTime.hour.toString().padLeft(2, '0')}:${_cityTime.minute.toString().padLeft(2, '0')}",
              style: GoogleFonts.robotoMono(fontSize: 24, color: Colors.white),
            ),
          ],
        );
      case 5:
        return Text(
          "Adesso",
          style: GoogleFonts.robotoMono(fontSize: 48, color: Colors.white),
        );
      case 6:
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day + 1);
        final remaining = midnight.difference(now);
        return Text(
          "${remaining.inHours}h ${remaining.inMinutes % 60}m ${remaining.inSeconds % 60}s",
          style: GoogleFonts.robotoMono(fontSize: 32, color: Colors.white),
        );
        // DA IMPLEMENTARE!
      case 7:
        return Text("🕊️", style: GoogleFonts.robotoMono(fontSize: 48));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _cityTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 11,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Stack(
                children: [
                  Image.asset('assets/timebox.png', fit: BoxFit.cover),

                  Positioned(
                    left: width * 0.52,
                    top: height * 0.22,
                    child: Container(
                      width: width * 0.33,
                      height: height * 0.31,
                      color: Colors.black,
                      child: Center(child: _buildContent()),
                    ),
                  ),

                  Positioned(
                    left: width * 0.03,
                    bottom: height * 0.1,
                    child: Container(
                      width: width * 0.3,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        //color: Colors.black.withAlpha(10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: MenuButtons(
                        options: [
                          '1. Orario',
                          '2. Orario (fino ai minuti)',
                          '3. Orario (solo ore)',
                          '4. Orario dei pasti',
                          '5. Orario nelle città con la N',
                          '6. Adesso',
                          '7. Countdown',
                          '8. Figura di un uccellino',
                        ],
                        selectedIndex: selectedIndex,
                        onSelect: (index) {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

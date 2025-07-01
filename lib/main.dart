import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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
  final double buttonFontSize;

  const MenuButtons({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
    required this.buttonFontSize,
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
          buttonFontSize: buttonFontSize,
        );
      }),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double buttonFontSize;

  const _MenuButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.buttonFontSize,
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
          padding: EdgeInsets.symmetric(vertical: widget.buttonFontSize * 0.8, horizontal: widget.buttonFontSize * 1.6),
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
              fontSize: widget.buttonFontSize,

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
  DateTime? _birthday;
  bool _isBirthdaySet = false;

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
    _loadBirthday();
    _updateTime();
    _updateCity();
    _cityTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _updateCity(),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  Future<void> _loadBirthday() async {
    final prefs = await SharedPreferences.getInstance();
    final birthdayMillis = prefs.getInt('user_birthday');
    if (birthdayMillis != null) {
      setState(() {
        _birthday = DateTime.fromMillisecondsSinceEpoch(birthdayMillis);
        _isBirthdaySet = true;
      });
    }
  }

  Future<void> _saveBirthday(DateTime birthday) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_birthday', birthday.millisecondsSinceEpoch);
    setState(() {
      _birthday = birthday;
      _isBirthdaySet = true;
    });
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthday) {
      _saveBirthday(picked);
    }
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

  Widget _buildContent(double fontSize) {
    final now = DateTime.now();

    switch (selectedIndex) {
      case 0:
        return FittedBox( 
        fit: BoxFit.scaleDown,
        child: Text(
          _time,
          style: GoogleFonts.robotoMono(fontSize: fontSize, color: Colors.white), 
        ),
      );
      case 1:
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
            style: GoogleFonts.robotoMono(fontSize: fontSize, color: Colors.white),
          ),
        );
      case 2:
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "${now.hour.toString().padLeft(2, '0')}",
            style: GoogleFonts.robotoMono(fontSize: fontSize, color: Colors.white),
          ),
        );
      case 3:
        final now = DateTime.now();
        final hour = now.hour;
        final minute = now.minute;
        final time = hour + (minute / 60);

        String message;

        if (time >= 0 && time < 6) {
          message = "Spuntino di mezzanotte";
        } else if (time >= 6 && time < 11) {
          message = "Colazione";
        } else if (time >= 11.5 && time <= 14) {
          message = "Ora di pranzo";
        } else if (time > 14 && time <= 16) {
          message = "Hai appena pranzato";
        } else if (time > 14 && time <= 17.5) {
          message = "Merenda";
        } else if (time > 17.5 && time <= 19.5) {
          message = "Aperitivooo";
        } else if (time >= 19.5 && time <= 21.5) {
          message = "Ora di cena";
        } else if (time >= 21.5 && time <= 23) {
          message = "Hai appena cenato";
        } else if (time >= 23 && time <= 23.9) {
          message = "Quasi mezzanotte";
        } else {
          message = "Nessun pasto";
        }
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            message,
            style: GoogleFonts.robotoMono(fontSize: fontSize, color: Colors.white),
          ),
        );
      case 4:
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "$_cityName: ${_cityTime.hour.toString().padLeft(2, '0')}:${_cityTime.minute.toString().padLeft(2, '0')}",
            style: GoogleFonts.robotoMono(
              fontSize: fontSize,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        );
      case 5:
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Adesso",
            style: GoogleFonts.robotoMono(fontSize: fontSize, color: Colors.white),
          ),
        );
      case 6:
        if (!_isBirthdaySet) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "Seleziona 'Countdown 80° compleanno' dal menu per inserire la tua data di nascita.",
              style: GoogleFonts.robotoMono(fontSize: fontSize, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        } else {
          final now = DateTime.now();
          final eightyYearsOld = DateTime(
            _birthday!.year + 80,
            _birthday!.month,
            _birthday!.day,
          );

          if (now.isAfter(eightyYearsOld)) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Ogni ticchettio un ricordo,\nogni secondo un tesoro.\nIl tempo è un capolavoro.",
                style: GoogleFonts.robotoMono(
                  fontSize: fontSize,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            final remaining = eightyYearsOld.difference(now);
            final days = remaining.inDays;
            final hours = remaining.inHours % 24;
            final minutes = remaining.inMinutes % 60;
            final seconds = remaining.inSeconds % 60;

            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "\nMancano $days giorni,\n$hours ore,\n$minutes\nminuti e\n$seconds secondi\nal tuo 80° compleanno!\n",
                style: GoogleFonts.robotoMono(
                  fontSize: fontSize,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
        }
      case 7:
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text("🕊️", style: TextStyle(fontSize: fontSize)));
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

              final double displayFontSize = width * 0.03;
              final double menuButtonFontSize = width * 0.01;

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
                      child: Center(child: _buildContent(displayFontSize)),
                    ),
                  ),

                  Positioned(
                    left: width * 0.03,
                    bottom: height * 0.1,
                    child: Container(
                      width: width * 0.3,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: MenuButtons(
                          options: [
                            '1. Orario',
                            '2. Orario (fino ai minuti)',
                            '3. Orario (solo ore)',
                            '4. Orario dei pasti',
                            '5. Orario nelle città con la N',
                            '6. Adesso',
                            '7. Countdown 80° compleanno',
                            '8. Figura di un uccellino',
                          ],
                          selectedIndex: selectedIndex,
                          onSelect: (index) async {
                            setState(() {
                              selectedIndex = index;
                            });
                            if (index == 6 && !_isBirthdaySet) {
                              await _selectBirthday(context);
                            }
                          },
                          buttonFontSize: menuButtonFontSize,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom:
                        height *
                        0.02, 
                    left:
                        width *
                        0.03, 
                    child: Text(
                      'Da un\'idea di Paolo Casarini\nIl mio GitHub: github.com/nicolagulmini',
                      style: GoogleFonts.robotoMono(
                        color: Colors
                            .white70, 
                        fontSize: 8, 
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color kBg = Color(0xFF050507);
const Color kCard = Color(0xFF0E0E14);
const Color kRed = Color(0xFFFF1744);
const Color kBlue = Color(0xFF00B0FF);

const String kMinecraftPackage = 'com.mojang.minecraftpe';
const MethodChannel kLauncherChannel =
    MethodChannel('com.aylegend.client/launcher');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AYLegendApp());
}

class AYLegendApp extends StatelessWidget {
  const AYLegendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A.Y Legend Client',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(
          primary: kRed,
          secondary: kBlue,
          surface: kCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _launchMinecraft(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    String message;
    try {
      final bool? ok = await kLauncherChannel.invokeMethod<bool>(
        'launchApp',
        <String, String>{'package': kMinecraftPackage},
      );
      message = ok == true
          ? 'Launching Minecraft...'
          : 'Minecraft Bedrock is not installed on this device.';
    } on PlatformException {
      message = 'Could not launch Minecraft.';
    } on MissingPluginException {
      message = 'Launching is only supported on Android.';
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF14000A), kBg, Color(0xFF00101A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _Logo(),
                    const SizedBox(height: 48),
                    NeonButton(
                      label: 'LAUNCH MINECRAFT',
                      icon: Icons.play_arrow_rounded,
                      color: kRed,
                      onPressed: () => _launchMinecraft(context),
                    ),
                    const SizedBox(height: 20),
                    NeonButton(
                      label: 'MOD MENU',
                      icon: Icons.tune_rounded,
                      color: kBlue,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ModMenuScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Companion app - UI & performance preferences only.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [kRed, kBlue],
      ).createShader(bounds),
      child: const Column(
        children: [
          Text(
            'A.Y',
            style: TextStyle(
              fontSize: 88,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
              color: Colors.white,
              shadows: [
                Shadow(color: kRed, blurRadius: 24),
                Shadow(color: kBlue, blurRadius: 48),
              ],
            ),
          ),
          Text(
            'LEGEND CLIENT',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 8,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: color.withAlpha(110), blurRadius: 18)],
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 26),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: kCard,
          side: BorderSide(color: color, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class ModSetting {
  const ModSetting(
    this.key,
    this.title,
    this.subtitle,
    this.icon,
    this.defaultValue,
  );

  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool defaultValue;
}

const List<ModSetting> kSettings = [
  ModSetting('custom_hud', 'Custom HUD', 'Personalised on-screen layout preset',
      Icons.dashboard_customize, false),
  ModSetting('pvp_ui', 'PvP UI', 'Compact interface preset for duels',
      Icons.sports_mma, false),
  ModSetting('fps_mode', 'FPS Mode', 'Performance-focused preference',
      Icons.speed, false),
  ModSetting('low_graphics', 'Low Graphics Mode',
      'Lighter visuals for weaker devices', Icons.eco, false),
  ModSetting('crosshair', 'Crosshair', 'Show a custom crosshair preference',
      Icons.gps_fixed, false),
  ModSetting('keystrokes_hud', 'Keystrokes HUD',
      'Show touch/key indicators preference', Icons.keyboard, false),
  ModSetting('neon_theme', 'A.Y Neon Theme', 'Red + blue neon accent style',
      Icons.palette, true),
];

class ModMenuScreen extends StatefulWidget {
  const ModMenuScreen({super.key});

  @override
  State<ModMenuScreen> createState() => _ModMenuScreenState();
}

class _ModMenuScreenState extends State<ModMenuScreen> {
  final Map<String, bool> _values = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      for (final s in kSettings) {
        _values[s.key] = prefs.getBool(s.key) ?? s.defaultValue;
      }
      _loaded = true;
    });
  }

  Future<void> _set(ModSetting s, bool value) async {
    setState(() => _values[s.key] = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(s.key, value);
  }

  Future<void> _reset() async {
    final prefs = await SharedPreferences.getInstance();
    for (final s in kSettings) {
      await prefs.setBool(s.key, s.defaultValue);
    }
    if (!mounted) return;
    setState(() {
      for (final s in kSettings) {
        _values[s.key] = s.defaultValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MOD MENU',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 3),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset to defaults',
            icon: const Icon(Icons.restart_alt),
            onPressed: _loaded ? _reset : null,
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kSettings.length,
              itemBuilder: (context, i) {
                final s = kSettings[i];
                final accent = i.isEven ? kRed : kBlue;
                final on = _values[s.key] ?? s.defaultValue;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: on ? accent : Colors.white12,
                      width: 1.5,
                    ),
                    boxShadow: on
                        ? [BoxShadow(color: accent.withAlpha(70), blurRadius: 12)]
                        : null,
                  ),
                  child: ListTile(
                    leading: Icon(s.icon, color: accent),
                    title: Text(
                      s.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      s.subtitle,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: Switch(
                      value: on,
                      onChanged: (v) => _set(s, v),
                      thumbColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? accent
                            : Colors.grey,
                      ),
                      trackColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? accent.withAlpha(90)
                            : Colors.white10,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

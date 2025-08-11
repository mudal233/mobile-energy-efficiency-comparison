import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MediaBenchmarkApp());
}

class MediaBenchmarkApp extends StatelessWidget {
  const MediaBenchmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Java Native Media Benchmark (Flutter)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6200EE)),
        useMaterial3: true,
      ),
      home: const MediaBenchmarkPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MediaBenchmarkPage extends StatefulWidget {
  const MediaBenchmarkPage({super.key});

  @override
  State<MediaBenchmarkPage> createState() => _MediaBenchmarkPageState();
}

class _MediaBenchmarkPageState extends State<MediaBenchmarkPage> {
  final String videoAsset = 'assets/video_8mbps.mp4';
  final String videoBitrate = '8 Mbps';

  final TextEditingController _repeatController = TextEditingController();
  final FocusNode _repeatFocus = FocusNode();

  VideoPlayerController? _controller;

  int _repeatCount = 1;
  int _currentRepeat = 0;
  bool _isPlayingSequence = false;
  String _status = 'Media Benchmark: Bereit';

  @override
  void initState() {
    super.initState();
    _repeatController.text = '1';
    _initPlayer(); // Vorinitialisieren für Vorschau/Poster
  }

  Future<void> _initPlayer() async {
    await _disposePlayer();
    final c = VideoPlayerController.asset(videoAsset);
    _controller = c;

    // Wir wollen NICHT automatisch loopen, sondern gezielt N-mal abspielen
    await c.initialize();
    c.setLooping(false);

    // Listener, der auf Ende der Wiedergabe reagiert
    c.addListener(() {
      final isInitialized = c.value.isInitialized;
      final isPlaying = c.value.isPlaying;
      final position = c.value.position;
      final duration = c.value.duration;

      if (isInitialized &&
          !_controllerEndedManually &&
          !isPlaying &&
          position >= duration &&
          _isPlayingSequence) {
        // Clip fertig → nächsten Start in Sequenz
        _onSinglePlaybackCompleted();
      }
    });

    setState(() {}); // UI updaten nach initialize()
  }

  bool _controllerEndedManually = false;

  Future<void> _disposePlayer() async {
    _controllerEndedManually = true;
    final old = _controller;
    _controller = null;
    if (old != null) {
      try {
        await old.pause();
      } catch (_) {}
      await old.dispose();
    }
    _controllerEndedManually = false;
  }

  Future<void> _startSequence() async {
    // Eingabe lesen/säubern
    final raw = _repeatController.text.trim();
    final parsed = int.tryParse(raw);
    _repeatCount = (parsed == null || parsed <= 0) ? 1 : parsed;

    _currentRepeat = 0;
    _isPlayingSequence = true;

    setState(() {
      _status = 'Starte Wiedergabe...';
    });

    // Zur Sicherheit frisch initialisieren, Cursor/Poster bleibt erhalten
    await _initPlayer();
    await _playOnce();
  }

  Future<void> _playOnce() async {
    if (!_isMounted || _controller == null) return;

    if (_currentRepeat >= _repeatCount) {
      _isPlayingSequence = false;
      setState(() {
        _status = 'Alle Wiederholungen abgeschlossen.';
      });
      return;
    }

    setState(() {
      _status =
      'Wiedergabe ${_currentRepeat + 1} von $_repeatCount ($videoBitrate)';
    });

    // Zurückspulen und starten
    await _controller!.seekTo(Duration.zero);
    await _controller!.play();
  }

  void _onSinglePlaybackCompleted() {
    _currentRepeat++;
    _playOnce(); // Nächsten Durchlauf starten
  }

  void _onPressedStart() {
    // Tastatur schließen (entspricht IME_ACTION_DONE)
    _repeatFocus.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _startSequence();
  }

  bool get _isMounted => mounted;

  @override
  void dispose() {
    _repeatController.dispose();
    _repeatFocus.dispose();
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canStart = !_isPlayingSequence;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Java Native Media Benchmark',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF6200EE),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Start-Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: canStart ? _onPressedStart : null,
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      child: Text(
                        canStart ? 'Wiedergabe starten' : 'Wird wiederholt...',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status-Text
                  Text(
                    _status,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF212121),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Video-Fläche
                  AspectRatio(
                    aspectRatio:
                    _controller?.value.isInitialized == true
                        ? _controller!.value.aspectRatio
                        : 16 / 9,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _controller?.value.isInitialized == true
                            ? VideoPlayer(_controller!)
                            : const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Eingabefeld: Anzahl Wiederholungen
                  TextField(
                    controller: _repeatController,
                    focusNode: _repeatFocus,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      _repeatFocus.unfocus();
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                    },
                    decoration: const InputDecoration(
                      hintText: 'Anzahl Wiederholungen',
                      border: OutlineInputBorder(),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

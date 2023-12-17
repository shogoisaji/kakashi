import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 111, 178, 75),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StateMachineController _stateMachineController;
  AccelerometerEvent? _accelerometerEvent;
  SMIInput<double>? _numberInput; // input value

  static const double GRAVITY = 9.8;
  static const double SCALE_FACTOR = 80;

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine');
    artboard.addController(controller!);
    _numberInput = controller.findInput<double>('angle') as SMINumber;
  }

  @override
  void initState() {
    super.initState();
    // 傾きを監視
    accelerometerEventStream().listen((event) {
      setState(() {
        _numberInput!.value = (GRAVITY + event.x) / GRAVITY * SCALE_FACTOR - SCALE_FACTOR;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: 600,
              height: 600,
              child: RiveAnimation.asset(
                'assets/rive/kakashi.riv',
                onInit: _onRiveInit,
                fit: BoxFit.contain,
              ),
            ),
            Text(_numberInput != null ? _numberInput!.value.toStringAsFixed(2) : '0.00',
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

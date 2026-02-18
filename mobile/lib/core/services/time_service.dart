import 'dart:async';

class TimeService {
  static final TimeService _instance = TimeService._internal();
  factory TimeService() => _instance;
  TimeService._internal();

  Duration _offset = Duration.zero;
  final StreamController<DateTime> _timerController = StreamController<DateTime>.broadcast();
  Timer? _ticker;

  // Stream of "current server time"
  Stream<DateTime> get nowStream => _timerController.stream;

  DateTime get now => DateTime.now().add(_offset);

  Future<void> init() async {
    // Simulating Server Fetch
    // In production, fetch endpoint: /api/time returning ISO string
    // final serverTime = await api.getServerTime();
    
    // For demo: Mock server time is 5 minutes ahead of local
    // final serverTime = DateTime.now().add(const Duration(minutes: 5)); 
    
    // For now, we assume local time is close enough or 0 offset until backend is ready
    _offset = Duration.zero;
    
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timerController.add(now);
    });
  }

  void dispose() {
    _ticker?.cancel();
    _timerController.close();
  }
}

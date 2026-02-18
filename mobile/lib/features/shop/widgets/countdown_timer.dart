import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/time_service.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  
  const CountdownTimer({Key? key, required this.endTime}) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late StreamSubscription<DateTime> _subscription;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining(TimeService().now);
    _subscription = TimeService().nowStream.listen((now) {
      if (mounted) {
        setState(() {
          _calculateRemaining(now);
        });
      }
    });
  }

  void _calculateRemaining(DateTime now) {
    if (now.isAfter(widget.endTime)) {
      _remaining = Duration.zero;
    } else {
      _remaining = widget.endTime.difference(now);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444), // Red
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            "$hours:$minutes:$seconds",
            style: GoogleFonts.robotoMono(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

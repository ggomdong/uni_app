import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uni_app/constants/sizes.dart';

class DateTimeDisplay extends StatefulWidget {
  const DateTimeDisplay({super.key});

  @override
  State<DateTimeDisplay> createState() => _DateTimeDisplayState();
}

class _DateTimeDisplayState extends State<DateTimeDisplay> {
  late Stream<DateTime> _dateTimeStream;

  @override
  void initState() {
    super.initState();
    _dateTimeStream = _getDateTimeStream();
  }

  Stream<DateTime> _getDateTimeStream() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1)); // 매초마다 업데이트
      yield DateTime.now();
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('yyy년 MM월 d일 HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _dateTimeStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            _formatTime(snapshot.data!),
            style: TextStyle(
              fontSize: Sizes.size20,
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

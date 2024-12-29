import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uni_app/constants/gaps.dart';
import 'package:uni_app/constants/sizes.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentDate = DateTime.now();
  Map<String, Map<String, String>> _attendanceData = {};

  static const Color primaryColor = Color.fromARGB(255, 2, 179, 187);
  static const Color sundayColor = Colors.red;
  static const Color checkInBackgroundColor = Colors.blueAccent;
  static const Color checkOutBackgroundColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _attendanceData = {
        '2024-12-01': {'checkIn': '09:00', 'checkOut': '18:00'},
        '2024-12-02': {'checkIn': '09:15', 'checkOut': '17:45'},
      };
    });
  }

  void _changeMonth(int months) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + months);
      _fetchAttendanceData();
    });
  }

  void _selectMonthAndYear(BuildContext context) async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = _currentDate.year;
        int selectedMonth = _currentDate.month;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('년월 선택'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() => selectedYear--),
                      ),
                      Text(
                        '$selectedYear년',
                        style: const TextStyle(
                            fontSize: Sizes.size16,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => setState(() => selectedYear++),
                      ),
                    ],
                  ),
                  Gaps.v10,
                  Wrap(
                    spacing: Sizes.size8,
                    runSpacing: Sizes.size8,
                    children: List.generate(12, (index) {
                      final month = index + 1;
                      return GestureDetector(
                        onTap: () => Navigator.pop(
                            context, DateTime(selectedYear, month)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: Sizes.size8, horizontal: Sizes.size16),
                          decoration: BoxDecoration(
                            color: month == selectedMonth
                                ? Colors.blueAccent
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(Sizes.size4),
                          ),
                          child: Text(
                            '$month월',
                            style: TextStyle(
                              color: month == selectedMonth
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _currentDate = selectedDate;
        _fetchAttendanceData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildMonthSelector(),
          _buildWeekDays(),
          Expanded(child: _buildCalendar()),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: Sizes.size12, horizontal: Sizes.size16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _changeMonth(-1),
          ),
          GestureDetector(
            onTap: () => _selectMonthAndYear(context),
            child: Text(
              '${_currentDate.year}년 ${_currentDate.month}월',
              style: const TextStyle(
                fontSize: Sizes.size16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    final weekDays = ['일', '월', '화', '수', '목', '금', '토'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: Sizes.size8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays
            .map((day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: day == '일' ? sundayColor : Colors.black54,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth =
        DateTime(_currentDate.year, _currentDate.month + 1, 0);

    final daysBefore = firstDayOfMonth.weekday % 7;
    // final daysAfter = 6 - lastDayOfMonth.weekday;
    // 마지막 날이 일요일인 경우 daysAfter가 음수가 되지 않도록 보정
    final daysAfter =
        lastDayOfMonth.weekday == 7 ? 6 : 6 - lastDayOfMonth.weekday;

    final totalDays = [
      ...List.generate(
          daysBefore,
          (index) => DateTime(_currentDate.year, _currentDate.month,
              -(daysBefore - index - 1))),
      ...List.generate(
          lastDayOfMonth.day,
          (index) =>
              DateTime(_currentDate.year, _currentDate.month, index + 1)),
      ...List.generate(
          daysAfter,
          (index) =>
              DateTime(_currentDate.year, _currentDate.month + 1, index + 1)),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0, // Increased box size to prevent overflow
      ),
      itemCount: totalDays.length,
      itemBuilder: (context, index) {
        final date = totalDays[index];
        final isCurrentMonth = date.month == _currentDate.month;
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        final attendance = _attendanceData[formattedDate];

        return Container(
          margin: const EdgeInsets.all(Sizes.size2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            color: isCurrentMonth
                ? (attendance != null ? Colors.blue[50] : Colors.white)
                : Colors.grey[200],
          ),
          child: Column(
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrentMonth
                      ? (date.weekday == DateTime.sunday
                          ? sundayColor
                          : Colors.black87)
                      : Colors.grey,
                ),
              ),
              if (isCurrentMonth && attendance != null) ...[
                Gaps.v4,
                Container(
                  color: checkInBackgroundColor,
                  child: Text(
                    '(출)${attendance['checkIn']}',
                    style: const TextStyle(
                        fontSize: Sizes.size10, color: Colors.white),
                  ),
                ),
                Container(
                  color: checkOutBackgroundColor,
                  child: Text(
                    '(퇴)${attendance['checkOut']}',
                    style: const TextStyle(
                        fontSize: Sizes.size10, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ver 1
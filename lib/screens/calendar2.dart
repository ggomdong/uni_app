import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, Map<String, String>> _attendanceData = {};

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData(_focusedDay);
  }

  Future<void> _fetchAttendanceData(DateTime focusedMonth) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _attendanceData = {
        '2024-12-01': {'checkIn': '09:00', 'checkOut': '18:00'},
        '2024-12-02': {'checkIn': '09:15', 'checkOut': '17:45'},
        '2024-12-03': {'checkIn': '09:30', 'checkOut': '18:30'},
      };
    });
  }

  void _showYearMonthPicker(BuildContext context) async {
    DateTime selectedDate = _focusedDay;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = selectedDate.year;
        int selectedMonth = selectedDate.month;

        return AlertDialog(
          title: const Text('년월 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        selectedYear--;
                      });
                    },
                  ),
                  Text('$selectedYear년'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      setState(() {
                        selectedYear++;
                      });
                    },
                  ),
                ],
              ),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: List.generate(12, (index) {
                  final month = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = DateTime(selectedYear, month);
                        _focusedDay = selectedDate;
                        Navigator.pop(context);
                        _fetchAttendanceData(selectedDate);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: month == selectedMonth
                            ? Colors.blueAccent
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        DateFormat.MMM('ko_KR').format(DateTime(0, month)),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('출퇴근 캘린더'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            _buildMonthSelector(),
            Expanded(
              child: TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedMonth) {
                  setState(() {
                    _focusedDay = focusedMonth;
                  });
                  _fetchAttendanceData(focusedMonth);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.red),
                  cellMargin: EdgeInsets.zero, // Disable default margin
                  cellPadding: const EdgeInsets.all(4), // Add padding for cells
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  decoration: BoxDecoration(color: Colors.transparent),
                  headerPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final formattedDate = DateFormat('yyyy-MM-dd').format(day);
                    final attendance = _attendanceData[formattedDate];

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black26), // Add border to each cell
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: day.weekday == DateTime.sunday
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                          if (attendance != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '(출)${attendance['checkIn']}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '(퇴)${attendance['checkOut']}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() {
            _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
            _fetchAttendanceData(_focusedDay);
          }),
        ),
        GestureDetector(
          onTap: () => _showYearMonthPicker(context),
          child: Text(
            DateFormat.yMMMM('ko_KR').format(_focusedDay),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => setState(() {
            _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
            _fetchAttendanceData(_focusedDay);
          }),
        ),
      ],
    );
  }
}

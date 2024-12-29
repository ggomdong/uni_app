import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uni_app/constants/sizes.dart';
import 'package:uni_app/services/api_service.dart';
import 'package:uni_app/widgets/datetime_display.dart';

class IBeaconScanner extends StatefulWidget {
  const IBeaconScanner({super.key});

  @override
  State<IBeaconScanner> createState() => _IBeaconScannerState();
}

class _IBeaconScannerState extends State<IBeaconScanner> {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();

  StreamSubscription<RangingResult>? _streamRanging;
  static const _noBeaconsFound = "비콘 신호 없음";
  String _beaconStatus = _noBeaconsFound;
  bool _isBeaconYn = false;

  final String _targetUUID =
      "B30B4025-BF21-41CD-85DA-9CE3BE7D67B6"; // iBeacon의 UUID
  final int _targetMajor = 40011;
  final int _targetMinor = 34479;

  @override
  void initState() {
    super.initState();
    _initializeBeacon();
  }

  Future<void> _initializeBeacon() async {
    await flutterBeacon.initializeScanning;

    // 권한 요청
    await requestPermissions();

    // Region을 정의
    final regions = [
      Region(
          identifier: 'MBeacon',
          proximityUUID: _targetUUID,
          major: _targetMajor,
          minor: _targetMinor)
    ];

    // 스캔 시작
    _streamRanging = flutterBeacon.ranging(regions).listen((result) {
      if (result.beacons.isNotEmpty) {
        final beacon = result.beacons.first;
        setState(() {
          _beaconStatus =
              'UUID: ${beacon.proximityUUID}\nMajor: ${beacon.major}\nMinor: ${beacon.minor}\nDistance: ${beacon.accuracy.toStringAsFixed(2)}m';
          _isBeaconYn = true;
        });
      } else {
        setState(() {
          _beaconStatus = _noBeaconsFound;
          _isBeaconYn = false;
        });
      }
    });
  }

  // 권한 요청 함수
  Future<void> requestPermissions() async {
    // 위치 권한 상태 확인
    var locationStatus = await Permission.location.status;
    var bluetoothScanStatus = await Permission.bluetoothScan.status;

    // 위치 권한 요청
    if (locationStatus.isDenied || locationStatus.isRestricted) {
      locationStatus = await Permission.location.request();
    }

    // Bluetooth 스캔 권한 요청 (Android 12+)
    if (bluetoothScanStatus.isDenied || bluetoothScanStatus.isRestricted) {
      bluetoothScanStatus = await Permission.bluetoothScan.request();
    }

    // 권한 상태 출력
    if (locationStatus.isGranted && bluetoothScanStatus.isGranted) {
      _logger.d("모든 권한 승인됨");
    } else if (locationStatus.isPermanentlyDenied ||
        bluetoothScanStatus.isPermanentlyDenied) {
      _logger.d("권한이 영구적으로 거부되었습니다. 설정에서 직접 변경해야 합니다.");
      // await openAppSettings(); // 앱 설정 화면으로 이동
    } else {
      _logger.d("권한이 거부되었습니다.");
    }
  }

  // 출근 등록
  void _onTapWorkRecord() async {
    Future<dynamic> response = await _apiService.workRecord();
    _logger.d(response);
  }

  @override
  void dispose() {
    _streamRanging?.cancel();
    super.dispose();
  }

  FutureBuilder<dynamic> getMe() {
    return FutureBuilder(
      future: _apiService.getMe(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('알 수 없는 오류가 발생했습니다.');
        } else if (snapshot.hasData) {
          return Text("${snapshot.data["dept"]} ${snapshot.data["emp_name"]}");
        } else {
          return Text('사용자 정보가 없습니다.');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 50,
            child: DateTimeDisplay(),
          ),
          Positioned(
            top: 100,
            child: getMe(),
          ),
          Center(
            child: GestureDetector(
              onTap: _isBeaconYn ? _onTapWorkRecord : null,
              child: Container(
                height: Sizes.size96 + Sizes.size52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isBeaconYn
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade500,
                ),
                child: Center(
                  child: Text(
                    _isBeaconYn ? "출근" : _noBeaconsFound,
                    style: TextStyle(
                      fontSize: Sizes.size16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

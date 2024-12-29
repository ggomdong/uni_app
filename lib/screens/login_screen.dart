import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uni_app/constants/gaps.dart';
import 'package:uni_app/constants/sizes.dart';
import 'package:uni_app/services/api_service.dart';
import 'package:uni_app/widgets/form_button.dart';
import 'package:uni_app/widgets/util.dart';
import 'package:uni_app/widgets/snackbar.dart';
import 'package:uni_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final String logo = 'assets/images/logo_transparent.png';

  final TextEditingController _idController =
      TextEditingController(text: '010-');
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _enteredId = '';
  var _enteredPassword = '';
  bool _obscureText = true;

  bool _isLoading = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _idController.addListener(() {
      setState(() {
        _enteredId = _idController.text;
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _enteredPassword = _passwordController.text;
      });
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Keyboard 외의 영역 클릭시 Keyboard가 사라지도록 처리
  void _onScaffoldTap() {
    FocusScope.of(context).unfocus();
  }

  void _onClearTap() {
    _passwordController.clear();
  }

  void _toggleObscureText() {
    _obscureText = !_obscureText;
    setState(() {});
  }

  // ID, PW 의 입력 조건 충족 여부 확인 -> submit과 FormButton 활성화 여부 결정
  bool _isInputValueValid() {
    return _enteredId.isNotEmpty && _enteredPassword.length > 3;
  }

  void _submit() async {
    if (!_isInputValueValid()) return;

    // 폼 입력 값 validation 체크, 유효하지 않으면 중단
    if (_formKey.currentState != null) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    _formKey.currentState!.save();

    // 로딩중
    setState(() {
      _isLoading = true;
    });

    // 로그인 및 사용자 정보 수신
    final success = await _apiService.login(_enteredId, _enteredPassword);

    // 로딩 종료
    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (!mounted) return;
      showSnackBar(
        context,
        '로그인 되었습니다.',
        Theme.of(context).colorScheme.primary,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      showSnackBar(
        context,
        'ID 또는 비밀번호를 확인해 주세요.',
        Theme.of(context).colorScheme.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onScaffoldTap,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Gaps.v96,
                Center(
                  child: Image.asset(
                    logo,
                    width: 186,
                    height: 70,
                    alignment: Alignment.center,
                  ),
                ),
                Gaps.v52,
                TextFormField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                    PhoneInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'ID (휴대폰 번호)',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        value.trim().length != 13) {
                      return 'ID를 정확히 입력해주세요.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      _enteredId = value.replaceAll('-', '');
                    }
                  },
                ),
                Gaps.v10,
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _onClearTap,
                          child: FaIcon(
                            FontAwesomeIcons.solidCircleXmark,
                            color: Colors.grey.shade500,
                            size: Sizes.size20,
                          ),
                        ),
                        Gaps.h16,
                        GestureDetector(
                          onTap: _toggleObscureText,
                          child: FaIcon(
                            _obscureText
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash,
                            color: Colors.grey.shade500,
                            size: Sizes.size20,
                          ),
                        ),
                      ],
                    ),
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: Sizes.size2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password를 입력해주세요.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      _enteredPassword = value;
                    }
                  },
                  onEditingComplete: _submit,
                ),
                Gaps.v32,
                _isLoading
                    ? CircularProgressIndicator()
                    : GestureDetector(
                        onTap: _submit,
                        child: FormButton(
                          disabled: !_isInputValueValid(),
                          text: "로그인",
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

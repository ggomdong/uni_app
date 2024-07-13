import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_app/classes/util.dart';
import 'package:uni_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.logo,
  });

  final String logo;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController =
      TextEditingController(text: '010-');

  final _form = GlobalKey<FormState>();

  var _enteredId = '';
  var _enteredPassword = '';

  // void login(BuildContext context) {
  void _submit() {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    try {
      print(_enteredId);
      print(_enteredPassword);
    } on Exception catch (error) {
      if (1 == 2) {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString() ?? '로그인에 실패하였습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              Center(
                child: Image.asset(
                  widget.logo,
                  width: 133,
                  height: 50,
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              TextFormField(
                controller: _idController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  // NumberFormatter(),
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
                  _enteredId = value!.replaceAll('-', '');
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
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
                  _enteredPassword = value!;
                },
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                // onPressed: () {
                //   login(context);
                // },
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary, // #02b3bb
                  minimumSize: const Size(400, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

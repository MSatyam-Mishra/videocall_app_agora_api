import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videocall_app_agora_api/constants/design_elements.dart';
import 'package:videocall_app_agora_api/pages/video_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _channelController = TextEditingController();
  bool _validateError = false;
  ClientRole? _role = ClientRole.Broadcaster;
  bool isDark = false;
  Icon appBarIcon = Icon(Icons.sunny);
  Color bgColor = bgColor1;
  Color textColor = textColor1;
  @override
  void dispose() {
    // TODO: implement dispose
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "Video Calling App",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isDark = !isDark;

                if (isDark == true) {
                  appBarIcon = Icon(Icons.dark_mode);
                  bgColor = bgColor2;
                  textColor = textColor2;
                } else if (isDark == false) {
                  appBarIcon = appBarIcon = Icon(Icons.sunny);
                  bgColor = bgColor1;
                  textColor = textColor1;
                }
              });
            },
            icon: appBarIcon,
            color: textColor,
          )
        ],
      ),
      body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Image.asset(
                    "assets/images/image-1.png",
                    color: isDark == true ? Colors.black45 : null,
                    colorBlendMode: BlendMode.darken,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    style: TextStyle(color: textColor),
                    controller: _channelController,
                    decoration: InputDecoration(
                        errorText:
                            _validateError ? "channel name is empty" : null,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 0.5,
                            color: bgColor,
                          ),
                        ),
                        hintStyle: TextStyle(color: textColor),
                        hintText: "Enter Channel Name"),
                  ),
                  RadioListTile(
                    title: Text(
                      "Brodcaster",
                      style: TextStyle(color: textColor),
                    ),
                    onChanged: (ClientRole? value) {
                      setState(() {
                        _role = value;
                      });
                    },
                    value: ClientRole.Broadcaster,
                    activeColor: textColor,
                    groupValue: _role,
                  ),
                  RadioListTile(
                    activeColor: textColor,
                    title: Text(
                      "Audience",
                      style: TextStyle(color: textColor),
                    ),
                    onChanged: (ClientRole? value) {
                      setState(() {
                        _role = value;
                      });
                    },
                    value: ClientRole.Audience,
                    groupValue: _role,
                  ),
                  ElevatedButton(
                    onPressed: onJoin,
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        backgroundColor: textColor,
                        foregroundColor: bgColor),
                    child: const Text(
                      "Join Now",
                    ),
                  )
                ],
              ))),
    );
  }

  Future<void> onJoin() async {
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VideoScreen(
                  channelName: _channelController.text, role: _role)));
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    log(status.toString());
  }
}

import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videocall_app_agora_api/constants/design_elements.dart';
import 'package:videocall_app_agora_api/pages/call.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final _channelController = TextEditingController();
  bool _validateError = false;
  ClientRole? _role = ClientRole.Broadcaster;
  @override
  void dispose() {
    // TODO: implement dispose
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Video Calling App",
          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Image.asset("assets/images/image-1.png"),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _channelController,
                    decoration: InputDecoration(
                        errorText:
                            _validateError ? "channel name is empty" : null,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.blue,
                          ),
                        ),
                        hintText: "Channel Name"),
                  ),
                  RadioListTile(
                    title: Text("Brodcaster"),
                    onChanged: (ClientRole? value) {
                      setState(() {
                        _role = value;
                      });
                    },
                    value: ClientRole.Broadcaster,
                    groupValue: _role,
                  ),
                  RadioListTile(
                    title: Text("Audience"),
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
                    child: Text(
                      "Join Now",
                    ),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white),
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
              builder: (context) =>
                  CallPage(channelName: _channelController.text, role: _role)));
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    log(status.toString());
  }
}

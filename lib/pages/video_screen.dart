import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../constants/design_elements.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;

class CallPage extends StatefulWidget {
  const CallPage({super.key, required this.channelName, required this.role});
  final String channelName;
  final ClientRole? role;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoString = <String>[];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine _engine;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Future<void> initialize() async {
    if (appID.isEmpty) {
      setState(() {
        _infoString
            .add('App_ID missing, please provide your APP_ID in settings.dart');
        _infoString.add('Agora Engine is not starting');
      });
      return;
    }
    //initialize agora engine
    _engine = await RtcEngine.create(appID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);

    //add Agora event handler

    _addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(token, widget.channelName, null, 0);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(
      RtcEngineEventHandler(error: (code) {
        setState(() {
          final info = 'Error:$code';
          _infoString.add(info);
        });
      }, joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'Join Channel: $channel, uid:$uid, ';
          _infoString.add(info);
        });
      }, leaveChannel: (stats) {
        setState(() {
          _infoString.add('Leave Channel');
          _users.clear();
        });
      }, userJoined: (uid, elapsed) {
        setState(() {
          final info = 'User Joined: $uid';
          _infoString.add(info);
          _users.add(uid);
        });
      }, userOffline: (uid, elapsed) {
        setState(() {
          final info = 'User Offline: $uid';
          _infoString.add(info);
          _users.remove(uid);
        });
      }, firstRemoteVideoFrame: ((uid, width, height, elapsed) {
        setState(() {
          final info = 'First Remote Video: $uid $width* $height';
          _infoString.add(info);
        });
      })),
    );
  }

  Widget _viewRows() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(rtc_local_view.SurfaceView());
    }
    for (var uid in _users) {
      list.add(
          rtc_remote_view.SurfaceView(uid: uid, channelId: widget.channelName));
    }
    final views = list;
    return Column(
        children: List.generate(
            views.length, (index) => Expanded(child: views[index])));
  }

  Widget _toolBar() {
    if (widget.role == ClientRole.Audience) return SizedBox();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        RawMaterialButton(
          onPressed: () {
            setState(() {
              muted = !muted;
            });
            _engine.muteLocalAudioStream(muted);
          },
          child: Icon(muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : themeColor, size: 20),
          shape: CircleBorder(),
          elevation: 2,
          fillColor: muted ? themeColor : Colors.white,
          padding: EdgeInsets.all(12),
        ),
        RawMaterialButton(
          onPressed: () => Navigator.pop(context),
          child: Icon(
            Icons.call_end,
            color: Colors.white,
            size: 35,
          ),
          shape: CircleBorder(),
          elevation: 2,
          fillColor: Colors.redAccent,
          padding: EdgeInsets.all(15),
        ),
        RawMaterialButton(
          onPressed: () {
            _engine.switchCamera();
          },
          child: Icon(
            Icons.switch_camera,
            color: themeColor,
            size: 20,
          ),
          shape: CircleBorder(),
          elevation: 2,
          fillColor: Colors.white,
          padding: EdgeInsets.all(12),
        )
      ]),
    );
  }

  Widget _panel() {
    return Visibility(
      visible: viewPanel,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: ListView.builder(
              reverse: true,
              itemCount: _infoString.length,
              itemBuilder: (context, index) {
                if (_infoString.isEmpty) {
                  return const Text("null");
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                          child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          _infoString[index],
                          style: TextStyle(color: themeColor),
                        ),
                      ))
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
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
        actions: [
          IconButton(
              onPressed: () {
                setState(
                  () {
                    viewPanel = !viewPanel;
                  },
                );
              },
              icon: Icon(Icons.info_outline))
        ],
      ),
      body: Center(
        child: Stack(
          children: [_viewRows(), _panel(), _toolBar()],
        ),
      ),
    );
  }
}

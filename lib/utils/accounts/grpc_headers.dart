import 'dart:convert';

import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/grpc/bilibili/metadata.pb.dart';
import 'package:PiliPlus/grpc/bilibili/metadata/device.pb.dart';
import 'package:PiliPlus/grpc/bilibili/metadata/fawkes.pb.dart';
import 'package:PiliPlus/grpc/bilibili/metadata/locale.pb.dart';
import 'package:PiliPlus/grpc/bilibili/metadata/network.pb.dart' as network;
import 'package:PiliPlus/utils/login_utils.dart';
import 'package:PiliPlus/utils/utils.dart';

/// gRPC 请求伪装的客户端身份
enum GrpcClient {
  hd('android_hd', 2001100, '2.0.1'),

  /// 谷歌Play版（哔哩漫游X「无限试用会员画质」所在客户端）
  play('android_i', 7750600, '3.19.2');

  final String mobiApp;
  final int build;
  final String versionName;

  const GrpcClient(this.mobiApp, this.build, this.versionName);
}

abstract final class GrpcHeaders {
  /// RequestOptions.extra 中指定 [GrpcClient] 的键
  static const clientKey = 'grpcClient';

  static const _biliChannel = 'master';
  static const _device = 'android';

  static String get _buvid => LoginUtils.buvid;
  static String get _traceId => Constants.traceId;
  static String get _sessionId => Utils.generateRandomString(8);

  static String _userAgent(GrpcClient client) => client == GrpcClient.hd
      ? Constants.userAgent
      : 'Mozilla/5.0 BiliDroid/${client.versionName} (bbcallen@gmail.com) '
            'os/android model/${client.mobiApp} mobi_app/${client.mobiApp} '
            'build/${client.build} channel/$_biliChannel '
            'innerVer/${client.build} osVer/15 network/2';

  static String _deviceBin(GrpcClient client) => base64Encode(
    Device(
      appId: 5,
      build: client.build,
      buvid: _buvid,
      mobiApp: client.mobiApp,
      platform: _device,
      channel: _biliChannel,
      brand: _device,
      model: _device,
      osver: '15',
      versionName: client.versionName,
    ).writeToBuffer(),
  );

  static final Map<String, String> _base = {
    'grpc-encoding': 'gzip',
    'gzip-accept-encoding': 'gzip,identity',
    'x-bili-gaia-vtoken': '',
    'x-bili-aurora-zone': '',
    'x-bili-trace-id': _traceId,
    'buvid': _buvid,
    'bili-http-engine': 'cronet',
    // 'te': 'trailers', // dio not supported
    'x-bili-network-bin': base64Encode(
      network.Network(type: network.NetworkType.WIFI).writeToBuffer(),
    ),
    'x-bili-locale-bin': base64Encode(
      Locale(
        cLocale: LocaleIds(language: 'zh', region: 'CN', script: 'Hans'),
        sLocale: LocaleIds(language: 'zh', region: 'CN', script: 'Hans'),
        timezone: 'Asia/Shanghai',
      ).writeToBuffer(),
    ),
    'x-bili-exps-bin': '',
  };

  static String get fawkes => _fawkes(GrpcClient.hd);

  static String _fawkes(GrpcClient client) => base64Encode(
    FawkesReq(
      appkey: client.mobiApp,
      env: 'prod',
      sessionId: _sessionId,
    ).writeToBuffer(),
  );

  static Map<String, String> newHeaders([
    String? accessKey,
    GrpcClient client = GrpcClient.hd,
  ]) {
    return {
      ..._base,
      'user-agent': _userAgent(client),
      'x-bili-device-bin': _deviceBin(client),
      if (accessKey != null) 'authorization': 'identify_v1 $accessKey',
      'x-bili-fawkes-req-bin': _fawkes(client),
      'x-bili-metadata-bin': base64Encode(
        Metadata(
          accessKey: accessKey,
          mobiApp: client.mobiApp,
          device: _device,
          build: client.build,
          channel: _biliChannel,
          buvid: _buvid,
          platform: _device,
        ).writeToBuffer(),
      ),
    };
  }
}

import 'package:PiliPlus/grpc/bilibili/app/playerunite/v1.pb.dart';
import 'package:PiliPlus/grpc/bilibili/playershared.pb.dart' show VideoVod;
import 'package:PiliPlus/grpc/grpc_req.dart';
import 'package:PiliPlus/grpc/url.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:PiliPlus/utils/accounts/grpc_headers.dart';
import 'package:fixnum/fixnum.dart';

/// 会员画质试用流及同来源（App端）音频
typedef TrialStreams = ({List<VideoItem> videos, List<AudioItem> audios});

abstract final class PlayUrlGrpc {
  /// App端 PlayViewUnite 以试用模式（is_need_trial）请求，非会员也会下发
  /// 可试用的会员画质流（need_vip=true），客户端忽略 need_vip 即可直接播放
  /// （同哔哩漫游X「无限试用会员画质」）
  static Future<LoadingState<TrialStreams>> vipTrialStreams({
    required int aid,
    required int cid,
    required String bvid,
    required int qn,
  }) async {
    final res = await GrpcReq.request(
      GrpcUrl.playViewUnite,
      PlayViewUniteReq(
        vod: VideoVod(
          aid: Int64(aid),
          cid: Int64(cid),
          qn: Int64(qn),
          fnver: 0,
          fnval: 4048,
          fourk: true,
          forceHost: 2,
          isNeedTrial: true,
        ),
        bvid: bvid,
      ),
      PlayViewUniteReply.fromBuffer,
      // 试用画质仅对官方新版客户端下发，伪装为哔哩漫游X所在的谷歌Play版
      client: GrpcClient.play,
    );
    if (res case Success(:final response)) {
      final videos = _toVideoItems(response);
      if (videos.isEmpty) {
        // 附带试用资格信息，便于判断是账号无试用资格还是请求方式问题
        final trial = response.qnTrialInfo;
        return Error(
          '服务器未下发会员画质试用流'
          '${response.hasQnTrialInfo() ? '（可试用:${trial.trialAble} 剩余次数:${trial.remainingTimes}）' : '（无试用信息）'}',
        );
      }
      return Success((videos: videos, audios: _toAudioItems(response)));
    }
    return res as Error;
  }

  static final _audioCodes = {for (final i in AudioQuality.values) i.code};

  static List<AudioItem> _toAudioItems(PlayViewUniteReply reply) {
    final list = <AudioItem>[];
    for (final dash in reply.vodInfo.dashAudio) {
      if (dash.baseUrl.isEmpty || !_audioCodes.contains(dash.id)) continue;
      list.add(
        AudioItem(
            id: dash.id,
            baseUrl: dash.baseUrl,
            backupUrl: dash.backupUrl.toList(),
            bandWidth: dash.bandwidth,
            codecs: 'mp4a.40.2',
            codecid: dash.codecid,
          )
          ..fromApp = true,
      );
    }
    return list;
  }

  static List<VideoItem> _toVideoItems(PlayViewUniteReply reply) {
    final list = <VideoItem>[];
    for (final stream in reply.vodInfo.streamList) {
      final quality = stream.streamInfo.quality;
      // 仅取会员画质，且必须真正下发了dash地址
      if (!VideoQuality.vipCodes.contains(quality) || !stream.hasDashVideo()) {
        continue;
      }
      final dash = stream.dashVideo;
      // 跳过空地址与DRM加密流（播放器无法解密）
      if (dash.baseUrl.isEmpty ||
          dash.bilidrmUri.isNotEmpty ||
          dash.widevinePssh.isNotEmpty) {
        continue;
      }
      list.add(
        VideoItem(
          id: quality,
          baseUrl: dash.baseUrl,
          backupUrl: dash.backupUrl.toList(),
          bandWidth: dash.bandwidth,
          codecs: _codecs(quality, dash.codecid),
          width: dash.width,
          height: dash.height,
          frameRate: dash.frameRate,
          codecid: dash.codecid,
          quality: VideoQuality.fromCode(quality),
        )..fromApp = true,
      );
    }
    return list;
  }

  /// App端只返回codecid，转换为web端codecs前缀以复用现有解码格式选择
  static String _codecs(int quality, int codecid) {
    if (quality == VideoQuality.dolbyVision.code) return 'dvh1.08.07';
    return switch (codecid) {
      12 => 'hev1.1.6.L150.90',
      13 => 'av01.0.13M.08.0.110.01.01.01.0',
      _ => 'avc1.640032',
    };
  }
}

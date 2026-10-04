import 'package:PiliPlus/grpc/bilibili/app/playurl/v1.pb.dart' as playurl;
import 'package:PiliPlus/grpc/grpc_req.dart';
import 'package:PiliPlus/grpc/url.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:fixnum/fixnum.dart';

abstract final class PlayUrlGrpc {
  /// App端播放地址：非会员也会下发可试用的会员画质流（need_vip=true），
  /// 客户端忽略 need_vip 即可直接播放（同哔哩漫游X「无限试用会员画质」）
  static Future<LoadingState<List<VideoItem>>> vipTrialVideos({
    required int aid,
    required int cid,
    required int qn,
  }) async {
    final res = await GrpcReq.request(
      GrpcUrl.playView,
      playurl.PlayViewReq(
        aid: Int64(aid),
        cid: Int64(cid),
        qn: Int64(qn),
        fnver: 0,
        fnval: 4048,
        fourk: true,
        forceHost: 2,
      ),
      playurl.PlayViewReply.fromBuffer,
    );
    if (res case Success(:final response)) {
      return Success(_toVideoItems(response));
    }
    return res as Error;
  }

  static List<VideoItem> _toVideoItems(playurl.PlayViewReply reply) {
    final list = <VideoItem>[];
    for (final stream in reply.videoInfo.streamList) {
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
        ),
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

import 'package:PiliPlus/grpc/bilibili/app/playurl/v1.pb.dart';
import 'package:PiliPlus/grpc/grpc_req.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:fixnum/fixnum.dart' show Int64;

abstract final class GrpcVideo {
  static const _playViewUrl = '/bilibili.app.playurl.v1.PlayURL/PlayView';

  /// gRPC playurl + BiliRoamingX 相同逻辑: needVip=false, vipFree=true
  static Future<LoadingState<PlayUrlModel>> playUrl({
    required int aid,
    required int cid,
    required int qn,
  }) async {
    final req = PlayViewReq(
      aid: Int64(aid),
      cid: Int64(cid),
      qn: Int64(qn),
      fnval: 4048,
      fnver: 0,
      fourk: true,
      forceHost: 2,
    );

    final result = await GrpcReq.request(
      _playViewUrl,
      req,
      PlayViewReply.fromBuffer,
    );

    if (result case Success(:final response)) {
      _makeVipFree(response);
      final model = _toPlayUrlModel(response);
      return Success(model);
    }
    return result as Error;
  }

  /// 与 BiliRoamingX TrialQualityPatch.makeVipFree() 相同逻辑
  static void _makeVipFree(PlayViewReply reply) {
    reply.clearAb();
    for (final stream in reply.videoInfo.streamList) {
      if (!stream.hasDashVideo()) continue;
      if (stream.streamInfo.needVip) {
        stream.streamInfo.needVip = false;
        stream.streamInfo.vipFree = true;
      }
    }
  }

  /// protobuf PlayViewReply → PlayUrlModel
  static PlayUrlModel _toPlayUrlModel(PlayViewReply reply) {
    final videoInfo = reply.videoInfo;
    final videoItems = <VideoItem>[];
    final audioItems = <AudioItem>[];

    for (final stream in videoInfo.streamList) {
      if (!stream.hasDashVideo()) continue;
      final dash = stream.dashVideo;
      final info = stream.streamInfo;
      final quality = VideoQuality.fromCode(info.quality);

      // 视频流 (width > 0 表示视频)
      if (dash.width > 0) {
        videoItems.add(VideoItem(
          id: info.quality,
          baseUrl: dash.baseUrl,
          backupUrl: dash.backupUrl,
          bandWidth: dash.bandwidth,
          codecs: info.format,
          width: dash.width,
          height: dash.height,
          frameRate: dash.frameRate,
          codecid: dash.codecid,
          quality: quality,
        ));
      }

      // 音频流 (只取第一个)
      if (dash.hasAudioId() && audioItems.isEmpty) {
        audioItems.add(AudioItem()
          ..id = dash.audioId
          ..baseUrl = dash.baseUrl
          ..backupUrl = dash.backupUrl
          ..bandWidth = dash.bandwidth
          ..codecs = info.format);
      }
    }

    if (videoItems.isEmpty) {
      return PlayUrlModel(quality: 0);
    }

    final frameRate = videoItems.first.frameRate;
    return PlayUrlModel(
      quality: videoItems.first.quality.code,
      timeLength: (videoInfo.timelength * 1000).toInt(),
      dash: Dash()
        ..video = videoItems
        ..audio = audioItems.isEmpty ? null : audioItems,
      acceptQuality: videoItems.map((v) => v.id).whereType<int>().toSet().toList(),
      acceptDesc: videoItems.map((v) => v.quality.desc).toList(),
      supportFormats: [
        for (final v in videoItems)
          FormatItem(
            quality: v.id,
            format: frameRate ?? '',
            newDesc: v.quality.desc,
            codecs: [frameRate ?? ''],
          ),
      ],
    );
  }
}

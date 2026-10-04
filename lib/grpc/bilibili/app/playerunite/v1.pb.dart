// Hand-written subset of bilibili/app/playerunite/v1.proto (not generated).
// Field numbers follow PlayViewUniteReq / PlayViewUniteReply in the official
// Android client; only the fields used by PiliPlus are declared, the others
// are kept as unknown fields.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../playershared.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class PlayViewUniteReq extends $pb.GeneratedMessage {
  factory PlayViewUniteReq({
    $0.VideoVod? vod,
    $core.String? spmid,
    $core.String? fromSpmid,
    $core.String? bvid,
  }) {
    final result = PlayViewUniteReq._();
    if (vod != null) result.vod = vod;
    if (spmid != null) result.spmid = spmid;
    if (fromSpmid != null) result.fromSpmid = fromSpmid;
    if (bvid != null) result.bvid = bvid;
    return result;
  }

  PlayViewUniteReq._();

  factory PlayViewUniteReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlayViewUniteReq()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PlayViewUniteReq',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'bilibili.app.playerunite.v1'),
      createEmptyInstance: PlayViewUniteReq.$_createMessage)
    ..aOM<$0.VideoVod>(1, _omitFieldNames ? '' : 'vod',
        subBuilder: $0.VideoVod.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'spmid')
    ..aOS(3, _omitFieldNames ? '' : 'fromSpmid')
    ..aOS(5, _omitFieldNames ? '' : 'bvid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlayViewUniteReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlayViewUniteReq copyWith(void Function(PlayViewUniteReq) updates) =>
      super.copyWith((message) => updates(message as PlayViewUniteReq))
          as PlayViewUniteReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlayViewUniteReq create() => PlayViewUniteReq._();
  static $pb.GeneratedMessage $_createMessage() => PlayViewUniteReq._();
  @$core.override
  PlayViewUniteReq createEmptyInstance() => PlayViewUniteReq._();
  @$core.pragma('dart2js:noInline')
  static PlayViewUniteReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlayViewUniteReq>(
          PlayViewUniteReq.$_createMessage);
  static PlayViewUniteReq? _defaultInstance;

  @$pb.TagNumber(1)
  $0.VideoVod get vod => $_getN(0);
  @$pb.TagNumber(1)
  set vod($0.VideoVod value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasVod() => $_has(0);

  @$pb.TagNumber(2)
  $core.String get spmid => $_getSZ(1);
  @$pb.TagNumber(2)
  set spmid($core.String value) => $_setString(1, value);

  @$pb.TagNumber(3)
  $core.String get fromSpmid => $_getSZ(2);
  @$pb.TagNumber(3)
  set fromSpmid($core.String value) => $_setString(2, value);

  @$pb.TagNumber(5)
  $core.String get bvid => $_getSZ(3);
  @$pb.TagNumber(5)
  set bvid($core.String value) => $_setString(3, value);
}

class PlayViewUniteReply extends $pb.GeneratedMessage {
  factory PlayViewUniteReply({
    $0.VodInfo? vodInfo,
    $0.QnTrialInfo? qnTrialInfo,
  }) {
    final result = PlayViewUniteReply._();
    if (vodInfo != null) result.vodInfo = vodInfo;
    if (qnTrialInfo != null) result.qnTrialInfo = qnTrialInfo;
    return result;
  }

  PlayViewUniteReply._();

  factory PlayViewUniteReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlayViewUniteReply()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PlayViewUniteReply',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'bilibili.app.playerunite.v1'),
      createEmptyInstance: PlayViewUniteReply.$_createMessage)
    ..aOM<$0.VodInfo>(1, _omitFieldNames ? '' : 'vodInfo',
        subBuilder: $0.VodInfo.$_createMessage)
    ..aOM<$0.QnTrialInfo>(7, _omitFieldNames ? '' : 'qnTrialInfo',
        subBuilder: $0.QnTrialInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlayViewUniteReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlayViewUniteReply copyWith(void Function(PlayViewUniteReply) updates) =>
      super.copyWith((message) => updates(message as PlayViewUniteReply))
          as PlayViewUniteReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlayViewUniteReply create() => PlayViewUniteReply._();
  static $pb.GeneratedMessage $_createMessage() => PlayViewUniteReply._();
  @$core.override
  PlayViewUniteReply createEmptyInstance() => PlayViewUniteReply._();
  @$core.pragma('dart2js:noInline')
  static PlayViewUniteReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlayViewUniteReply>(
          PlayViewUniteReply.$_createMessage);
  static PlayViewUniteReply? _defaultInstance;

  @$pb.TagNumber(1)
  $0.VodInfo get vodInfo => $_getN(0);
  @$pb.TagNumber(1)
  set vodInfo($0.VodInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasVodInfo() => $_has(0);

  @$pb.TagNumber(7)
  $0.QnTrialInfo get qnTrialInfo => $_getN(1);
  @$pb.TagNumber(7)
  set qnTrialInfo($0.QnTrialInfo value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasQnTrialInfo() => $_has(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');

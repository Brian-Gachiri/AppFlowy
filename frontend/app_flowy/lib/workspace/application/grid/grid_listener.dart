import 'package:dartz/dartz.dart';
import 'package:flowy_sdk/protobuf/flowy-grid-data-model/grid.pb.dart';
import 'package:flowy_sdk/protobuf/flowy-error/errors.pb.dart';
import 'package:flowy_sdk/protobuf/flowy-grid/dart_notification.pb.dart';
import 'package:flowy_infra/notifier.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:app_flowy/core/notification_helper.dart';

class GridRowListener {
  final String gridId;
  PublishNotifier<Either<List<GridRowsChangeset>, FlowyError>> rowsUpdateNotifier = PublishNotifier(comparable: null);
  GridNotificationListener? _listener;

  GridRowListener({required this.gridId});

  void start() {
    _listener = GridNotificationListener(
      objectId: gridId,
      handler: _handler,
    );
  }

  void _handler(GridNotification ty, Either<Uint8List, FlowyError> result) {
    switch (ty) {
      case GridNotification.DidUpdateGridRow:
        result.fold(
          (payload) => rowsUpdateNotifier.value = left([GridRowsChangeset.fromBuffer(payload)]),
          (error) => rowsUpdateNotifier.value = right(error),
        );
        break;

      default:
        break;
    }
  }

  Future<void> stop() async {
    await _listener?.stop();
    rowsUpdateNotifier.dispose();
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:bazar/features/sensor/domain/entities/motion_reading.dart';
import 'package:bazar/features/sensor/domain/usecases/sensor_usecases.dart';
import 'package:bazar/features/sensor/presentation/state/sensor_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sensorViewModelProvider = NotifierProvider<SensorViewModel, SensorState>(
  SensorViewModel.new,
);

class SensorViewModel extends Notifier<SensorState> {
  static const double _gravity = 9.81;
  static const double _shakeGForceThreshold = 2.2;
  static const double _movementDeltaThreshold = 1.2;
  static const int _requiredShakeHits = 2;
  static const Duration _shakeWindow = Duration(milliseconds: 700);
  static const Duration _shakeCooldown = Duration(seconds: 2);
  static const Duration _movementDecay = Duration(seconds: 3);

  late final WatchMotionUsecase _watchMotionUsecase;
  late final WatchHeadingUsecase _watchHeadingUsecase;

  StreamSubscription? _motionSubscription;
  StreamSubscription? _headingSubscription;
  Timer? _movementTimer;
  DateTime? _lastShakeTriggeredAt;
  DateTime? _shakeWindowStartAt;
  int _shakeHitCount = 0;
  int _activeClients = 0;

  @override
  SensorState build() {
    _watchMotionUsecase = ref.read(watchMotionUsecaseProvider);
    _watchHeadingUsecase = ref.read(watchHeadingUsecaseProvider);
    ref.onDispose(_disposeAll);
    return const SensorState();
  }

  void attach() {
    _activeClients += 1;
    if (state.isActive) return;
    _startStreams();
  }

  void detach() {
    _activeClients = math.max(0, _activeClients - 1);
    if (_activeClients > 0) return;
    _disposeStreams();
    state = state.copyWith(isActive: false, isMoving: false);
  }

  void _startStreams() {
    _disposeStreams();
    _motionSubscription = _watchMotionUsecase().listen(_onMotion);
    _headingSubscription = _watchHeadingUsecase().listen((reading) {
      state = state.copyWith(headingDegrees: reading.degrees);
    });
    state = state.copyWith(isActive: true);
  }

  void _onMotion(MotionReading reading) {
    final delta = (reading.magnitude - _gravity).abs();
    final gForce = reading.magnitude / _gravity;
    final now = DateTime.now();

    if (delta >= _movementDeltaThreshold) {
      _markMoving();
    }

    if (gForce < _shakeGForceThreshold) {
      if (_shakeWindowStartAt != null &&
          now.difference(_shakeWindowStartAt!) > _shakeWindow) {
        _resetShakeWindow();
      }
      return;
    }

    if (_lastShakeTriggeredAt != null &&
        now.difference(_lastShakeTriggeredAt!) < _shakeCooldown) {
      return;
    }

    if (_shakeWindowStartAt == null ||
        now.difference(_shakeWindowStartAt!) > _shakeWindow) {
      _shakeWindowStartAt = now;
      _shakeHitCount = 1;
      return;
    }

    _shakeHitCount += 1;
    if (_shakeHitCount < _requiredShakeHits) return;

    _lastShakeTriggeredAt = now;
    _resetShakeWindow();
    state = state.copyWith(
      lastShakeAt: now,
      shakeCount: state.shakeCount + 1,
      isMoving: true,
    );
    _scheduleMovementDecay();
  }

  void _markMoving() {
    if (!state.isMoving) {
      state = state.copyWith(isMoving: true);
    }
    _scheduleMovementDecay();
  }

  void _scheduleMovementDecay() {
    _movementTimer?.cancel();
    _movementTimer = Timer(_movementDecay, () {
      state = state.copyWith(isMoving: false);
    });
  }

  void _disposeStreams() {
    _motionSubscription?.cancel();
    _headingSubscription?.cancel();
    _movementTimer?.cancel();
    _motionSubscription = null;
    _headingSubscription = null;
    _movementTimer = null;
    _resetShakeWindow();
  }

  void _disposeAll() {
    _activeClients = 0;
    _disposeStreams();
  }

  void _resetShakeWindow() {
    _shakeWindowStartAt = null;
    _shakeHitCount = 0;
  }
}

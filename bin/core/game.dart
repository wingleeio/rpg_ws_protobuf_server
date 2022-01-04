import 'dart:async';

import 'package:fixnum/fixnum.dart';

import '../data/data.pbserver.dart';
import '../utils/constants.dart';
import '../utils/global.dart';
import 'connection.dart';

class GameLoop {
  final duration = Duration(microseconds: rate);

  double _lastTime = 0.0;
  double _currentTime = 0.0;
  double _delta = 0.0;

  void start() {
    Timer.periodic(duration, initializeGameLoop);
  }

  void initializeGameLoop(timer) {
    updateDelta();
    handleMovement();
  }

  void updateDelta() {
    _currentTime = DateTime.now().millisecondsSinceEpoch.toDouble();
    _delta = (_currentTime - _lastTime) / 1000;
    _lastTime = _currentTime;
  }

  void handleMovement() {
    PlayersState playersState = PlayersState();

    players.forEach((id, player) {
      if (player.movement.up) {
        player.y += _delta * -player.speed;
      }

      if (player.movement.down) {
        player.y += _delta * player.speed;
      }

      if (player.movement.left) {
        player.x += _delta * -player.speed;
      }

      if (player.movement.right) {
        player.x += _delta * player.speed;
      }

      playersState.players[id] = player;
    });

    ServerPacket packet = ServerPacket(
      time: Int64(_currentTime.toInt()),
      type: ServerPacketType.PLAYERS,
      players: playersState,
    );

    broadcast(packet.writeToBuffer());
  }
}

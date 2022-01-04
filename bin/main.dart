import 'dart:io';

import 'core/connection.dart';
import 'core/game.dart';

Future<void> main() async {
  GameLoop game = GameLoop();

  await startConnection();

  game.start();
}

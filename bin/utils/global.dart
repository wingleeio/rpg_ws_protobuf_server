import 'dart:io';

import '../data/data.pbserver.dart';

late final HttpServer socket;

final Map<int, Player> players = {};

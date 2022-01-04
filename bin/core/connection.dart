import 'dart:io';
import 'dart:math';

import '../data/data.pb.dart';
import '../utils/constants.dart';
import '../utils/global.dart';

int interval = 0;
final Map<int, WebSocket> clients = {};

Future<void> startConnection() async {
  socket = await HttpServer.bind("localhost", port);

  socket.transform(WebSocketTransformer()).listen(handleClient);

  print("Listening on port: $port");
}

void handleClient(WebSocket client) {
  int id = interval;
  print("Client $id connected.");

  clients[id] = client;

  players[id] = Player(
    id: id,
    x: 50,
    y: 50,
    speed: 150.0,
    sprite: Random().nextInt(7),
    direction: Direction.DOWN,
    movement: Movement(
      up: false,
      down: false,
      left: false,
      right: false,
    ),
  );

  void handleMessage(message) {
    List<int> buffer = message.cast<int>();
    ClientPacket packet = ClientPacket.fromBuffer(buffer);
    switch (packet.type) {
      case ClientPacketType.MOVEMENT_INPUT:
        players[id]?.direction = packet.movementInput.direction;

        switch (packet.movementInput.direction) {
          case Direction.UP:
            players[id]?.movement.up = packet.movementInput.isMoving;
            break;
          case Direction.DOWN:
            players[id]?.movement.down = packet.movementInput.isMoving;
            break;
          case Direction.LEFT:
            players[id]?.movement.left = packet.movementInput.isMoving;
            break;
          case Direction.RIGHT:
            players[id]?.movement.right = packet.movementInput.isMoving;
            break;
          default:
            break;
        }
        break;
      default:
        break;
    }
  }

  client.listen(handleMessage, onDone: () {
    print("Client $id disconnected.");
    clients.remove(id);
    players.remove(id);

    ServerPacket packet = ServerPacket(
      type: ServerPacketType.PLAYER_DISCONNECTED,
      id: id,
    );

    broadcast(packet.writeToBuffer());
  });

  interval += 1;
}

void broadcast(List<int> data) {
  clients.forEach((id, client) {
    client.add(data);
  });
}

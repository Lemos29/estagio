// To parse this JSON data, do
//
//     final pagamentos = pagamentosFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Pagamentos pagamentosFromJson(String str) => Pagamentos.fromJson(json.decode(str));

String pagamentosToJson(Pagamentos data) => json.encode(data.toJson());

class Pagamentos {
  final int status;
  final Data data;

  Pagamentos({
    required this.status,
    required this.data,
  });

  factory Pagamentos.fromJson(Map<String, dynamic> json) => Pagamentos(
    status: json["status"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
  };
}

class Data {
  final int id;
  final String userId;
  final String eventId;
  final String amount;
  final String method;
  final String reference;
  final String qrcode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String pin;

  Data({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.amount,
    required this.method,
    required this.reference,
    required this.qrcode,
    required this.createdAt,
    required this.updatedAt,
    required this.pin
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    userId: json["user_id"],
    eventId: json["event_id"],
    amount: json["amount"],
    method: json["method"],
    reference: json["reference"],
    qrcode: json["qrcode"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    pin: json["pin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "event_id": eventId,
    "amount": amount,
    "method": method,
    "reference": reference,
    "qrcode": qrcode,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "pin":pin,
  };
}

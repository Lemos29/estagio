import 'dart:convert';

Events geteventsFromJson(String str) => Events.fromJson(json.decode(str));

String geteventsToJson(Events data) => json.encode(data.toJson());

class Events {
  Events({
    required this.data,
  });

  final List<Datum> data;

  factory Events.fromJson(Map<String, dynamic> json) => Events(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    required this.id,
    required this.nome,
    required this.localizacao,
    required this.descricao,
    required this.imagem,
  });

  final int id;
  final String nome;
  final String localizacao;
  final String descricao;
  final String imagem;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    nome: json["nome"],
    localizacao: json["localizacao"],
    imagem: json["imagem"],
    descricao: json["descricao"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nome": nome,
    "descricao": descricao,
    "imagem": imagem,
    "localizao": localizacao,
  };
}
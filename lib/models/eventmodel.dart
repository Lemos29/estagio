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
    required this.preco,
    required this.dataInicio,
    required this.dataFim,
    required this.numeroVagas,
    required this.vagasDisponiveis,
  });

  final int id;
  final String nome;
  final String localizacao;
  final String descricao;
  final String imagem;
  final String preco;
  final DateTime dataInicio;
  final DateTime dataFim;
  final int numeroVagas;
  final int vagasDisponiveis;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"],
      nome: json["nome"],
      localizacao: json["localizacao"],
      descricao: json["descricao"],
      imagem: json["imagem"],
      preco: json["preco"],
      dataInicio: DateTime.parse(json["data_inicio"]),
      dataFim: DateTime.parse(json["data_fim"]),
      numeroVagas: json["numero_vagas"],
      vagasDisponiveis: json["vagas_disponiveis"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nome": nome,
    "localizacao": localizacao,
    "descricao": descricao,
    "imagem": imagem,
    "preco": preco,
    "data_inicio": dataInicio.toIso8601String(),
    "data_fim": dataFim.toIso8601String(),
    "numero_vagas": numeroVagas,
    "vagas_disponiveis": vagasDisponiveis,
  };
}

class SyncItem {
  final String id;
  final String type;
  final String data;
  final String createdAt;

  SyncItem({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'data': data, 'createdAt': createdAt};
  }

  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      data: json['data'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

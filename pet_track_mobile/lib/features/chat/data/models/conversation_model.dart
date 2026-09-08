import '../../domain/entities/conversation.dart';

class ConversationModel {
  final Map<String, dynamic> json;
  ConversationModel.fromJson(this.json);

  Conversation toEntity(String baseUrl) {
    final rawPhoto = (json['report_photo'] ?? '').toString();
    final photo = rawPhoto.isEmpty || rawPhoto.startsWith('http')
        ? rawPhoto
        : '$baseUrl$rawPhoto';
    return Conversation(
      id: json['id'] as int,
      reportId: json['report_id'] as int,
      reportName: (json['report_name'] ?? 'Sin nombre').toString(),
      reportPhoto: photo,
      reportOwnerId: json['report_owner_id'] as int,
      interestedUserId: json['interested_user_id'] as int,
      otherUserId: json['other_user_id'] as int,
      otherUserName: json['other_user_name'].toString(),
      lastMessage: json['last_message']?.toString(),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
    );
  }
}

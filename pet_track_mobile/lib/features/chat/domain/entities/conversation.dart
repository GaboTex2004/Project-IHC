import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final int id;
  final int reportId;
  final String reportName;
  final String reportPhoto;
  final int reportOwnerId;
  final int interestedUserId;
  final int otherUserId;
  final String otherUserName;
  final String? lastMessage;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.reportId,
    required this.reportName,
    required this.reportPhoto,
    required this.reportOwnerId,
    required this.interestedUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    reportId,
    reportName,
    reportPhoto,
    reportOwnerId,
    interestedUserId,
    otherUserId,
    otherUserName,
    lastMessage,
    updatedAt,
  ];
}

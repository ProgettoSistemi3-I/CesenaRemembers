import '../repositories/user_repository.dart';

class UserModerationUseCases {
  const UserModerationUseCases(this._repository);

  final IUserRepository _repository;

  Future<void> blockUser(String currentUid, String targetUid) =>
      _repository.blockUser(currentUid, targetUid);

  Future<void> unblockUser(String currentUid, String targetUid) =>
      _repository.unblockUser(currentUid, targetUid);

  Future<List<String>> getBlockedUserIds(String uid) =>
      _repository.getBlockedUserIds(uid);

  Future<void> reportUser({
    required String reporterUid,
    required String reportedUid,
    required String reportedField,
    required String reason,
    required String details,
  }) => _repository.reportUser(
    reporterUid: reporterUid,
    reportedUid: reportedUid,
    reportedField: reportedField,
    reason: reason,
    details: details,
  );
}

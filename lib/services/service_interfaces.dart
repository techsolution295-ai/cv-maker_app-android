// Abstract service classes for future implementation with APIs

abstract class AuthService {
  Future<void> signUp(String email, String password, String fullName);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<bool> isUserLoggedIn();
  Future<String?> getCurrentUserId();
}

abstract class ResumeService {
  Future<void> createResume(Map<String, dynamic> resumeData);
  Future<List<Map<String, dynamic>>> getResumes(String userId);
  Future<void> updateResume(String resumeId, Map<String, dynamic> updates);
  Future<void> deleteResume(String resumeId);
}

abstract class AIService {
  Future<String> generateResumeSummary(String jobTitle, String experience);
  Future<String> generateCoverLetter(String companyName, String jobTitle);
  Future<int> analyzeATSScore(String resumeContent);
}

abstract class PDFService {
  Future<void> generateAndDownloadPDF(Map<String, dynamic> resumeData);
  Future<void> shareResumePDF(Map<String, dynamic> resumeData);
}

abstract class SubscriptionService {
  Future<void> purchaseSubscription(String planId);
  Future<bool> isPremiumUser();
  Future<void> restorePurchase();
}

abstract class AnalyticsService {
  void trackEvent(String eventName, Map<String, dynamic>? parameters);
  void trackScreenView(String screenName);
}

abstract class RemoteConfigService {
  Future<bool> isAdsEnabled();
  Future<bool> isFeatureEnabled(String featureName);
}

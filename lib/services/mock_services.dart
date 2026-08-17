// Mock implementations for development
import 'package:cv_ganerator/services/service_interfaces.dart';

class MockAuthService implements AuthService {
  @override
  Future<void> signUp(String email, String password, String fullName) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return false;
  }

  @override
  Future<String?> getCurrentUserId() async {
    return 'user_123';
  }
}

class MockResumeService implements ResumeService {
  @override
  Future<void> createResume(Map<String, dynamic> resumeData) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<List<Map<String, dynamic>>> getResumes(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': '1',
        'title': 'Software Engineer Resume',
        'createdAt': DateTime.now(),
      },
      {
        'id': '2',
        'title': 'Product Manager Resume',
        'createdAt': DateTime.now(),
      },
    ];
  }

  @override
  Future<void> updateResume(
    String resumeId,
    Map<String, dynamic> updates,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> deleteResume(String resumeId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

class MockAIService implements AIService {
  @override
  Future<String> generateResumeSummary(
    String jobTitle,
    String experience,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return 'Experienced $jobTitle professional with strong background in $experience. Proven track record of delivering results and leading teams.';
  }

  @override
  Future<String> generateCoverLetter(
    String companyName,
    String jobTitle,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return 'Dear Hiring Manager,\n\nI am writing to express my interest in the $jobTitle position at $companyName...';
  }

  @override
  Future<int> analyzeATSScore(String resumeContent) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return 78;
  }
}

class MockPDFService implements PDFService {
  @override
  Future<void> generateAndDownloadPDF(Map<String, dynamic> resumeData) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Future<void> shareResumePDF(Map<String, dynamic> resumeData) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }
}

class MockSubscriptionService implements SubscriptionService {
  @override
  Future<void> purchaseSubscription(String planId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> isPremiumUser() async {
    return false;
  }

  @override
  Future<void> restorePurchase() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

class MockAnalyticsService implements AnalyticsService {
  @override
  void trackEvent(String eventName, Map<String, dynamic>? parameters) {
    print('Event tracked: $eventName');
  }

  @override
  void trackScreenView(String screenName) {
    print('Screen viewed: $screenName');
  }
}

class MockRemoteConfigService implements RemoteConfigService {
  @override
  Future<bool> isAdsEnabled() async {
    return true;
  }

  @override
  Future<bool> isFeatureEnabled(String featureName) async {
    return true;
  }
}

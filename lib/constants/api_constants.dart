// Constants for API endpoints and configuration
class ApiConstants {
  static const String baseUrl = 'https://api.cvgenerator.com';
  static const String userResumeBaseUrl = 'https://useresume.ai';
  static const String userResumeApiKey = 'YOUR_API_KEY';
  static const String sprintCvBaseUrl = 'https://app.sprintcv.com';
  static const String sprintCvCompanyUser = 'YOUR_COMPANY_USER';
  static const String sprintCvAccessToken = 'YOUR_TOKEN';
  static const String sprintCvClient = 'YOUR_CLIENT';

  // Auth endpoints
  static const String signUp = '/auth/signup';
  static const String signIn = '/auth/signin';
  static const String signOut = '/auth/signout';

  // Resume endpoints
  static const String resumes = '/resumes';
  static const String createResume = '/resumes/create';
  static const String userResumeCreate = '/api/v3/resume/create';
  static const String sprintCvTemplates = '/api/v1';

  // AI endpoints
  static const String aiGenerateSummary = '/ai/generate-summary';
  static const String aiGenerateCoverLetter = '/ai/generate-cover-letter';
  static const String aiAnalyzeATS = '/ai/analyze-ats';

  // PDF endpoints
  static const String generatePDF = '/pdf/generate';
  static const String sharePDF = '/pdf/share';
}

class StorageConstants {
  static const String userKey = 'user_data';
  static const String resumesKey = 'resumes_data';
  static const String preferencesKey = 'app_preferences';
  static const String onboardingCompleted = 'onboarding_completed';
}

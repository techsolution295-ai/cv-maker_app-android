import 'dart:convert';
import 'package:cv_ganerator/models/user_model.dart';
import 'package:cv_ganerator/models/resume_model.dart';
import 'package:cv_ganerator/models/cover_letter_model.dart';
import 'package:cv_ganerator/models/saved_resume.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._internal();

  static final LocalStorageService instance = LocalStorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User methods
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toMap());
    await _prefs.setString('user', userJson);
  }

  User? getUser() {
    final userJson = _prefs.getString('user');
    if (userJson == null) return null;
    return User.fromMap(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<void> clearUser() async {
    await _prefs.remove('user');
  }

  // Resume methods
  Future<void> saveResume(Resume resume) async {
    final resumes = getResumes();
    resumes.add(resume);
    final resumesJson = jsonEncode(resumes.map((r) => r.toMap()).toList());
    await _prefs.setString('resumes', resumesJson);
  }

  List<Resume> getResumes() {
    final resumesJson = _prefs.getString('resumes');
    if (resumesJson == null) return [];
    final list = jsonDecode(resumesJson) as List<dynamic>;
    return list.map((r) => Resume.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<void> updateResume(Resume resume) async {
    final resumes = getResumes();
    final index = resumes.indexWhere((r) => r.id == resume.id);
    if (index != -1) {
      resumes[index] = resume;
      final resumesJson = jsonEncode(resumes.map((r) => r.toMap()).toList());
      await _prefs.setString('resumes', resumesJson);
    }
  }

  Future<void> deleteResume(String resumeId) async {
    final resumes = getResumes();
    resumes.removeWhere((r) => r.id == resumeId);
    final resumesJson = jsonEncode(resumes.map((r) => r.toMap()).toList());
    await _prefs.setString('resumes', resumesJson);
  }

  // Saved resume data methods
  Future<void> saveResumeData(SavedResume resume) async {
    final resumes = getSavedResumes();
    resumes.add(resume);
    final resumesJson = jsonEncode(resumes.map((r) => r.toMap()).toList());
    await _prefs.setString('saved_resumes', resumesJson);
  }

  List<SavedResume> getSavedResumes() {
    final resumesJson = _prefs.getString('saved_resumes');
    if (resumesJson == null) return [];
    final list = jsonDecode(resumesJson) as List<dynamic>;
    return list
        .map((r) => SavedResume.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteSavedResume(String resumeId) async {
    final resumes = getSavedResumes();
    resumes.removeWhere((r) => r.id == resumeId);
    final resumesJson = jsonEncode(resumes.map((r) => r.toMap()).toList());
    await _prefs.setString('saved_resumes', resumesJson);
  }

  // Resume draft methods
  Future<void> saveResumeDraft(Map<String, dynamic> draft) async {
    await _prefs.setString('resume_draft', jsonEncode(draft));
  }

  Map<String, dynamic>? getResumeDraft() {
    final draftJson = _prefs.getString('resume_draft');
    if (draftJson == null) return null;
    return jsonDecode(draftJson) as Map<String, dynamic>;
  }

  Future<void> clearResumeDraft() async {
    await _prefs.remove('resume_draft');
  }

  // Cover letter methods
  Future<void> saveCoverLetter(CoverLetter letter) async {
    final letters = getCoverLetters();
    letters.add(letter);
    final lettersJson = jsonEncode(letters.map((l) => l.toMap()).toList());
    await _prefs.setString('cover_letters', lettersJson);
  }

  List<CoverLetter> getCoverLetters() {
    final lettersJson = _prefs.getString('cover_letters');
    if (lettersJson == null) return [];
    final list = jsonDecode(lettersJson) as List<dynamic>;
    return list
        .map((l) => CoverLetter.fromMap(l as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteCoverLetter(String letterId) async {
    final letters = getCoverLetters();
    letters.removeWhere((l) => l.id == letterId);
    final lettersJson = jsonEncode(letters.map((l) => l.toMap()).toList());
    await _prefs.setString('cover_letters', lettersJson);
  }

  

  // Preferences methods
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool('onboarding_completed', completed);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool('onboarding_completed') ?? false;
  }

  Future<void> setDarkMode(bool enabled) async {
    await _prefs.setBool('dark_mode', enabled);
  }

  bool isDarkModeEnabled() {
    return _prefs.getBool('dark_mode') ?? false;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool('notifications_enabled', enabled);
  }

  bool areNotificationsEnabled() {
    return _prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> setProUser(bool isPro) async {
    await _prefs.setBool('is_pro_user', isPro);
  }

  bool isProUser() {
    return _prefs.getBool('is_pro_user') ?? false;
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}

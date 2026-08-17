import 'dart:convert';

import 'package:cv_ganerator/constants/api_constants.dart';
import 'package:cv_ganerator/models/resume_data.dart';
import 'package:http/http.dart' as http;

class UserResumeApiService {
  UserResumeApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<http.Response> downloadPdf({required String url}) async {
    final uri = Uri.parse(url);
    final response = await _client.get(uri);
    return response;
  }

  Future<ResumePdfResult> createResumePdf({
    required ResumeData data,
    required String apiKey,
    String template = 'vertex',
    String templateColor = 'sapphire',
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.userResumeBaseUrl}${ApiConstants.userResumeCreate}',
    );
    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(_buildPayload(
        data: data,
        template: template,
        templateColor: templateColor,
      )),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Resume API failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] == true;
    if (!success) {
      throw Exception('Resume API returned success=false: ${response.body}');
    }

    final dataMap = body['data'] as Map<String, dynamic>?;
    final fileUrl = dataMap?['file_url'] as String?;
    final expiresAt = dataMap?['file_url_expires_at'] as int?;
    if (fileUrl == null || fileUrl.isEmpty) {
      throw Exception('Resume API response missing file_url: ${response.body}');
    }

    return ResumePdfResult(
      fileUrl: fileUrl,
      expiresAt: expiresAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(expiresAt),
    );
  }

  Map<String, dynamic> _buildPayload({
    required ResumeData data,
    required String template,
    required String templateColor,
  }) {
    return {
      'content': {
        'name': data.fullName,
        'role': data.jobTitle,
        'email': data.email,
        'phone': data.phone,
        'summary': data.summary,
        'skills': data.skills
            .where((skill) => skill.trim().isNotEmpty)
            .map((skill) => {
                  'name': skill,
                  'proficiency': 'Advanced',
                })
            .toList(),
      },
      'style': {
        'template': template,
        'template_color': templateColor,
      },
    };
  }
}

class ResumePdfResult {
  final String fileUrl;
  final DateTime? expiresAt;

  const ResumePdfResult({
    required this.fileUrl,
    required this.expiresAt,
  });
}

class SprintCvApiService {
  SprintCvApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Map<String, dynamic>>> fetchTemplates({
    required String companyUser,
    required String accessToken,
    required String client,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.sprintCvBaseUrl}${ApiConstants.sprintCvTemplates}/$companyUser/cv_templates',
    );
    final response = await _client.get(
      uri,
      headers: {
        'access-token': accessToken,
        'client': client,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('SprintCV API failed (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    }

    throw Exception('SprintCV API response format not supported.');
  }
}

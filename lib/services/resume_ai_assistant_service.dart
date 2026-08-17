import 'package:cv_ganerator/constants/api_constants.dart';
import 'package:cv_ganerator/models/resume_data.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ResumeAiAssistantService {
  static const String _defaultModel = 'gemini-1.5-flash';

  Future<String> generateSummary({
    required String fullName,
    required String jobTitle,
    required List<String> skills,
    required List<ExperienceItem> experiences,
  }) async {
    final prompt = '''
Write a concise and strong professional resume summary in 3-4 lines.
Name: $fullName
Job title: $jobTitle
Skills: ${skills.where((s) => s.trim().isNotEmpty).join(', ')}
Experience highlights: ${experiences.map((e) => '${e.title} at ${e.company}').join('; ')}
Requirements:
- Use achievement-focused language.
- Keep it ATS-friendly and simple.
- Output plain text only.
''';
    return _generateOrFallback(
      prompt: prompt,
      fallback: _summaryFallback(
        fullName: fullName,
        jobTitle: jobTitle,
        skills: skills,
        experiences: experiences,
      ),
    );
  }

  Future<String> generateExperienceDescription({
    required String jobTitle,
    required String company,
    required String duration,
  }) async {
    final prompt = '''
Write 2-3 impactful lines for resume experience description.
Job title: $jobTitle
Company: $company
Duration: $duration
Requirements:
- Mention ownership, outcomes, and collaboration.
- Keep language simple and professional.
- Output plain text only.
''';

    final fallback =
        'Led core responsibilities as $jobTitle at $company, delivering consistent results across $duration. Collaborated with cross-functional teams to improve quality, streamline workflows, and support business goals.';
    return _generateOrFallback(prompt: prompt, fallback: fallback);
  }

  Future<String> generateCoverLetter({
    required String fullName,
    required String email,
    required String phone,
    required String location,
    required String company,
    required String jobTitle,
    required String experience,
  }) async {
    final prompt = '''
Write a professional and concise cover letter for this role.
Candidate name: $fullName
Email: $email
Phone: $phone
Location: $location
Company: $company
Role: $jobTitle
Experience summary: $experience
Requirements:
- Keep it human and confident.
- 4-5 short paragraphs.
- Mention why this company and role.
- Output plain text only.
''';

    final fallback = '''Dear Hiring Manager,

I am excited to apply for the $jobTitle position at $company. I bring strong experience and a practical approach to solving business problems through high-quality execution.

In my recent work, I have consistently delivered value through ownership, collaboration, and measurable outcomes. $experience

I am confident my background aligns well with your team needs, and I would welcome the opportunity to contribute to your goals.

Thank you for your time and consideration.

Sincerely,
$fullName
$email | $phone | $location''';

    return _generateOrFallback(prompt: prompt, fallback: fallback);
  }

  Future<List<String>> generateAtsTips({
    required String jobTitle,
    required List<String> skills,
    required String summary,
  }) async {
    final prompt = '''
Generate 4 ATS improvement tips for a resume.
Job title: $jobTitle
Skills: ${skills.join(', ')}
Summary: $summary
Requirements:
- Each tip should be one short sentence.
- Practical and specific.
- Output as plain text with each tip on a new line.
''';
    final fallback = <String>[
      'Add more role-specific keywords from the target job description.',
      'Use strong action verbs and include measurable results in experience.',
      'Keep section headings standard like Summary, Experience, Skills, Education.',
      'Expand technical and domain skills that directly match the target role.',
    ];

    final text = await _generateOrFallback(
      prompt: prompt,
      fallback: fallback.join('\n'),
    );
    return text
        .split('\n')
        .map((line) => line.trim().replaceFirst(RegExp(r'^[\-\d\.\)\s]+'), ''))
        .where((line) => line.isNotEmpty)
        .take(4)
        .toList();
  }

  Future<String> _generateOrFallback({
    required String prompt,
    required String fallback,
  }) async {
    final key = ApiConstants.userResumeApiKey;
    if (key.isEmpty || key == 'YOUR_API_KEY') {
      return fallback;
    }

    try {
      final model = GenerativeModel(model: _defaultModel, apiKey: key);
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        return fallback;
      }
      return text;
    } catch (_) {
      return fallback;
    }
  }

  String _summaryFallback({
    required String fullName,
    required String jobTitle,
    required List<String> skills,
    required List<ExperienceItem> experiences,
  }) {
    final topSkills = skills.take(4).where((s) => s.trim().isNotEmpty).toList();
    final latestRole =
        experiences.isNotEmpty ? experiences.first.title : jobTitle;
    final safeName = fullName.trim().isEmpty ? 'Professional' : fullName.trim();
    final skillsText = topSkills.isEmpty
        ? 'strong execution and communication skills'
        : topSkills.join(', ');

    return '$safeName is a results-driven $jobTitle with practical experience as $latestRole. Known for $skillsText, with a focus on delivering measurable outcomes, improving processes, and supporting team success.';
  }
}

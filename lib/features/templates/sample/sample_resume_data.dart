import 'package:cv_ganerator/models/resume_data.dart';

class SampleResumeData {
  static const ResumeData alexMorgan = ResumeData(
    fullName: 'Alex Morgan',
    jobTitle: 'Senior Product Designer',
    email: 'alex.morgan@email.com',
    phone: '+1 (415) 555-0182',
    location: 'San Francisco, USA',
    address: '120 Market Street',
    city: 'San Francisco',
    country: 'United States',
    website: 'alexmorgan.design',
    linkedin: 'linkedin.com/in/alexmorgan',
    github: 'github.com/alexmorgan',
    summary:
        'Product designer with 8+ years of experience building human-centered digital products for SaaS and consumer brands. Known for turning complex workflows into clear, accessible interfaces and partnering closely with engineering and research teams.',
    skills: [
      'Product Design|0.95',
      'User Research|0.88',
      'Design Systems|0.92',
      'Figma|0.96',
      'Prototyping|0.9',
      'Interaction Design|0.86',
      'HTML/CSS|0.72',
      'Design Ops|0.8',
    ],
    experience: [
      ExperienceItem(
        title: 'Senior Product Designer',
        company: 'Northstar Labs',
        duration: 'Jan 2021 - Present',
        location: 'San Francisco, USA',
        startDate: 'Jan 2021',
        currentlyWorking: true,
        description:
            'Lead end-to-end product design for the flagship analytics platform used by 40k monthly active users.\nGrew design system adoption across 5 squads and reduced UI inconsistencies by 35%.\nPartnered with PM and engineering to ship an onboarding flow that improved activation by 18%.',
        achievements: [
          'Led design for the analytics platform used by 40k monthly active users.',
          'Grew design system adoption across 5 squads and reduced UI inconsistencies by 35%.',
          'Shipped an onboarding flow that improved activation by 18%.',
        ],
      ),
      ExperienceItem(
        title: 'Product Designer',
        company: 'Brightline Studio',
        duration: 'Mar 2018 - Dec 2020',
        location: 'Austin, USA',
        startDate: 'Mar 2018',
        endDate: 'Dec 2020',
        description:
            'Designed mobile and web experiences for fintech and health clients.\nRan usability studies and translated findings into prioritized design changes.',
        achievements: [
          'Designed mobile and web experiences for fintech and health clients.',
          'Ran usability studies and translated findings into prioritized design changes.',
        ],
      ),
      ExperienceItem(
        title: 'UI Designer',
        company: 'Harbor Creative',
        duration: 'Jun 2016 - Feb 2018',
        location: 'Chicago, USA',
        startDate: 'Jun 2016',
        endDate: 'Feb 2018',
        description:
            'Created marketing sites, dashboards, and brand systems for early-stage startups.',
      ),
    ],
    education: [
      EducationItem(
        degree: 'BFA in Graphic Design',
        school: 'Rhode Island School of Design',
        year: '2012 - 2016',
        field: 'Graphic Design',
        startDate: '2012',
        endDate: '2016',
        grade: 'GPA 3.8',
        description: 'Focus on typography, visual systems, and interactive media.',
      ),
    ],
    languages: ['English|Native', 'Spanish|Professional', 'French|Conversational'],
    references: [
      'Jordan Hale - Design Director, Northstar Labs',
      'Priya Shah - Head of Product, Brightline Studio',
    ],
    projects: [
      ProjectItem(
        name: 'Atlas Design System',
        description:
            'A cross-platform component library covering web and mobile patterns, documentation, and accessibility guidelines.',
        technologies: ['Figma', 'Storybook', 'WCAG'],
        url: 'alexmorgan.design/atlas',
        date: '2023',
      ),
      ProjectItem(
        name: 'Pulse Onboarding',
        description:
            'A guided first-run experience that reduced time-to-value for new analytics customers.',
        technologies: ['User Research', 'Prototyping'],
        date: '2022',
      ),
    ],
    certifications: [
      CertificationItem(
        name: 'NN/g UX Certification',
        organization: 'Nielsen Norman Group',
        date: '2022',
      ),
      CertificationItem(
        name: 'Google UX Design Certificate',
        organization: 'Google',
        date: '2020',
      ),
    ],
    awards: [
      AwardItem(
        title: 'Best Product Experience',
        organization: 'West Coast Design Awards',
        date: '2023',
        description: 'Recognized for the Pulse onboarding redesign.',
      ),
    ],
    volunteer: [
      VolunteerItem(
        role: 'Design Mentor',
        organization: 'ADPList',
        duration: '2021 - Present',
        description: 'Mentor early-career designers on portfolio reviews and career growth.',
      ),
    ],
    publications: [
      PublicationItem(
        title: 'Designing Calm Dashboards for Dense Data',
        publisher: 'UX Collective',
        date: '2023',
        description: 'A practical guide to hierarchy, scanning, and progressive disclosure.',
      ),
    ],
    interests: ['Urban sketching', 'Trail running', 'Typography'],
    customSections: [
      CustomSection(
        id: 'custom_tools',
        title: 'Tools',
        content: 'Figma, FigJam, Principle, Maze, Jira, Notion, Git',
      ),
    ],
  );

  static ResumeData get alexMorganCompact => alexMorgan.copyWith(
        experience: alexMorgan.experience.take(2).toList(),
        projects: alexMorgan.projects.take(1).toList(),
        publications: const [],
        volunteer: const [],
        customSections: const [],
        awards: const [],
        references: const [],
      );

  static ResumeData? _gallerySample;
  static ResumeData get gallerySample {
    return _gallerySample ??= alexMorgan.copyWith(
      photoUrl: '',
      summary:
          'Product designer with 8+ years of experience building digital products.',
      skills: alexMorgan.skills.take(5).toList(),
      experience: alexMorgan.experience.take(1).toList(),
      education: alexMorgan.education.take(1).toList(),
      languages: alexMorgan.languages.take(2).toList(),
      projects: const [],
      certifications: const [],
      awards: const [],
      volunteer: const [],
      publications: const [],
      references: const [],
      interests: const [],
      customSections: const [],
    );
  }

  static ResumeData forPreview(ResumeData? userData) {
    if (userData != null) {
      final hasIdentity = userData.fullName.trim().isNotEmpty ||
          userData.jobTitle.trim().isNotEmpty ||
          userData.summary.trim().isNotEmpty ||
          userData.experience.isNotEmpty;
      if (hasIdentity) return userData;
    }
    return alexMorganCompact;
  }
}

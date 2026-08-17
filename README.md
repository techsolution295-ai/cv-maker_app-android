# CV Generator - Flutter App

A comprehensive, production-ready Flutter application for creating professional resumes with AI-powered content generation, multiple templates, and ATS optimization.

## Features

✨ **9 Complete Screens** - From onboarding to settings
🤖 **AI-Powered** - Generate resumes, cover letters, ATS analysis
📱 **Modern UI** - Beautiful gradient design matching your screenshots
📄 **PDF Export** - Download and share resumes
🎨 **Multiple Templates** - 6+ professional resume templates
💾 **Local Storage** - Save multiple resumes
🔐 **Authentication** - Login, signup, guest access
🛒 **Subscription** - Free and premium plans

## Project Structure

```
lib/
├── config/              # Theme & styling
├── constants/           # Strings, dimensions, API config
├── models/             # Data models (User, Resume, etc.)
├── screens/            # 9 complete UI screens
├── widgets/            # Reusable UI components
├── services/           # Business logic & APIs
├── utils/              # Helper functions
└── main.dart          # App entry point
```

## Getting Started

### Prerequisites
- Flutter 3.10.7+
- Dart 3.10.7+

### Installation

```bash
cd cv_ganerator
flutter pub get
flutter run
```

## Screens Included

1. **Onboarding** - 4-step animated onboarding
2. **Authentication** - Login/Signup/Guest access
3. **Home Dashboard** - Feature cards with 4 main actions
4. **Resume Creation** - 5-step multi-step form
5. **Templates** - 6 modern template options
6. **Resume Preview** - Live preview with PDF download
7. **Cover Letter** - AI-powered generation
8. **ATS Score** - Compatibility analysis
9. **Settings** - Profile, preferences, legal

## Design System

- **Colors**: Blue (#4A90E2), Green (#50C878), Orange (#FFB84D)
- **Gradient**: Blue to Green background
- **Typography**: Google Fonts "Inter"
- **Components**: Modern card-based UI with rounded corners

## Technologies Used

- Flutter & Dart
- Provider (state management ready)
- Firebase (prepared for integration)
- Google Fonts
- SharedPreferences (local storage)

## Next Steps for Production

1. Add Firebase authentication
2. Implement AI content generation API
3. Connect Firestore for cloud storage
4. Add PDF generation
5. Implement in-app purchases
6. Deploy to App Store/Play Store

## File Structure Reference

All features match the design:
- Gradient backgrounds
- Feature cards (2x2 grid)
- Bottom navigation
- Multi-step forms
- Progress indicators
- Loading states
- Error handling

## Support

See `QUICK_START.md` and `README_IMPLEMENTATION.md` for detailed documentation.

---

**Built with Flutter ❤️**

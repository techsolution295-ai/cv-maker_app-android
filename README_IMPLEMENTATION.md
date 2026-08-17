# CV Generator - Flutter App

A comprehensive, production-ready Flutter application for creating professional resumes and cover letters with AI-powered content generation, multiple templates, and ATS optimization.

## Features

### 1. **User Onboarding & Authentication**
- Attractive onboarding screens explaining app benefits
- Guest access for immediate usage
- Optional login/signup with email and password
- First-time user guidance

### 2. **Resume Management**
- Create new resumes with multi-step wizard
- Input personal details, job title, experience, education, skills
- Save multiple resumes locally or in cloud
- Edit and manage existing resumes
- Reorder sections and customize content

### 3. **AI-Powered Features**
- Generate professional resume summaries based on job title and experience
- AI-based cover letter generation using company name and job title
- ATS (Applicant Tracking System) compatibility analysis
- Automated content suggestions and improvements

### 4. **Resume Templates**
- 6+ modern, professional resume templates
- Free and premium template options
- Live preview before selection
- Responsive design for all screen sizes
- Premium lock system for exclusive templates

### 5. **Resume Preview & Export**
- Real-time resume preview with selected template
- Download as PDF with one click
- Share via email or other apps
- Print-friendly formatting

### 6. **ATS Score Analysis**
- Analyze resume compatibility with ATS systems
- Detailed improvement tips and recommendations
- Keyword optimization suggestions
- Formatting analysis

### 7. **User Profile & Settings**
- User profile management
- Subscription status display
- Push notifications for tips and updates
- Privacy policy and terms of service
- Rate app option
- Restore purchase for subscriptions

### 8. **Premium Subscription**
- Monthly, yearly, and lifetime plans
- Remove ads with premium
- Unlock all templates and features
- In-app purchase integration
- Subscription status tracking

### 9. **Free User Limitations**
- Limited AI generations (5/month)
- Limited template access
- Limited downloads
- Banner and interstitial ads

### 10. **Additional Features**
- Analytics and usage tracking
- Remote feature configuration
- Error handling with user-friendly messages
- Loading states for async operations
- Offline support with local storage
- Clean, modern UI with gradient backgrounds

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── config/
│   └── theme.dart                     # App theming and styling
├── constants/
│   ├── strings.dart                   # App strings and labels
│   ├── dimensions.dart                # UI dimensions and spacing
│   └── api_constants.dart             # API endpoints and config
├── models/
│   ├── user_model.dart                # User data model
│   ├── resume_model.dart              # Resume, Experience, Education models
│   ├── cover_letter_model.dart        # Cover letter model
│   └── template_model.dart            # Template model
├── screens/
│   ├── onboarding_screen.dart         # Onboarding flow
│   ├── auth_screen.dart               # Login/Signup
│   ├── home_screen.dart               # Home dashboard
│   ├── resume_creation_screen.dart    # Multi-step resume creation
│   ├── resume_preview_screen.dart     # Resume preview with PDF export
│   ├── template_screen.dart           # Template selection
│   ├── cover_letter_screen.dart       # Cover letter generation
│   ├── ats_score_screen.dart          # ATS analysis
│   └── settings_screen.dart           # User settings
├── widgets/
│   ├── common_widgets.dart            # Reusable UI components
│   └── app_widgets.dart               # App-specific widgets
├── services/
│   ├── service_interfaces.dart        # Abstract service definitions
│   ├── mock_services.dart             # Mock implementations
│   ├── local_storage_service.dart     # Local storage management
│   └── (Firebase/API services ready) # Ready for production setup
└── providers/
    └── (Ready for state management)    # Provider for state management
```

## UI/UX Design

### Color Scheme
- **Primary Blue**: #4A90E2
- **Secondary Green**: #50C878
- **Accent Orange**: #FFB84D
- **Background**: Light gray gradient to green gradient

### Typography
- Font Family: Google Fonts "Inter"
- Clean, modern, readable font
- Consistent sizing hierarchy

### Components
- Custom gradient backgrounds
- Rounded card-based UI
- Feature cards with icons
- Progress indicators
- Loading states
- Empty states
- Error handling widgets

## Getting Started

### Prerequisites
- Flutter 3.10.7 or higher
- Dart SDK 3.10.7 or higher
- A compatible IDE (VS Code or Android Studio)

### Installation

1. **Clone the repository**
```bash
cd cv_ganerator
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### Configuration

Before running the app, configure the following:

#### 1. **Firebase Setup** (Optional)
- Add Firebase configuration to `lib/config/firebase_config.dart`
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

#### 2. **Google Mobile Ads**
- Add your Ad Unit IDs in `lib/constants/api_constants.dart`

#### 3. **In-App Purchases**
- Configure subscription plan IDs in `lib/constants/api_constants.dart`

#### 4. **API Keys**
- Add Google Generative AI key for AI features
- Configure API endpoints in `lib/constants/api_constants.dart`

## State Management

The app uses Provider for state management. To implement:

```bash
flutter pub add provider
```

Create providers in `lib/providers/` for:
- Authentication state
- Resume management
- User preferences
- Subscription status

## Backend Integration

The app is prepared for integration with:
- **Firebase Firestore** for cloud resume storage
- **Firebase Authentication** for user management
- **Google Generative AI API** for content generation
- **Firebase Cloud Storage** for PDF storage
- **Stripe/Google Play Billing** for subscriptions

Mock services are implemented for development. Replace with actual implementations in production.

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

## Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## API Documentation

### Resume API
- `POST /resumes` - Create resume
- `GET /resumes/{userId}` - Get user's resumes
- `PUT /resumes/{id}` - Update resume
- `DELETE /resumes/{id}` - Delete resume

### AI API
- `POST /ai/generate-summary` - Generate resume summary
- `POST /ai/generate-cover-letter` - Generate cover letter
- `POST /ai/analyze-ats` - Analyze ATS score

### PDF API
- `POST /pdf/generate` - Generate PDF
- `POST /pdf/share` - Share PDF

## Development Features

### Code Organization
- Separation of concerns with clear layer architecture
- Reusable components and widgets
- Service-based abstraction for external dependencies
- Model-based data management

### Error Handling
- Try-catch blocks for all async operations
- User-friendly error messages
- Graceful degradation on network failures
- Retry mechanisms

### Performance
- Lazy loading of screens
- Efficient state management
- Image caching
- Minimal re-renders

## Future Enhancements

1. **Advanced AI Features**
   - Multi-language support
   - Industry-specific content generation
   - LinkedIn profile integration

2. **Template Marketplace**
   - User-created templates
   - Template ratings and reviews
   - Premium template authors

3. **Collaboration Features**
   - Share drafts with others
   - Feedback and comments
   - Version history

4. **Analytics Dashboard**
   - Resume view tracking
   - Application success rates
   - Interview statistics

5. **Integration**
   - LinkedIn login and auto-fill
   - Google Drive sync
   - Email campaign integration

## Troubleshooting

### Common Issues

1. **Build fails with dependency errors**
   ```bash
   flutter clean
   flutter pub get
   flutter pub upgrade
   ```

2. **Gradle build issues (Android)**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter run
   ```

3. **Pod install issues (iOS)**
   ```bash
   cd ios
   rm -rf Pods
   rm Podfile.lock
   pod install
   cd ..
   flutter run
   ```

## Contributing

1. Create a feature branch (`git checkout -b feature/amazing-feature`)
2. Commit your changes (`git commit -m 'Add amazing feature'`)
3. Push to the branch (`git push origin feature/amazing-feature`)
4. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@cvgenerator.com or open an issue in the repository.

## Version History

- **v1.0.0** (Current) - Initial release with core features

---

**Built with ❤️ using Flutter**

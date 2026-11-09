import '../domain/models/portfolio_models.dart';

class MockPortfolioRepository {
  const MockPortfolioRepository();

  Future<PortfolioContent> fetchContent() async {
    return const PortfolioContent(
      profile: PortfolioProfile(
        name: 'Mohsin Ali',
        role: 'Flutter Developer & Product Builder',
        tagline:
            'I design and ship polished cross-platform apps with performance, clean architecture, and product thinking at the center.',
        about:
            'I build responsive Flutter experiences for mobile and web, turning product ideas into maintainable apps. My focus is scalable architecture, smooth UI, practical state management, and features that are easy to evolve with backend services like Supabase.',
        location: 'Okara, Pakistan',
        email: 'mohsin.dev@example.com',
        resumeUrl: 'https://example.com/resume.pdf',
        socialLinks: [
          SocialLink(
            label: 'GitHub',
            url: 'https://github.com/',
            icon: 'github',
          ),
          SocialLink(
            label: 'LinkedIn',
            url: 'https://linkedin.com/',
            icon: 'linkedin',
          ),
          SocialLink(
            label: 'YouTube',
            url: 'https://youtube.com/',
            icon: 'youtube',
          ),
          SocialLink(
            label: 'Email',
            url: 'mailto:mohsin.dev@example.com',
            icon: 'email',
          ),
        ],
        skills: [
          'Flutter',
          'Dart',
          'Hydrated BLoC',
          'Supabase',
          'REST APIs',
          'Firebase',
          'Responsive UI',
          'Clean Architecture',
        ],
        stats: [
          HighlightStat(label: 'Projects Delivered', value: '14+'),
          HighlightStat(label: 'Years Building', value: '4'),
          HighlightStat(label: 'Target Rating', value: '4.8'),
        ],
      ),
      services: [
        ServiceItem(
          title: 'Mobile App Development',
          description:
              'Production-ready Flutter apps with thoughtful UX, modular architecture, and store-ready delivery.',
          highlights: [
            'Android and iOS releases',
            'Feature-first architecture',
            'API and backend integration',
          ],
        ),
        ServiceItem(
          title: 'Responsive Web Experiences',
          description:
              'Landing pages, dashboards, and portfolio sites that feel native across desktop, tablet, and mobile.',
          highlights: [
            'Adaptive layouts',
            'Fast interactions',
            'SEO-friendly structure',
          ],
        ),
        ServiceItem(
          title: 'App Modernization',
          description:
              'Refactoring legacy codebases into maintainable, testable apps with stronger state management and clearer boundaries.',
          highlights: [
            'BLoC migration',
            'Performance tuning',
            'Backend-ready data layers',
          ],
        ),
      ],
      projects: [
        ProjectItem(
          id: 'fittrack-pro',
          name: 'FitTrack Pro',
          summary:
              'A fitness coaching app with personalized workout plans, progress charts, subscription flows, and wearable sync preparation.',
          category: 'Health & Fitness',
          accentHex: 0xFF21C7F6,
          tags: ['Flutter', 'Charts', 'Subscriptions', 'Hydrated BLoC'],
          demoVideoUrl: 'https://youtube.com/watch?v=fittrack-demo',
          liveUrl: 'https://example.com/fittrack',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=fittrack',
          appStoreUrl: 'https://apps.apple.com/app/id0000000001',
        ),
        ProjectItem(
          id: 'shopnest',
          name: 'ShopNest',
          summary:
              'An e-commerce experience with product discovery, cart persistence, order flow, and promo campaign support.',
          category: 'E-Commerce',
          accentHex: 0xFF4EE29A,
          tags: ['Flutter Web', 'Payments', 'Animations', 'Supabase Ready'],
          demoVideoUrl: 'https://youtube.com/watch?v=shopnest-demo',
          liveUrl: 'https://example.com/shopnest',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=shopnest',
          appStoreUrl: 'https://apps.apple.com/app/id0000000002',
        ),
        ProjectItem(
          id: 'medlink',
          name: 'MedLink Care',
          summary:
              'A telehealth booking platform with doctor search, appointments, real-time status, and secure patient flows.',
          category: 'Healthcare',
          accentHex: 0xFFFF8E5E,
          tags: ['Realtime', 'Scheduling', 'Role-based UI', 'Scalable'],
          demoVideoUrl: 'https://youtube.com/watch?v=medlink-demo',
          liveUrl: 'https://example.com/medlink',
          playStoreUrl: 'https://play.google.com/store/apps/details?id=medlink',
          appStoreUrl: 'https://apps.apple.com/app/id0000000003',
        ),
        ProjectItem(
          id: 'carrental',
          name: 'Car Rental Management',
          summary:
              'A comprehensive car rental and expense management system with vehicle management, booking operations, customer records, rental tracking, and expense monitoring.',
          category: 'Management',
          accentHex: 0xFF4F8CFF,
          tags: ['Flutter', 'Booking', 'Expense Tracking', 'Management'],
          demoVideoUrl: 'https://youtube.com/watch?v=carrental-demo',
          liveUrl: 'https://example.com/carrental',
          playStoreUrl: '',
          appStoreUrl: '',
        ),

        ProjectItem(
          id: 'hrmanagement',
          name: 'HR Management System',
          summary:
              'An HR management platform for employee records, attendance tracking, leave management, payroll operations, and workforce administration.',
          category: 'Management',
          accentHex: 0xFF8B6CFF,
          tags: ['Flutter', 'HR Management', 'Attendance', 'Payroll'],
          demoVideoUrl: 'https://youtube.com/watch?v=hrmanagement-demo',
          liveUrl: 'https://example.com/hrmanagement',
          playStoreUrl: '',
          appStoreUrl: '',
        ),
      ],
      contacts: [
        ContactItem(
          title: 'Email',
          value: 'mohsin.dev@example.com',
          actionLabel: 'Send email',
          url: 'mailto:mohsin.dev@example.com',
        ),
        ContactItem(
          title: 'WhatsApp',
          value: '+92 300 1234567',
          actionLabel: 'Start chat',
          url: 'https://wa.me/923001234567',
        ),
        ContactItem(
          title: 'Location',
          value: 'Okara, Pakistan',
          actionLabel: 'View map',
          url: 'https://maps.google.com/?q=Okara',
        ),
      ],
    );
  }
}

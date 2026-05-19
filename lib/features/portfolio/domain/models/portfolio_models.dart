class PortfolioProfile {
  const PortfolioProfile({
    required this.name,
    required this.role,
    required this.tagline,
    required this.about,
    required this.location,
    required this.email,
    required this.resumeUrl,
    required this.socialLinks,
    required this.skills,
    required this.stats,
  });

  final String name;
  final String role;
  final String tagline;
  final String about;
  final String location;
  final String email;
  final String resumeUrl;
  final List<SocialLink> socialLinks;
  final List<String> skills;
  final List<HighlightStat> stats;
}

class SocialLink {
  const SocialLink({
    required this.label,
    required this.url,
    required this.icon,
  });

  final String label;
  final String url;
  final String icon;
}

class HighlightStat {
  const HighlightStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class ServiceItem {
  const ServiceItem({
    required this.title,
    required this.description,
    required this.highlights,
  });

  final String title;
  final String description;
  final List<String> highlights;
}

class ProjectItem {
  const ProjectItem({
    required this.id,
    required this.name,
    required this.summary,
    required this.category,
    required this.accentHex,
    required this.tags,
    required this.demoVideoUrl,
    required this.liveUrl,
    required this.playStoreUrl,
    required this.appStoreUrl,
  });

  final String id;
  final String name;
  final String summary;
  final String category;
  final int accentHex;
  final List<String> tags;
  final String demoVideoUrl;
  final String liveUrl;
  final String playStoreUrl;
  final String appStoreUrl;
}

class ContactItem {
  const ContactItem({
    required this.title,
    required this.value,
    required this.actionLabel,
    required this.url,
  });

  final String title;
  final String value;
  final String actionLabel;
  final String url;
}

class PortfolioContent {
  const PortfolioContent({
    required this.profile,
    required this.services,
    required this.projects,
    required this.contacts,
  });

  final PortfolioProfile profile;
  final List<ServiceItem> services;
  final List<ProjectItem> projects;
  final List<ContactItem> contacts;
}

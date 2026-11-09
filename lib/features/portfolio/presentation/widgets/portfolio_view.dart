import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/portfolio_models.dart';
import '../cubit/portfolio_state.dart';

enum _PortfolioSection { home, about, services, projects, contact }

class PortfolioView extends StatefulWidget {
  const PortfolioView({
    required this.state,
    required this.onProjectSelected,
    super.key,
  });

  final PortfolioState state;
  final ValueChanged<String> onProjectSelected;

  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _introController;
  late final Map<_PortfolioSection, GlobalKey> _sectionKeys;
  _PortfolioSection? _activeSection = _PortfolioSection.home;
  int? _presentationProjectIndex;
  bool _presentationStarted = false;
  bool _presentationFinished = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _sectionKeys = {
      _PortfolioSection.home: GlobalKey(),
      _PortfolioSection.about: GlobalKey(),
      _PortfolioSection.services: GlobalKey(),
      _PortfolioSection.projects: GlobalKey(),
      _PortfolioSection.contact: GlobalKey(),
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _presentationStarted) {
        return;
      }
      _presentationStarted = true;
      if (MediaQuery.disableAnimationsOf(context)) {
        _presentationFinished = true;
        setState(() => _activeSection = null);
        return;
      }
      unawaited(_runPresentation());
    });
  }

  Future<void> _runPresentation() async {
    await _introController.forward();
    if (!_canContinuePresentation) {
      return;
    }

    for (final section in [
      _PortfolioSection.about,
      _PortfolioSection.services,
      _PortfolioSection.projects,
      _PortfolioSection.contact,
    ]) {
      await _animateSection(section);
      if (!_canContinuePresentation) {
        return;
      }
      if (section == _PortfolioSection.projects) {
        await _presentProjectDetails();
      }
    }

    final projects = widget.state.content?.projects;
    if (projects != null && projects.isNotEmpty) {
      setState(() => _presentationProjectIndex = null);
      widget.onProjectSelected(projects.first.id);
    }

    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 1800),
        curve: Curves.easeInOutCubic,
      );
    }
    if (!_canContinuePresentation) {
      return;
    }
    _finishPresentation();
  }

  bool get _canContinuePresentation => mounted && !_presentationFinished;

  Future<void> _presentProjectDetails() async {
    final projects = widget.state.content?.projects;
    if (projects == null) {
      return;
    }

    for (var index = 0; index < projects.length; index++) {
      if (!_canContinuePresentation) {
        return;
      }
      setState(() => _presentationProjectIndex = index);
      await Future<void>.delayed(const Duration(milliseconds: 1150));
    }
  }

  void _selectProject(String projectId) {
    _interruptPresentation();
    setState(() => _presentationProjectIndex = null);
    widget.onProjectSelected(projectId);
  }

  Future<void> _animateSection(_PortfolioSection section) async {
    if (!_canContinuePresentation) {
      return;
    }

    setState(() => _activeSection = section);
    _introController.reset();
    await Future.wait([
      _introController.forward(),
      _scrollToSection(section, duration: const Duration(milliseconds: 1600)),
    ]);
  }

  void _finishPresentation() {
    if (_presentationFinished) {
      return;
    }
    _presentationFinished = true;
    if (mounted) {
      setState(() => _activeSection = null);
    }
  }

  void _interruptPresentation() {
    if (_presentationFinished) {
      return;
    }
    _presentationFinished = true;
    _introController.stop(canceled: false);
    if (mounted) {
      setState(() => _activeSection = null);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _introController.dispose();
    super.dispose();
  }

  Future<void> _scrollToSection(
    _PortfolioSection section, {
    Duration duration = const Duration(milliseconds: 1000),
  }) async {
    final context = _sectionKeys[section]?.currentContext;
    if (context == null) {
      return;
    }

    await Scrollable.ensureVisible(
      context,
      duration: duration,
      curve: Curves.easeInOutCubic,
      alignment: section == _PortfolioSection.home ? 0 : 0.08,
    );
  }

  Future<void> _navigateToSection(_PortfolioSection section) async {
    _interruptPresentation();
    await _scrollToSection(section);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final content = state.content!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1080;
    final isTablet = screenWidth >= 720;
    final showTopNavigation = screenWidth >= 720;
    final selectedProject = state.selectedProject ?? content.projects.first;
    final selectedProjectIndex =
        _presentationProjectIndex ?? content.projects.indexOf(selectedProject);
    final visibleProject =
        content.projects[_presentationProjectIndex ?? selectedProjectIndex];

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction != ScrollDirection.idle) {
          _interruptPresentation();
        }
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF07111B), Color(0xFF081828), Color(0xFF091F32)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 20,
                vertical: isDesktop ? 28 : 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showTopNavigation)
                        _StageReveal(
                          controller: _introController,
                          isActive: _activeSection == _PortfolioSection.home,
                          begin: 0,
                          end: 0.2,
                          child: _TopNavigation(
                            profileName: content.profile.name,
                            onSectionTap: _navigateToSection,
                          ),
                        ),
                      if (showTopNavigation) const SizedBox(height: 28),
                      KeyedSubtree(
                        key: _sectionKeys[_PortfolioSection.home],
                        child: _HeroSection(
                          profile: content.profile,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                          controller: _introController,
                          animate: _activeSection == _PortfolioSection.home,
                        ),
                      ),
                      const SizedBox(height: 28),
                      KeyedSubtree(
                        key: _sectionKeys[_PortfolioSection.about],
                        child: _SectionShell(
                          controller: _introController,
                          animate: _activeSection == _PortfolioSection.about,
                          title: 'About me',
                          subtitle:
                              'A portfolio foundation you can later connect to Supabase without changing the UI layer.',
                          child: _AboutSection(
                            profile: content.profile,
                            controller: _introController,
                            animate: _activeSection == _PortfolioSection.about,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      KeyedSubtree(
                        key: _sectionKeys[_PortfolioSection.services],
                        child: _SectionShell(
                          controller: _introController,
                          animate: _activeSection == _PortfolioSection.services,
                          title: 'Services',
                          subtitle:
                              'Core areas where I help teams move from idea to shipped product.',
                          child: _ServicesSection(
                            services: content.services,
                            isDesktop: isDesktop,
                            controller: _introController,
                            animate:
                                _activeSection == _PortfolioSection.services,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      KeyedSubtree(
                        key: _sectionKeys[_PortfolioSection.projects],
                        child: _SectionShell(
                          controller: _introController,
                          animate: _activeSection == _PortfolioSection.projects,
                          title: 'Featured projects',
                          subtitle:
                              'Each project includes a mock visual, demo video, live product link, and store destinations.',
                          child: _ProjectsSection(
                            projects: content.projects,
                            selectedProject: visibleProject,
                            selectedProjectIndex: selectedProjectIndex,
                            isDesktop: isDesktop,
                            onProjectSelected: _selectProject,
                            controller: _introController,
                            animate:
                                _activeSection == _PortfolioSection.projects,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      KeyedSubtree(
                        key: _sectionKeys[_PortfolioSection.contact],
                        child: _SectionShell(
                          controller: _introController,
                          animate: _activeSection == _PortfolioSection.contact,
                          title: 'Contact',
                          subtitle:
                              'Open to freelance work, product collaborations, and long-term Flutter roles.',
                          child: _ContactSection(
                            profile: content.profile,
                            contacts: content.contacts,
                            isDesktop: isDesktop,
                            controller: _introController,
                            animate:
                                _activeSection == _PortfolioSection.contact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopNavigation extends StatelessWidget {
  const _TopNavigation({required this.profileName, required this.onSectionTap});

  final String profileName;
  final ValueChanged<_PortfolioSection> onSectionTap;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 860;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1B2A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1A3047)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/profile.jpg',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          profileName,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        if (isWide)
          Wrap(
            spacing: 20,
            children: [
              _NavLabel(
                label: 'Home',
                onTap: () => onSectionTap(_PortfolioSection.home),
              ),
              _NavLabel(
                label: 'About',
                onTap: () => onSectionTap(_PortfolioSection.about),
              ),
              _NavLabel(
                label: 'Services',
                onTap: () => onSectionTap(_PortfolioSection.services),
              ),
              _NavLabel(
                label: 'Projects',
                onTap: () => onSectionTap(_PortfolioSection.projects),
              ),
              _NavLabel(
                label: 'Contact',
                onTap: () => onSectionTap(_PortfolioSection.contact),
              ),
            ],
          )
        else
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0E1B2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1A3047)),
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.grid_view_rounded),
          ),
      ],
    );
  }
}

class _NavLabel extends StatelessWidget {
  const _NavLabel({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StageReveal extends StatelessWidget {
  const _StageReveal({
    required this.controller,
    required this.isActive,
    required this.child,
    this.begin = 0,
    this.end = 1,
    this.scale = false,
  });

  final AnimationController controller;
  final bool isActive;
  final Widget child;
  final double begin;
  final double end;
  final bool scale;

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return child;
    }

    final reveal = CurvedAnimation(
      parent: controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: reveal,
      child: child,
      builder: (context, child) {
        final value = reveal.value;
        final offsetY = (1 - value) * 20;

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: Transform.scale(
              scale: scale ? 0.96 + (value * 0.04) : 1,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.profile,
    required this.isDesktop,
    required this.isTablet,
    required this.controller,
    required this.animate,
  });

  final PortfolioProfile profile;
  final bool isDesktop;
  final bool isTablet;
  final AnimationController controller;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final isMobile = !isTablet;

    final heroIntro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StageReveal(
          controller: controller,
          isActive: animate,
          begin: 0.12,
          end: 0.32,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0C2132),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF1A3047)),
            ),
            child: const Text(
              'Available for Flutter projects',
              style: TextStyle(
                color: Color(0xFF21C7F6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _StageReveal(
          controller: controller,
          isActive: animate,
          begin: 0.2,
          end: 0.46,
          child: Text(
            'Hi, I\'m ${profile.name}',
            style:
                (isDesktop
                        ? Theme.of(context).textTheme.displayMedium
                        : Theme.of(context).textTheme.headlineLarge)
                    ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 12),
        _StageReveal(
          controller: controller,
          isActive: animate,
          begin: 0.38,
          end: 0.62,
          child: Text(
            profile.role,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF21C7F6),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _StageReveal(
          controller: controller,
          isActive: animate,
          begin: 0.54,
          end: 0.76,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              profile.tagline,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );

    final heroActions = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: isTablet ? 28 : 22),
        _StageReveal(
          controller: controller,
          isActive: animate,
          begin: 0.66,
          end: 0.86,
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _PrimaryActionButton(
                label: 'Hire Me',
                icon: Icons.rocket_launch_rounded,
                onPressed: () => _launch(profile.socialLinks.last.url),
              ),
              _SecondaryActionButton(
                label: 'Download CV',
                icon: Icons.download_rounded,
                onPressed: () => _launch(profile.resumeUrl),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 24 : 18),
        _StageReveal(
          controller: controller,
          isActive: animate,
          begin: 0.78,
          end: 0.98,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: profile.socialLinks
                .map(
                  (social) => _SocialChip(
                    label: social.label,
                    icon: _iconForName(social.icon),
                    onTap: () => _launch(social.url),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );

    final heroVisual = Padding(
      padding: EdgeInsets.only(top: isDesktop ? 0 : 14),
      child: _StageReveal(
        controller: controller,
        isActive: animate,
        begin: 0.22,
        end: 0.68,
        scale: true,
        child: _PortraitCard(location: profile.location),
      ),
    );

    final heroText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [heroIntro, if (isMobile) heroVisual, heroActions],
    );

    return _GlassSection(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32 : 20),
        child: isTablet
            ? Row(
                children: [
                  Expanded(flex: isDesktop ? 11 : 1, child: heroText),
                  const SizedBox(width: 24),
                  Expanded(flex: isDesktop ? 9 : 1, child: heroVisual),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [heroText],
              ),
      ),
    );
  }
}

class _PortraitCard extends StatelessWidget {
  const _PortraitCard({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 720;
    final useCompactDesktopLayout = screenWidth >= 720 && screenWidth < 980;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF28445F)),
            ),
            child: Text(
              location,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF21C7F6), Color(0xFF1452FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x5521C7F6),
                    blurRadius: 50,
                    spreadRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF08111A),
                ),
                child: ClipOval(
                  child: Image.asset('assets/profile.jpg', fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(
                child: _MobileStatCard(value: '14+', label: 'Projects'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MobileStatCard(value: '4', label: 'Years'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MobileStatCard(value: '4.8', label: 'Goal'),
              ),
            ],
          ),
        ],
      );
    }

    if (useCompactDesktopLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF28445F)),
            ),
            child: Text(
              location,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF21C7F6), Color(0xFF1452FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x5521C7F6),
                    blurRadius: 50,
                    spreadRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF08111A),
                ),
                child: ClipOval(
                  child: Image.asset('assets/profile.jpg', fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(
                child: _MobileStatCard(value: '14+', label: 'Projects'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MobileStatCard(value: '4', label: 'Years'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MobileStatCard(value: '4.8', label: 'Goal'),
              ),
            ],
          ),
        ],
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const RadialGradient(
                  center: Alignment(0.2, -0.25),
                  radius: 0.9,
                  colors: [Color(0xFF143B60), Color(0xFF0B1722)],
                ),
                border: Border.all(color: const Color(0xFF1A3047)),
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: 22,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.22),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF28445F)),
              ),
              child: Text(
                location,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF21C7F6), Color(0xFF1452FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x5521C7F6),
                    blurRadius: 50,
                    spreadRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF08111A),
                ),
                child: ClipOval(
                  child: Image.asset('assets/profile.jpg', fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          Positioned(
            right: 22,
            bottom: 22,
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xCC0F1E2D),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1A3047)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _StatItem(value: '14+', label: 'Projects'),
                  SizedBox(height: 10),
                  _StatItem(value: '4', label: 'Years'),
                  SizedBox(height: 10),
                  _StatItem(value: '4.8', label: 'Goal'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileStatCard extends StatelessWidget {
  const _MobileStatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xCC0F1E2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1A3047)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.controller,
    required this.animate,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final AnimationController controller;
  final bool animate;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _GlassSection(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StageReveal(
              controller: controller,
              isActive: animate,
              begin: 0.06,
              end: 0.25,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 10),
            _StageReveal(
              controller: controller,
              isActive: animate,
              begin: 0.18,
              end: 0.38,
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.profile,
    required this.controller,
    required this.animate,
  });

  final PortfolioProfile profile;
  final AnimationController controller;
  final bool animate;

  List<Widget> _skillBadges() => profile.skills.asMap().entries.map((entry) {
    final start = 0.4 + (entry.key * 0.055);
    return _StageReveal(
      controller: controller,
      isActive: animate,
      begin: start,
      end: (start + 0.25).clamp(0.0, 1.0).toDouble(),
      child: Chip(
        label: Text(
          entry.value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }).toList();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 920;

    final intro = Expanded(
      flex: 6,
      child: _StageReveal(
        controller: controller,
        isActive: animate,
        begin: 0.34,
        end: 0.56,
        child: Text(
          profile.about,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );

    final skills = Expanded(
      flex: 5,
      child: Wrap(spacing: 10, runSpacing: 10, children: _skillBadges()),
    );

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [intro, const SizedBox(width: 28), skills],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StageReveal(
                controller: controller,
                isActive: animate,
                begin: 0.34,
                end: 0.56,
                child: Text(
                  profile.about,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(spacing: 10, runSpacing: 10, children: _skillBadges()),
            ],
          );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({
    required this.services,
    required this.isDesktop,
    required this.controller,
    required this.animate,
  });

  final List<ServiceItem> services;
  final bool isDesktop;
  final AnimationController controller;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 18,
      children: services.asMap().entries.map((entry) {
        final index = entry.key;
        final service = entry.value;
        final start = 0.3 + (index * 0.2);
        return _StageReveal(
          controller: controller,
          isActive: animate,
          begin: start,
          end: (start + 0.32).clamp(0.0, 1.0).toDouble(),
          scale: true,
          child: SizedBox(
            width: isDesktop ? 370 : double.infinity,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.layers_rounded,
                      color: Color(0xFF21C7F6),
                      size: 34,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      service.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      service.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ...service.highlights.map(
                      (highlight) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: Color(0xFF4EE29A),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                highlight,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({
    required this.projects,
    required this.selectedProject,
    required this.selectedProjectIndex,
    required this.isDesktop,
    required this.onProjectSelected,
    required this.controller,
    required this.animate,
  });

  final List<ProjectItem> projects;
  final ProjectItem selectedProject;
  final int selectedProjectIndex;
  final bool isDesktop;
  final ValueChanged<String> onProjectSelected;
  final AnimationController controller;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 720;
    final projectList = Column(
      children: projects.asMap().entries.map((entry) {
        final index = entry.key;
        final project = entry.value;
        final start = 0.28 + (index * 0.12);
        return _StageReveal(
          controller: controller,
          isActive: animate,
          begin: start,
          end: (start + 0.3).clamp(0.0, 1.0).toDouble(),
          scale: true,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: isMobile
                ? _MobileProjectCard(project: project)
                : _ProjectPreviewCard(
                    project: project,
                    isSelected: index == selectedProjectIndex,
                    onTap: () => onProjectSelected(project.id),
                  ),
          ),
        );
      }).toList(),
    );

    final details = _StageReveal(
      controller: controller,
      isActive: animate,
      begin: 0.3,
      end: 0.72,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 650),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.035),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: _ProjectDetailCard(
          key: ValueKey(selectedProjectIndex),
          project: selectedProject,
        ),
      ),
    );

    if (isMobile) {
      return projectList;
    }

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: projectList),
              const SizedBox(width: 22),
              Expanded(flex: 6, child: details),
            ],
          )
        : Column(children: [details, const SizedBox(height: 18), projectList]);
  }
}

class _MobileProjectCard extends StatelessWidget {
  const _MobileProjectCard({required this.project});

  final ProjectItem project;

  @override
  Widget build(BuildContext context) {
    final accent = Color(project.accentHex);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1825),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1A3047)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.92), const Color(0xFF10263A)],
                  ),
                ),
                child: const Icon(Icons.phone_android_rounded, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      project.category,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PrimaryActionButton(
                label: 'Demo',
                icon: Icons.play_circle_fill_rounded,
                onPressed: () => _launch(project.demoVideoUrl),
              ),
              _SecondaryActionButton(
                label: 'Live',
                icon: Icons.open_in_new_rounded,
                onPressed: () => _launch(project.liveUrl),
              ),
              _SecondaryActionButton(
                label: 'Play Store',
                icon: Icons.shop_2_rounded,
                onPressed: () => _launch(project.playStoreUrl),
              ),
              _SecondaryActionButton(
                label: 'App Store',
                icon: Icons.apple_rounded,
                onPressed: () => _launch(project.appStoreUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectPreviewCard extends StatelessWidget {
  const _ProjectPreviewCard({
    required this.project,
    required this.isSelected,
    required this.onTap,
  });

  final ProjectItem project;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Color(project.accentHex);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF132538) : const Color(0xFF0C1825),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? accent : const Color(0xFF1A3047),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [accent.withOpacity(0.92), const Color(0xFF10263A)],
                ),
              ),
              child: const Icon(Icons.phone_android_rounded, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project.category,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: accent),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.arrow_forward_rounded
                  : Icons.keyboard_arrow_right_rounded,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectDetailCard extends StatefulWidget {
  const _ProjectDetailCard({required this.project, super.key});

  final ProjectItem project;

  @override
  State<_ProjectDetailCard> createState() => _ProjectDetailCardState();
}

class _ProjectDetailCardState extends State<_ProjectDetailCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion && _controller.value < 1) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _reveal(
    Widget child, {
    required double begin,
    required double end,
    bool scale = false,
  }) {
    if (_reduceMotion) {
      return child;
    }

    final animation = _controller.drive(
      CurveTween(curve: Interval(begin, end, curve: Curves.easeOutCubic)),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.045),
          end: Offset.zero,
        ).animate(animation),
        child: scale
            ? ScaleTransition(
                scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
                child: child,
              )
            : child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final accent = Color(project.accentHex);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _reveal(
              Container(
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withOpacity(0.96),
                      const Color(0xFF0A1723),
                      accent.withOpacity(0.18),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 22,
                      top: 22,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          project.category,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          size: 74,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 18,
                      bottom: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.24),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Mock preview image',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              begin: 0,
              end: 0.34,
              scale: true,
            ),
            const SizedBox(height: 20),
            _reveal(
              Text(
                project.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              begin: 0.22,
              end: 0.44,
            ),
            const SizedBox(height: 10),
            _reveal(
              Text(
                project.summary,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              begin: 0.34,
              end: 0.56,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: project.tags.asMap().entries.map((entry) {
                final begin = (0.48 + entry.key * 0.065).clamp(0.0, 0.78);
                return _reveal(
                  Chip(
                    label: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  begin: begin,
                  end: (begin + 0.22).clamp(0.0, 1.0),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _reveal(
                  _PrimaryActionButton(
                    label: 'Demo Video',
                    icon: Icons.play_circle_fill_rounded,
                    onPressed: () => _launch(project.demoVideoUrl),
                  ),
                  begin: 0.67,
                  end: 0.88,
                ),
                _reveal(
                  _SecondaryActionButton(
                    label: 'Live Project',
                    icon: Icons.open_in_new_rounded,
                    onPressed: () => _launch(project.liveUrl),
                  ),
                  begin: 0.72,
                  end: 0.93,
                ),
                _reveal(
                  _SecondaryActionButton(
                    label: 'Play Store',
                    icon: Icons.shop_2_rounded,
                    onPressed: () => _launch(project.playStoreUrl),
                  ),
                  begin: 0.77,
                  end: 0.98,
                ),
                _reveal(
                  _SecondaryActionButton(
                    label: 'App Store',
                    icon: Icons.apple_rounded,
                    onPressed: () => _launch(project.appStoreUrl),
                  ),
                  begin: 0.8,
                  end: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.profile,
    required this.contacts,
    required this.isDesktop,
    required this.controller,
    required this.animate,
  });

  final PortfolioProfile profile;
  final List<ContactItem> contacts;
  final bool isDesktop;
  final AnimationController controller;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final intro = _StageReveal(
      controller: controller,
      isActive: animate,
      begin: 0.3,
      end: 0.62,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1825),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF1A3047)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Let\'s build something useful',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'This mock portfolio is already arranged so a future Supabase layer can replace static content with dynamic project, profile, and contact data.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            _PrimaryActionButton(
              label: 'Email Me',
              icon: Icons.send_rounded,
              onPressed: () => _launch('mailto:${profile.email}'),
            ),
          ],
        ),
      ),
    );

    final contactsList = Column(
      children: contacts.asMap().entries.map((entry) {
        final index = entry.key;
        final contact = entry.value;
        final start = 0.38 + (index * 0.16);
        return _StageReveal(
          controller: controller,
          isActive: animate,
          begin: start,
          end: (start + 0.3).clamp(0.0, 1.0).toDouble(),
          scale: true,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(
                      Icons.contact_page_rounded,
                      color: Color(0xFF21C7F6),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF9CB0C4)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact.value,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _launch(contact.url),
                      child: Text(contact.actionLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: intro),
              const SizedBox(width: 22),
              Expanded(flex: 5, child: contactsList),
            ],
          )
        : Column(children: [intro, const SizedBox(height: 18), contactsList]);
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xCC09131F),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF1A3047)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 30,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF21C7F6),
        foregroundColor: const Color(0xFF031019),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF2E4B69)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1825),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF1A3047)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF21C7F6)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launch(String rawUrl) async {
  final uri = Uri.parse(rawUrl);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

IconData _iconForName(String iconName) {
  switch (iconName) {
    case 'github':
      return Icons.code_rounded;
    case 'linkedin':
      return Icons.work_rounded;
    case 'youtube':
      return Icons.ondemand_video_rounded;
    case 'email':
      return Icons.mail_rounded;
    default:
      return Icons.link_rounded;
  }
}

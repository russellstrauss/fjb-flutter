import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SocialLink(
            iconPath: 'assets/images/instagram-icon.svg',
            label: 'Instagram',
            url: 'https://www.instagram.com/farmerjohnsbotanicals/',
          ),
          const SizedBox(width: 20),
          _SocialLink(
            iconPath: 'assets/images/email-icon.svg',
            label: 'Email',
            url: 'mailto:farmerjsbotanicals@gmail.com',
          ),
        ],
      ),
    );
  }
}

class _SocialLink extends StatelessWidget {
  final String iconPath;
  final String label;
  final String url;

  const _SocialLink({
    required this.iconPath,
    required this.label,
    required this.url,
  });

  Future<void> _launchUrl() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // On Flutter Web, strip 'assets/' prefix to avoid double prefix issue
    // Flutter Web automatically prepends '/assets/' to asset paths
    String assetPath = iconPath;
    if (kIsWeb && assetPath.startsWith('assets/')) {
      assetPath = assetPath.substring(7); // Remove 'assets/' prefix
    }

    return InkWell(
      onTap: _launchUrl,
      child: SvgPicture.asset(
        assetPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}






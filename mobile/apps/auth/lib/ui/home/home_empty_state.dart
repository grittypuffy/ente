import 'package:ente_auth/ui/settings/data/import_page.dart';
import 'package:ente_auth/utils/navigation_util.dart' as auth_nav;
import 'package:ente_auth/utils/platform_util.dart';
import 'package:ente_components/ente_components.dart';
import 'package:ente_pure_utils/ente_pure_utils.dart';
import 'package:ente_strings/ente_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeEmptyStateWidget extends StatelessWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onImportImageTap;
  final VoidCallback? onManuallySetupTap;

  const HomeEmptyStateWidget({
    super.key,
    required this.onScanTap,
    required this.onImportImageTap,
    required this.onManuallySetupTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.strings;
    final colors = context.componentColors;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final bgSvgPath = isDarkTheme
        ? 'assets/svg/empty-state-bg-dark.svg'
        : 'assets/svg/empty-state-bg-light.svg';

    return Semantics(
      container: true,
      identifier: 'auth_empty_state',
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(
                left: Spacing.xl,
                right: Spacing.xl,
                bottom: Spacing.xl,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 128,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                bottom: 6,
                                child: SvgPicture.asset(
                                  bgSvgPath,
                                  width: 224,
                                  height: 96,
                                  excludeFromSemantics: true,
                                ),
                              ),
                              Image.asset(
                                'assets/onboarding-2.png',
                                height: 96,
                                excludeFromSemantics: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Spacing.xl),
                        SizedBox(
                          width: 280,
                          child: Semantics(
                            header: true,
                            headingLevel: 1,
                            child: Text(
                              l10n.setupFirstAccount,
                              textAlign: TextAlign.center,
                              style: TextStyles.h1.copyWith(
                                color: colors.textBase,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (PlatformDetector.isMobile()) ...[
                            Semantics(
                              identifier: 'auth_empty_scan',
                              child: ButtonComponent(
                                variant: ButtonComponentVariant.primary,
                                leading: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedQrCode,
                                  size: IconSizes.medium,
                                ),
                                label: l10n.scanAQrCode,
                                onTap: onScanTap,
                              ),
                            ),
                          ] else ...[
                            Semantics(
                              identifier: 'auth_empty_gallery',
                              child: ButtonComponent(
                                leading: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedAlbum02,
                                  size: IconSizes.medium,
                                ),
                                label: l10n.importFromGallery,
                                onTap: onImportImageTap,
                              ),
                            ),
                          ],
                          const SizedBox(height: Spacing.md),
                          Semantics(
                            identifier: 'auth_empty_manual_setup',
                            child: ButtonComponent(
                              leading: const HugeIcon(
                                icon: HugeIcons.strokeRoundedKey01,
                                size: IconSizes.medium,
                              ),
                              label: l10n.importEnterSetupKey,
                              variant: ButtonComponentVariant.secondary,
                              onTap: onManuallySetupTap,
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ButtonComponent(
                                label: l10n.importCodes,
                                size: ButtonComponentSize.small,
                                leading: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedFileImport,
                                  size: IconSizes.medium,
                                ),
                                variant: ButtonComponentVariant.link,
                                onTap: () {
                                  auth_nav.routeToPage(
                                    context,
                                    const ImportCodePage(),
                                  );
                                },
                              ),
                              ButtonComponent(
                                label: l10n.faq,
                                size: ButtonComponentSize.small,
                                variant: ButtonComponentVariant.link,
                                linkUrl: Uri.parse(
                                  'https://ente.com/help/auth/faq',
                                ),
                                onTap: () {
                                  PlatformUtil.openUrlInBrowser(
                                    'https://ente.com/help/auth/faq',
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

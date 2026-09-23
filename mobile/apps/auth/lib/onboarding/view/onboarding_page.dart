import 'dart:async';
import 'dart:io';

import 'package:ente_accounts/pages/developer_settings_page.dart';
import 'package:ente_accounts/pages/email_entry_page.dart';
import 'package:ente_accounts/pages/login_page.dart';
import 'package:ente_accounts/pages/password_entry_page.dart';
import 'package:ente_accounts/pages/password_reentry_page.dart';
import 'package:ente_auth/app/view/app.dart';
import 'package:ente_auth/core/configuration.dart';
import 'package:ente_auth/events/trigger_logout_event.dart';
import 'package:ente_auth/locale.dart';
import 'package:ente_auth/theme/colors.dart';
import 'package:ente_auth/theme/ente_theme.dart';
import 'package:ente_auth/ui/account/logout_dialog.dart';
import 'package:ente_auth/ui/components/dialog_widget.dart';
import 'package:ente_auth/ui/home/widgets/rounded_action_buttons.dart';
import 'package:ente_auth/ui/home_page.dart';
import 'package:ente_auth/ui/settings/developer_settings_widget.dart';
import 'package:ente_auth/ui/settings/language_picker.dart';
import 'package:ente_auth/utils/debug_build_flags.dart';
import 'package:ente_auth/utils/dialog_util.dart';
import 'package:ente_auth/utils/navigation_util.dart';
import 'package:ente_auth/utils/platform_util.dart';
import 'package:ente_auth/utils/toast_util.dart';
import 'package:ente_components/ente_components.dart';
import 'package:ente_events/event_bus.dart';
import 'package:ente_strings/ente_strings.dart';
import 'package:ente_ui/components/alert_bottom_sheet.dart';
import 'package:ente_ui/components/buttons/button_widget.dart';
import 'package:ente_ui/components/buttons/models/button_result.dart';
import 'package:ente_ui/components/buttons/models/button_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';

class OnboardingPage extends StatefulWidget {
  final bool showOfflineKeyUnavailableDialog;

  const OnboardingPage({
    super.key,
    this.showOfflineKeyUnavailableDialog = false,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late StreamSubscription<TriggerLogoutEvent> _triggerLogoutEvent;

  @override
  void initState() {
    _triggerLogoutEvent = Bus.instance.on<TriggerLogoutEvent>().listen((
      event,
    ) async {
      if (!mounted) return;
      await autoLogoutAlert(context);
    });
    if (widget.showOfflineKeyUnavailableDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_showOfflineKeyUnavailableDialog());
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _triggerLogoutEvent.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building OnboardingPage");
    final l10n = context.strings;
    final textTheme = getEnteTextTheme(context);

    return Scaffold(
      backgroundColor: accentColor,
      appBar: AppBar(
        leading: const SizedBox(),
        title: SvgPicture.asset("assets/svg/app-logo.svg"),
        backgroundColor: accentColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: 1 != 1
            ? [
                GestureDetector(
                  onTap: () async {
                    final locale = (await getLocale())!;
                    if (!context.mounted) return;
                    unawaited(
                      routeToPage(
                        context,
                        LanguageSelectorPage(appSupportedLocales, (
                          locale,
                        ) async {
                          await setLocale(locale);
                          if (!context.mounted) return;
                          App.setLocale(context, locale);
                        }, locale),
                      ).then((value) {
                        setState(() {});
                      }),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      "Lang(i)",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ]
            : null,
      ),
      // [Accessibility] Allow scrolling so large text never overflows the
      // screen.
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 28),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _FeatureItemWidget(
                    assetPath: 'assets/onboarding-1.png',
                    title: l10n.featureBackupCodes,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            // [Accessibility] Keep both buttons equal height when labels
            // wrap.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: RoundedButton(
                          label: l10n.signUp,
                          onPressed: _navigateToSignUpPage,
                          type: RoundedButtonType.secondaryInverse,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: RoundedButton(
                          label: l10n.logInLabel,
                          onPressed: _navigateToSignInPage,
                          type: RoundedButtonType.primaryInverse,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // [Accessibility] Keep wrapped labels centered.
            Center(
              child: TextButton(
                onPressed: _optForOfflineMode,
                child: Text(
                  l10n.useOffline,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyBold.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const DeveloperSettingsWidget(),
            // [Accessibility] Remove requirement for 7-tap for non-phantom
            // perception of developer settings for assistive technology users
            Center(
              child: TextButton(
                onPressed: () => _openDeveloperSettings(context),
                child: Text(
                  l10n.developerSettings,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyBold.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDeveloperSettings(BuildContext context) async {
    await showAlertBottomSheet(
      context,
      title: context.strings.developerSettings,
      message: context.strings.developerSettingsWarning,
      assetPath: 'assets/warning-grey.png',
      isDismissible: false,
      showCloseButton: false,
      buttons: [
        ButtonComponent(
          label: context.strings.yes,
          onTap: () async {
            Navigator.of(context).pop();
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return DeveloperSettingsPage(
                    getCurrentEndpoint: () =>
                        Configuration.instance.getHttpEndpoint(),
                    setEndpoint: (url) async =>
                        Configuration.instance.setHttpEndpoint(url),
                  );
                },
              ),
            );
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ],
    );
  }

  Future<void> _optForOfflineMode() async {
    bool canCheckBio =
        Platform.isMacOS ||
        Platform.isLinux ||
        Platform.isWindows ||
        await LocalAuthentication().canCheckBiometrics;
    if (!canCheckBio) {
      if (!mounted) return;
      showToast(
        context,
        "Sorry, biometric authentication is not supported on this device.",
      );
      return;
    }
    final bool hasOptedBefore = Configuration.instance.hasOptedForOfflineMode();
    if (!Configuration.instance.hasConfiguredAccount() &&
        hasOptedBefore &&
        Configuration.instance.getOfflineSecretKey() == null) {
      await _showOfflineKeyUnavailableDialog();
      return;
    }
    ButtonResult? result;
    if (!hasOptedBefore && !shouldSkipAuthGuidance) {
      if (!mounted) return;
      result = await showChoiceActionSheet(
        context,
        title: context.strings.warning,
        body: context.strings.offlineModeWarning,
        secondButtonLabel: context.strings.cancel,
        firstButtonLabel: context.strings.ok,
      );
    }
    if (hasOptedBefore ||
        shouldSkipAuthGuidance ||
        result?.action == ButtonAction.first) {
      if (!context.mounted) return;
      await Configuration.instance.optForOfflineMode();
      if (!mounted) return;
      unawaited(
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const HomePage();
            },
          ),
        ),
      );
    }
  }

  Future<void> _showOfflineKeyUnavailableDialog() async {
    if (!mounted) return;
    final l10n = context.strings;
    await showDialogWidget(
      context: context,
      title: l10n.unableToAccessYourCodes,
      body: l10n.offlineKeyUnavailableMessage,
      buttons: [
        ButtonWidget(
          buttonType: ButtonType.neutral,
          labelText: l10n.troubleshooting,
          onTap: () => PlatformUtil.openUrlInBrowser(
            "https://ente.com/help/auth/troubleshooting/offline-codes-unavailable",
          ),
        ),
      ],
      isDismissible: false,
    );
  }

  void _navigateToSignUpPage() {
    Widget page;
    if (Configuration.instance.getEncryptedToken() == null) {
      page = EmailEntryPage(Configuration.instance);
    } else {
      if (Configuration.instance.getKeyAttributes() == null) {
        page = PasswordEntryPage(
          Configuration.instance,
          PasswordEntryMode.set,
          const HomePage(),
        );
      } else if (Configuration.instance.getKey() == null) {
        page = PasswordReentryPage(Configuration.instance, const HomePage());
      } else {
        page = const HomePage();
      }
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }

  void _navigateToSignInPage() {
    Widget page;
    if (Configuration.instance.getEncryptedToken() == null) {
      page = LoginPage(Configuration.instance);
    } else {
      if (Configuration.instance.getKeyAttributes() == null) {
        page = PasswordEntryPage(
          Configuration.instance,
          PasswordEntryMode.set,
          const HomePage(),
        );
      } else if (Configuration.instance.getKey() == null) {
        page = PasswordReentryPage(Configuration.instance, const HomePage());
      } else {
        page = const HomePage();
      }
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }
}

class _FeatureItemWidget extends StatelessWidget {
  const _FeatureItemWidget({required this.assetPath, required this.title});

  final String assetPath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(assetPath, height: 188, excludeFromSemantics: true),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            title,
            style: getEnteTextTheme(
              context,
            ).largeBold.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

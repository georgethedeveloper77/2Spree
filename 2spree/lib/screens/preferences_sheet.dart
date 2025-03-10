import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:reddigram/app.dart';
import 'package:reddigram/consts.dart';
import 'package:reddigram/store/store.dart';
import 'package:reddigram/widgets/loaders/color_loader_2.dart';
import 'package:reddigram/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class PreferencesSheet extends StatelessWidget {
  void _connectToReddit(BuildContext context) async {
    ReddigramApp.analytics.logEvent(name: 'login_attempt');

    if (await _showRedditBugWarningAlert(context) != true) return;

    launch('https://www.reddit.com/api/v1/authorize'
        '?client_id=${GlanceConsts.oauthClientId}&response_type=code'
        '&state=x&scope=read+mysubreddits+vote+identity&duration=permanent'
        '&redirect_uri=${GlanceConsts.oauthRedirectUrl}');
  }

  Future<bool> _showRedditBugWarningAlert(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Warning',style: TextStyle(color: Colors.red),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.body1,
                children: [
                  const TextSpan(
                      text: 'Due to Reddit\'s bug, '
                          'if you are unable to sign in please turn on '),
                  const TextSpan(
                    text: 'Desktop site',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' option and try again. '),
                  TextSpan(
                    text: 'Read more',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          launch('https://www.reddit.com/r/bugs/comments/dc8cea'
                              '/cant_sign_in_on_mobile_on_logindest/'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Image.asset('assets/chrome_desktop_site.png'),
          ],
        ),
        actions: [
          FlatButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    StoreProvider.of<ReddigramState>(context).dispatch(signUserOut());
    ReddigramApp.analytics.logEvent(name: 'sign_out');
  }

  void _openPrivacyPolicy() async {
    launch('https://reddigram.wolszon.me/privacy');
    ReddigramApp.analytics.logEvent(name: 'open_privacy_policy');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildConnectTile(),
        const ListTile(
          title: Text(
            'PREFERENCES',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          dense: true,
        ),
        const DarkThemePreferenceTile(),
        const ShowNsfwPreferenceTile(),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildConnectTile() {
    return StoreConnector<ReddigramState, AuthState>(
      converter: (store) => store.state.authState,
      builder: (context, authState) =>
          authState.status == AuthStatus.authenticated
              ? ListTile(
                  title: const Text('Sign out'),
                  trailing: Text(authState.username),
                  leading: const Icon(Icons.power_settings_new),
                  onTap: () => _signOut(context),
                )
              : ListTile(
                  title: const Text('Connect to Reddit'),
                  leading: const Icon(Icons.record_voice_over),
                  onTap: () => _connectToReddit(context),
                  trailing: authState.status == AuthStatus.authenticating
                      ? Transform.scale(
                          scale: 0.5,
                          child:  ColorLoader2(),
                        )
                      : null,
                ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return ListTile(
      enabled: false,
      dense: true,
      title: RichText(
        text: TextSpan(
          style: Theme.of(context)
              .textTheme
              .body2
              .copyWith(color: Theme.of(context).disabledColor),
          children: [
            const TextSpan(text: '2Spree • '),
            TextSpan(
              text: 'Privacy policy',
              style: const TextStyle(
                decoration: TextDecoration.underline,
              ),
              /*recognizer: TapGestureRecognizer()..onTap = _openPrivacyPolicy,*/
            ),
          ],
        ),
      ),
    );
  }
}

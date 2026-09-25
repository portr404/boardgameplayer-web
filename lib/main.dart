import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';

abstract final class AppDesign {
  static const Color ink = Color(0xFF071417);
  static const Color canvas = Color(0xFF0A1719);
  static const Color panel = Color(0xFF102326);
  static const Color panelRaised = Color(0xFF153034);
  static const Color teal = Color(0xFF54D6C2);
  static const Color tealDeep = Color(0xFF167E79);
  static const Color gold = Color(0xFFE4B85D);
  static const Color goldSoft = Color(0xFFFFD88A);
  static const Color text = Color(0xFFF4F0E7);
  static const Color textMuted = Color(0xFF9EB4B1);
  static const Color danger = Color(0xFFE88779);
  static const double radiusSmall = 12;
  static const double radiusMedium = 20;
  static const double radiusLarge = 28;
  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionMedium = Duration(milliseconds: 320);
  static const Curve motionCurve = Curves.easeOutCubic;

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF071417), Color(0xFF0C2022), Color(0xFF0A1719)],
  );
}

class BoardBackdrop extends StatelessWidget {
  const BoardBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppDesign.backgroundGradient),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0.025),
                      Colors.transparent,
                      AppDesign.teal.withValues(alpha: 0.035),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

const List<Locale> supportedLocales = <Locale>[
  Locale('it'),
  Locale('en'),
  Locale('fr'),
  Locale('de'),
  Locale('es'),
  Locale('pt'),
  Locale('ru'),
  Locale('zh'),
  Locale('ja'),
];

const Map<String, String> languageFlags = <String, String>{
  'it': '🇮🇹',
  'en': '🇬🇧',
  'fr': '🇫🇷',
  'de': '🇩🇪',
  'es': '🇪🇸',
  'pt': '🇵🇹',
  'ru': '🇷🇺',
  'zh': '🇨🇳',
  'ja': '🇯🇵',
};

final ValueNotifier<Locale> appLocale = ValueNotifier<Locale>(
  supportedLocales.first,
);

class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings) ??
      AppStrings(appLocale.value);

  String get _language => locale.languageCode;

  static const Map<String, Map<String, String>>
  _values = <String, Map<String, String>>{
    'it': <String, String>{
      'loginWelcome': 'Bentornato al tavolo',
      'registerWelcome': 'Apri il tuo tavolo',
      'loginDescription':
          'Accedi per ritrovare le tue partite su ogni dispositivo.',
      'email': 'Email',
      'password': 'Password',
      'login': 'Accedi',
      'register': 'Crea account',
      'newAccount': 'Crea un nuovo account',
      'existingAccount': 'Ho già un account',
      'google': 'Continua con Google',
      'logout': 'Esci dall’account',
      'newGame': 'Crea una partita',
      'ready': 'Il tavolo è pronto',
      'readyDescription': 'Crea la prima partita per iniziare la serata.',
      'noPlayers': 'Nessun giocatore presente',
      'dice': 'Lancia dadi',
      'firstPlayer': 'Estrai primo giocatore',
      'addPlayer': 'Aggiungi giocatore',
      'delete': 'Elimina',
      'cancel': 'Annulla',
      'save': 'Salva',
      'close': 'Chiudi',
      'roll': 'Lancia',
      'games': 'partite',
      'players': 'giocatori',
      'updated': 'Aggiornata il',
      'contact': 'Creato da Francesco Fasolato',
      'language': 'Lingua',
      'authError': 'Accesso non riuscito. Riprova.',
      'popupClosed':
          'La finestra Google è stata chiusa. Riprova o consenti i popup.',
      'unauthorizedDomain':
          'Questo dominio non è autorizzato in Firebase Authentication.',
      'popupBlocked': 'Il popup è stato bloccato. Riprova per usare il reindirizzamento Google.',
    },
    'en': <String, String>{
      'loginWelcome': 'Welcome back to the table',
      'registerWelcome': 'Open your table',
      'loginDescription': 'Sign in to find your games on every device.',
      'email': 'Email',
      'password': 'Password',
      'login': 'Sign in',
      'register': 'Create account',
      'newAccount': 'Create a new account',
      'existingAccount': 'I already have an account',
      'google': 'Continue with Google',
      'logout': 'Sign out',
      'newGame': 'Create a game',
      'ready': 'The table is ready',
      'readyDescription': 'Create your first game to start the evening.',
      'noPlayers': 'No players yet',
      'dice': 'Roll dice',
      'firstPlayer': 'Draw first player',
      'addPlayer': 'Add player',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'save': 'Save',
      'close': 'Close',
      'roll': 'Roll',
      'games': 'games',
      'players': 'players',
      'updated': 'Updated on',
      'contact': 'Created by Francesco Fasolato',
      'language': 'Language',
      'authError': 'Sign-in failed. Try again.',
      'popupClosed': 'The Google window was closed. Try again or allow popups.',
      'unauthorizedDomain':
          'This domain is not authorized in Firebase Authentication.',
      'popupBlocked':
          'The popup was blocked. Try again to use Google redirect.',
    },
    'fr': <String, String>{
      'loginWelcome': 'Bon retour à la table',
      'registerWelcome': 'Ouvrez votre table',
      'loginDescription':
          'Connectez-vous pour retrouver vos parties sur chaque appareil.',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'login': 'Se connecter',
      'register': 'Créer un compte',
      'newAccount': 'Créer un nouveau compte',
      'existingAccount': 'J’ai déjà un compte',
      'google': 'Continuer avec Google',
      'logout': 'Se déconnecter',
      'newGame': 'Créer une partie',
      'ready': 'La table est prête',
      'readyDescription': 'Créez votre première partie pour commencer.',
      'noPlayers': 'Aucun joueur',
      'dice': 'Lancer les dés',
      'firstPlayer': 'Tirer le premier joueur',
      'addPlayer': 'Ajouter un joueur',
      'delete': 'Supprimer',
      'cancel': 'Annuler',
      'save': 'Enregistrer',
      'close': 'Fermer',
      'roll': 'Lancer',
      'games': 'parties',
      'players': 'joueurs',
      'updated': 'Mise à jour le',
      'contact': 'Créé par Francesco Fasolato',
      'language': 'Langue',
      'authError': 'Échec de la connexion. Réessayez.',
      'popupClosed': 'La fenêtre Google a été fermée. Réessayez ou autorisez les fenêtres popup.',
      'unauthorizedDomain':
          'Ce domaine n’est pas autorisé dans Firebase Authentication.',
      'popupBlocked': 'La fenêtre popup a été bloquée. Réessayez avec la redirection Google.',
    },
    'de': <String, String>{
      'loginWelcome': 'Willkommen zurück am Tisch',
      'registerWelcome': 'Eröffne deinen Tisch',
      'loginDescription':
          'Melde dich an, um deine Spiele auf jedem Gerät zu finden.',
      'email': 'E-Mail',
      'password': 'Passwort',
      'login': 'Anmelden',
      'register': 'Konto erstellen',
      'newAccount': 'Neues Konto erstellen',
      'existingAccount': 'Ich habe bereits ein Konto',
      'google': 'Mit Google fortfahren',
      'logout': 'Abmelden',
      'newGame': 'Spiel erstellen',
      'ready': 'Der Tisch ist bereit',
      'readyDescription': 'Erstelle dein erstes Spiel und starte den Abend.',
      'noPlayers': 'Noch keine Spieler',
      'dice': 'Würfel werfen',
      'firstPlayer': 'Ersten Spieler ziehen',
      'addPlayer': 'Spieler hinzufügen',
      'delete': 'Löschen',
      'cancel': 'Abbrechen',
      'save': 'Speichern',
      'close': 'Schließen',
      'roll': 'Werfen',
      'games': 'Spiele',
      'players': 'Spieler',
      'updated': 'Aktualisiert am',
      'contact': 'Erstellt von Francesco Fasolato',
      'language': 'Sprache',
      'authError': 'Anmeldung fehlgeschlagen. Bitte erneut versuchen.',
      'popupClosed': 'Das Google-Fenster wurde geschlossen. Erlaube Popups und versuche es erneut.',
      'unauthorizedDomain':
          'Diese Domain ist in Firebase Authentication nicht autorisiert.',
      'popupBlocked': 'Das Popup wurde blockiert. Versuche es mit der Google-Weiterleitung.',
    },
    'es': <String, String>{
      'loginWelcome': 'Bienvenido de nuevo a la mesa',
      'registerWelcome': 'Abre tu mesa',
      'loginDescription':
          'Inicia sesión para encontrar tus partidas en cualquier dispositivo.',
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'login': 'Iniciar sesión',
      'register': 'Crear cuenta',
      'newAccount': 'Crear una cuenta nueva',
      'existingAccount': 'Ya tengo una cuenta',
      'google': 'Continuar con Google',
      'logout': 'Cerrar sesión',
      'newGame': 'Crear partida',
      'ready': 'La mesa está lista',
      'readyDescription': 'Crea tu primera partida para empezar.',
      'noPlayers': 'Aún no hay jugadores',
      'dice': 'Lanzar dados',
      'firstPlayer': 'Elegir primer jugador',
      'addPlayer': 'Añadir jugador',
      'delete': 'Eliminar',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'close': 'Cerrar',
      'roll': 'Lanzar',
      'games': 'partidas',
      'players': 'jugadores',
      'updated': 'Actualizada el',
      'contact': 'Creado por Francesco Fasolato',
      'language': 'Idioma',
      'authError': 'No se pudo iniciar sesión. Inténtalo de nuevo.',
      'popupClosed': 'La ventana de Google se cerró. Permite las ventanas emergentes y vuelve a intentarlo.',
      'unauthorizedDomain':
          'Este dominio no está autorizado en Firebase Authentication.',
      'popupBlocked': 'La ventana emergente fue bloqueada. Prueba con la redirección de Google.',
    },
    'pt': <String, String>{
      'loginWelcome': 'Bem-vindo de volta à mesa',
      'registerWelcome': 'Abra a sua mesa',
      'loginDescription':
          'Entre para encontrar os seus jogos em qualquer dispositivo.',
      'email': 'E-mail',
      'password': 'Palavra-passe',
      'login': 'Entrar',
      'register': 'Criar conta',
      'newAccount': 'Criar uma nova conta',
      'existingAccount': 'Já tenho uma conta',
      'google': 'Continuar com Google',
      'logout': 'Sair',
      'newGame': 'Criar jogo',
      'ready': 'A mesa está pronta',
      'readyDescription': 'Crie o seu primeiro jogo para começar.',
      'noPlayers': 'Ainda não há jogadores',
      'dice': 'Lançar dados',
      'firstPlayer': 'Sortear primeiro jogador',
      'addPlayer': 'Adicionar jogador',
      'delete': 'Eliminar',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'close': 'Fechar',
      'roll': 'Lançar',
      'games': 'jogos',
      'players': 'jogadores',
      'updated': 'Atualizado em',
      'contact': 'Criado por Francesco Fasolato',
      'language': 'Idioma',
      'authError': 'Não foi possível entrar. Tente novamente.',
      'popupClosed':
          'A janela do Google foi fechada. Permita popups e tente novamente.',
      'unauthorizedDomain':
          'Este domínio não está autorizado no Firebase Authentication.',
      'popupBlocked':
          'O popup foi bloqueado. Tente o redirecionamento do Google.',
    },
    'ru': <String, String>{
      'loginWelcome': 'С возвращением за стол',
      'registerWelcome': 'Откройте свой стол',
      'loginDescription': 'Войдите, чтобы найти свои игры на любом устройстве.',
      'email': 'Электронная почта',
      'password': 'Пароль',
      'login': 'Войти',
      'register': 'Создать аккаунт',
      'newAccount': 'Создать новый аккаунт',
      'existingAccount': 'У меня уже есть аккаунт',
      'google': 'Продолжить с Google',
      'logout': 'Выйти',
      'newGame': 'Создать игру',
      'ready': 'Стол готов',
      'readyDescription': 'Создайте первую игру, чтобы начать.',
      'noPlayers': 'Игроков пока нет',
      'dice': 'Бросить кубики',
      'firstPlayer': 'Выбрать первого игрока',
      'addPlayer': 'Добавить игрока',
      'delete': 'Удалить',
      'cancel': 'Отмена',
      'save': 'Сохранить',
      'close': 'Закрыть',
      'roll': 'Бросить',
      'games': 'игр',
      'players': 'игроков',
      'updated': 'Обновлено',
      'contact': 'Создано Франческо Фасолато',
      'language': 'Язык',
      'authError': 'Не удалось войти. Повторите попытку.',
      'popupClosed': 'Окно Google закрыто. Разрешите всплывающие окна и повторите попытку.',
      'unauthorizedDomain': 'Этот домен не разрешён в Firebase Authentication.',
      'popupBlocked':
          'Всплывающее окно заблокировано. Попробуйте перенаправление Google.',
    },
    'zh': <String, String>{
      'loginWelcome': '欢迎回到牌桌',
      'registerWelcome': '开启你的牌桌',
      'loginDescription': '登录后即可在所有设备上找到你的游戏。',
      'email': '电子邮箱',
      'password': '密码',
      'login': '登录',
      'register': '创建账户',
      'newAccount': '创建新账户',
      'existingAccount': '我已有账户',
      'google': '使用 Google 继续',
      'logout': '退出登录',
      'newGame': '创建游戏',
      'ready': '牌桌已准备好',
      'readyDescription': '创建第一场游戏，开始今晚的对局。',
      'noPlayers': '暂无玩家',
      'dice': '掷骰子',
      'firstPlayer': '抽取首位玩家',
      'addPlayer': '添加玩家',
      'delete': '删除',
      'cancel': '取消',
      'save': '保存',
      'close': '关闭',
      'roll': '掷骰',
      'games': '场游戏',
      'players': '位玩家',
      'updated': '更新于',
      'contact': '由 Francesco Fasolato 创建',
      'language': '语言',
      'authError': '登录失败，请重试。',
      'popupClosed': 'Google 窗口已关闭。请允许弹出窗口后重试。',
      'unauthorizedDomain': '此域名未获 Firebase Authentication 授权。',
      'popupBlocked': '弹出窗口被拦截。请尝试 Google 重定向。',
    },
    'ja': <String, String>{
      'loginWelcome': 'テーブルへおかえりなさい',
      'registerWelcome': 'あなたのテーブルを開く',
      'loginDescription': 'ログインすると、どの端末からでもゲームを利用できます。',
      'email': 'メールアドレス',
      'password': 'パスワード',
      'login': 'ログイン',
      'register': 'アカウント作成',
      'newAccount': '新しいアカウントを作成',
      'existingAccount': 'アカウントをお持ちですか',
      'google': 'Google で続行',
      'logout': 'ログアウト',
      'newGame': 'ゲームを作成',
      'ready': 'テーブルの準備完了',
      'readyDescription': '最初のゲームを作って夜を始めましょう。',
      'noPlayers': 'プレイヤーはいません',
      'dice': 'サイコロを振る',
      'firstPlayer': '最初のプレイヤーを選ぶ',
      'addPlayer': 'プレイヤーを追加',
      'delete': '削除',
      'cancel': 'キャンセル',
      'save': '保存',
      'close': '閉じる',
      'roll': '振る',
      'games': 'ゲーム',
      'players': 'プレイヤー',
      'updated': '更新日',
      'contact': 'Francesco Fasolato 作',
      'language': '言語',
      'authError': 'ログインできませんでした。もう一度お試しください。',
      'popupClosed': 'Google ウィンドウが閉じられました。ポップアップを許可して再試行してください。',
      'unauthorizedDomain': 'このドメインは Firebase Authentication で許可されていません。',
      'popupBlocked': 'ポップアップがブロックされました。Google リダイレクトをお試しください。',
    },
  };

  String text(String key) => _values[_language]?[key] ?? _values['en']![key]!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => supportedLocales.any(
    (Locale item) => item.languageCode == locale.languageCode,
  );

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (_, Locale locale, _) => PopupMenuButton<Locale>(
        tooltip: AppStrings.of(context).text('language'),
        onSelected: (Locale value) => appLocale.value = value,
        constraints: const BoxConstraints(minWidth: 72, maxWidth: 72),
        padding: EdgeInsets.zero,
        icon: Text(
          languageFlags[locale.languageCode] ?? '🌐',
          style: const TextStyle(fontSize: 24),
        ),
        itemBuilder: (_) => supportedLocales
            .map(
              (Locale value) => PopupMenuItem<Locale>(
                value: value,
                height: 58,
                child: Center(
                  child: Text(
                    languageFlags[value.languageCode] ?? '🌐',
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class CreditsFooter extends StatelessWidget {
  const CreditsFooter({super.key});

  Future<void> _openContactEmail() async {
    final String subject = Uri.encodeComponent(
      'BoardGamePlayer - segnalazione o recensione',
    );
    final String body = Uri.encodeComponent('Ciao Francesco,\n\n');
    final Uri email = Uri(
      scheme: 'mailto',
      path: 'portr404@gmail.com',
      query: 'subject=$subject&body=$body',
    );
    await launchUrl(email);
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Semantics(
        link: true,
        label: 'Contatta Francesco Fasolato per segnalazioni o recensioni',
        child: TextButton(
          onPressed: _openContactEmail,
          style: TextButton.styleFrom(
            foregroundColor: AppDesign.textMuted,
            padding: EdgeInsets.zero,
            minimumSize: const Size(52, 26),
            tapTargetSize: MaterialTapTargetSize.padded,
            textStyle: const TextStyle(
              fontSize: 11,
              letterSpacing: 0.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(strings.text('contact')),
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

const List<IconData> playerIcons = <IconData>[
  Icons.person_rounded,
  Icons.castle_rounded,
  Icons.shield_rounded,
  Icons.auto_awesome_rounded,
  Icons.explore_rounded,
  Icons.workspace_premium_rounded,
  Icons.dark_mode_rounded,
  Icons.bolt_rounded,
  Icons.map_rounded,
  Icons.star_rounded,
  Icons.favorite_rounded,
  Icons.rocket_launch_rounded,
  Icons.gamepad_rounded,
  Icons.group_rounded,
  Icons.menu_book_rounded,
  Icons.key_rounded,
  Icons.diamond_rounded,
  Icons.forest_rounded,
  Icons.tips_and_updates_rounded,
  Icons.emoji_events_rounded,
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme darkScheme = ColorScheme.fromSeed(
      seedColor: AppDesign.teal,
      brightness: Brightness.dark,
      primary: AppDesign.teal,
      onPrimary: AppDesign.ink,
      secondary: AppDesign.gold,
      onSecondary: AppDesign.ink,
      tertiary: AppDesign.goldSoft,
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: AppDesign.canvas,
      fontFamily: 'Trebuchet MS',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppDesign.canvas,
        foregroundColor: AppDesign.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppDesign.text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppDesign.panel,
        elevation: 0,
        shadowColor: AppDesign.teal.withValues(alpha: 0.16),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppDesign.panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkScheme.primary,
        foregroundColor: AppDesign.ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppDesign.panelRaised,
        selectedColor: AppDesign.tealDeep,
        secondarySelectedColor: AppDesign.tealDeep,
        labelStyle: const TextStyle(color: AppDesign.text),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppDesign.ink.withValues(alpha: 0.45),
        labelStyle: const TextStyle(color: AppDesign.textMuted),
        floatingLabelStyle: const TextStyle(color: AppDesign.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
          borderSide: const BorderSide(color: AppDesign.teal, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        space: 1,
      ),
      visualDensity: VisualDensity.standard,
    );

    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (_, Locale locale, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BoardGamePlayer',
        theme: darkTheme,
        locale: locale,
        supportedLocales: supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const GamesPage();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == null ? const AuthPage() : const GamesPage();
      },
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      if (_isRegistering) {
        await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (exception) {
      setState(() => _error = _authMessage(exception.code));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final GoogleAuthProvider provider = GoogleAuthProvider();
      if (kIsWeb) {
        try {
          await auth.signInWithPopup(provider);
        } on FirebaseAuthException catch (exception) {
          if (exception.code == 'popup-blocked' ||
              exception.code == 'popup-closed-by-user') {
            await auth.signInWithRedirect(provider);
            return;
          }
          rethrow;
        }
      } else {
        await auth.signInWithProvider(provider);
      }
    } on FirebaseAuthException catch (exception) {
      setState(() => _error = _authMessage(exception.code));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _authMessage(String code) {
    final AppStrings strings = AppStrings.of(context);
    switch (code) {
      case 'email-already-in-use':
        return strings.text('authError');
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return strings.text('authError');
      case 'weak-password':
        return strings.text('authError');
      case 'popup-closed-by-user':
        return strings.text('popupClosed');
      case 'popup-blocked':
        return strings.text('popupBlocked');
      case 'unauthorized-domain':
        return strings.text('unauthorizedDomain');
      default:
        return strings.text('authError');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    return Scaffold(
      body: BoardBackdrop(
        child: Stack(
          children: <Widget>[
            const Positioned(top: 12, right: 12, child: LanguagePicker()),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 56),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.035),
                      borderRadius: BorderRadius.circular(
                        AppDesign.radiusLarge,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Semantics(
                                label: 'Logo BoardGamePlayer',
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppDesign.gold.withValues(
                                      alpha: 0.12,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    size: 34,
                                    color: AppDesign.goldSoft,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'BOARDGAMEPLAYER',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: AppDesign.goldSoft,
                                      letterSpacing: 2.4,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isRegistering
                                    ? strings.text('registerWelcome')
                                    : strings.text('loginWelcome'),
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                strings.text('loginDescription'),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppDesign.textMuted),
                              ),
                              const SizedBox(height: 26),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: strings.text('email'),
                                  prefixIcon: const Icon(Icons.alternate_email),
                                ),
                                validator: (String? value) =>
                                    value == null || !value.contains('@')
                                    ? 'Inserisci un’email valida'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: strings.text('password'),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                ),
                                validator: (String? value) =>
                                    value == null || value.length < 6
                                    ? 'Almeno 6 caratteri'
                                    : null,
                              ),
                              if (_error != null) ...<Widget>[
                                const SizedBox(height: 12),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _busy ? null : _submitEmail,
                                  icon: Icon(
                                    _isRegistering
                                        ? Icons.person_add
                                        : Icons.login,
                                  ),
                                  label: Text(
                                    _isRegistering
                                        ? strings.text('register')
                                        : strings.text('login'),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _busy
                                    ? null
                                    : () => setState(() {
                                        _isRegistering = !_isRegistering;
                                        _error = null;
                                      }),
                                child: Text(
                                  _isRegistering
                                      ? strings.text('existingAccount')
                                      : strings.text('newAccount'),
                                ),
                              ),
                              const Divider(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _busy ? null : _signInWithGoogle,
                                  icon: const Icon(
                                    Icons.g_mobiledata,
                                    size: 28,
                                  ),
                                  label: Text(strings.text('google')),
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
            ),
            const Positioned(
              left: 16,
              right: 16,
              bottom: 4,
              child: Center(child: CreditsFooter()),
            ),
          ],
        ),
      ),
    );
  }
}

enum TimerState { stopped, running, paused }

enum DieType {
  d4(4),
  d6(6),
  d8(8),
  d10(10),
  d12(12),
  d20(20),
  d100(100);

  const DieType(this.faces);

  final int faces;

  String get label => 'd$faces';
}

abstract class RandomSource {
  int nextInt(int max);
}

class DartRandomSource implements RandomSource {
  DartRandomSource([Random? random]) : _random = random ?? Random();

  final Random _random;

  @override
  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(
        max,
        'max',
        'Il numero di facce deve essere > 0',
      );
    }
    return _random.nextInt(max);
  }
}

class DiceRollController {
  DiceRollController({RandomSource? randomSource})
    : _randomSource = randomSource ?? DartRandomSource();

  final RandomSource _randomSource;

  int roll(DieType dieType) {
    return _randomSource.nextInt(dieType.faces) + 1;
  }
}

Future<void> showDiceSheet(
  BuildContext context, {
  RandomSource? randomSource,
}) async {
  final bool useBottomSheet = MediaQuery.sizeOf(context).width < 700;
  final Widget content = DiceRollSheet(randomSource: randomSource);

  if (useBottomSheet) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => content,
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: content,
      ),
    ),
  );
}

class DiceRollSheet extends StatefulWidget {
  const DiceRollSheet({
    super.key,
    this.initialType = DieType.d20,
    this.randomSource,
  });

  final DieType initialType;
  final RandomSource? randomSource;

  @override
  State<DiceRollSheet> createState() => _DiceRollSheetState();
}

class _DiceRollSheetState extends State<DiceRollSheet> {
  late final DiceRollController _controller;
  late DieType _selectedDie;
  int? _result;

  @override
  void initState() {
    super.initState();
    _selectedDie = widget.initialType;
    _controller = DiceRollController(
      randomSource: widget.randomSource ?? DartRandomSource(),
    );
    _result = null;
  }

  void _rollDice() {
    final int preparedResult = _controller.roll(_selectedDie);
    setState(() => _result = preparedResult);
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    final List<Widget> dieOptions = DieType.values
        .map(
          (DieType dieType) => ChoiceChip(
            label: Text(dieType.label),
            selected: _selectedDie == dieType,
            onSelected: (_) => setState(() => _selectedDie = dieType),
          ),
        )
        .toList();

    final bool isExtreme =
        _result != null && (_result == 1 || _result == _selectedDie.faces);

    final double resultSize = (MediaQuery.sizeOf(context).width - 64).clamp(
      160.0,
      220.0,
    );
    final Widget resultDisplay = AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppDesign.motionMedium,
      curve: AppDesign.motionCurve,
      width: resultSize,
      height: resultSize,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isExtreme
              ? <Color>[
                  Colors.amber.shade200,
                  Colors.orange.shade500,
                  Colors.red.shade400,
                ]
              : <Color>[
                  const Color(0xFF123E52),
                  const Color(0xFF1A6B87),
                  const Color(0xFF2B9BB6),
                ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (isExtreme ? Colors.orange : Colors.blue).withValues(
              alpha: 0.35,
            ),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Semantics(
            liveRegion: true,
            label: 'Risultato ${_result ?? 1} sul dado ${_selectedDie.label}',
            child: Text(
              '${_result ?? 1}',
              style: const TextStyle(
                fontSize: 78,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedDie.label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );

    final BoxDecoration mysticalSheetDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xFF101827),
          const Color(0xFF151E35),
          const Color(0xFF10151F),
        ],
      ),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    );

    return Container(
      decoration: mysticalSheetDecoration,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  strings.locale.languageCode == 'it'
                      ? 'Dadi'
                      : strings.text('dice'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dado attivo: ${_selectedDie.label}',
                  style: const TextStyle(
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: dieOptions,
                ),
                const SizedBox(height: 22),
                resultDisplay,
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: _rollDice,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppDesign.teal,
                      foregroundColor: AppDesign.ink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(strings.text('roll')),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(strings.text('close')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Player {
  Player({required this.id, required this.name, this.iconIndex = 0});

  final int id;
  String name;
  int iconIndex;
  Duration elapsed = Duration.zero;
  TimerState timerState = TimerState.stopped;
  int turns = 0;
  double score = 0;
  double scoreStep = 1;
  Timer? timer;

  void dispose() => timer?.cancel();

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'iconIndex': iconIndex,
    'elapsed': elapsed.inSeconds,
    'turns': turns,
    'score': score,
    'scoreStep': scoreStep,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    final Player player = Player(
      id: json['id'] as int,
      name: json['name'] as String,
      iconIndex: (json['iconIndex'] as int?) ?? 0,
    );
    player.elapsed = Duration(seconds: (json['elapsed'] as int?) ?? 0);
    player.turns = ((json['turns'] as int?) ?? 0).clamp(0, 99);
    player.score = (json['score'] as num?)?.toDouble() ?? 0;
    player.scoreStep = (json['scoreStep'] as num?)?.toDouble() ?? 1;
    return player;
  }
}

class Game {
  Game({required this.id, required this.name, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now(),
      updatedAt = DateTime.now();

  final String id;
  String name;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<Player> players = <Player>[];
  int nextPlayerId = 1;
  int? selectedFirstPlayerId;

  int? pickRandomFirstPlayer({Random? randomSource}) {
    if (players.isEmpty) {
      return null;
    }

    final Random random = randomSource ?? Random();
    final int index = random.nextInt(players.length);
    return players[index].id;
  }

  void clearSelectedFirstPlayerIfRemoved(Player player) {
    if (selectedFirstPlayerId == player.id) {
      selectedFirstPlayerId = null;
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'nextPlayerId': nextPlayerId,
    'selectedFirstPlayerId': selectedFirstPlayerId,
    'players': players.map((Player player) => player.toJson()).toList(),
  };

  factory Game.fromJson(Map<String, dynamic> json) {
    final Game game = Game(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
    game.updatedAt = DateTime.parse(json['updatedAt'] as String);
    game.nextPlayerId = (json['nextPlayerId'] as int?) ?? 1;
    game.players.addAll(
      (json['players'] as List<dynamic>? ?? <dynamic>[]).map(
        (dynamic item) => Player.fromJson(item as Map<String, dynamic>),
      ),
    );

    final dynamic rawSelectedFirstPlayerId =
        json['selectedFirstPlayerId'] ??
        json['selected_first_player_id'] ??
        json['firstPlayerId'];
    game.selectedFirstPlayerId = rawSelectedFirstPlayerId == null
        ? null
        : (rawSelectedFirstPlayerId as num?)?.toInt() ??
              int.tryParse(rawSelectedFirstPlayerId.toString());

    if (game.selectedFirstPlayerId != null &&
        !game.players.any(
          (Player player) => player.id == game.selectedFirstPlayerId,
        )) {
      game.selectedFirstPlayerId = null;
    }

    return game;
  }
}

class GameStore {
  static const String key = 'board_game_player_games';
  static const String _gamesField = 'games';
  Future<void> _lastSave = Future<void>.value();
  SharedPreferences? _cachedPreferences;

  static String storageKeyForUser(String? userId) {
    final String normalizedUserId = (userId ?? '').trim();
    return normalizedUserId.isEmpty
        ? '${key}_guest'
        : '${key}_$normalizedUserId';
  }

  String _storageKeyForCurrentUser() => storageKeyForUser(_currentUser?.uid);

  Future<SharedPreferences> _getPreferences() async {
    return _cachedPreferences ??= await SharedPreferences.getInstance();
  }

  Future<List<Game>> load() async {
    final SharedPreferences preferences = await _getPreferences();
    final User? user = _currentUser;
    final String storageKey = _storageKeyForCurrentUser();
    final String? raw = preferences.getString(storageKey);
    final List<Game> localGames = _decode(raw ?? preferences.getString(key));

    if (user == null) {
      return localGames;
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final dynamic remoteGames = snapshot.data()?[_gamesField];
      if (remoteGames is List<dynamic>) {
        final List<Game> games = _decodeList(remoteGames);
        await preferences.setString(
          storageKey,
          jsonEncode(games.map((Game game) => game.toJson()).toList()),
        );
        await preferences.remove(key);
        return games;
      }
      if (localGames.isNotEmpty) {
        await _saveToCloud(user, localGames);
      }
    } on FirebaseException {
      return localGames;
    }

    return localGames;
  }

  List<Game> _decode(String? raw) {
    if (raw == null) return <Game>[];
    try {
      return _decodeList(jsonDecode(raw) as List<dynamic>);
    } catch (_) {
      return <Game>[];
    }
  }

  List<Game> _decodeList(List<dynamic> rawGames) {
    try {
      return rawGames
          .map((dynamic item) => Game.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <Game>[];
    }
  }

  User? get _currentUser {
    try {
      return FirebaseAuth.instance.currentUser;
    } on FirebaseException {
      return null;
    } on StateError {
      return null;
    }
  }

  Future<void> _saveToCloud(User user, List<Game> games) {
    return FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      <String, dynamic>{
        _gamesField: games.map((Game game) => game.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> save(List<Game> games) async {
    _lastSave = _lastSave.then((_) async {
      final SharedPreferences preferences = await _getPreferences();
      final String storageKey = _storageKeyForCurrentUser();
      final String payload = jsonEncode(
        games.map((Game game) => game.toJson()).toList(),
      );
      final bool saved = await preferences.setString(storageKey, payload);
      if (!saved) throw StateError('Salvataggio locale non riuscito.');
      final User? user = _currentUser;
      if (user == null) {
        await preferences.setString(key, payload);
      } else {
        await preferences.remove(key);
      }
      if (user != null) {
        try {
          await _saveToCloud(user, games);
        } on FirebaseException {
          // Local persistence remains available when the network is offline.
        }
      }
    });
    await _lastSave;
  }
}

class DiceLauncherButton extends StatelessWidget {
  const DiceLauncherButton({
    super.key,
    required this.onPressed,
    this.label = 'Lancia dadi',
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: FloatingActionButton.extended(
        heroTag: 'dice-launcher-main',
        onPressed: onPressed,
        tooltip: label,
        backgroundColor: AppDesign.teal,
        foregroundColor: AppDesign.ink,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.casino),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> with WidgetsBindingObserver {
  final GameStore store = GameStore();
  List<Game> games = <Game>[];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadGames();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(store.save(games));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final Game game in games) {
      for (final Player player in game.players) {
        player.dispose();
      }
    }
    super.dispose();
  }

  Future<void> loadGames() async {
    try {
      final List<Game> loaded = await store.load();
      if (!mounted) return;
      setState(() {
        games = loaded;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<String?> gameNameDialog({String? initial}) async {
    final TextEditingController controller = TextEditingController(
      text: initial,
    );
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(initial == null ? 'Nuova partita' : 'Modifica partita'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nome della partita',
            hintText: 'Es. Serata del venerdì',
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () {
              final String value = controller.text.trim();
              if (value.isNotEmpty && RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(value)) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('SALVA'),
          ),
        ],
      ),
    );
    controller.dispose();
    return name;
  }

  Future<void> addGame() async {
    final String? name = await gameNameDialog();
    if (name == null || !mounted) return;

    setState(() {
      games.add(
        Game(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name),
      );
    });
    await store.save(games);
  }

  Future<void> deleteGame(Game game) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Elimina partita'),
        content: Text(
          'Saranno eliminati anche giocatori e statistiche di "${game.name}".',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => games.remove(game));
    await store.save(games);
  }

  Future<void> openGame(Game game) async {
    final GameDetailPage page = GameDetailPage(
      game: game,
      store: store,
      games: games,
    );

    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => page));

    if (mounted) {
      setState(() {});
    }
  }

  String dateLabel(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppDesign.canvas,
      appBar: AppBar(
        title: const Text('BoardGamePlayer'),
        actions: <Widget>[
          const LanguagePicker(),
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: strings.text('logout'),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: loading
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'create-game',
                  onPressed: addGame,
                  tooltip: strings.text('newGame'),
                  backgroundColor: AppDesign.gold,
                  foregroundColor: AppDesign.ink,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: BoardBackdrop(
        child: SafeArea(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: <Widget>[
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: games.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  24,
                                  24,
                                  120,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: AppDesign.teal.withValues(
                                          alpha: 0.10,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.casino_outlined,
                                        size: 42,
                                        color: AppDesign.teal,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      strings.text('ready'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      strings.text('readyDescription'),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppDesign.textMuted,
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  120,
                                ),
                                itemCount: games.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (BuildContext context, int index) {
                                  final Game game = games[index];
                                  return Semantics(
                                    button: true,
                                    label:
                                        '${strings.text('newGame')}: ${game.name}',
                                    child: Container(
                                      key: ValueKey<String>(game.id),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.035,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppDesign.radiusMedium,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.07,
                                          ),
                                        ),
                                      ),
                                      child: Card(
                                        child: ListTile(
                                          onTap: () => openGame(game),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                          leading: const CircleAvatar(
                                            backgroundColor: AppDesign.tealDeep,
                                            child: Icon(
                                              Icons.games_rounded,
                                              color: AppDesign.goldSoft,
                                            ),
                                          ),
                                          title: Text(
                                            game.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${game.players.length} ${strings.text('players')} • ${strings.text('updated')} ${dateLabel(game.updatedAt)}',
                                            style: const TextStyle(
                                              color: AppDesign.textMuted,
                                            ),
                                          ),
                                          trailing: IconButton(
                                            onPressed: () => deleteGame(game),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            tooltip: strings.text('delete'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 34,
                      child: Center(
                        child: DiceLauncherButton(
                          onPressed: () => showDiceSheet(context),
                          label: strings.text('dice'),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 100,
                      bottom: 30,
                      child: CreditsFooter(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class GameDetailPage extends StatefulWidget {
  const GameDetailPage({
    super.key,
    required this.game,
    required this.store,
    required this.games,
  });

  final Game game;
  final GameStore store;
  final List<Game> games;

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage>
    with WidgetsBindingObserver {
  static const List<double> scoreSteps = <double>[0.5, 1, 5, 10, 50];

  final ScrollController _scrollController = ScrollController();
  bool _selectionAnimationVisible = false;

  Game get game => widget.game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(save());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    for (final Player player in game.players) {
      player.dispose();
    }
    super.dispose();
  }

  Future<void> selectFirstPlayer() async {
    if (game.players.isEmpty) {
      return;
    }

    final int? selectedId = game.pickRandomFirstPlayer(randomSource: Random());
    if (selectedId == null || !mounted) {
      return;
    }

    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    final int index = game.players.indexWhere(
      (Player player) => player.id == selectedId,
    );

    setState(() {
      game.selectedFirstPlayerId = selectedId;
      _selectionAnimationVisible = true;
    });

    if (!reduceMotion) {
      await Future<void>.delayed(const Duration(milliseconds: 240));
      if (!mounted) {
        return;
      }
      setState(() => _selectionAnimationVisible = false);
    } else {
      _selectionAnimationVisible = false;
    }

    await save();

    if (index == -1 || !_scrollController.hasClients) {
      return;
    }

    final double offset = index * 170.0;
    final double target = offset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    if (reduceMotion) {
      _scrollController.jumpTo(target);
      return;
    }

    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> save() async {
    game.updatedAt = DateTime.now();
    await widget.store.save(widget.games);
  }

  Future<String?> textDialog({
    required String title,
    required String label,
    String? initial,
    required bool Function(String) isValid,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: initial,
    );
    final String? value = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () {
              final String result = controller.text.trim();
              if (isValid(result)) Navigator.pop(dialogContext, result);
            },
            child: const Text('SALVA'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  Future<void> addOrEditPlayer({Player? player}) async {
    final String? name = await textDialog(
      title: player == null ? 'Aggiungi giocatore' : 'Modifica nome',
      label: 'Nome del giocatore',
      initial: player?.name,
      isValid: (String value) =>
          RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(value) &&
          !game.players.any(
            (Player item) =>
                item != player &&
                item.name.toLowerCase() == value.toLowerCase(),
          ),
    );
    if (name == null || !mounted) return;

    final int? iconIndex = await choosePlayerIcon(player?.iconIndex ?? 0);
    if (!mounted) return;

    setState(() {
      if (player == null) {
        game.players.add(
          Player(
            id: game.nextPlayerId++,
            name: name,
            iconIndex: iconIndex ?? 0,
          ),
        );
      } else {
        player.name = name;
        if (iconIndex != null) player.iconIndex = iconIndex;
      }
    });
    await save();
  }

  Future<int?> choosePlayerIcon(int currentIndex) => showDialog<int>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Scegli miniatura'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List<Widget>.generate(playerIcons.length, (int index) {
          return IconButton(
            onPressed: () => Navigator.pop(dialogContext, index),
            isSelected: index == currentIndex,
            icon: Icon(playerIcons[index]),
            tooltip: 'Miniatura ${index + 1}',
          );
        }),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('ANNULLA'),
        ),
      ],
    ),
  );

  Future<void> editTurns(Player player) async {
    final String? value = await textDialog(
      title: 'Modifica turni',
      label: 'Turni (0-99)',
      initial: '${player.turns}',
      isValid: (String value) {
        final int? parsed = int.tryParse(value);
        return parsed != null && parsed >= 0 && parsed <= 99;
      },
      keyboardType: TextInputType.number,
      formatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
    );
    final int? turns = value == null ? null : int.tryParse(value);
    if (turns != null && mounted) {
      setState(() => player.turns = turns);
      await save();
    }
  }

  Future<void> editScore(Player player) async {
    final String? value = await textDialog(
      title: 'Modifica punteggio',
      label: 'Punteggio',
      initial: formatNumber(player.score),
      isValid: (String value) =>
          double.tryParse(value.replaceAll(',', '.')) != null &&
          RegExp(r'^-?\d+([.,]\d)?$').hasMatch(value),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      formatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.-]')),
      ],
    );
    final double? score = value == null
        ? null
        : double.tryParse(value.replaceAll(',', '.'));
    if (score != null && mounted) {
      setState(() => player.score = score);
      await save();
    }
  }

  Future<void> removePlayer(Player player) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Elimina giocatore'),
        content: Text('Vuoi eliminare ${player.name}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() {
        player.dispose();
        game.clearSelectedFirstPlayerIfRemoved(player);
        game.players.remove(player);
      });
      await save();
    }
  }

  void toggleTimer(Player player) {
    setState(() {
      if (player.timerState == TimerState.running) {
        player.timer?.cancel();
        player.timerState = TimerState.paused;
      } else {
        player.timerState = TimerState.running;
        player.timer?.cancel();
        player.timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() => player.elapsed += const Duration(seconds: 1));
        });
      }
    });
    unawaited(save());
  }

  void stopTimer(Player player) {
    setState(() {
      player.timer?.cancel();
      player.timerState = TimerState.stopped;
      player.elapsed = Duration.zero;
    });
    unawaited(save());
  }

  String formatDuration(Duration value) =>
      '${value.inHours.toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';

  String formatNumber(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    final bool isPortraitMobile =
        MediaQuery.sizeOf(context).width < 700 &&
        MediaQuery.orientationOf(context) == Orientation.portrait;

    final Widget firstPlayerButton = isPortraitMobile
        ? FloatingActionButton(
            heroTag: 'first-player',
            onPressed: game.players.isEmpty ? null : selectFirstPlayer,
            tooltip: strings.text('firstPlayer'),
            backgroundColor: game.players.isEmpty
                ? AppDesign.panelRaised
                : AppDesign.gold,
            foregroundColor: game.players.isEmpty
                ? AppDesign.textMuted
                : AppDesign.ink,
            elevation: 12,
            child: const Icon(Icons.workspace_premium_rounded),
          )
        : FloatingActionButton.extended(
            heroTag: 'first-player',
            onPressed: game.players.isEmpty ? null : selectFirstPlayer,
            tooltip: strings.text('firstPlayer'),
            backgroundColor: game.players.isEmpty
                ? AppDesign.panelRaised
                : AppDesign.gold,
            foregroundColor: game.players.isEmpty
                ? AppDesign.textMuted
                : AppDesign.ink,
            elevation: 12,
            icon: const Icon(Icons.workspace_premium_rounded),
            label: Text(strings.text('firstPlayer')),
          );

    final Widget diceButton = isPortraitMobile
        ? FloatingActionButton(
            heroTag: 'dice-launcher',
            onPressed: () => showDiceSheet(context),
            tooltip: strings.text('dice'),
            backgroundColor: AppDesign.teal,
            foregroundColor: AppDesign.ink,
            elevation: 12,
            child: const Icon(Icons.casino),
          )
        : FloatingActionButton.extended(
            heroTag: 'dice-launcher',
            onPressed: () => showDiceSheet(context),
            tooltip: strings.text('dice'),
            backgroundColor: AppDesign.teal,
            foregroundColor: AppDesign.ink,
            elevation: 12,
            icon: const Icon(Icons.casino),
            label: Text(strings.text('dice')),
          );

    return Scaffold(
      backgroundColor: AppDesign.canvas,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            await save();
            if (context.mounted) Navigator.pop(context);
          },
        ),
        title: Text(game.name),
        actions: const <Widget>[LanguagePicker()],
      ),
      body: BoardBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Stack(
                children: <Widget>[
                  game.players.isEmpty
                      ? const Center(child: Text('Nessun giocatore presente'))
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
                          itemCount: game.players.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, int index) {
                            final Player player = game.players[index];
                            final bool isSelected =
                                game.selectedFirstPlayerId == player.id;
                            return PlayerCard(
                              player: player,
                              isSelected: isSelected,
                              isHighlightAnimating:
                                  _selectionAnimationVisible && isSelected,
                              formatDuration: formatDuration,
                              formatNumber: formatNumber,
                              onEdit: () => addOrEditPlayer(player: player),
                              onRemove: () => removePlayer(player),
                              onToggleTimer: () => toggleTimer(player),
                              onStopTimer: () => stopTimer(player),
                              onTurnsEdit: () => editTurns(player),
                              onScoreEdit: () => editScore(player),
                              onTurnChange: (int value) {
                                setState(() {
                                  player.turns = (player.turns + value).clamp(
                                    0,
                                    99,
                                  );
                                });
                                unawaited(save());
                              },
                              onScoreChange: (double value) {
                                setState(() => player.score += value);
                                unawaited(save());
                              },
                              onStepChange: (double? value) {
                                setState(() => player.scoreStep = value ?? 1);
                                unawaited(save());
                              },
                              scoreSteps: scoreSteps,
                            );
                          },
                        ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: Row(
                        children: <Widget>[
                          firstPlayerButton,
                          const Spacer(),
                          diceButton,
                          const Spacer(),
                          FloatingActionButton(
                            heroTag: 'add-player',
                            onPressed: () => addOrEditPlayer(),
                            tooltip: 'Aggiungi giocatore',
                            backgroundColor: AppDesign.teal,
                            foregroundColor: AppDesign.ink,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.add),
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
      ),
    );
  }
}

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    required this.isSelected,
    required this.isHighlightAnimating,
    required this.formatDuration,
    required this.formatNumber,
    required this.onEdit,
    required this.onRemove,
    required this.onToggleTimer,
    required this.onStopTimer,
    required this.onTurnsEdit,
    required this.onScoreEdit,
    required this.onTurnChange,
    required this.onScoreChange,
    required this.onStepChange,
    required this.scoreSteps,
  });

  final Player player;
  final bool isSelected;
  final bool isHighlightAnimating;
  final String Function(Duration) formatDuration;
  final String Function(double) formatNumber;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onToggleTimer;
  final VoidCallback onStopTimer;
  final VoidCallback onTurnsEdit;
  final VoidCallback onScoreEdit;
  final ValueChanged<int> onTurnChange;
  final ValueChanged<double> onScoreChange;
  final ValueChanged<double?> onStepChange;
  final List<double> scoreSteps;

  @override
  Widget build(BuildContext context) {
    final BorderSide selectedBorder = BorderSide(
      color: isSelected ? AppDesign.gold : Colors.transparent,
      width: isSelected ? 2 : 1,
    );
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: isSelected ? '${player.name}, primo giocatore' : player.name,
      selected: isSelected,
      child: AnimatedScale(
        scale: isSelected && isHighlightAnimating ? 1.02 : 1,
        duration: reduceMotion ? Duration.zero : AppDesign.motionFast,
        curve: AppDesign.motionCurve,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppDesign.gold.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.025),
            borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
            border: Border.all(
              color: isSelected
                  ? AppDesign.gold.withValues(alpha: 0.36)
                  : Colors.white.withValues(alpha: 0.07),
            ),
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            color: isSelected ? AppDesign.panelRaised : null,
            shape: RoundedRectangleBorder(
              side: selectedBorder,
              borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? AppDesign.gold.withValues(alpha: 0.18)
                        : AppDesign.tealDeep,
                    foregroundColor: isSelected
                        ? AppDesign.goldSoft
                        : AppDesign.text,
                    child: Icon(
                      playerIcons[player.iconIndex.clamp(
                        0,
                        playerIcons.length - 1,
                      )],
                    ),
                  ),
                  title: InkWell(
                    onTap: onEdit,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            player.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppDesign.gold.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppDesign.gold.withValues(alpha: 0.42),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.workspace_premium_rounded,
                                  size: 14,
                                  color: AppDesign.goldSoft,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'PRIMO',
                                  style: TextStyle(
                                    color: AppDesign.goldSoft,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    isSelected ? 'Inizia il turno' : 'Giocatore',
                    style: const TextStyle(color: AppDesign.textMuted),
                  ),
                  trailing: IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close),
                    tooltip: 'Elimina giocatore',
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
                    runSpacing: 16,
                    children: <Widget>[
                      ControlColumn(
                        label: 'Tempo',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              onPressed: onStopTimer,
                              icon: const Icon(
                                Icons.stop_rounded,
                                color: AppDesign.danger,
                              ),
                              tooltip: 'Azzera timer',
                            ),
                            Text(formatDuration(player.elapsed)),
                            IconButton(
                              onPressed: onToggleTimer,
                              icon: Icon(
                                player.timerState == TimerState.running
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: player.timerState == TimerState.running
                                    ? AppDesign.goldSoft
                                    : AppDesign.teal,
                              ),
                              tooltip: player.timerState == TimerState.running
                                  ? 'Pausa'
                                  : 'Avvia',
                            ),
                          ],
                        ),
                      ),
                      ControlColumn(
                        label: 'Turni',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              onPressed: player.turns > 0
                                  ? () => onTurnChange(-1)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            InkWell(
                              onTap: onTurnsEdit,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text('${player.turns}'),
                              ),
                            ),
                            IconButton(
                              onPressed: player.turns < 99
                                  ? () => onTurnChange(1)
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                      ControlColumn(
                        label: 'Punteggio',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              onPressed: () => onScoreChange(-player.scoreStep),
                              icon: const Icon(Icons.remove),
                            ),
                            InkWell(
                              onTap: onScoreEdit,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(formatNumber(player.score)),
                              ),
                            ),
                            IconButton(
                              onPressed: () => onScoreChange(player.scoreStep),
                              icon: const Icon(Icons.add),
                            ),
                            DropdownButton<double>(
                              value: player.scoreStep,
                              items: scoreSteps
                                  .map(
                                    (double value) => DropdownMenuItem<double>(
                                      value: value,
                                      child: Text(formatNumber(value)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: onStepChange,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ControlColumn extends StatelessWidget {
  const ControlColumn({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppDesign.textMuted,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        child,
      ],
    );
  }
}

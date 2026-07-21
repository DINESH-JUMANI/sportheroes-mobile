import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/features/auth/screens/complete_profile_screen.dart';
import 'package:sportheroes_mobile/features/auth/screens/otp_verification_screen.dart';
import 'package:sportheroes_mobile/features/auth/screens/phone_login_screen.dart';
import 'package:sportheroes_mobile/features/home/screens/home_shell_screen.dart';
import 'package:sportheroes_mobile/features/matches/screens/create_match_screen.dart';
import 'package:sportheroes_mobile/features/matches/screens/match_detail_screen.dart';
import 'package:sportheroes_mobile/features/matches/screens/matches_screen.dart';
import 'package:sportheroes_mobile/features/onboarding/screens/onboarding_screen.dart';
import 'package:sportheroes_mobile/features/profile/screens/edit_profile_screen.dart';
import 'package:sportheroes_mobile/features/profile/screens/my_stats_screen.dart';
import 'package:sportheroes_mobile/features/profile/screens/profile_screen.dart';
import 'package:sportheroes_mobile/features/search/screens/search_screen.dart';
import 'package:sportheroes_mobile/features/settings/screens/settings_screen.dart';
import 'package:sportheroes_mobile/features/splash/screens/splash_screen.dart';
import 'package:sportheroes_mobile/features/sports/screens/my_sports_screen.dart';
import 'package:sportheroes_mobile/features/support/screens/help_support_screen.dart';
import 'package:sportheroes_mobile/features/support/screens/my_support_tickets_screen.dart';
import 'package:sportheroes_mobile/features/teams/screens/create_team_screen.dart';
import 'package:sportheroes_mobile/features/teams/screens/team_detail_screen.dart';
import 'package:sportheroes_mobile/features/teams/screens/teams_screen.dart';
import 'package:sportheroes_mobile/features/tournaments/screens/create_tournament_screen.dart';
import 'package:sportheroes_mobile/features/tournaments/screens/tournament_detail_screen.dart';
import 'package:sportheroes_mobile/features/tournaments/screens/tournaments_screen.dart';
import 'package:sportheroes_mobile/features/venues/screens/create_venue_screen.dart';
import 'package:sportheroes_mobile/features/venues/screens/venues_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String completeProfile = '/complete-profile';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String teams = '/teams';
  static const String createTeam = '/teams/create';
  static const String teamDetail = '/teams/detail';
  static const String matches = '/matches';
  static const String createMatch = '/matches/create';
  static const String matchDetail = '/matches/detail';
  static const String tournaments = '/tournaments';
  static const String createTournament = '/tournaments/create';
  static const String tournamentDetail = '/tournaments/detail';
  static const String mySports = '/sports/mine';
  static const String search = '/search';
  static const String venues = '/venues';
  static const String createVenue = '/venues/create';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String myStats = '/profile/stats';
  static const String helpSupport = '/support';
  static const String mySupportTickets = '/support/tickets';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const PhoneLoginScreen(),
      otp: (context) => const OtpVerificationScreen(),
      completeProfile: (context) => const CompleteProfileScreen(),
      home: (context) => const HomeShellScreen(),
      teams: (context) => const TeamsScreen(),
      createTeam: (context) => const CreateTeamScreen(),
      matches: (context) => const MatchesScreen(),
      createMatch: (context) => const CreateMatchScreen(),
      tournaments: (context) => const TournamentsScreen(),
      createTournament: (context) => const CreateTournamentScreen(),
      mySports: (context) => const MySportsScreen(),
      search: (context) => const SearchScreen(),
      venues: (context) => const VenuesScreen(),
      createVenue: (context) => const CreateVenueScreen(),
      settings: (context) => const SettingsScreen(),
      profile: (context) => const ProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),
      myStats: (context) => const MyStatsScreen(),
      helpSupport: (context) => const HelpSupportScreen(),
      mySupportTickets: (context) => const MySupportTicketsScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case teamDetail:
        final id = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => TeamDetailScreen(teamId: id),
          settings: settings,
        );
      case matchDetail:
        final id = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => MatchDetailScreen(matchId: id),
          settings: settings,
        );
      case tournamentDetail:
        final id = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => TournamentDetailScreen(tournamentId: id),
          settings: settings,
        );
      default:
        return null;
    }
  }
}

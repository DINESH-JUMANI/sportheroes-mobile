import 'package:sportheroes_mobile/core/config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => AppConfig.instance.baseUrl;

  // ── Auth ────────────────────────────────────────────────────────────────
  static const String authLogin = '/v1/auth/login';
  static const String authRegister = '/v1/auth/register';
  static const String authCheck = '/v1/auth/check';
  static const String authSetPassword = '/v1/auth/set-password';
  static const String authResetPassword = '/v1/auth/reset-password';
  static const String authChangePassword = '/v1/auth/change-password';
  static const String authMe = '/v1/auth/me';
  static const String authProfile = '/v1/auth/profile';
  static const String authAvatar = '/v1/auth/avatar';
  static const String authLogout = '/v1/auth/logout';

  // ── Search ──────────────────────────────────────────────────────────────
  static const String search = '/v1/search';
  static const String searchUsers = '/v1/search/users';

  // ── Sports ──────────────────────────────────────────────────────────────
  static const String sports = '/v1/sports';
  static String sportById(String id) => '/v1/sports/$id';
  static String sportByCode(String code) => '/v1/sports/code/$code';
  static String sportRulesByCode(String code) => '/v1/sports/code/$code/rules';

  // ── Player profiles ─────────────────────────────────────────────────────
  static const String playerProfiles = '/v1/player-profiles';
  static const String playerProfilesMe = '/v1/player-profiles/me';
  static String playerProfilesByUser(String userId) =>
      '/v1/player-profiles/user/$userId';
  static String playerProfileById(String id) => '/v1/player-profiles/$id';

  // ── Teams ───────────────────────────────────────────────────────────────
  static const String teams = '/v1/teams';
  static const String teamLookupUser = '/v1/teams/lookup-user';
  static String teamById(String id) => '/v1/teams/$id';
  static String teamLogo(String id) => '/v1/teams/$id/logo';
  static String teamMembers(String teamId) => '/v1/teams/$teamId/members';
  static String teamMemberById(String teamId, String memberId) =>
      '/v1/teams/$teamId/members/$memberId';

  // ── Matches ─────────────────────────────────────────────────────────────
  static const String matches = '/v1/matches';
  static String matchById(String id) => '/v1/matches/$id';
  static String matchTimeline(String id) => '/v1/matches/$id/timeline';
  static String matchStart(String id) => '/v1/matches/$id/start';
  static String matchPause(String id) => '/v1/matches/$id/pause';
  static String matchResume(String id) => '/v1/matches/$id/resume';
  static String matchPoint(String id) => '/v1/matches/$id/point';
  static String matchUndoPoint(String id) => '/v1/matches/$id/undo-point';
  static String matchFinishSet(String id) => '/v1/matches/$id/finish-set';
  static String matchComplete(String id) => '/v1/matches/$id/complete';
  static String matchCancel(String id) => '/v1/matches/$id/cancel';

  // ── Tournaments ─────────────────────────────────────────────────────────
  static const String tournaments = '/v1/tournaments';
  static String tournamentById(String id) => '/v1/tournaments/$id';
  static String tournamentStatus(String id) => '/v1/tournaments/$id/status';
  static String tournamentParticipants(String id) =>
      '/v1/tournaments/$id/participants';
  static String tournamentParticipantById(String id, String participantId) =>
      '/v1/tournaments/$id/participants/$participantId';
  static String tournamentRounds(String id) => '/v1/tournaments/$id/rounds';
  static String tournamentStandings(String id) =>
      '/v1/tournaments/$id/standings';

  // ── Venues ──────────────────────────────────────────────────────────────
  static const String venues = '/v1/venues';
  static String venueById(String id) => '/v1/venues/$id';

  // ── Statistics ──────────────────────────────────────────────────────────
  static const String playerLeaderboard = '/v1/statistics/players/leaderboard';
  static String playerStats(String userId) => '/v1/statistics/players/$userId';
  static const String teamLeaderboard = '/v1/statistics/teams/leaderboard';
  static String teamStats(String teamId) => '/v1/statistics/teams/$teamId';

  // ── Support ─────────────────────────────────────────────────────────────
  static const String supportConcerns = '/v1/support/concerns';
  static String supportConcernById(String id) => '/v1/support/concerns/$id';
  static const String supportTickets = '/v1/support/tickets';
  static String supportTicketById(String id) => '/v1/support/tickets/$id';
  static String supportTicketByNumber(String ticketNumber) =>
      '/v1/support/tickets/by-number/$ticketNumber';
  static String supportTicketStatus(String id) =>
      '/v1/support/tickets/$id/status';
  static const String supportUploadImage = '/v1/support/upload-image';
  static String supportTicketImage(String ticketId, String imageId) =>
      '/v1/support/tickets/$ticketId/images/$imageId';

  // ── HTTP Status Codes ───────────────────────────────────────────────────
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
}

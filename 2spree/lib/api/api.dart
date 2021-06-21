import 'package:reddigram/api/api.dart';

export 'api_repository/api.dart';
export 'api_repository/facade.dart';
export 'api_repository/local.dart';
export 'mappers/link_listing_photos_mapper.dart';
export 'mappers/subreddit_info_mapper.dart';
export 'reddit_repository.dart';

final redditRepository = RedditRepository();
final apiRepository = ApiRepositoriesFacade(
  fetchRedditAccessToken: redditRepository.getAccessToken,
);

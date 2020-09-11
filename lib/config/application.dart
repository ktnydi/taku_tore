import 'package:algolia/algolia.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Application {
  static final Algolia algolia = Algolia.init(
    applicationId: DotEnv().env['ALGOLIA_APPLICATION_ID'],
    apiKey: DotEnv().env['ALGOLIA_API_KEY'],
  );
}

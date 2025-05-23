import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get DB_PATH async => join((await getApplicationDocumentsDirectory()).path, "noodles.db");
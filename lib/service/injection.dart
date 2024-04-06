import 'package:app_chat365_pc/data/datas/typing_user.dart';
import 'package:app_chat365_pc/service/app_service.dart';
import 'package:app_chat365_pc/service/firebase_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  //
  getIt.registerSingleton<AppService>(AppService());
  //
  getIt.registerSingleton<TypingUser>(const TypingUser());
}

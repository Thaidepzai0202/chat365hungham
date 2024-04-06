import 'package:app_chat365_pc/modules/layout/pages/sub_pages/notification_screen/models/notification_model.dart';
import 'package:equatable/equatable.dart';

class NotificationState extends Equatable{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
class InitialNotificationState extends NotificationState{}
  class LoadingNotificationState extends NotificationState{}
  class LoadedNotificationState extends NotificationState{
    LoadedNotificationState(this.listNoti);
   final  List<NotificationModel> listNoti;
  }
  class EmptyNotificationState extends NotificationState{}
  class ErrorNotificationState extends NotificationState{
  final String mess;
  ErrorNotificationState(this.mess);
  }

  class ReadAllNotificationState extends NotificationState{}
class ReadNotificationState extends NotificationState{}
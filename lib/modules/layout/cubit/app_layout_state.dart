part of 'app_layout_cubit.dart';

sealed class AppLayoutState extends Equatable {
  const AppLayoutState();

  @override
  List<Object> get props => [];
}

final class AppLayoutInitial extends AppLayoutState {}

final class AppMainLayoutNavigation extends AppLayoutState {
  final Widget layout;
  final AppMainPages page;
  const AppMainLayoutNavigation(this.layout, this.page);
}

final class AppSubLayoutNavigation extends AppLayoutState {
  final Widget layout;
  final AppSubPages page;
  const AppSubLayoutNavigation(this.layout, this.page);
}

final class AppSubLayoutBackNavigation extends AppLayoutState {
  final Widget layout;
  const AppSubLayoutBackNavigation(this.layout);
}

final class ChangeGradient extends AppLayoutState{}
final class InitGradient extends AppLayoutState{}

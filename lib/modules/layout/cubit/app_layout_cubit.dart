

import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_layout_state.dart';

class SubLayoutHistory {
  final AppSubPages page;
  final Map<String, dynamic>? agruments;
  final List<BlocProvider>? providers;
  SubLayoutHistory(
      {required this.page, required this.agruments, required this.providers});
}

class MainLayoutHistory {
  final AppMainPages page;
  final Map<String, dynamic>? agruments;
  final List<BlocProvider>? providers;
  MainLayoutHistory(
      {required this.page, required this.agruments, required this.providers});
}

class AppLayoutCubit extends Cubit<AppLayoutState> {
  AppLayoutCubit() : super(AppLayoutInitial());
  List<SubLayoutHistory> subPageHistory = [];
  List<MainLayoutHistory> mainPageHistory = [];

  Widget _layoutBuilder(Widget body, List<BlocProvider>? providers) {
    if (providers != null && providers.isNotEmpty) {
      return MultiBlocProvider(

          /// TL 4/1/2024: Thêm key thử chống lỗi Rebuilt _InheritedProviderScope using a different constructor
          /// Có thể là do cái multibloc này không rebuild, nhưng cứ nhét các provider vào, thành ra bloc class này
          /// bị dùng cho class khác
          key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
          providers: providers,
          child: body);
    }
    return body;
  }

  toSubLayout(AppSubPages page,
      {Map<String, dynamic>? agruments, List<BlocProvider>? providers}) {
    Widget layout =
        _layoutBuilder(AppSubPagesHelper.getPage(page, agruments), providers);
    subPageHistory.add(SubLayoutHistory(
        page: page, agruments: agruments, providers: providers));
    emit(AppLayoutInitial());
    emit(AppSubLayoutNavigation(layout, page));
  }

  toMainLayout(AppMainPages page,
      {Map<String, dynamic>? agruments, List<BlocProvider>? providers}) {
    Widget layout =
        _layoutBuilder(AppMainPagesHelper.getPage(page, agruments), providers);
    mainPageHistory.add(MainLayoutHistory(
        page: page, agruments: agruments, providers: providers));
    emit(AppLayoutInitial());
    emit(AppMainLayoutNavigation(layout, page));
  }

  subLayoutBack() {
    if (subPageHistory.isNotEmpty) {
      SubLayoutHistory _history = subPageHistory[subPageHistory.length - 2];
      Widget layout = _layoutBuilder(
          AppSubPagesHelper.getPage(_history.page, _history.agruments),
          _history.providers);
      emit(AppLayoutInitial());
      emit(AppSubLayoutNavigation(layout, _history.page));
      subPageHistory.add(SubLayoutHistory(
          page: _history.page,
          agruments: _history.agruments,
          providers: _history.providers));
    }
  }

  mainLayoutBack() {
    if (mainPageHistory.isNotEmpty) {
      MainLayoutHistory _history = mainPageHistory.first;
      Widget layout = _layoutBuilder(
          AppMainPagesHelper.getPage(_history.page, _history.agruments),
          _history.providers);
      emit(AppLayoutInitial());
      emit(AppMainLayoutNavigation(layout, _history.page));
    }
  }
}

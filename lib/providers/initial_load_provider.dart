import 'package:flutter_riverpod/flutter_riverpod.dart';


final initialLoadProvider = NotifierProvider<InitialLoadNotifier, bool>(
  () => InitialLoadNotifier(),
);

class InitialLoadNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setInitialLoadDone() {
    state = true;
  }
}

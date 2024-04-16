import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class WebsocketClient {
  Stream<int> getCounterStream([int start]);
}

class FakeWebsocketClient implements WebsocketClient {
  @override
  Stream<int> getCounterStream([int start = 0]) async* {
    int i = start;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield i++;
    }
  }
}

final websocketClientProvider = Provider<WebsocketClient>(
  (ref) {
    return FakeWebsocketClient();
  },
);
final counterProvider =
    StreamProvider.family.autoDispose<int, int>((ref, start) {
  final wsClient = ref.watch(websocketClientProvider);
  return wsClient.getCounterStream(start);
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Colors.green),
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, foregroundColor: Colors.white),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => const CounterPage()),
              ),
            );
          },
          child: const Text('Go to Counter Page'),
        ),
      ),
    );
  }
}

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> counter = ref.watch(counterProvider(5));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Counter"),
      ),
      body: Center(
        child: Text(
            counter
                .when(
                    data: (int value) => value,
                    error: (Object e, _) => e,
                    loading: () => 5)
                .toString(),
            style: Theme.of(context).textTheme.displayMedium),
      ),
    );
  }
}

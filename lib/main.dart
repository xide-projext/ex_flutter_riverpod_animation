import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

// A Counter example implemented with riverpod

void main() {
  runApp(
    // Adding ProviderScope enables Riverpod for the entire project
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

/// Annotating a class by `@riverpod` defines a new shared state for your application,
/// accessible using the generated [counterProvider].
/// This class is both responsible for initializing the state (through the [build] method)
/// and exposing ways to modify it (cf [increment]).
@riverpod
class Counter extends _$Counter {
  /// Classes annotated by `@riverpod` **must** define a [build] function.
  /// This function is expected to return the initial state of your shared state.
  /// It is totally acceptable for this function to return a [Future] or [Stream] if you need to.
  /// You can also freely define parameters on this method.
  @override
  int build() => 0;

  void increment() => state++;
  void decrease() => state--;
}

class Home extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter example')),
      body: Center(
        child: 
        Column(children: [
            Text('${ref.watch(counterProvider)}'),
            TextButton(child: Text('Sub page'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubPage())),
            )  
        ])
      ),
      floatingActionButton: FloatingActionButton(
        // The read method is a utility to read a provider without listening to it
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SubPage extends ConsumerWidget {
  const SubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title:  Text('Counter x Animation ${ref.watch(counterProvider)}')),
      body: SizedBox(
                height: 300.0,
                child: AnimationExample(color: Colors.blue),
              ),
    ); 
  }
}


class AnimationExample extends StatefulWidget {
  final Color color;

  const AnimationExample({Key? key, this.color = Colors.grey}) : super(key: key);

  @override
  _AnimationExampleState createState() => _AnimationExampleState();
}

class _AnimationExampleState extends State<AnimationExample>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Tween을 사용하여 시작과 끝 크기를 정의합니다. 여기서는 100에서 200으로 변합니다.
    final sizeTween = Tween<double>(begin: 100.0, end: 200.0);

    // CurvedAnimation을 사용하여 속도 곡선을 정의합니다.
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    );

    // Tween과 CurvedAnimation을 결합합니다.
    _animation = sizeTween.animate(curve);

    // 리니어한 애니메이션을 위해 Tween만 사용합니다.
    // _animation = sizeTween.animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // _animation.value는 sizeTween에서 정의한 범위 내에서 변합니다.
          return Column(
            children: [
              TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue), // Set the background color to blue
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Colors.white), // Set the text color to white
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(
                            16.0)), // Increase padding for larger touch area
                  ),
                  onPressed: () {
                    if (_controller.status == AnimationStatus.completed) {
                      _controller.reverse();
                    } else {
                      _controller.forward();
                    }
                  },
                  child: Text('Animate')),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Container(
                  width: _animation.value,
                  height: _animation.value,
                  color: widget.color,
                  alignment: Alignment.center,
                  child: Text('Animating... ${widget.color.value}'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

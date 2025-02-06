import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider<CounterCubit>(
        create: (BuildContext context) {
          return CounterCubit();
        },
        child: const MyHomePage(
          title: 'Flutter Demo Home Page'
        ),
      ),
    );
  }
}

// Counter State class
class CounterState {
  final int count;
  
  CounterState({required this.count});
}

// Counter Cubit class
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState(count: 0));

  void increment() {
    // replace the old state with emit function
    emit(CounterState(count: state.count + 1));
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {

  // Create a countercubit variable to access increment function
    CounterCubit cb = BlocProvider.of<CounterCubit>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            BlocBuilder<CounterCubit, CounterState>(
              builder: (context, state) {
                return Text(
                  '${state.count}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => cb.increment(),   // call cb function
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_example/models/ModelProvider.dart';
import 'package:flutter/material.dart';
// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

// Generated in previous step
import 'package:amplify_example/amplifyconfiguration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  void _configureAmplify() async {
    // Add the following line to add API plugin to your app
    await Amplify.addPlugin(AmplifyAPI(modelProvider: ModelProvider.instance));

    // Once Plugins are added, configure Amplify
    // Note: Amplify can only be configured once.
    try {
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      print(
          "Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
    }
  }

  Future<void> _createTodo() async {
    try {
      Todo todo = Todo(name: 'my first todo', description: 'todo description');
      final request = ModelMutations.create(todo);
      final response = await Amplify.API.mutate(request: request).response;

      Todo? createdTodo = response.data;
      if (createdTodo == null) {
        print('errors: ' + response.errors.toString());
        return;
      }
      // update Todo
      await _updateTodo(createdTodo);
      print('Mutation result: ' + createdTodo.name);
    } on ApiException catch (e) {
      print('Mutation failed: $e');
    }
  }

  Future<void> _updateTodo(Todo createdTodo) async {
    final todoWithNewName = createdTodo.copyWith(name: 'new name');

    final request = ModelMutations.update(todoWithNewName);
    final response = await Amplify.API.mutate(request: request).response;

    await _deleteTodo(todoWithNewName);
  }

  Future<void> _deleteTodo(Todo todoWithNewName) async {
    final request = ModelMutations.delete(todoWithNewName);
    final response = await Amplify.API.mutate(request: request).response;

    // or delete by ID, ideal if you do not have the instance in memory, yet
    // final request = ModelMutations.deleteById(Todo.classType, todoWithNewName.id);
    // final response = await Amplify.API.mutate(request: request).response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => await _createTodo(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

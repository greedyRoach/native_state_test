import 'package:flutter/material.dart';
import 'package:native_state/native_state.dart';

void main() {
  debugPrint("main()");
  runApp(SavedState(child: MyApp()));
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var savedState = SavedState.of(context);
    debugPrint("rebuild app");

    try {
      debugPrint("\n\nCounter total: ${savedState.getInt('counter')}");
      debugPrint("\n\nSaved: ${savedState.getBool("saved")}");
      debugPrint("\n\nNormal url: ${SavedStateRouteObserver.restoreRoute(savedState)}");
    } catch (e) {
      debugPrint("\n\nError $e");
    }

    // Navigator will set up the correct route history if they are structured in a hierarchical way.
    // See https://api.flutter.dev/flutter/widgets/Navigator/initialRoute.html
    return MaterialApp(
      // for restoring navigator state, you'll need to set a navigator key!
      debugShowCheckedModeBanner: false,
      navigatorKey: GlobalKey(),
      // Setup an observer that will save the current route into the saved state
      navigatorObservers: [SavedStateRouteObserver(savedState: savedState)],
      routes: {
        // If you want to get the saved state passed to your widget, use the builder constructor
        // The SavedState passed in here is "scoped" to this widget; it won't see any of the global state.
        NestedState.route: (context) => SavedState.builder(
            builder: (context, savedState) =>
                NestedState(savedState: savedState)),

        DummyPage.route: (context) => DummyPage(),
      },
      // restore the route or default to the home page
      initialRoute: SavedStateRouteObserver.restoreRoute(savedState) ?? "/",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with StateRestoration {
  var _counter = 0;

  void _increment() async {
    _counter++;
    debugPrint('\n\nSaving total');
    await SavedState.of(context).putInt("counter", _counter);
    debugPrint('total saved: ${SavedState.of(context).getInt("counter")}');

    setState(() {});
  }

  @override
  void restoreState(SavedStateData savedState) {
    debugPrint("restoreState: ${savedState.getInt("counter")} ");
    setState(() {
      _counter = savedState.getInt("counter") ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Count = $_counter'),
            MaterialButton(
              child: Text("Increment"),
              onPressed: () => _increment(),
            ),
            LayoutBuilder(
              builder: (context, _) => RaisedButton(
                child: Text("Go"),
                onPressed: () =>
                    Navigator.of(context).pushNamed("/intermediate"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DummyPage extends StatelessWidget {
  static const route = "/intermediate";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Another page'),
      ),
      body: RaisedButton(
        child: Text("Onwards"),
        onPressed: () => Navigator.of(context).pushNamed(NestedState.route),
      ),
    );
  }
}

class NestedState extends StatelessWidget {
  static const String route = "/intermediate/nested_state";

  final SavedStateData savedState;
  final bool restoredFromState;

  NestedState({this.savedState}) : this.restoredFromState = savedState.getBool("saved") {
    savedState.putBool("saved", true);
    debugPrint("\n\nsaved state: ${savedState.getBool("saved")}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Text('Restored from state: $restoredFromState'),
      ),
    );
  }
}

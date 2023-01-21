import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
@override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollectionBloc(),
      child: const MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
@override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionBloc, CollectionState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Deeply nested data and Bloc 8.0.0+'),
          ),
          body: ListView.builder(
            itemCount: state.getAllNodes(state).length,
            itemBuilder: (context, index) {
              var nodes = state.getAllNodes(state)[index];
              Color textColor = getColor(nodes);
              double distance = getPaddingDistance(nodes);
              return Padding(
                padding: EdgeInsets.only(left: distance),
                child: ListTile(
                  onTap: () => addToCollectionLogic(nodes.showType, index,
                      nodes.children.length, context),
                  leading: Card(
                    child: Text(nodes.name, style: TextStyle(color: textColor)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
double getPaddingDistance(CollectionState nodes) {
    switch (nodes.showType) {
      case ShowType.collection:
        return 0;
      case ShowType.series:
        return 20;
      case ShowType.season:
        return 40;
      case ShowType.episode:
        return 60;
    }
  }
Color getColor(CollectionState nodes) {
    switch (nodes.showType) {
      case ShowType.collection:
        return Colors.black;
      case ShowType.series:
        return Colors.blue;
      case ShowType.season:
        return Colors.green;
      case ShowType.episode:
        return Colors.red;
    }
  }
}

enum ShowType { collection, series, season, episode }
class CollectionState extends Equatable {
  const CollectionState({
    required this.name,
    required this.children,
    required this.showType,
    required this.heartbeats, // hack to get Equatable to work
  });
  final String name;
  final List<CollectionState> children;
  final ShowType showType;
  final int heartbeats;
factory CollectionState.initial() {
    return const CollectionState(
      name: "Collection",
      showType: ShowType.collection,
      children: [],
      heartbeats: 0,
    );
  }
List<CollectionState> getAllNodes(CollectionState node) {
    List<CollectionState> result = [];
    result.add(node);
    for (CollectionState child in node.children) {
      result.addAll(getAllNodes(child));
    }
    return result;
  }
CollectionState copyWith({
    String? name,
    List<CollectionState>? children,
    ShowType? showType,
  }) {
    return CollectionState(
      name: name ?? this.name,
      children: children ?? this.children,
      showType: showType ?? this.showType,
      heartbeats: heartbeats + 1,
    );
  }
@override
  List<Object> get props => [name, children, showType,
  heartbeats
  ];
}

abstract class CollectionEvents extends Equatable {
@override
  List<Object> get props => [];
}
class AddToTopLayer extends CollectionEvents {
  AddToTopLayer({required this.index, required this.child});
final int index;
  final CollectionState child;
}
class AddToNode extends CollectionEvents {
  AddToNode({required this.index, required this.child});
final int index;
  final CollectionState child;
}

class CollectionBloc extends Bloc<CollectionEvents, CollectionState> {
  CollectionBloc() : super(CollectionState.initial()) {
    on<AddToTopLayer>((event, emit) =>
        emit(state.copyWith(children: [...state.children, event.child])));
on<AddToNode>(
      (event, emit) {
        final List<CollectionState> nodes = state.getAllNodes(state);
/// Expose the parent node.
        final CollectionState parent = nodes[event.index];
/// add to the children of the parent, which changes the nested state of the data.
        parent.children.add(event.child);
/// adds the updated nested data to the empty children list of the copyWith object.
        //emit(state.copyWith(children: []..addAll(state.children)));
        /// OR
        emit(state.copyWith(children: [...state.children]));
        /// OR
        /// emit(state.copyWith(children: [...list[0].children]));
      },
    );
  }
}

void addToCollectionLogic(
    ShowType showType, int index, int count, BuildContext context) {
  switch (showType) {
    case ShowType.collection:
      addToTopLayer('Series ${count + 1}', index, ShowType.series, context);
      break;
    case ShowType.series:
      addToNodes('Season ${count + 1}', index, ShowType.season, context);
      break;
    case ShowType.season:
      addToNodes('Episode ${count + 1}', index, ShowType.episode, context);
      break;
    case ShowType.episode:
      break;
  }
}
void addToTopLayer(name, index, showType, context) {
  BlocProvider.of<CollectionBloc>(context).add(
    AddToTopLayer(
      index: index,
      child: CollectionState(
        name: name,
        showType: showType,
        children: [],
        // todo: add this code.
        heartbeats: 0
      ),
    ),
  );
}
void addToNodes(name, index, showType, context) {
  BlocProvider.of<CollectionBloc>(context).add(
    AddToNode(
      index: index,
      child: CollectionState(
        name: name,
        showType: showType,
        children: [],
        // todo: add this code.
        heartbeats: 0
      ),
    ),
  );
}
// ignore_for_file: prefer_const_literals_to_create_immutables

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
                  onTap: () =>
                      nodes.showType.fx(nodes.children.length, index, context),
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

  double getPaddingDistance(CollectionState nodes) =>
      nodes.showType.paddingDistance.toDouble();

  Color getColor(CollectionState nodes) => nodes.showType.textColor;
}

abstract class ShowType2 {
  ShowType2(this.paddingDistance, this.textColor, this.fx);
  final int paddingDistance;
  final Color textColor;
  final Function fx;
}

class Collection extends ShowType2 {
  Collection()
      : super(
          0,
          Colors.black,
          (int count, int index, BuildContext context) => addToCollection(
              'Series ${count + 1}', index, Series(), context, true),
        );
}

class Series extends ShowType2 {
  Series()
      : super(
            20,
            Colors.blue,
            (int count, int index, BuildContext context) => addToCollection(
                'Season ${count + 1}', index, Season(), context, false));
}

class Season extends ShowType2 {
  Season()
      : super(
            40,
            Colors.green,
            (int count, int index, BuildContext context) => addToCollection(
                'Episode ${count + 1}', index, Episode(), context, false));
}

class Episode extends ShowType2 {
  Episode()
      : super(
            60, Colors.red, (int count, int index, BuildContext context) => {});
}

class CollectionState extends Equatable {
  const CollectionState({
    required this.name,
    required this.children,
    required this.showType,
    required this.heartbeats, // hack to get Equatable to work
  });
  final String name;
  final List<CollectionState> children;
  final ShowType2 showType;
  final int heartbeats;
  factory CollectionState.initial() {
    return CollectionState(
      name: "Collection",
      showType: Collection(),
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
    ShowType2? showType,
  }) {
    return CollectionState(
      name: name ?? this.name,
      children: children ?? this.children,
      showType: showType ?? this.showType,
      heartbeats: heartbeats + 1,
    );
  }

  @override
  List<Object> get props => [name, children, showType, heartbeats];
}

abstract class CollectionEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class AddToTopLayer extends CollectionEvents {
  AddToTopLayer({required this.index, required this.child});
  final int index;
  final CollectionState child;
  @override
  List<Object> get props => [index, child.heartbeats];
}

class AddToNode extends CollectionEvents {
  AddToNode({required this.index, required this.child});
  final int index;
  final CollectionState child;
  @override
  List<Object> get props => [index, child.heartbeats];
}

class CollectionBloc extends Bloc<CollectionEvents, CollectionState> {
  CollectionBloc() : super(CollectionState.initial()) {
    on<AddToTopLayer>((event, emit) =>
        emit(state.copyWith(children: [...state.children, event.child])));
    on<AddToNode>(
      (event, emit) {
        final List<CollectionState> nodes = state.getAllNodes(state);
        final CollectionState parent = nodes[event.index];
        parent.children.add(event.child);

        emit(state.copyWith(children: [...state.children]));
      },
    );
  }
}

void addToCollection(String name, int index, ShowType2 showType2,
    BuildContext context, bool isTopLayer) {
  CollectionEvents event;
  if (isTopLayer) {
    event = AddToTopLayer(
      index: index,
      child: CollectionState(
          name: name, showType: showType2, children: [], heartbeats: 0),
    );
  } else {
    event = AddToNode(
      index: index,
      child: CollectionState(
          name: name, showType: showType2, children: [], heartbeats: 0),
    );
  }
  BlocProvider.of<CollectionBloc>(context).add(event);
}
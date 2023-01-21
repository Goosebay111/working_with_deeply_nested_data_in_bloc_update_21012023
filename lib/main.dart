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
            title: const Text('Deeply nested data and Bloc 8.1.1+'),
          ),
          body: ListView.builder(
            itemCount: getAllNodes(state).length,
            itemBuilder: (context, index) {
              var nodes = getAllNodes(state)[index];
              Color textColor = nodes.showType.textColor;
              double distance = nodes.showType.paddingDistance;
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
}

// add the constructor to repertoire for 5-lines of code method.
class ShowType {
  final double paddingDistance;
  final Color textColor;
  final Function fx;

  ShowType._({required this.paddingDistance, required this.textColor, required this.fx});

  factory ShowType.collection() => ShowType._(paddingDistance: 0, textColor: Colors.black, fx: (int count, int index, BuildContext context) => addToCollection('Series ${count + 1}', index, ShowType.series(), context));
  factory ShowType.series() => ShowType._(paddingDistance: 20, textColor: Colors.blue, fx: (int count, int index, BuildContext context) => addToCollection('Season ${count + 1}', index, ShowType.season(), context));
  factory ShowType.season() => ShowType._(paddingDistance: 40, textColor: Colors.green, fx: (int count, int index, BuildContext context) => addToCollection('Episode ${count + 1}', index, ShowType.episode(), context));
  factory ShowType.episode() => ShowType._(paddingDistance: 60, textColor: Colors.red, fx: (int count, int index, BuildContext context) => {});
}

class CollectionBloc extends Bloc<CollectionEvents, CollectionState> {
  CollectionBloc() : super(CollectionState.initial()) {
    on<AddToNode>((event, emit) {
      /// as expected...
      final List<CollectionState> nodes = getAllNodes(state);
      final CollectionState parent = nodes[event.index];
      final CollectionState updatedParent =
          parent.copyWith(children: [...parent.children, event.child]);

      /// emitting a nested tree is a bit more complicated..
      final CollectionState updatedNode =
          updateNode(state, parent, updatedParent);
      emit(updatedNode);
    });
  }
}

CollectionState updateNode(
    CollectionState current, CollectionState parent, CollectionState updated) {
/* The updateNode function is used to recursively update the entire tree with the new parent node. It takes in three arguments, node, current, and updated.

node represents the current node that is being processed in the recursion.
parent represents the parent node that needs to be updated with the new child.
updated represents the updated version of the parent node that contains the new child.

The function first checks if the current node is the same as the current parent node. If it is, it returns the updated parent node. If not, it recursively calls the updateNode function for each child node and maps the returned value to a new list of updated children. Finally, it returns a new node with the updated children list using the copyWith method.

In this way, the entire tree gets updated, replacing the original parent node with the updated one that contains the new child, making sure the entire tree structure is updated and maintained. */

  if (current == parent) {
    return updated;
  }
  final List<CollectionState> updatedChildren = current.children
      .map((childNode) => updateNode(childNode, parent, updated))
      .toList();

  return current.copyWith(children: updatedChildren);
}

List<CollectionState> getAllNodes(CollectionState node) {
  /// the getAllNodes function is used to recursively traverse a tree of CollectionState nodes and return a flattened list of all nodes in the tree.
  /* 
  The function takes in a single argument node, which is the root node of the tree that you want to traverse.

The function starts by using the fold method on the children property of the node argument. The fold method takes in two arguments, an initial value and a callback function.

The initial value is a list containing the node argument, [node]. This is the starting point for the recursion and represents the current list of all nodes that have been traversed so far.

The callback function takes in two arguments, previousValue and element. previousValue represents the current list of all nodes that have been traversed so far, and element represents the current child node that is being processed.

The callback function uses the spread operator (...) to concatenate the previousValue list with the result of calling getAllNodes on the current element child node. This is where the recursion happens. The getAllNodes function is called on each child node, which in turn calls the getAllNodes function on each of its children, and so on, recursively traversing the entire tree.

When the recursion reaches the leaf nodes of the tree, the function stops and the final list of all nodes is returned.

This way, the function will return all the nodes of the tree in a single flattened list.
 */
  return node.children.fold(
    [node],
    (previousValue, element) => [...previousValue, ...getAllNodes(element)],
  );
}

class CollectionState extends Equatable {
  const CollectionState({
    required this.name,
    required this.children,
    required this.showType,
  });
  final String name;
  final List<CollectionState> children;
  final ShowType showType;

  factory CollectionState.initial() {
    return CollectionState(
      name: "Collection",
      showType: ShowType.collection(),
      children: const [],
    );
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
    );
  }

  @override
  List<Object> get props => [name, children, showType];
}

abstract class CollectionEvents extends Equatable {
  @override
  List<Object> get props => [];
}

void addToCollection(
    String name, int index, ShowType showType, BuildContext context) {
  CollectionEvents event;

  event = AddToNode(
    index: index,
    child: CollectionState(
      name: name,
      showType: showType,
      children: const [],
    ),
  );

  BlocProvider.of<CollectionBloc>(context).add(event);
}

class AddToNode extends CollectionEvents {
  AddToNode({required this.index, required this.child});
  final int index;
  final CollectionState child;
  @override
  List<Object> get props => [index, child];
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:working_with_deeply_nested_data_in_bloc_update_21012023/collection_bloc.dart';
import 'package:working_with_deeply_nested_data_in_bloc_update_21012023/collection_state.dart';

void main() => runApp(const MyApp());

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
            itemCount: getNodes(state).length,
            itemBuilder: (context, index) {
              var nodes = getNodes(state)[index];
              Color textColor = nodes.showType.textColor;
              double distance = nodes.showType.spacing;
              return Padding(
                padding: EdgeInsets.only(left: distance),
                child: ListTile(
                  onTap: () => nodes.showType
                      .addToFx(nodes.children.length, index, context),
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

// getNodes helper function to do the recursion
List<CollectionState> getNodes(CollectionState state) {
  return state.children.fold(
    [state],
    (previousValue, element) => [...previousValue, ...getNodes(element)],
  );
}

// node represents the current node that is being processed in the recursion.

// parent represents the parent node that needs to be updated with the new child.

// updated represents the updated version of the parent node that contains the new child.

// The function first checks if the current node is the same as the current parent node. If it is, it returns the updated parent node. If not, it recursively calls the updateNode function for each child node and maps the returned value to a new list of updated children. Finally, it returns a new node with the updated children list using the copyWith method.

// In this way, the entire tree gets updated, replacing the original parent node with the updated one that contains the new child, making sure the entire tree structure is updated and maintained. */

// the getAllNodes function is used to recursively traverse a tree of CollectionState nodes and return a flattened list of all nodes in the tree.
   
//   The function takes in a single argument node, which is the root node of the tree that you want to traverse.

// The function starts by using the fold method on the children property of the node argument. The fold method takes in two arguments, an initial value and a callback function.

// The initial value is a list containing the node argument, [node]. This is the starting point for the recursion and represents the current list of all nodes that have been traversed so far.

// The callback function takes in two arguments, previousValue and element. previousValue represents the current list of all nodes that have been traversed so far, and element represents the current child node that is being processed.

// The callback function uses the spread operator (...) to concatenate the previousValue list with the result of calling getAllNodes on the current element child node. This is where the recursion happens. The getAllNodes function is called on each child node, which in turn calls the getAllNodes function on each of its children, and so on, recursively traversing the entire tree.

// When the recursion reaches the leaf nodes of the tree, the function stops and the final list of all nodes is returned.

// This way, the function will return all the nodes of the tree in a single flattened list. 
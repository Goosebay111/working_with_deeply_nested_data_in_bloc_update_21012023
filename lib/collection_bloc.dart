import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:working_with_deeply_nested_data_in_bloc_update_21012023/collection_event.dart';
import 'package:working_with_deeply_nested_data_in_bloc_update_21012023/collection_model.dart';
import 'package:working_with_deeply_nested_data_in_bloc_update_21012023/collection_state.dart';
import 'package:working_with_deeply_nested_data_in_bloc_update_21012023/main.dart';

class CollectionBloc extends Bloc<CollectionEvents, CollectionState> {
  CollectionBloc()
      : super(InitialState(
            name: 'Collection',
            showType: ShowType.collection(),
            children: const [])) {
    on<InsertionEvent>((event, emit) {
      /// as expected...
      final List<CollectionState> nodes = getNodes(state);
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

CollectionState updateNode(CollectionState current, CollectionState parent,
    CollectionState updatedParent) {
  if (current == parent) {
    return updatedParent;
  }
  final List<CollectionState> updatedChildren = current.children
      .map((childNode) => updateNode(childNode, parent, updatedParent))
      .toList();

  return current.copyWith(children: updatedChildren);
}
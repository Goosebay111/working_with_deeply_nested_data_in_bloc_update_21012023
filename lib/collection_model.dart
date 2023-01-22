import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:working_with_deeply_nested_data_in_bloc_update_21012023/collection_bloc.dart';
import 'package:working_with_deeply_nested_data_in_bloc_update_21012023/collection_event.dart';
import 'package:working_with_deeply_nested_data_in_bloc_update_21012023/collection_state.dart';

class ShowType {
  /// Add any number of node extensions here by adding a new named constructor and a new addToFx function to the predecessor. The last node extension should have an empty addToFx function.
  final double spacing;
  final Color textColor;
  final Function addToFx;

  ShowType._(
      {required this.spacing, required this.textColor, required this.addToFx});
  ShowType.collection()
      : this._(spacing: 0, textColor: Colors.black, addToFx: AddTo.collection);
  ShowType.series()
      : this._(spacing: 20, textColor: Colors.blue, addToFx: AddTo.series);
  ShowType.season()
      : this._(spacing: 40, textColor: Colors.green, addToFx: AddTo.season);
  ShowType.episode()
      : this._(spacing: 60, textColor: Colors.red, addToFx: AddTo.episode);
}

class AddTo {
  static void collection(int count, int index, BuildContext context) {
    addToNode('Series ${count + 1}', index, ShowType.series(), context);
  }

  static void series(int count, int index, BuildContext context) {
    addToNode('Season ${count + 1}', index, ShowType.season(), context);
  }

  static void season(int count, int index, BuildContext context) {
    addToNode('Episode ${count + 1}', index, ShowType.episode(), context);
  }

  static void episode(int count, int index, BuildContext context) {
    () {};
  }
}

void addToNode(
    String name, int index, ShowType showType, BuildContext context) {
  CollectionEvents event;

  event = InsertionEvent(
    index: index,
    child: ModifiableState(
      name: name,
      showType: showType,
      children: const [],
    ),
  );

  BlocProvider.of<CollectionBloc>(context).add(event);
}


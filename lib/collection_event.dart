import 'package:equatable/equatable.dart';
import 'package:working_with_deeply_nested_data_in_bloc_update_21012023/collection_state.dart';

abstract class CollectionEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class InsertionEvent extends CollectionEvents {
  InsertionEvent({required this.index, required this.child});
  final int index;
  final ModifiableState child;
  @override
  List<Object> get props => [index, child];
}
import 'package:equatable/equatable.dart';
import 'package:working_with_deeply_nested_data_in_bloc_update_21012023/collection_model.dart';

abstract class CollectionState extends Equatable {
  const CollectionState(
      {required this.name, required this.children, required this.showType});

  final String name;
  final List<CollectionState> children;
  final ShowType showType;

  CollectionState copyWith(
      {String? name, List<CollectionState>? children, ShowType? showType});
}

class InitialState extends CollectionState {
  const InitialState(
      {required String name,
      required List<CollectionState> children,
      required ShowType showType})
      : super(name: name, children: children, showType: showType);

  @override
  CollectionState copyWith(
      {String? name, List<CollectionState>? children, ShowType? showType}) {
    return InitialState(
      name: name ?? this.name,
      children: children ?? this.children,
      showType: showType ?? this.showType,
    );
  }

  @override
  List<Object> get props => [name, children, showType];
}

class ModifiableState extends CollectionState {
  const ModifiableState({
    required this.name,
    required this.children,
    required this.showType,
  }) : super(name: name, children: children, showType: showType);
  @override
  final String name;
  @override
  final List<CollectionState> children;
  @override
  final ShowType showType;

  @override
  ModifiableState copyWith({
    String? name,
    List<CollectionState>? children,
    ShowType? showType,
  }) {
    return ModifiableState(
      name: name ?? this.name,
      children: children ?? this.children,
      showType: showType ?? this.showType,
    );
  }

  @override
  List<Object> get props => [name, children, showType];
}
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

class CreateMemePageBloc {
  final memeTextSubject = BehaviorSubject<List<MemeText>>.seeded(<MemeText>[]);
  final selectedMemeTextSubject = BehaviorSubject<MemeText?>.seeded(null);

  Stream<List<MemeText>> observeMemeTexts() => memeTextSubject
      .distinct((prev, next) => ListEquality().equals(prev, next));

  Stream<MemeText?> observeSelectedMemeText() =>
      selectedMemeTextSubject.distinct();

  Stream<List<MemeTextWithSelection>> observeMemeTextsWithSelection() {
    return Rx.combineLatest2<List<MemeText>, MemeText?,
            List<MemeTextWithSelection>>(
        observeMemeTexts(), observeSelectedMemeText(),
        (memeTexts, selectedMemeText) {
      return memeTexts.map((memeText) {
        return MemeTextWithSelection(
          memeText: memeText,
          selected: memeText.id == selectedMemeText?.id,
        );
      }).toList();
    });
  }

  CreateMemePageBloc() {}

  void addNewText() {
    final newMemeText = MemeText.create();
    memeTextSubject.add([...memeTextSubject.value, newMemeText]);
    selectedMemeTextSubject.add(newMemeText);
  }

  void selectMemeText(final String id) {
    final foundMemeText =
        memeTextSubject.value.firstWhereOrNull((memeText) => memeText.id == id);
    selectedMemeTextSubject.add(foundMemeText);
  }

  void deselectMemeText() {
    print("deselect");
    selectedMemeTextSubject.add(null);
  }

  void changeMemeText(final String id, final String text) {
    final copiedList = [...memeTextSubject.value];
    final index = copiedList.indexWhere((memeText) => memeText.id == id);
    if (index == -1) {
      return;
    }

    copiedList.removeAt(index);
    copiedList.insert(index, MemeText(id: id, text: text));
    memeTextSubject.add(copiedList);
  }

  bool isMemeTextSelected(final String id) {
    final foundMemeText =
        memeTextSubject.value.firstWhereOrNull((memeText) => memeText.id == id);
    if (foundMemeText != null &&
        foundMemeText == selectedMemeTextSubject.value) {
      return true;
    }
    return false;
  }

  void dispose() {
    memeTextSubject.close();
    selectedMemeTextSubject.close();
  }
}

class MemeText {
  final String id;
  final String text;

  MemeText({required this.id, required this.text});

  factory MemeText.create() {
    return MemeText(id: Uuid().v4(), text: "");
  }

  @override
  String toString() {
    return 'MemeText{id: $id, text: $text}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemeText &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text;

  @override
  int get hashCode => id.hashCode ^ text.hashCode;
}

class MemeTextWithSelection {
  final MemeText memeText;
  final bool selected;

  MemeTextWithSelection({required this.memeText, required this.selected});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemeTextWithSelection &&
          runtimeType == other.runtimeType &&
          memeText == other.memeText &&
          selected == other.selected;

  @override
  int get hashCode => memeText.hashCode ^ selected.hashCode;

  @override
  String toString() {
    return 'MemeTextWithSelection{memeText: $memeText, selected: $selected}';
  }
}

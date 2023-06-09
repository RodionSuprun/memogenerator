import 'dart:async';
import 'dart:ui';

import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/models/position.dart';
import 'package:memogenerator/data/models/text_with_position.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_offset.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_offset.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import '../../domain/interactors/save_meme_interactor.dart';
import 'models/meme_text.dart';
import 'models/meme_text_with_selection.dart';

class CreateMemePageBloc {
  final memeTextSubject = BehaviorSubject<List<MemeText>>.seeded(<MemeText>[]);
  final selectedMemeTextSubject = BehaviorSubject<MemeText?>.seeded(null);
  final memeTextOffsetsSubject =
      BehaviorSubject<List<MemeTextOffset>>.seeded(<MemeTextOffset>[]);

  final newMemeTextOffsetSubject =
      BehaviorSubject<MemeTextOffset?>.seeded(null);

  final memePathSubject = BehaviorSubject<String?>.seeded(null);

  Stream<List<MemeText>> observeMemeTexts() => memeTextSubject
      .distinct((prev, next) => ListEquality().equals(prev, next));

  Stream<List<MemeTextWithOffset>> observeMemeTextsWithOffsets() {
    return Rx.combineLatest2<List<MemeText>, List<MemeTextOffset>,
            List<MemeTextWithOffset>>(
        observeMemeTexts(), memeTextOffsetsSubject.distinct(),
        (memeTexts, memeTextOffsets) {
      return memeTexts.map((memeText) {
        final memeTextOffset =
            memeTextOffsets.firstWhereOrNull((memeTextOffset) {
          return memeTextOffset.id == memeText.id;
        });
        return MemeTextWithOffset(
            id: memeText.id,
            text: memeText.text,
            offset: memeTextOffset?.offset);
      }).toList();
    });
  }

  Stream<MemeText?> observeSelectedMemeText() =>
      selectedMemeTextSubject.distinct();

  StreamSubscription<MemeTextOffset?>? newMemeTextOffsetSubscription;
  StreamSubscription<bool>? saveMemeSubscription;
  StreamSubscription<Meme?>? existMemeSubscription;

  final String id;

  Stream<String?> observeMemePath() => memePathSubject.distinct();

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

  CreateMemePageBloc({final String? id, final String? selectedMemePath})
      : this.id = id ?? Uuid().v4() {
    memePathSubject.add(selectedMemePath);
    _subscribeToNewMemeTextOffset();
    _subscribeToExistingMeme();
  }

  void _subscribeToExistingMeme() {
    existMemeSubscription = MemesRepository.getInstance()
        .getMeme(this.id)
        .asStream()
        .listen((meme) {
      if (meme == null) {
        return;
      }
      final memeTexts = meme.texts.map((textWithPosition) {
        return MemeText(id: textWithPosition.id, text: textWithPosition.text);
      }).toList();
      final memeTextOffsets = meme.texts.map((textWithPosition) {
        return MemeTextOffset(
          id: textWithPosition.id,
          offset: Offset(
            textWithPosition.position.left,
            textWithPosition.position.top,
          ),
        );
      }).toList();
      memeTextSubject.add(memeTexts);
      memeTextOffsetsSubject.add(memeTextOffsets);
      memePathSubject.add(meme.memePath);
    }, onError: (error, stackTrace) {});
  }

  void saveMeme() {
    final memeTexts = memeTextSubject.value;
    final memeTextOffsets = memeTextOffsetsSubject.value;
    final textsWithPositions = memeTexts.map((memeText) {
      final memeTextPosition =
          memeTextOffsets.firstWhereOrNull((memeTextOffset) {
        return memeTextOffset.id == memeText.id;
      });
      final position = Position(
        left: memeTextPosition?.offset.dx ?? 0,
        top: memeTextPosition?.offset.dy ?? 0,
      );
      return TextWithPosition(
        id: memeText.id,
        text: memeText.text,
        position: position,
      );
    }).toList();
    saveMemeSubscription = SaveMemeInteractor.getInstance()
        .saveMeme(
            id: id,
            textWithPositions: textsWithPositions,
            imagePath: memePathSubject.value)
        .asStream()
        .listen((event) {
      print("Meme saved");
    }, onError: (error, stackTrace) {
      print("Error in saveMemeSubscription $error");
    });
  }

  void _subscribeToNewMemeTextOffset() {
    newMemeTextOffsetSubscription = newMemeTextOffsetSubject
        .debounceTime(Duration(milliseconds: 300))
        .listen(
      (newMemeTextOffset) {
        if (newMemeTextOffset != null) {
          _changeMemeTextOffsetInternal(newMemeTextOffset);
        }
      },
      onError: (error, stackTrace) {
        print("Error in newMemeTextSubscription $error");
      },
    );
  }

  void changeMemeTextOffset(final String id, final Offset offset) {
    newMemeTextOffsetSubject.add(MemeTextOffset(id: id, offset: offset));
  }

  void _changeMemeTextOffsetInternal(final MemeTextOffset newMemeTextOffset) {
    final copiedMemeTextOffsets = [...memeTextOffsetsSubject.value];
    final currentTextOffset = copiedMemeTextOffsets.firstWhereOrNull(
        (memeTextOffset) => memeTextOffset.id == newMemeTextOffset.id);
    if (currentTextOffset != null) {
      copiedMemeTextOffsets.remove(currentTextOffset);
    }

    copiedMemeTextOffsets.add(newMemeTextOffset);
    memeTextOffsetsSubject.add(copiedMemeTextOffsets);

    print("Got new object ${newMemeTextOffset}");
  }

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
    memeTextOffsetsSubject.close();
    newMemeTextOffsetSubject.close();
    newMemeTextOffsetSubscription?.cancel();
    saveMemeSubscription?.cancel();
    existMemeSubscription?.cancel();
    memePathSubject.close();
  }
}

import 'package:flutter/material.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

import '../blocs/create_meme_page_bloc.dart';

class CreateMemePage extends StatefulWidget {
  const CreateMemePage({Key? key}) : super(key: key);

  @override
  State<CreateMemePage> createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late CreateMemePageBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = CreateMemePageBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: AppColors.lemon,
          foregroundColor: AppColors.darkGrey,
          title: Text(
            "Создаем мем",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
          bottom: EditTextBar(),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CreateMemePageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class CreateMemePageContent extends StatelessWidget {
  const CreateMemePageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: MemeCanvasWidget(),
        ),
        Container(
          color: AppColors.darkGrey,
          height: 1,
          width: double.infinity,
        ),
        Expanded(
          flex: 1,
          child: BottomList(),
        ),
      ],
    );
  }
}

class BottomList extends StatelessWidget {
  const BottomList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemePageBloc>(context, listen: false);
    return Container(
      color: Colors.white,
      child: StreamBuilder<List<MemeTextWithSelection>>(
        stream: bloc.observeMemeTextsWithSelection(),
        initialData: <MemeTextWithSelection>[],
        builder: (context, snapshot) {
          final listItems =
              snapshot.hasData ? snapshot.data! : <MemeTextWithSelection>[];
          return ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: listItems.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return AddNewMemeTextButton(
                  onTap: () {
                    bloc.addNewText();
                  },
                );
              } else {
                return BottomMemeText(
                  memeText: listItems[index - 1],
                );
              }
            },
            separatorBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return SizedBox.shrink();
              }
              return BottomSeparator();
            },
          );
        },
      ),
    );
  }
}

class BottomSeparator extends StatelessWidget {
  const BottomSeparator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.only(left: 16),
      color: AppColors.darkGrey,
    );
  }
}

class BottomMemeText extends StatelessWidget {
  final MemeTextWithSelection memeText;

  const BottomMemeText({Key? key, required this.memeText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      color: memeText.selected ? AppColors.darkGrey16 : Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Text(
        memeText.memeText.text,
        style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: AppColors.darkGrey),
      ),
    );
  }
}

class MemeCanvasWidget extends StatelessWidget {
  const MemeCanvasWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemePageBloc>(context, listen: false);
    return Container(
      color: AppColors.darkGrey38,
      padding: EdgeInsets.all(8),
      alignment: Alignment.topCenter,
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: () {
            bloc.deselectMemeText();
          },
          child: Container(
            color: Colors.white,
            child: StreamBuilder<List<MemeText>>(
                initialData: <MemeText>[],
                stream: bloc.observeMemeTexts(),
                builder: (context, snapshot) {
                  final memeTexts =
                      snapshot.hasData ? snapshot.data! : <MemeText>[];
                  return LayoutBuilder(builder: (context, constraints) {
                    return Stack(
                      children: memeTexts
                          .map(
                            (memeText) => DraggableMemeText(
                              memeText: memeText,
                              parentConstraints: constraints,
                            ),
                          )
                          .toList(),
                    );
                  });
                }),
          ),
        ),
      ),
    );
  }
}

class DraggableMemeText extends StatefulWidget {
  final MemeText memeText;
  final BoxConstraints parentConstraints;

  const DraggableMemeText({
    Key? key,
    required this.memeText,
    required this.parentConstraints,
  }) : super(key: key);

  @override
  State<DraggableMemeText> createState() => _DraggableMemeTextState();
}

class _DraggableMemeTextState extends State<DraggableMemeText> {
  late double top;
  late double left;
  final double padding = 8;
  final double fontSize = 24;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();

    top = widget.parentConstraints.maxHeight / 2;
    left = widget.parentConstraints.maxWidth / 3;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemePageBloc>(context, listen: false);

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          bloc.selectMemeText(widget.memeText.id);
        },
        onPanStart: (details) {
          bloc.selectMemeText(widget.memeText.id);
        },
        onPanUpdate: (details) {
          setState(() {
            left = calculateLeft(details);
            top = calculateTop(details);
          });
        },
        child: StreamBuilder<MemeText?>(
            stream: bloc.observeSelectedMemeText(),
            builder: (context, snapshot) {
              final MemeText? memeText =
                  snapshot.hasData ? snapshot.data : null;
              final selected = widget.memeText.id == memeText?.id;
              return MemeTextOnCanvas(
                  padding: padding,
                  parentConstraints: widget.parentConstraints,
                  memeText: widget.memeText,
                  selected: selected);
            }),
      ),
    );
  }

  double calculateTop(DragUpdateDetails details) {
    final rawTop = top + details.delta.dy;
    if (rawTop < 0) {
      return 0;
    }
    if (rawTop > widget.parentConstraints.maxHeight - padding * 2 - fontSize) {
      return widget.parentConstraints.maxHeight - padding * 2 - fontSize;
    }
    return top + details.delta.dy;
  }

  double calculateLeft(DragUpdateDetails details) {
    final rawLeft = left + details.delta.dx;
    if (rawLeft < 0) {
      return 0;
    }
    if (rawLeft > widget.parentConstraints.maxWidth - padding * 2 - fontSize) {
      return widget.parentConstraints.maxWidth - padding * 2 - fontSize;
    }
    return left + details.delta.dx;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class MemeTextOnCanvas extends StatelessWidget {
  const MemeTextOnCanvas({
    Key? key,
    required this.padding,
    required this.parentConstraints,
    required this.memeText,
    required this.selected,
  }) : super(key: key);

  final MemeText memeText;
  final bool selected;
  final double padding;
  final BoxConstraints parentConstraints;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: parentConstraints.maxWidth,
        maxHeight: parentConstraints.maxHeight,
      ),
      decoration: BoxDecoration(
          color: selected ? AppColors.darkGrey16 : Colors.transparent,
          border: selected ? Border.all(color: AppColors.fuchsia) : null),
      padding: EdgeInsets.all(padding),
      child: Text(
        memeText.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class AddNewMemeTextButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddNewMemeTextButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: AppColors.fuchsia,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                "Добавить текст".toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fuchsia,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditTextBar extends StatefulWidget implements PreferredSizeWidget {
  const EditTextBar({Key? key}) : super(key: key);

  @override
  State<EditTextBar> createState() => _EditTextBarState();

  @override
  Size get preferredSize => Size.fromHeight(68);
}

class _EditTextBarState extends State<EditTextBar> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemePageBloc>(context, listen: false);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: StreamBuilder<MemeText?>(
          stream: bloc.observeSelectedMemeText(),
          builder: (context, snapshot) {
            final MemeText? selectedMemeText =
                snapshot.hasData ? snapshot.data : null;
            if (selectedMemeText?.text != controller.text) {
              final newText = selectedMemeText?.text ?? "";
              controller.text = newText;
              controller.selection =
                  TextSelection.collapsed(offset: newText.length);
            }
            return TextField(
              enabled: selectedMemeText != null,
              controller: controller,
              cursorColor: AppColors.fuchsia,
              onChanged: (text) {
                if (selectedMemeText != null) {
                  bloc.changeMemeText(selectedMemeText.id, text);
                }
              },
              onEditingComplete: () {
                bloc.deselectMemeText();
              },
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: AppColors.darkGrey38,
                  fontSize: 16,
                ),
                hintText: controller.text == "" && selectedMemeText?.text == ""
                    ? "Ввести текст"
                    : "",
                filled: true,
                fillColor: selectedMemeText == null
                    ? AppColors.darkGrey6
                    : AppColors.fuchsia16,
                focusedBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(
                    color: AppColors.fuchsia,
                    width: 2,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(
                    color: AppColors.fuchsia38,
                    width: 1,
                  ),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(
                    color: AppColors.darkGrey38,
                    width: 1,
                  ),
                ),
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

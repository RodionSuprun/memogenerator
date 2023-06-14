import 'package:flutter/material.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_page_bloc.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memogenerator/presentation/widgets/app_button.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

import 'meme_text_on_canvas.dart';

class FontSettingsBottomSheet extends StatefulWidget {
  final MemeText memeText;

  const FontSettingsBottomSheet({Key? key, required this.memeText})
      : super(key: key);

  @override
  State<FontSettingsBottomSheet> createState() =>
      _FontSettingsBottomSheetState();
}

class _FontSettingsBottomSheetState extends State<FontSettingsBottomSheet> {
  late double fontSize;
  late Color color;
  late FontWeight fontWeight;

  @override
  void initState() {
    super.initState();
    fontSize = widget.memeText.fontSize;
    color = widget.memeText.color;
    fontWeight = widget.memeText.fontWeight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 8,
          ),
          Center(
            child: Container(
              height: 4,
              width: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: AppColors.darkGrey38,
              ),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          MemeTextOnCanvas(
            padding: 8,
            parentConstraints: BoxConstraints.expand(),
            text: widget.memeText.text,
            selected: true,
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
          ),
          SizedBox(
            height: 48,
          ),
          FontSizeSlider(
            initialFontSize: fontSize,
            changeFontSize: (value) {
              setState(() {
                fontSize = value;
              });
            },
          ),
          SizedBox(
            height: 16,
          ),
          ColorSelection(changeColor: (value) {
            setState(() {
              color = value;
            });
          }),
          SizedBox(
            height: 24,
          ),
          FontWeightSlider(
              initialFontWeight: fontWeight,
              changeFontWeight: (value) {
                setState(() {
                  fontWeight = value;
                });
              }),
          SizedBox(
            height: 36,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Buttons(
              textId: widget.memeText.id,
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
          SizedBox(
            height: 48,
          ),
        ],
      ),
    );
  }
}

class Buttons extends StatelessWidget {
  final String textId;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  const Buttons({
    Key? key,
    required this.textId,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemePageBloc>(context, listen: false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          onTap: () {
            Navigator.of(context).pop();
          },
          text: "Отмена",
          color: AppColors.darkGrey,
        ),
        SizedBox(
          width: 24,
        ),
        AppButton(
          onTap: () {
            bloc.changeFontSettings(textId, color, fontSize, fontWeight);
            Navigator.of(context).pop();
          },
          text: "Сохранить",
        ),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }
}

class ColorSelection extends StatelessWidget {
  const ColorSelection({
    Key? key,
    required this.changeColor,
  }) : super(key: key);

  final ValueChanged<Color> changeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 16,
        ),
        Text(
          "Color:",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        SizedBox(
          width: 16,
        ),
        ColorSelectionBox(
          color: Colors.white,
          changeColor: changeColor,
        ),
        SizedBox(
          width: 16,
        ),
        ColorSelectionBox(
          color: Colors.black,
          changeColor: changeColor,
        ),
      ],
    );
  }
}

class ColorSelectionBox extends StatelessWidget {
  const ColorSelectionBox({
    Key? key,
    required this.color,
    required this.changeColor,
  }) : super(key: key);

  final Color color;
  final ValueChanged<Color> changeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        changeColor(color);
      },
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class FontSizeSlider extends StatefulWidget {
  const FontSizeSlider({
    Key? key,
    required this.initialFontSize,
    required this.changeFontSize,
  }) : super(key: key);

  final double initialFontSize;

  final ValueChanged<double> changeFontSize;

  @override
  State<FontSizeSlider> createState() => _FontSizeSliderState();
}

class _FontSizeSliderState extends State<FontSizeSlider> {
  late double fontSize;

  @override
  void initState() {
    super.initState();
    fontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 8,
          ),
          child: Text(
            "Size:",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.fuchsia,
              inactiveTrackColor: AppColors.fuchsia38,
              valueIndicatorShape: PaddleSliderValueIndicatorShape(),
              thumbColor: AppColors.fuchsia,
              inactiveTickMarkColor: AppColors.fuchsia,
              valueIndicatorColor: AppColors.fuchsia,
            ),
            child: Slider(
              min: 16,
              max: 32,
              divisions: 10,
              label: fontSize.round().toString(),
              value: fontSize,
              onChanged: (double value) {
                setState(() {
                  fontSize = value;
                  widget.changeFontSize(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class FontWeightSlider extends StatefulWidget {
  const FontWeightSlider({
    Key? key,
    required this.initialFontWeight,
    required this.changeFontWeight,
  }) : super(key: key);

  final FontWeight initialFontWeight;

  final ValueChanged<FontWeight> changeFontWeight;

  @override
  State<FontWeightSlider> createState() => _FontWeightSliderState();
}

class _FontWeightSliderState extends State<FontWeightSlider> {
  late FontWeight fontWeight;
  late double fontWeightIndex;

  @override
  void initState() {
    super.initState();
    fontWeight = widget.initialFontWeight;
    fontWeightIndex = FontWeight.values.indexOf(fontWeight).toDouble();
    print(fontWeightIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 8,
          ),
          child: Text(
            "Font Weight:",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.fuchsia,
              inactiveTrackColor: AppColors.fuchsia38,
              thumbColor: AppColors.fuchsia,
              inactiveTickMarkColor: AppColors.fuchsia,
              valueIndicatorColor: AppColors.fuchsia,
            ),
            child: Slider(
              min: 0,
              max: FontWeight.values.length - 1,
              divisions: FontWeight.values.length,
              value: fontWeightIndex,
              onChanged: (double value) {
                setState(() {
                  fontWeightIndex = value;
                  print(FontWeight.values[fontWeightIndex.toInt()]);
                  widget.changeFontWeight(
                      FontWeight.values[fontWeightIndex.toInt()]);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

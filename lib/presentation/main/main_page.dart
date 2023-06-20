import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_page.dart';
import 'package:memogenerator/presentation/easter_egg/easter_egg_page.dart';
import 'package:memogenerator/presentation/main/models/meme_thumbnail.dart';
import 'package:memogenerator/presentation/main/models/template_full.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

import '../widgets/app_button.dart';
import 'main_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late MainBloc bloc;
  late TabController controller;

  int index = 0;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc();
    controller = TabController(length: 2, vsync: this);

    controller.addListener(() {
      setState(() {
        index = controller.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: WillPopScope(
        onWillPop: () async {
          final goBack = await _showConfirmationExitDialog(context);
          return goBack ?? false;
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColors.lemon,
            foregroundColor: AppColors.darkGrey,
            title: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return EasterEggPage();
                    },
                  ),
                );
              },
              child: Text(
                "Мемогенератор",
                style: GoogleFonts.seymourOne(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            bottom: TabBar(
              controller: controller,
              labelColor: AppColors.darkGrey,
              indicatorColor: AppColors.fuchsia,
              tabs: [
                Tab(
                  text: "Созданные".toUpperCase(),
                ),
                Tab(
                  text: "Шаблоны".toUpperCase(),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          floatingActionButton: index == 0 ? CreateMemeFab() : CreateTemplateFab(),
          body: TabBarView(
            controller: controller,
            children: [
              SafeArea(
                child: CreatedMemesGrid(),
              ),
              SafeArea(
                child: TemplatesMemesGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationExitDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Точно хотите выйти?"),
            content: Text(
              "Мемы сами себя не сделают",
              style: TextStyle(
                color: AppColors.darkGrey86,
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 16),
            actions: [
              AppButton(
                onTap: () => Navigator.of(context).pop(false),
                text: "Остаться",
                color: AppColors.darkGrey,
              ),
              AppButton(
                  onTap: () => Navigator.of(context).pop(true), text: "Выйти")
            ],
          );
        });
  }

  @override
  void dispose() {
    bloc.dispose();
    controller.dispose();
    super.dispose();
  }
}

class CreateMemeFab extends StatelessWidget {
  const CreateMemeFab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return FloatingActionButton.extended(
      onPressed: () async {
        final selectedMemePath = await bloc.selectMeme();
        if (selectedMemePath == null) {
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return CreateMemePage(
                selectedMemePath: selectedMemePath,
              );
            },
          ),
        );
      },
      icon: Icon(Icons.add),
      backgroundColor: AppColors.fuchsia,
      label: Text(
        "Мем",
      ),
    );
  }
}

class CreateTemplateFab extends StatelessWidget {
  const CreateTemplateFab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return FloatingActionButton.extended(
      onPressed: () async {
        await bloc.selectTemplate();
      },
      icon: Icon(Icons.add),
      backgroundColor: AppColors.fuchsia,
      label: Text(
        "Шаблон",
      ),
    );
  }
}

class CreatedMemesGrid extends StatelessWidget {
  const CreatedMemesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<List<MemeThumbnail>>(
      stream: bloc.observeMemes(),
      initialData: [],
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        final items = snapshot.requireData;
        return GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          children: items.map(
            (item) {
              return MemeGridItem(
                memeThumbnail: item,
              );
            },
          ).toList(),
        );
      },
    );
  }
}

class MemeGridItem extends StatelessWidget {
  const MemeGridItem({
    Key? key,
    required this.memeThumbnail,
  }) : super(key: key);

  final MemeThumbnail memeThumbnail;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    final imageFile = File(memeThumbnail.fullImageUrl);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return CreateMemePage(
                id: memeThumbnail.memeId,
              );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.darkGrey,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            imageFile.existsSync()
                ? Image.file(File(memeThumbnail.fullImageUrl,))
                : Text(memeThumbnail.memeId),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 4,
                  bottom: 4,
                ),
                child: GestureDetector(
                  onTap: () async {
                    final acceptRemove =
                        await _showConfirmationDeleteMemeDialog(context);
                    if (acceptRemove == true) {
                      bloc.deleteMeme(memeThumbnail.memeId);
                    }
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey38,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                        horizontal: 13,
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDeleteMemeDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Удалить мем?"),
            content: Text(
              "Выбранный мем будет удалён навсегда",
              style: TextStyle(
                color: AppColors.darkGrey86,
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 16),
            actions: [
              AppButton(
                onTap: () => Navigator.of(context).pop(false),
                text: "Отмена",
                color: AppColors.darkGrey,
              ),
              AppButton(
                  onTap: () => Navigator.of(context).pop(true), text: "Удалить")
            ],
          );
        });
  }
}

class TemplatesMemesGrid extends StatelessWidget {
  const TemplatesMemesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<List<TemplateFull>>(
      stream: bloc.observeTemplates(),
      initialData: [],
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        final items = snapshot.requireData;
        return GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          children: items.map(
            (item) {
              return TemplateGridItem(
                templateFull: item,
              );
            },
          ).toList(),
        );
      },
    );
  }
}

class TemplateGridItem extends StatelessWidget {
  const TemplateGridItem({
    Key? key,
    required this.templateFull,
  }) : super(key: key);

  final TemplateFull templateFull;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    final imageFile = File(templateFull.fullImagePath);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return CreateMemePage(
                selectedMemePath: templateFull.fullImagePath,
              );
            },
          ),
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.darkGrey,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            imageFile.existsSync()
                ? Image.file(
                    imageFile,
                  )
                : Text(templateFull.id),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 4,
                  bottom: 4,
                ),
                child: GestureDetector(
                  onTap: () async {
                    final acceptRemove =
                        await _showConfirmationDeleteTemplateDialog(context);
                    if (acceptRemove == true) {
                      bloc.deleteTemplate(templateFull.id);
                    }
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey38,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                        horizontal: 13,
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDeleteTemplateDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Удалить шаблон?"),
            content: Text(
              "Выбранный шаблон будет удалён навсегда",
              style: TextStyle(
                color: AppColors.darkGrey86,
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 16),
            actions: [
              AppButton(
                onTap: () => Navigator.of(context).pop(false),
                text: "Отмена",
                color: AppColors.darkGrey,
              ),
              AppButton(
                  onTap: () => Navigator.of(context).pop(true), text: "Удалить")
            ],
          );
        });
  }
}

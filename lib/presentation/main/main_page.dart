import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_page.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

import '../../data/models/meme.dart';
import 'main_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.lemon,
          foregroundColor: AppColors.darkGrey,
          title: Text(
            "Мемогенератор",
            style: GoogleFonts.seymourOne(
              fontSize: 24,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton.extended(
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
            "Создать".toUpperCase(),
          ),
        ),
        body: SafeArea(
          child: MainPageContent(),
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

class MainPageContent extends StatelessWidget {
  const MainPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<List<Meme>>(
        stream: bloc.observeMemes,
        initialData: <Meme>[],
        builder: (context, snapshot) {
          final items = snapshot.hasData ? snapshot.data! : const <Meme>[];
          return ListView(
            children: items.map((item) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return CreateMemePage(id: item.id);
                      },
                    ),
                  );
                },
                child: Container(
                    height: 48,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Text(item.id)),
              );
            }).toList(),
          );
        });
  }
}

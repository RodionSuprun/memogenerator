import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memogenerator/pages/create_meme_page.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

import '../blocs/main_bloc.dart';

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
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateMemePage(),
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
    return const Stack(
      children: [],
    );
  }
}

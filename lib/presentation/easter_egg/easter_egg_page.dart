import 'package:flutter/material.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:memogenerator/resources/app_images.dart';

class EasterEggPage extends StatelessWidget {
  const EasterEggPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lemon,
        foregroundColor: AppColors.darkGrey,
      ),
      body: RocketAnimationBody(),
    );
  }
}

class RocketAnimationBody extends StatefulWidget {
  const RocketAnimationBody({Key? key}) : super(key: key);

  @override
  State<RocketAnimationBody> createState() => _RocketAnimationBodyState();
}

class _RocketAnimationBodyState extends State<RocketAnimationBody>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Alignment> rocketPositionAnimation;
  late Animation<double> rocketScaleAnimation;
  late Animation<double> fireRotationAnimation;
  late Animation<double> glowScaleAnimation;
  late Animation<double> opacityAnimation;

  static const animationDurationSecond = 10;

  bool started = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: animationDurationSecond),
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
        setState(() {
          started = false;
        });
      }
    });

    rocketPositionAnimation = AlignmentTween(
      begin: Alignment(0, 0.9),
      end: Alignment(0, -1),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.1,
          0.8,
          curve: Curves.easeInCubic,
        ),
      ),
    );

    rocketScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.3,
          0.8,
          curve: Curves.easeIn,
        ),
      ),
    );

    opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.3,
          0.5,
          curve: Curves.easeIn,
        ),
      ),
    );

    fireRotationAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.005, end: -0.005),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.005, end: 0.005),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: SawTooth(animationDurationSecond * 5),
      ),
    );

    glowScaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.8, 0.9),
      ),
    );
  }

  void animate() {
    if (controller.isAnimating) {
      return;
    }
    controller.forward();
    setState(() {
      started = true;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppImages.starsPattern),
                repeat: ImageRepeat.repeat),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: FadeTransition(
                  opacity: opacityAnimation,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.elliptical(constraints.maxWidth, 200),
                      ),
                    ),
                  ),
                ),
              ),
              if (started)
                AlignTransition(
                  alignment: rocketPositionAnimation,
                  child: RotationTransition(
                    turns: fireRotationAnimation,
                    child: ScaleTransition(
                      scale: rocketScaleAnimation,
                      child: Image.asset(
                        AppImages.rocketFire,
                        height: 200,
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => animate(),
                child: AlignTransition(
                  alignment: rocketPositionAnimation,
                  child: ScaleTransition(
                    scale: rocketScaleAnimation,
                    child: Image.asset(
                      AppImages.rocketWithoutFire,
                      height: 200,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 70,
                left: constraints.maxWidth / 2 - 40,
                child: ScaleTransition(
                  scale: glowScaleAnimation,
                  child: Image.asset(
                    AppImages.starGlow,
                    height: 50,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

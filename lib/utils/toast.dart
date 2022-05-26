import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

CancelFunc showText({
  required String text,
  WrapAnimation? wrapAnimation,
  WrapAnimation? wrapToastAnimation,
  Color backgroundColor = Colors.transparent,
  Color contentColor = Colors.black45,
  BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(4)),
  TextStyle textStyle = const TextStyle(fontSize: 14, color: Colors.white),
  AlignmentGeometry? align = const Alignment(0, 0.8),
  EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
  Duration? duration = const Duration(seconds: 2),
  Duration? animationDuration,
  Duration? animationReverseDuration,
  BackButtonBehavior? backButtonBehavior,
  VoidCallback? onClose,
  bool enableKeyboardSafeArea = true,
  bool clickClose = false,
  bool crossPage = true,
  bool onlyOne = true,
}) {
  return BotToast.showText(
    text: text,
    wrapAnimation: wrapAnimation,
    wrapToastAnimation: wrapToastAnimation,
    backgroundColor: backgroundColor,
    contentColor: contentColor,
    borderRadius: borderRadius,
    textStyle: textStyle,
    align: align,
    contentPadding: contentPadding,
    duration: duration,
    animationDuration: animationDuration,
    animationReverseDuration: animationReverseDuration,
    backButtonBehavior: backButtonBehavior,
    onClose: onClose,
    enableKeyboardSafeArea: enableKeyboardSafeArea,
    clickClose: clickClose,
    crossPage: crossPage,
    onlyOne: onlyOne,
  );
}

void showAlertDialog({
  required String title,
  String confirmText = '确认',
  String cancelText = '取消',
  Color confirmTextColor = Colors.orange,
  Color cancelTextColor = Colors.black45,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  VoidCallback? backgroundReturn,
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.close,
}) {
  BotToast.showAnimationWidget(
      clickClose: false,
      allowClick: false,
      onlyOne: true,
      crossPage: true,
      backButtonBehavior: backButtonBehavior,
      wrapToastAnimation: (controller, cancel, child) => Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  cancel();
                  backgroundReturn?.call();
                },
                //The DecoratedBox here is very important,he will fill the entire parent component
                child: AnimatedBuilder(
                  builder: (_, child) => Opacity(
                    opacity: controller.value,
                    child: child,
                  ),
                  animation: controller,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black26),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
              _CustomOffsetAnimation(
                controller: controller,
                child: child,
              )
            ],
          ),
      toastBuilder: (cancelFunc) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            title: Text(title),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  cancelFunc();
                  onCancel?.call();
                },
                child: Text(
                  cancelText,
                  style: TextStyle(color: cancelTextColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  cancelFunc();
                  onConfirm?.call();
                },
                child: Text(
                  confirmText,
                  style: TextStyle(color: confirmTextColor),
                ),
              ),
            ],
          ),
      animationDuration: const Duration(milliseconds: 300));
}

class _CustomOffsetAnimation extends StatefulWidget {
  const _CustomOffsetAnimation({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  final AnimationController controller;
  final Widget child;

  @override
  State<_CustomOffsetAnimation> createState() => _CustomOffsetAnimationState();
}

class _CustomOffsetAnimationState extends State<_CustomOffsetAnimation> {
  Tween<Offset>? tweenOffset;
  Tween<double>? tweenScale;

  Animation<double>? animation;

  @override
  void initState() {
    tweenOffset = Tween<Offset>(
      begin: const Offset(0.0, 0.8),
      end: Offset.zero,
    );
    tweenScale = Tween<double>(begin: 0.3, end: 1.0);
    animation = CurvedAnimation(parent: widget.controller, curve: Curves.decelerate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return FractionalTranslation(
            translation: tweenOffset!.evaluate(animation!),
            child: ClipRect(
              child: Transform.scale(
                scale: tweenScale!.evaluate(animation!),
                child: Opacity(
                  opacity: animation!.value,
                  child: child,
                ),
              ),
            ));
      },
      child: widget.child,
    );
  }
}
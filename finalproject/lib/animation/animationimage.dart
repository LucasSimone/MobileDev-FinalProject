import 'package:flutter/material.dart';
import 'dart:io';

class Animated extends StatefulWidget {
  //ratios
  final double ratioxinitial;
  final double ratioyinitial;
  final double ratioxfinal;
  final double ratioyfinal;
  final double ratiowinitial;
  final double ratiohinitial;
  final double ratiowfinal;
  final double ratiohfinal;
  //image size
  final double width;
  final double height;
  //animation curves
  final int curvex;
  final int curvey;
  final int curvesize;
  //files
  final File mainfile;
  final File subfile;
  //links
  final String mainlink;
  final String sublink;
  //if animation is a preview
  final bool ispreview;

  const Animated(
      {Key key,
      this.mainfile,
      this.subfile,
      this.ratioxinitial,
      this.ratioyinitial,
      this.ratioxfinal,
      this.ratioyfinal,
      this.ratiowinitial,
      this.ratiohinitial,
      this.ratiowfinal,
      this.ratiohfinal,
      this.curvesize,
      this.curvex,
      this.curvey,
      this.height,
      this.width,
      this.ispreview,
      this.sublink,
      this.mainlink})
      : super(key: key);

  @override
  _AnimatedState createState() => _AnimatedState();
}

class _AnimatedState extends State<Animated>
    with SingleTickerProviderStateMixin {
  //based on ratios from the size of the main image canvas
  AnimationController _controller;
  Animation<double> _animationMoveX;
  Animation<double> _animationMoveY;
  Animation<double> _animationWidth;
  Animation<double> _animationHeight;
  //order of indexed curves
  List<Curve> curve = [
    Curves.linear,
    Curves.easeInOutQuart,
    Curves.bounceOut,
    Curves.elasticInOut
  ];

  double mh = 1;
  double mw = 1;

  double xinitial = 0;
  double yinitial = 0;
  double xfinal = 0;
  double yfinal = 0;
  //double _balloonBottomLocation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //animations for directions and size
    _animationMoveX =
        Tween(begin: widget.ratioxinitial, end: widget.ratioxfinal).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: curve[widget.curvex]),
      ),
    );
    _animationMoveY =
        Tween(begin: widget.ratioyinitial, end: widget.ratioyfinal).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: curve[widget.curvey]),
      ),
    );

    _animationWidth =
        Tween(begin: widget.ratiowinitial, end: widget.ratiowfinal).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: curve[widget.curvesize]),
      ),
    );
    _animationHeight =
        Tween(begin: widget.ratiohinitial, end: widget.ratiohfinal).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: curve[widget.curvesize]),
      ),
    );

    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationMoveX,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          child: new LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(children: [
              Image(
                image: widget.ispreview
                    ? FileImage(widget.mainfile)
                    : NetworkImage(widget.mainlink),
              ),
              Transform.translate(
                offset: Offset(_animationMoveX.value * constraints.maxWidth,
                    _animationMoveY.value * constraints.maxHeight),
                child: GestureDetector(
                  child: Image(
                    //uses either image file or links if preview or not
                    image: widget.ispreview
                        ? FileImage(widget.subfile)
                        : NetworkImage(widget.sublink),
                    height: _animationHeight.value * constraints.maxHeight,
                    width: _animationWidth.value * constraints.maxWidth,
                  ),
                  onTap: () {
                    if (_controller.isCompleted) {
                      _controller.reverse();
                    } else {
                      _controller.forward();
                    }
                  },
                ),
              )
            ]);
          }),
        );
      },
      child: Container(),
    );
  }
}

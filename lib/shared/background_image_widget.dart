import 'package:flutter/material.dart';

class BackgroundPageImage extends StatelessWidget {
  final String imageLocation;

  const BackgroundPageImage({Key key, this.imageLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
                colors: [Colors.black, Colors.black12],
                begin: Alignment.bottomCenter,
                end: Alignment.center)
            .createShader(rect);
      },
      blendMode: BlendMode.darken,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
             imageLocation
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
          ),
        ),
      ),
    );
  }
}

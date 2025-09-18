import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselWidgets extends StatefulWidget {
  const CarouselWidgets({super.key});

  @override
  State<CarouselWidgets> createState() => _CarouselWidgetsState();
}

class _CarouselWidgetsState extends State<CarouselWidgets> {
  final List<String> imgList = [
    'assets/images/carousal/image1.png',
    'assets/images/carousal/image2.png',
    'assets/images/carousal/image3.png',
    'assets/images/carousal/image4.png',
  ];
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController(); // Change this line

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            height: 300,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            autoPlayAnimationDuration: const Duration(milliseconds: 500),
            viewportFraction: 0.8,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: imgList.map((item) => Container(
            child: Center(
              child: Image.asset(item, fit: BoxFit.cover, width: 500, height: 200,),
            ),
          )).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)
                      .withOpacity(_current == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
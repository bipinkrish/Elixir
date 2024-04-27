import 'package:elixir/api.dart';
import 'package:elixir/theme.dart';
import 'package:flutter/material.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:loading_indicator/loading_indicator.dart';

FastCachedImage getCahcedImage(String url, {double? height, BoxFit? fit}) {
  return FastCachedImage(
    url: url,
    fit: fit,
    height: height,
    loadingBuilder: (context, progress) => const CircularProgressIndicator(
      color: Colors.white,
    ),
    errorBuilder: (context, exception, stacktrace) => const Icon(
      Icons.error_rounded,
      color: Colors.red,
    ),
  );
}

class FullScreenImage extends StatelessWidget {
  final String url;
  const FullScreenImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.red,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: kWhiteColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: getCahcedImage(url),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageWidget extends StatelessWidget {
  final String url;
  final double? height;
  final BoxFit? fit;

  const ImageWidget({super.key, required this.url, this.height, this.fit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return FullScreenImage(url: url);
          },
        );
      },
      child: getCahcedImage(
        url,
        height: height,
        fit: fit,
      ),
    );
  }
}

Column getSourcesWidget(Map sources) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Sources",
        style: kWhiteText.copyWith(
            fontSize: 16, fontWeight: kSemiBold, color: Colors.green),
      ),
      const SizedBox(
        height: 8,
      ),
      for (var source in sources.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const Icon(
                Icons.link,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style:
                      kWhiteText.copyWith(fontSize: 14, fontWeight: kRegular),
                  children: [
                    TextSpan(
                      text: source.key + ": ",
                    ),
                    TextSpan(
                      text: source.value.join(", "),
                      style: const TextStyle(color: Colors.yellow),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

RawScrollbar getImagesWidget(List images) {
  final ScrollController scrollController = ScrollController();

  return RawScrollbar(
    controller: scrollController,
    thumbVisibility: true,
    trackVisibility: true,
    thumbColor: kWhiteColor,
    trackColor: kBg100Color,
    radius: const Radius.circular(4),
    trackRadius: const Radius.circular(4),
    child: SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var image in images)
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ImageWidget(
                  url: getImageUrl(image),
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

void showConfirmationDialog(BuildContext context, String title, String msg,
    void Function()? onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('$title Confirmation'),
        content: Text(msg),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: onConfirm,
            child: Text(title),
          ),
        ],
      );
    },
  );
}

LoadingIndicator getPackman() {
  return const LoadingIndicator(
    indicatorType: Indicator.pacman,
    colors: [kWhiteColor, Colors.green, Colors.red],
  );
}

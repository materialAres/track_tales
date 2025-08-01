import 'dart:async';
import 'package:flutter/material.dart';

class AdaptiveImageContainer extends StatefulWidget {
  final String imageUrl;
  final double width;

  const AdaptiveImageContainer({
    Key? key,
    required this.imageUrl,
    required this.width,
  }) : super(key: key);

  @override
  _AdaptiveImageContainerState createState() => _AdaptiveImageContainerState();
}

class _AdaptiveImageContainerState extends State<AdaptiveImageContainer> {
  Future<double>? _aspectRatioFuture;

  @override
  void initState() {
    super.initState();
    _aspectRatioFuture = _getAspectRatio();
  }

  // This method fetches the image and calculates its aspect ratio.
  Future<double> _getAspectRatio() async {
    final completer = Completer<double>();
    final image = NetworkImage(widget.imageUrl);

    // This listener waits for the image to be loaded, then gets its dimensions.
    final listener = ImageStreamListener(
          (ImageInfo info, bool _) {
        if (!completer.isCompleted) {
          final double ratio = info.image.width / info.image.height;
          completer.complete(ratio);
        }
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          // If image fails to load, fall back to a default aspect ratio
          completer.complete(2 / 3);
        }
      },
    );

    image.resolve(const ImageConfiguration()).addListener(listener);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder rebuilds the UI based on the state of our async task.
    return FutureBuilder<double>(
      future: _aspectRatioFuture,
      // The builder provides a placeholder while the aspect ratio is loading.
      builder: (context, snapshot) {
        // STATE 1: While waiting, show a placeholder with a default shape
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return AspectRatio(
            aspectRatio: 2 / 3, // Default aspect ratio for the placeholder
            child: Container(
              width: widget.width,
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // Placeholder color
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }

        // STATE 2: If there was an error, show a broken image icon
        if (snapshot.hasError) {
          return AspectRatio(
            aspectRatio: 2 / 3,
            child: Container(
              width: widget.width,
              child: const Icon(Icons.broken_image),
            ),
          );
        }

        // STATE 3: Success! We have the aspect ratio. Build the final image.
        final double aspectRatio = snapshot.data!;
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                // IMPORTANT: Use BoxFit.fill as the container now perfectly matches the image ratio.
                fit: BoxFit.fill,
                image: NetworkImage(widget.imageUrl),
              ),
            ),
          ),
        );
      },
    );
  }
}

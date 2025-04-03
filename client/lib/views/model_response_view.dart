import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/main.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../styles.dart';
import 'view_model.dart';

class ModelResponseView extends StatefulWidget {
  const ModelResponseView({required this.message, super.key});

  final ModelResponse message;

  @override
  State<ModelResponseView> createState() => _ModelResponseViewState();
}

class _ModelResponseViewState extends State<ModelResponseView> {
  late ModelResponseText parsedMessage;
  final List<Widget> recommendationWidgets = [];

  // On larger screens, this array holds the recommendations that are currently visible.
  // On smaller screens, only a single recommendation at the active index is shown.
  final List<Widget> visibleRecs = [];
  int activeIndex = 0;

  @override
  void initState() {
    parsedMessage = widget.message.modelResponseText;
    if (parsedMessage.didParse) {
      for (var rec in parsedMessage.recommendations) {
        recommendationWidgets.add(_RecommendationWidget(rec));
      }
      visibleRecs.add(recommendationWidgets.first);
    }
    super.initState();
  }

  void _showNext() {
    // reset if we're at the end
    if (activeIndex + 1 == recommendationWidgets.length) {
      activeIndex = -1;
      visibleRecs.clear();
    }

    activeIndex++;
    visibleRecs.add(recommendationWidgets[activeIndex]);
    setState(() {});
  }

  void _showPrev() {
    // if we're at the beginning, go to the end
    if (activeIndex == 0) {
      activeIndex = recommendationWidgets.length - 1;
      visibleRecs.clear();
      visibleRecs.addAll(recommendationWidgets);
    } else {
      activeIndex--;
      visibleRecs.removeAt(activeIndex);
    }
    setState(() {});
  }

  Widget _mobileControls() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      TextButton.icon(
        onPressed: _showPrev,
        label: Text('Previous'),
        icon: Icon(Icons.chevron_left),
      ),
      TextButton.icon(
        onPressed: _showNext,
        label: Text('Next'),
        icon: Icon(Icons.chevron_right),
        iconAlignment: IconAlignment.end,
      ),
    ],
  );

  Widget _webControls() {
    // There are no more recs to show
    if (activeIndex + 1 == recommendationWidgets.length) {
      return Container();
    }

    return Center(
      child: TextButton.icon(
        onPressed: _showNext,
        label: Text('Next'),
        icon: Icon(Icons.expand_more),
        iconAlignment: IconAlignment.end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width <= breakpoint;
    if (parsedMessage.didParse) {
      return Padding(
        padding: const EdgeInsets.all(AppLayout.defaultPadding),
        child: ListView(
          children: [
            Text('Recommendations', style: AppTextStyles.heading),
            Text(parsedMessage.intro),
            if (isMobile) recommendationWidgets[activeIndex],
            if (isMobile) _mobileControls(),
            if (!isMobile) ...visibleRecs,
            if (!isMobile) _webControls(),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppLayout.extraLargePadding),
      child: SingleChildScrollView(
        child: Center(
          child: MarkdownBody(
            data: widget.message.text,
            styleSheet: MarkdownStyleSheet(
              p: AppTextStyles.body.copyWith(fontWeight: FontWeight.normal),
            ),
            imageBuilder: (uri, title, alt) {
              final image = uri.toString();
              return Image.asset(
                'assets/product-images/$image',
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading image: $error');
                  return SizedBox.shrink();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RecommendationWidget extends StatelessWidget {
  const _RecommendationWidget(this.recommendation, {super.key});
  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recommendation.title,
          style: AppTextStyles.subheading.copyWith(fontSize: 16),
        ),
        Text(recommendation.description),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _ProductWidget(recommendation.product),
        ),
      ],
    );
  }
}

class _ProductWidget extends StatefulWidget {
  const _ProductWidget(this.product, {super.key});

  final Product product;

  @override
  State<_ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<_ProductWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width <= breakpoint;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: Container(
        width:
            isMobile
                ? MediaQuery.of(context).size.width -
                    (AppLayout.defaultPadding * 2)
                : 400,
        height: isMobile ? 75 : 100,
        decoration: BoxDecoration(
          color: isHovered ? AppColors.panelBackground : Colors.white60,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        padding: EdgeInsets.all(4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/product-images/${widget.product.image}',
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading image: $error');
                  return SizedBox(height: 100, child: Text('no image'));
                },
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: isMobile ? 14 : 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.product.cost} from ${widget.product.manufacturer}',
                  style: AppTextStyles.body.copyWith(
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
                Spacer(),
                Text(
                  'Add to cart',
                  style: AppTextStyles.body.copyWith(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.blue.shade700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

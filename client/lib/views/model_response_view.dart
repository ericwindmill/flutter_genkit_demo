import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/main.dart';
import 'package:flutter_fix_warehouse/widgets/sparkle_leaf.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../styles.dart';
import 'view_model.dart';

final _random = Random();

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
        if (parsedMessage.shouldShowReminderForRecommendation(rec)) {
          recommendationWidgets.add(
            Padding(
              padding: const EdgeInsets.only(left: AppLayout.defaultPadding),
              child: _RecommendationWidget(rec, shouldShowReminder: true),
            ),
          );
        } else {
          recommendationWidgets.add(
            Padding(
              padding: const EdgeInsets.only(left: AppLayout.defaultPadding),
              child: _RecommendationWidget(rec),
            ),
          );
        }
      }

      // TODO(ewindmill): Remove before deploying.
      //  This adds an additional widget some amount of the time, which in reality
      // will happen rarely and is based on the the LLMs response.
      final replace =
          _random.nextInt(100) < 50 &&
          !parsedMessage.hasReminder &&
          recommendationWidgets.length >= 2;
      if (replace) {
        recommendationWidgets[1] = Padding(
          padding: const EdgeInsets.only(left: AppLayout.defaultPadding),
          child: _RecommendationWidget(
            reminderRecommendation,
            shouldShowReminder: true,
          ),
        );
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
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Recommendations', style: AppTextStyles.heading),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(width: 500, child: Text(parsedMessage.intro)),
            ),
          ),
          SizedBox(height: 10),
          if (isMobile) recommendationWidgets[activeIndex],
          if (isMobile) SizedBox(height: 10),
          if (isMobile) _mobileControls(),
          if (!isMobile) ...visibleRecs,
          if (!isMobile) SizedBox(height: 10),
          if (!isMobile) _webControls(),
          SizedBox(height: 20),
        ],
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
                height: 200,
                width: 200,
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
  const _RecommendationWidget(
    this.recommendation, {
    super.key,
    this.shouldShowReminder = false,
  });
  final Recommendation recommendation;
  final bool shouldShowReminder;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width <= breakpoint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recommendation.title,
          style: AppTextStyles.subheading.copyWith(
            fontSize: isMobile ? 16 : 18,
          ),
        ),
        SizedBox(height: 5),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 500,
            child: Text(
              recommendation.description,
              style: AppTextStyles.body.copyWith(fontSize: isMobile ? 13 : 14),
            ),
          ),
        ),
        SizedBox(height: 10),
        if (shouldShowReminder) _SetReminderWidget(),
        if (!shouldShowReminder) _ProductWidget(recommendation.product),
        SizedBox(height: 25),
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

    return Container(
      width:
          isMobile
              ? min(
                400,
                MediaQuery.of(context).size.width -
                    (AppLayout.defaultPadding * 2),
              )
              : 400,
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Image.asset(
              'assets/product-images/${widget.product.image}',
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: $error');
                return ProductPlaceholderSparkleLeaf();
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: AppTextStyles.heading.copyWith(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.product.cost} from ${widget.product.manufacturer}',
                    style: AppTextStyles.body.copyWith(fontSize: 13),
                  ),
                  Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'See product details',
                      style: AppTextStyles.body.copyWith(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.blue.shade700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          MouseRegion(
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
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border(left: BorderSide(width: .1)),
                color: isHovered ? AppColors.primaryLight : Colors.transparent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Symbols.add_shopping_cart, color: AppColors.primary),
                  Text(
                    'Add to cart',
                    style: AppTextStyles.breadcrumb.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetReminderWidget extends StatefulWidget {
  const _SetReminderWidget({super.key});

  @override
  State<_SetReminderWidget> createState() => _SetReminderWidgetState();
}

class _SetReminderWidgetState extends State<_SetReminderWidget> {
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
                ? min(
                  400,
                  MediaQuery.of(context).size.width -
                      (AppLayout.defaultPadding * 2),
                )
                : 400,
        height: 85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.infoBlue, width: 2),
          color:
              isHovered
                  ? AppColors.infoBlueLight.withValues(alpha: .1)
                  : AppColors.infoBlueLight,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Add reminder',
                          style: AppTextStyles.heading.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Symbols.open_in_new,
                          size: 18,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    Text(
                      'Add a weekly recurring event to your calendar to remind you.',
                      style: AppTextStyles.body.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Symbols.add_alarm, color: AppColors.infoBlue)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

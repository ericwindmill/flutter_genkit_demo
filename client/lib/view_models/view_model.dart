import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../greenthumb/data.dart';

sealed class Message {
  Message._(RawMessage rawMessage) : _rawMessage = rawMessage;
  final RawMessage _rawMessage;

  String get text;

  static List<Message> messagesFrom(List<RawMessage> rawMessages) {
    final result = <Message>[];

    for (var i = 0; i < rawMessages.length; i++) {
      final rawMessage = rawMessages[i];

      // skip system messages
      if (rawMessage.role == 'system') continue;

      // handle user messages
      if (rawMessage.role == 'user') {
        result.add(UserRequest(rawMessage));
        continue;
      }

      // handle model messages
      assert(rawMessage.role == 'model');
      assert(rawMessage.content.isNotEmpty);

      final toolRequest = Message.toolRequestFrom(rawMessage);

      if (toolRequest == null) {
        // found a model response and not a interrupt tool request
        result.add(ModelResponse(rawMessage));
        continue;
      }

      final metadata = Message.metadataFrom(rawMessage);

      if (i + 1 == rawMessages.length || rawMessages[i + 1].role != 'tool') {
        // found a tool request without a response, but is it an interrupt?

        if (metadata == null) {
          // no metadata means this is not an interrupt, so skip it
          continue;
        } else {
          // metadata means this is an interrupt
          result.add(InterruptMessage(rawMessage));
        }
        continue;
      }

      // found a tool response and a tool request, but is it an interrupt?
      if (metadata == null) {
        // no metadata means this is not an interrupt, so skip it
      } else {
        // metadata means this is an interrupt
        result.add(InterruptMessage(rawMessage, rawMessages[i + 1]));
      }

      // skip the interrupt tool response message in next loop thru
      i++;
    }

    if (result.isEmpty) {
      // placeholder to make building the UI easier; shows the UserPromptView
      // before there are any messages (because we haven't requested anything
      // yet)
      result.add(
        UserRequest(RawMessage(role: 'user', content: [Content(text: 'TBD')])),
      );
    }

    return List.unmodifiable(result);
  }

  static ContentMetadata? metadataFrom(RawMessage rawMessage) {
    return rawMessage.content
        .firstWhereOrNull((m) => m.metadata != null)
        ?.metadata;
  }

  static ToolRequest? toolRequestFrom(RawMessage rawMessage) {
    return rawMessage.content
        .firstWhereOrNull((m) => m.toolRequest != null)
        ?.toolRequest;
  }

  static ToolResponse? toolResponseFrom(RawMessage rawMessage) {
    return rawMessage.content
        .firstWhereOrNull((m) => m.toolResponse != null)
        ?.toolResponse;
  }
}

class UserRequest extends Message {
  UserRequest(RawMessage rawMessage) : super._(rawMessage) {
    assert(rawMessage.role == 'user');
    assert(rawMessage.content.isNotEmpty);
    assert(rawMessage.content.first.text != null);
  }

  @override
  String get text => _rawMessage.content.first.text!;
}

class InterruptMessage extends Message {
  final RawMessage? _rawMessage2;

  InterruptMessage(RawMessage rawMessage, [RawMessage? rawMessage2])
    : _rawMessage2 = rawMessage2,
      super._(rawMessage) {
    assert(rawMessage.role == 'model');
    assert(rawMessage2 == null || rawMessage2.role == 'tool');
    assert(rawMessage.content.isNotEmpty);
  }

  ContentMetadata? get metadata => Message.metadataFrom(_rawMessage);
  ToolRequest? get toolRequest => Message.toolRequestFrom(_rawMessage);
  ToolResponse? get toolResponse =>
      _rawMessage2 == null ? null : Message.toolResponseFrom(_rawMessage2);

  @override
  String get text => toolRequest?.input.question ?? '';
}

class ModelResponse extends Message {
  ModelResponse(RawMessage rawMessage) : super._(rawMessage) {
    assert(rawMessage.role == 'model');
    assert(rawMessage.content.isNotEmpty);
    assert(rawMessage.content.first.text != null);
  }

  @override
  String get text => _rawMessage.content.first.text!;

  /// This method takes the markdown response and parses into
  /// structured data so we can make it look good on screen.
  // See /server/index.ts variable gtSystem to see the markdown structure
  // TODO: This is a mess. It's extremely fragile. This is a band-aid that will get us through Cloud Next without having to re-dploy.
  // If you're reading this after the fact, you should not copy this. Instead, you should return structured data from your Genkit flows
  ModelResponseText get modelResponseText {
    var recommendations = <Recommendation>[];
    // This splits the text at the beginning of new products
    // The first item will contain the intro text, and the remaining
    // items will be recommendations
    final splitText = text.trim().split('##');
    var preamble = splitText.first.trim();

    // remove lines that are just newlines or spaces, if any
    final rawRecommendations = splitText.sublist(1).where((line) {
      return line.trim().length > 1;
    });

    for (var recommendationMarkdown in rawRecommendations) {
      try {
        var lines = recommendationMarkdown.split('\n');
        // remove lines that are just newlines or spaces, if any
        lines =
            lines.where((line) {
              return line.trim().length > 1;
            }).toList();

        // get rec title
        final recTitleWords = lines.first.trim().split(' ');
        // unify the casing of all titles.
        for (var i = 1; i < recTitleWords.length; i++) {
          recTitleWords[i] = recTitleWords[i].toLowerCase();
        }
        final recTitle = recTitleWords.join(' ');
        lines.removeAt(0);

        // get rec description
        final productTitleLineIndex = lines.indexWhere(
          (line) => line.trim().startsWith('-'),
        );
        final recDescriptionLines = lines.sublist(0, productTitleLineIndex);
        final recDescription = recDescriptionLines.join(' ');
        lines = lines.sublist(productTitleLineIndex);

        // get rec product
        final recProductTitle = lines.removeAt(0).substring(1).trim();

        // Price line looks like this:
        // **$15.0** from AquaFlow
        final priceLine = lines.firstWhere((line) {
          return line.trim().startsWith('**');
        }, orElse: () => '**\$29.99** from GreenThumb');
        final priceLineSplit = priceLine.trim().split('**');
        final price = priceLineSplit.firstWhere((str) => str.startsWith('\$'));
        final manufacturer = priceLineSplit.last.split('from').last.trim();

        String? imageLine = lines.firstWhere(
          (line) => line.trim().startsWith('![]('),
          orElse: () => 'no image',
        );
        List<String> imageSplit = imageLine.split('![](');
        String? image = imageSplit[1].split(')').first;

        recommendations.add(
          Recommendation(
            title: recTitle,
            description: recDescription,
            product: Product(
              name: recProductTitle,
              manufacturer: manufacturer,
              cost: int.tryParse(price) ?? 12,
              image: image,
              description: '',
            ),
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
      }
    }

    // Remove the part of the response where the LLM says something generic like
    // 'These are my final recommendations'.
    if (preamble.contains(':')) {
      preamble = preamble.split(':').sublist(1).join('').trim();
    }

    return ModelResponseText(
      intro: preamble,
      recommendations: recommendations,
      raw: text,
    );
  }
}

class ModelResponseText {
  final String intro;
  final List<Recommendation> recommendations;
  final String raw;

  // if recommendations are empty or all the recommendations are
  // the hardcoded seed rec, then parsing failed.
  bool get didParse {
    if (recommendations.isEmpty) return false;
    return recommendations.any((rec) {
      return rec.title != 'Give plants more nutrients';
    });
  }

  // only show one reminder widget per LLM response
  bool hasReminder = false;

  bool shouldShowReminderForRecommendation(Recommendation rec) {
    if (hasReminder) return false;

    if (rec.title.contains('water')) {
      hasReminder = true;
      return true;
    }

    return false;
  }

  ModelResponseText({
    String? intro,
    required this.recommendations,
    required this.raw,
  }) : intro = intro ?? '';
}

class Recommendation {
  final String title;
  final String description;
  final Product product;

  Recommendation({
    required this.title,
    required this.description,
    required this.product,
  });
}

class Product {
  final String name;
  final String manufacturer;
  final int cost;
  final String description;
  final String? image;

  Product({
    required this.name,
    required this.manufacturer,
    required this.cost,
    required this.description,
    this.image,
  });
}

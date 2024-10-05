import 'package:clearassistapp/ui/gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('W-2: gallery screen loads correctly ',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: GalleryScreen(), //Gallery Scren
    ));

    //search icon
    final searchIcon = find.byKey(const Key('searchIcon'));
    expect(searchIcon, findsOneWidget);

    //favorites star
    final favoriteIcon = find.byKey(const Key('favoriteIcon'));
    expect(favoriteIcon, findsOneWidget);

    //photo filter icon
    final photoFilter =
        find.byKey(const Key('filterPhotoIcon'), skipOffstage: false);
    expect(photoFilter, findsOneWidget);

    //video filter icon
    final videoFilter =
        find.byKey(const Key('filterVideoIcon'), skipOffstage: false);
    expect(videoFilter, findsOneWidget);

    //conversation filter icon
    final conversationFilter =
        find.byKey(const Key('filterConversationIcon'), skipOffstage: false);
    expect(conversationFilter, findsOneWidget);

    //sort gallery menu item
    final sortGalleryButton =
        find.byKey(const Key('sortGalleryButton'), skipOffstage: false);
    expect(sortGalleryButton, findsOneWidget);
  });
}

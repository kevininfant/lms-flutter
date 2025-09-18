import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lms_rnd/screens/scorm_screen.dart';

void main() {
  group('SCORM Screen Integration Tests', () {
    testWidgets('SCORM Screen should render without errors', (
      WidgetTester tester,
    ) async {
      // Build the SCORM screen
      await tester.pumpWidget(const MaterialApp(home: ScormScreen()));

      // Verify the screen renders
      expect(find.text('SCORM Player'), findsOneWidget);
      expect(find.text('Available SCORM Files:'), findsOneWidget);
    });

    testWidgets('SCORM Screen should have correct tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ScormScreen()));

      // Verify tabs are present
      expect(find.text('SCORM'), findsOneWidget);
      expect(find.text('H5P'), findsOneWidget);
      expect(find.text('Docs'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
    });

    testWidgets('SCORM Screen should show SCORM files list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ScormScreen()));

      // Verify SCORM files are listed
      expect(find.text('pri.zip'), findsOneWidget);
      expect(find.text('SCORM Package'), findsOneWidget);
    });

    testWidgets('H5P tab should show H5P files list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ScormScreen()));

      // Tap on H5P tab
      await tester.tap(find.text('H5P'));
      await tester.pumpAndSettle();

      // Verify H5P content options
      expect(find.text('Available H5P Files:'), findsOneWidget);
      expect(find.text('boardgame.h5p'), findsOneWidget);
    });

    testWidgets('Docs tab should show document preview options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ScormScreen()));

      // Tap on Docs tab
      await tester.tap(find.text('Docs'));
      await tester.pumpAndSettle();

      // Verify docs content options
      expect(find.text('Preview online documents:'), findsOneWidget);
      expect(find.text('Open DOC/DOCX (viewer)'), findsOneWidget);
    });

    testWidgets('Audio tab should show audio preview options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ScormScreen()));

      // Tap on Audio tab
      await tester.tap(find.text('Audio'));
      await tester.pumpAndSettle();

      // Verify audio content options
      expect(find.text('Online audio preview:'), findsOneWidget);
      expect(find.text('Sample Track 1 (MP3)'), findsOneWidget);
    });
  });
}

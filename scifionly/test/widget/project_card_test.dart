import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/ui/components/project_card.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ProjectCard', () {
    group('ready status', () {
      testWidgets('shows Ready label and check icon', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ProjectCard(
              title: 'Alien (1979)',
              status: ProjectCardStatus.ready,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Ready'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });
    });

    group('missingRiffTrack status', () {
      testWidgets('shows Missing RiffTrack warning', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ProjectCard(
              title: 'Blade Runner (1982)',
              status: ProjectCardStatus.missingRiffTrack,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Missing RiffTrack'), findsOneWidget);
        expect(find.byIcon(Icons.music_off_outlined), findsOneWidget);
      });
    });

    group('draft status', () {
      testWidgets('shows Draft state', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ProjectCard(
              title: 'The Matrix (1999)',
              status: ProjectCardStatus.draft,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Draft'), findsOneWidget);
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      });
    });

    group('malformedPackage status', () {
      testWidgets('shows Malformed Package error', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ProjectCard(
              title: 'Corrupted Project',
              status: ProjectCardStatus.malformedPackage,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Malformed Package'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('metadata display', () {
      testWidgets('shows title', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ProjectCard(
              title: 'Star Wars (1977)',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Star Wars (1977)'), findsOneWidget);
      });

      testWidgets('shows subtitle when provided', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ProjectCard(
              title: 'Star Wars',
              subtitle: 'A New Hope',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Star Wars'), findsOneWidget);
        expect(find.text('A New Hope'), findsOneWidget);
      });

      testWidgets('shows year chip', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ProjectCard(
              title: 'Alien',
              year: 1979,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('1979'), findsOneWidget);
      });

      testWidgets('shows language chip', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ProjectCard(
              title: 'Alien',
              language: 'EN',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('EN'), findsOneWidget);
      });

      testWidgets('shows track count chip', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ProjectCard(
              title: 'Alien',
              trackCount: 3,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('3 tracks'), findsOneWidget);
      });

      testWidgets('shows theme tag chip', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ProjectCard(
              title: 'Alien',
              themeTag: 'sci-fi',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('sci-fi'), findsOneWidget);
      });

      testWidgets('shows all metadata together', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ProjectCard(
              title: 'Alien',
              subtitle: 'Ridley Scott',
              year: 1979,
              language: 'EN',
              trackCount: 3,
              themeTag: 'sci-fi',
              status: ProjectCardStatus.ready,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Alien'), findsOneWidget);
        expect(find.text('Ridley Scott'), findsOneWidget);
        expect(find.text('1979'), findsOneWidget);
        expect(find.text('EN'), findsOneWidget);
        expect(find.text('3 tracks'), findsOneWidget);
        expect(find.text('sci-fi'), findsOneWidget);
        expect(find.text('Ready'), findsOneWidget);
      });
    });

    group('interactions', () {
      testWidgets('handles onTap callback', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          wrapWithTheme(
            ProjectCard(
              title: 'Alien',
              onTap: () => tapped = true,
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(InkWell).first);
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('shows overflow button when onOverflowTap provided',
          (tester) async {
        var overflowTapped = false;
        await tester.pumpWidget(
          wrapWithTheme(
            ProjectCard(
              title: 'Alien',
              onOverflowTap: () => overflowTapped = true,
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.more_vert), findsOneWidget);

        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pump();

        expect(overflowTapped, isTrue);
      });

      testWidgets('hides overflow button when onOverflowTap is null',
          (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ProjectCard(
              title: 'Alien',
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.more_vert), findsNothing);
      });
    });

    group('all status variants render', () {
      for (final status in ProjectCardStatus.values) {
        testWidgets('${status.name} status renders without error',
            (tester) async {
          await tester.pumpWidget(
            wrapWithTheme(
              ProjectCard(
                title: 'Test Project',
                status: status,
              ),
            ),
          );
          await tester.pump();

          expect(find.byType(ProjectCard), findsOneWidget);
        });
      }
    });
  });
}

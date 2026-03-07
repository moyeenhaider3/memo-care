import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/chain_engine/domain/chain_validator.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_error.dart';

/// Helper to create edges for testing.
/// Each tuple is (sourceId, targetId).
List<({int sourceId, int targetId})> _edges(
  List<(int, int)> pairs,
) =>
    pairs
        .map((p) => (sourceId: p.$1, targetId: p.$2))
        .toList();

void main() {
  late ChainValidator validator;

  setUp(() {
    validator = const ChainValidator();
  });

  group('ChainValidator.validate', () {
    group('valid chains', () {
      test('empty chain (no nodes, no edges) is valid', () {
        final result = validator.validate(
          nodeIds: [],
          edges: [],
        );
        expect(result.isRight(), isTrue);
      });

      test('single node with no edges is valid', () {
        final result = validator.validate(
          nodeIds: [1],
          edges: [],
        );
        expect(result.isRight(), isTrue);
        result.fold(
          (_) {},
          (sorted) => expect(sorted, [1]),
        );
      });

      test('linear chain A→B→C is valid', () {
        final result = validator.validate(
          nodeIds: [1, 2, 3],
          edges: _edges([(1, 2), (2, 3)]),
        );
        expect(result.isRight(), isTrue);
        result.fold((_) {}, (sorted) {
          // A must come before B, B before C.
          expect(
            sorted.indexOf(1),
            lessThan(sorted.indexOf(2)),
          );
          expect(
            sorted.indexOf(2),
            lessThan(sorted.indexOf(3)),
          );
        });
      });

      test('diamond DAG A→B, A→C, B→D, C→D is valid', () {
        final result = validator.validate(
          nodeIds: [1, 2, 3, 4],
          edges: _edges([(1, 2), (1, 3), (2, 4), (3, 4)]),
        );
        expect(result.isRight(), isTrue);
        result.fold((_) {}, (sorted) {
          expect(
            sorted.indexOf(1),
            lessThan(sorted.indexOf(2)),
          );
          expect(
            sorted.indexOf(1),
            lessThan(sorted.indexOf(3)),
          );
          expect(
            sorted.indexOf(2),
            lessThan(sorted.indexOf(4)),
          );
          expect(
            sorted.indexOf(3),
            lessThan(sorted.indexOf(4)),
          );
        });
      });

      test(
        'disconnected nodes (no edges between them) are valid',
        () {
          final result = validator.validate(
            nodeIds: [1, 2, 3],
            edges: [],
          );
          expect(result.isRight(), isTrue);
          result.fold(
            (_) {},
            (sorted) => expect(sorted.length, 3),
          );
        },
      );

      test(
        'chain with exactly 10 levels (max depth) is valid',
        () {
          // Linear chain: 1→2→3→...→10
          final nodeIds = List.generate(10, (i) => i + 1);
          final edgeList = _edges([
            for (int i = 1; i < 10; i++) (i, i + 1),
          ]);
          final result = validator.validate(
            nodeIds: nodeIds,
            edges: edgeList,
          );
          expect(result.isRight(), isTrue);
        },
      );

      test(
        'fan-out: one node to multiple children is valid',
        () {
          // 1→2, 1→3, 1→4
          final result = validator.validate(
            nodeIds: [1, 2, 3, 4],
            edges: _edges([(1, 2), (1, 3), (1, 4)]),
          );
          expect(result.isRight(), isTrue);
        },
      );

      test(
        'fan-in: multiple parents to one child is valid',
        () {
          // 1→3, 2→3
          final result = validator.validate(
            nodeIds: [1, 2, 3],
            edges: _edges([(1, 3), (2, 3)]),
          );
          expect(result.isRight(), isTrue);
        },
      );
    });

    group('cycle detection', () {
      test('self-loop A→A is rejected as cycle', () {
        final result = validator.validate(
          nodeIds: [1],
          edges: _edges([(1, 1)]),
        );
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<CycleDetected>()),
          (_) => fail('Should have detected cycle'),
        );
      });

      test('simple cycle A→B→A is rejected', () {
        final result = validator.validate(
          nodeIds: [1, 2],
          edges: _edges([(1, 2), (2, 1)]),
        );
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<CycleDetected>()),
          (_) => fail('Should have detected cycle'),
        );
      });

      test('triangle cycle A→B→C→A is rejected', () {
        final result = validator.validate(
          nodeIds: [1, 2, 3],
          edges: _edges([(1, 2), (2, 3), (3, 1)]),
        );
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<CycleDetected>()),
          (_) => fail('Should have detected cycle'),
        );
      });

      test('cycle in subset of nodes is rejected', () {
        // 1→2 (valid), 3→4→5→3 (cycle)
        final result = validator.validate(
          nodeIds: [1, 2, 3, 4, 5],
          edges: _edges([(1, 2), (3, 4), (4, 5), (5, 3)]),
        );
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<CycleDetected>()),
          (_) => fail('Should have detected cycle'),
        );
      });
    });

    group('max depth enforcement', () {
      test(
        'chain with 11 levels exceeds default max depth of 10',
        () {
          // Linear chain: 1→2→3→...→11
          final nodeIds = List.generate(11, (i) => i + 1);
          final edgeList = _edges([
            for (int i = 1; i < 11; i++) (i, i + 1),
          ]);
          final result = validator.validate(
            nodeIds: nodeIds,
            edges: edgeList,
          );
          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error, isA<MaxDepthExceeded>());
              final e = error as MaxDepthExceeded;
              expect(e.depth, 11);
              expect(e.maxDepth, 10);
            },
            (_) => fail('Should have rejected deep chain'),
          );
        },
      );

      test('custom max depth is respected', () {
        const customValidator = ChainValidator(maxDepth: 3);
        // Linear chain: 1→2→3→4 (depth 4, exceeds max 3)
        final result = customValidator.validate(
          nodeIds: [1, 2, 3, 4],
          edges: _edges([(1, 2), (2, 3), (3, 4)]),
        );
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<MaxDepthExceeded>());
            final e = error as MaxDepthExceeded;
            expect(e.depth, 4);
            expect(e.maxDepth, 3);
          },
          (_) => fail('Should have rejected deep chain'),
        );
      });

      test(
        'wide but shallow chain passes depth check',
        () {
          // Root with 10 children (depth 2, width 10)
          final nodeIds = List.generate(11, (i) => i + 1);
          final edgeList = _edges([
            for (int i = 2; i <= 11; i++) (1, i),
          ]);
          final result = validator.validate(
            nodeIds: nodeIds,
            edges: edgeList,
          );
          expect(result.isRight(), isTrue);
        },
      );
    });

    group('performance', () {
      test(
        'validates chain with 10 nodes in under 50ms',
        () {
          final nodeIds = List.generate(10, (i) => i + 1);
          final edgeList = _edges([
            for (int i = 1; i < 10; i++) (i, i + 1),
          ]);

          final stopwatch = Stopwatch()..start();
          for (var i = 0; i < 100; i++) {
            validator.validate(
              nodeIds: nodeIds,
              edges: edgeList,
            );
          }
          stopwatch.stop();

          // 100 iterations should complete well under
          // 5000ms (50ms each).
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(5000),
          );
        },
      );
    });
  });
}

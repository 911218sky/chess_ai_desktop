import 'dart:math' as math;
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:chess_ai_desktop/src/models/engine_models.dart';
import 'package:chess_ai_desktop/src/services/stockfish_service.dart';

void main() {
  test('detectHardwareProfile prefers fewer default threads', () async {
    final service = StockfishService(windowsMemoryDetector: () async => 8192);

    final profile = await service.detectHardwareProfile();

    expect(
      profile.recommendedThreads,
      equals(math.max(1, math.min(4, Platform.numberOfProcessors - 2))),
    );
  });

  test(
    'dispose cancels in-flight analysis and prevents new processes',
    () async {
      late _FakeProcess process;
      var startCount = 0;
      final service = StockfishService(
        processStarter: (_, _, {runInShell = false}) async {
          startCount += 1;
          process = _FakeProcess();
          return process;
        },
      );

      final analysisFuture = service.analyze(
        fen: 'startpos',
        settings: const EngineSettings(
          moveTimeMs: 10,
          multiPv: 1,
          hashMb: 64,
          threads: 1,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final cancellationExpectation = expectLater(
        analysisFuture,
        throwsA(isA<StockfishCancelledException>()),
      );
      await service.dispose();
      await cancellationExpectation;
      await Future<void>.delayed(Duration.zero);
      expect(process.killed, isTrue);

      await expectLater(
        service.analyze(
          fen: 'startpos',
          settings: const EngineSettings(
            moveTimeMs: 10,
            multiPv: 1,
            hashMb: 64,
            threads: 1,
          ),
        ),
        throwsA(isA<StockfishCancelledException>()),
      );
      expect(startCount, 1);
    },
  );
}

class _FakeProcess implements Process {
  _FakeProcess() : stdin = IOSink(_NullStreamConsumer());

  final StreamController<List<int>> _stdoutController =
      StreamController<List<int>>();
  final StreamController<List<int>> _stderrController =
      StreamController<List<int>>();
  final Completer<int> _exitCode = Completer<int>();
  bool killed = false;

  @override
  final IOSink stdin;

  @override
  int get pid => 1;

  @override
  Future<int> get exitCode => _exitCode.future;

  @override
  Stream<List<int>> get stdout => _stdoutController.stream;

  @override
  Stream<List<int>> get stderr => _stderrController.stream;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killed = true;
    if (!_exitCode.isCompleted) {
      _exitCode.complete(0);
    }
    unawaited(_stdoutController.close());
    unawaited(_stderrController.close());
    return true;
  }
}

class _NullStreamConsumer implements StreamConsumer<List<int>> {
  @override
  Future<void> addStream(Stream<List<int>> stream) => stream.drain<void>();

  @override
  Future<void> close() async {}
}

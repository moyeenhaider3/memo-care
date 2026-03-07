import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/features/chain_engine/data/chain_repository.dart';
import 'package:memo_care/features/chain_engine/domain/chain_validator.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_error.dart';
import 'package:memo_care/features/onboarding/domain/models/onboarding_state.dart';
import 'package:memo_care/features/reminders/data/reminder_repository.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/templates/domain/models/template_pack.dart';
import 'package:memo_care/features/templates/domain/models/template_packs.dart';
import 'package:memo_care/features/templates/domain/template_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockChainRepository extends Mock
    implements ChainRepository {}

class _MockReminderRepository extends Mock
    implements ReminderRepository {}

class _MockChainValidator extends Mock implements ChainValidator {}

class _MockAlarmScheduler extends Mock implements AlarmScheduler {}

void main() {
  late _MockChainRepository chainRepo;
  late _MockReminderRepository reminderRepo;
  late _MockChainValidator validator;
  late _MockAlarmScheduler scheduler;
  late TemplateService service;

  setUpAll(() {
    registerFallbackValue(MedicineType.afterMeal);
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    chainRepo = _MockChainRepository();
    reminderRepo = _MockReminderRepository();
    validator = _MockChainValidator();
    scheduler = _MockAlarmScheduler();
    service = TemplateService(
      chainRepository: chainRepo,
      reminderRepository: reminderRepo,
      chainValidator: validator,
      alarmScheduler: scheduler,
    );
  });

  void stubHappyPath() {
    when(() => chainRepo.createChain(name: any(named: 'name')))
        .thenAnswer((_) async => 1);

    var reminderIdCounter = 100;
    when(
      () => reminderRepo.createReminder(
        chainId: any(named: 'chainId'),
        medicineName: any(named: 'medicineName'),
        medicineType: any(named: 'medicineType'),
        dosage: any(named: 'dosage'),
        scheduledAt: any(named: 'scheduledAt'),
        gapHours: any(named: 'gapHours'),
      ),
    ).thenAnswer((_) async => reminderIdCounter++);

    var edgeIdCounter = 200;
    when(
      () => chainRepo.createEdge(
        chainId: any(named: 'chainId'),
        sourceId: any(named: 'sourceId'),
        targetId: any(named: 'targetId'),
      ),
    ).thenAnswer((_) async => edgeIdCounter++);

    when(
      () => validator.validate(
        nodeIds: any(named: 'nodeIds'),
        edges: any(named: 'edges'),
      ),
    ).thenReturn(right(const <int>[]));

    when(
      () => scheduler.schedule(
        reminderId: any(named: 'reminderId'),
        fireAt: any(named: 'fireAt'),
        callbackHandle: any(named: 'callbackHandle'),
      ),
    ).thenAnswer((_) async => true);
  }

  group('TemplateService.apply', () {
    test(
      'Diabetic Pack creates 6 reminders and 3 edges',
      () async {
        stubHappyPath();

        final result = await service.apply(
          pack: kDiabeticPack,
          mealAnchorTimes: {
            'breakfast': 480,
            'lunch': 780,
            'dinner': 1140,
          },
        );

        expect(result.isRight(), isTrue);
        final r = result.getOrElse(
          (_) => throw StateError('expected Right'),
        );
        expect(r.reminderIds, hasLength(6));
        expect(r.edgeIds, hasLength(3));
        expect(r.chainId, 1);

        verify(
          () => reminderRepo.createReminder(
            chainId: any(named: 'chainId'),
            medicineName: any(named: 'medicineName'),
            medicineType: any(named: 'medicineType'),
            dosage: any(named: 'dosage'),
            scheduledAt: any(named: 'scheduledAt'),
            gapHours: any(named: 'gapHours'),
          ),
        ).called(6);

        verify(
          () => chainRepo.createEdge(
            chainId: any(named: 'chainId'),
            sourceId: any(named: 'sourceId'),
            targetId: any(named: 'targetId'),
          ),
        ).called(3);

        verify(
          () => validator.validate(
            nodeIds: any(named: 'nodeIds'),
            edges: any(named: 'edges'),
          ),
        ).called(1);
      },
    );

    test(
      'user override replaces medicine name and dosage',
      () async {
        stubHappyPath();

        final overrides = {
          0: const CustomMedicineEntry(
            name: 'Humalog',
            medicineType: MedicineType.beforeMeal,
            dosage: '15 units',
          ),
        };

        await service.apply(
          pack: kDiabeticPack,
          userOverrides: overrides,
          mealAnchorTimes: {
            'breakfast': 480,
            'lunch': 780,
            'dinner': 1140,
          },
        );

        verify(
          () => reminderRepo.createReminder(
            chainId: 1,
            medicineName: 'Humalog',
            medicineType: MedicineType.beforeMeal,
            dosage: '15 units',
            scheduledAt: any(named: 'scheduledAt'),
            gapHours: any(named: 'gapHours'),
          ),
        ).called(1);
      },
    );

    test('rolls back on cycle detection', () async {
      stubHappyPath();

      when(
        () => validator.validate(
          nodeIds: any(named: 'nodeIds'),
          edges: any(named: 'edges'),
        ),
      ).thenReturn(left(const CycleDetected()));

      when(() => chainRepo.deleteChain(any()))
          .thenAnswer((_) async {});

      final result =
          await service.apply(pack: kBloodPressurePack);

      expect(result.isLeft(), isTrue);
      result.match(
        (error) => expect(error, isA<TemplateCycleDetected>()),
        (_) => fail('Expected Left'),
      );

      verify(() => chainRepo.deleteChain(1)).called(1);

      verifyNever(
        () => scheduler.schedule(
          reminderId: any(named: 'reminderId'),
          fireAt: any(named: 'fireAt'),
          callbackHandle: any(named: 'callbackHandle'),
        ),
      );
    });

    test(
      'rejects template with out-of-bounds edge index',
      () async {
        const badPack = TemplatePack(
          id: 'bad',
          name: 'Bad Pack',
          description: 'Invalid edges',
          condition: 'test',
          medicines: [
            TemplateMedicine(
              name: 'Med A',
              medicineType: MedicineType.fixedTime,
              chainPosition: 0,
              defaultTimeMinutes: 480,
            ),
          ],
          edges: [
            TemplateEdge(sourceIndex: 0, targetIndex: 5),
          ],
        );

        final result = await service.apply(pack: badPack);

        expect(result.isLeft(), isTrue);
        result.match(
          (error) =>
              expect(error, isA<TemplateInvalidEdgeIndex>()),
          (_) => fail('Expected Left'),
        );

        verifyNever(
          () =>
              chainRepo.createChain(name: any(named: 'name')),
        );
      },
    );
  });
}

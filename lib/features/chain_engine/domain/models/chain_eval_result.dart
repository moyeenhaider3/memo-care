import 'package:fpdart/fpdart.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_error.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// The result of evaluating a reminder chain.
///
/// - `Left(ChainError)` — validation or evaluation failed.
/// - `Right(List<Reminder>)` — ordered list of reminders
///   to fire, from root to deepest satisfied node.
typedef ChainEvalResult = Either<ChainError, List<Reminder>>;

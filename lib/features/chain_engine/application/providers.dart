// Riverpod's StreamProvider.autoDispose types are not publicly exported.
// ignore_for_file: specify_nonobvious_property_types

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo_care/core/providers/database_provider.dart';
import 'package:memo_care/features/chain_engine/data/chain_dao.dart';
import 'package:memo_care/features/chain_engine/data/chain_repository.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_edge.dart';
import 'package:memo_care/features/chain_engine/domain/models/reminder_chain.dart';

/// Provides the [ChainDao] from the database singleton.
final chainDaoProvider = Provider<ChainDao>((ref) {
  return ref.watch(appDatabaseProvider).chainDao;
});

/// Provides the [ChainRepository] wrapping the [ChainDao].
final chainRepositoryProvider = Provider<ChainRepository>((ref) {
  return ChainRepository(ref.watch(chainDaoProvider));
});

/// Reactive stream of all reminder chains, newest first.
final allChainsProvider =
    StreamProvider.autoDispose<List<ReminderChain>>((ref) {
  return ref.watch(chainRepositoryProvider).watchAllChains();
});

/// Reactive stream of edges for a specific chain.
final chainEdgesProvider =
    StreamProvider.autoDispose.family<List<ChainEdge>, int>((ref, chainId) {
  return ref.watch(chainRepositoryProvider).watchEdgesForChain(chainId);
});

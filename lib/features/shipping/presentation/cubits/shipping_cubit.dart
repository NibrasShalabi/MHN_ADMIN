import '../../../../core/bloc/safe_cubit.dart';
import '../../data/repository/shipping_repository.dart';
import '../../domain/entities/shipping_rates.dart';

enum ShippingStatus { loading, ready, saving, saved, error }

class ShippingState {
  final ShippingStatus status;
  final ShippingRates rates;
  final String? error;

  const ShippingState({this.status = ShippingStatus.loading, this.rates = const ShippingRates(), this.error});
}

class ShippingCubit extends SafeCubit<ShippingState> {
  final ShippingRepository _repo;

  ShippingCubit(this._repo) : super(const ShippingState());

  Future<void> load() async {
    try {
      emit(ShippingState(status: ShippingStatus.ready, rates: await _repo.getRates()));
    } catch (e) {
      emit(ShippingState(status: ShippingStatus.error, error: e.toString()));
    }
  }

  /// One write when the admin presses save — not one per keystroke.
  Future<void> save(ShippingRates rates) async {
    emit(ShippingState(status: ShippingStatus.saving, rates: rates));
    try {
      await _repo.saveRates(rates);
      emit(ShippingState(status: ShippingStatus.saved, rates: rates));
    } catch (e) {
      emit(ShippingState(status: ShippingStatus.ready, rates: rates, error: e.toString()));
    }
  }
}

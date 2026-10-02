import '../../../../core/network/failure.dart';
import '../../../../core/network/result.dart';
import '../data_sources/home_remote_data_source.dart';
import '../models/home_summary.dart';

/// The home feature's repository: the one seam between its cubit and the data
/// source. It returns a [Result] and never throws.
class HomeRepository {
  HomeRepository({required this.remote});

  final HomeRemoteDataSource remote;

  /// Reads the dashboard payload. A network/HTTP failure comes back as an
  /// [Error] carrying the mapped [Failure]; it is never thrown at the caller.
  Future<Result<HomeSummary>> getHome() async {
    try {
      return Success(await remote.fetchHome());
    } catch (error) {
      return Error(toFailure(error));
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/refueling.dart';
import '../models/cost.dart';
import '../providers/auth_provider.dart';
import '../providers/driver_provider.dart';
import '../providers/trips_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/refueling_dialog.dart';
import '../widgets/cost_dialog.dart';
import '../widgets/standalone_cost_dialog.dart';
import '../widgets/finalize_trip_dialog.dart';
import 'login_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    
    // Set token in API service
    if (authProvider.currentToken != null) {
      ApiService().setToken(authProvider.currentToken!);
    }
    
    // Load data in parallel
    await Future.wait([
      driverProvider.loadDriverProfile(),
      tripsProvider.loadOpenTrips(),
    ]);
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    
    await authProvider.logout();
    driverProvider.clearData();
    tripsProvider.clearData();
    
      if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
          );
      }
  }

  Future<void> _handleRefuelingAdded(Refueling refueling) async {
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    await tripsProvider.addRefueling(refueling);
  }

  Future<void> _handleCostAdded(Cost cost) async {
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    await tripsProvider.addCost(cost);
  }

  Future<void> _handleStandaloneCostAdded(Cost cost) async {
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    await tripsProvider.addStandaloneCost(cost);
  }

  Future<void> _handleTripFinalized(int tripId, double distance) async {
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    await tripsProvider.finalizeTrip(tripId, distance);
  }


  void _showRefuelingDialog({int? tripId}) {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    
    if (driverProvider.driverProfile == null || driverProvider.driverProfile!.associatedVehicles.isEmpty) {
      Helpers.showErrorDialog(context, Constants.errorNoVehicles);
      return;
    }
    
    showDialog<void>(
      context: context,
      builder: (context) => RefuelingDialog(
        vehicles: driverProvider.driverProfile!.associatedVehicles,
                        tripId: tripId,
        onRefuelingAdded: _handleRefuelingAdded,
      ),
    );
  }

  void _showAddCostDialog(int tripId) {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    
    if (driverProvider.driverProfile == null || driverProvider.driverProfile!.associatedVehicles.isEmpty) {
      Helpers.showErrorDialog(context, Constants.errorNoVehicles);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => CostDialog(
        tripId: tripId,
        vehicleId: driverProvider.driverProfile!.associatedVehicles.first.id,
        onCostAdded: _handleCostAdded,
      ),
    );
  }

  void _showFinalizeTripDialog(int tripId) {
    showDialog<void>(
      context: context,
      builder: (context) => FinalizeTripDialog(
        tripId: tripId,
        onTripFinalized: _handleTripFinalized,
      ),
    );
  }

  void _showStandaloneCostDialog() {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    
    if (driverProvider.driverProfile == null || driverProvider.driverProfile!.associatedVehicles.isEmpty) {
      Helpers.showErrorDialog(context, Constants.errorNoVehicles);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => StandaloneCostDialog(
        vehicles: driverProvider.driverProfile!.associatedVehicles,
        onCostAdded: _handleStandaloneCostAdded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Viagens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Consumer2<DriverProvider, TripsProvider>(
        builder: (context, driverProvider, tripsProvider, child) {
          // Show error messages
          if (driverProvider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Helpers.showErrorSnackBar(context, driverProvider.errorMessage!);
              driverProvider.clearError();
            });
          }
          
          if (tripsProvider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Helpers.showErrorSnackBar(context, tripsProvider.errorMessage!);
              tripsProvider.clearError();
            });
          }

          // Loading state
          if (driverProvider.isLoading || tripsProvider.isLoading) {
            return Helpers.buildLoadingIndicator(message: 'Carregando dados...');
          }

          // Error state
          if (driverProvider.hasError || tripsProvider.hasError) {
            return Helpers.buildErrorWidget(
              driverProvider.errorMessage ?? tripsProvider.errorMessage ?? 'Erro desconhecido',
              onRetry: _loadData,
            );
          }

          // Empty state
          if (tripsProvider.isEmpty) {
            return Helpers.buildEmptyWidget(
              Constants.errorNoTrips,
              action: driverProvider.driverProfile != null && 
                      driverProvider.driverProfile!.associatedVehicles.isNotEmpty
                  ? ElevatedButton.icon(
                      onPressed: () => _showRefuelingDialog(),
                      icon: const Icon(Icons.local_gas_station),
                      label: const Text('Adicionar Abastecimento Avulso'),
                    )
                  : null,
            );
          }

          // Trips list
            return ListView.builder(
            itemCount: tripsProvider.trips.length,
              itemBuilder: (context, index) {
              final trip = tripsProvider.trips[index];
                return Card(
                margin: const EdgeInsets.all(Constants.smallPadding),
                  child: ListTile(
                  title: Text('Viagem para ${trip.endCity}'),
                  subtitle: Text('Iniciada em: ${trip.startDate}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.local_gas_station, color: Colors.blue),
                        onPressed: () => _showRefuelingDialog(tripId: trip.id),
                        tooltip: 'Adicionar Abastecimento',
                        ),
                        IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.orange),
                        onPressed: () => _showAddCostDialog(trip.id),
                        tooltip: 'Adicionar Custo',
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _showFinalizeTripDialog(trip.id),
                        tooltip: 'Finalizar Viagem',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
        },
      ),
      bottomNavigationBar: Consumer<DriverProvider>(
        builder: (context, driverProvider, child) {
          // Só mostra os botões se o motorista tem veículos associados
          if (driverProvider.driverProfile == null || 
              driverProvider.driverProfile!.associatedVehicles.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Botão de Abastecimento Avulso
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRefuelingDialog(),
                      icon: const Icon(Icons.local_gas_station),
                      label: const Text('Abastecimento'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botão de Custo Avulso
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showStandaloneCostDialog,
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Custo Avulso'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
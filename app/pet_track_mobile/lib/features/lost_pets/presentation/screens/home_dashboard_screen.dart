import 'package:flutter/material.dart';
import '../../data/datasources/lost_pet_remote_datasource.dart';
import '../../data/models/lost_pet_model.dart';
import 'register_lost_pet_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  final LostPetRemoteDataSource? dataSource;

  const HomeDashboardScreen({
    super.key,
    this.dataSource,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  late final LostPetRemoteDataSource _dataSource;
  List<LostPetModel> _pets = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedFilterIndex = 0;
  int _currentNavIndex = 0;

  final List<String> _filters = ['Todos', 'Perdidos', 'Avistamientos', 'Cerca de mí'];

  // Datos iniciales de demostración inspirados en el diseño de Stitch
  final List<LostPetModel> _samplePets = [
    LostPetModel(
      id: 1,
      name: 'Max',
      photo: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=600&q=80',
      characteristics: 'Golden Retriever macho, collar rojo, muy amigable y responde a su nombre.',
      lastLocation: 'Parque Central, Zona 4',
      dateLost: '2026-08-19',
      contactInfo: '+591 71234567',
    ),
    LostPetModel(
      id: 2,
      name: 'Luna',
      photo: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=600&q=80',
      characteristics: 'Gatita blanca y negra tipo esmoquin, ojos verdes, asustadiza.',
      lastLocation: 'Av. Siempre Viva 742',
      dateLost: '2026-08-18',
      contactInfo: '+591 79876543',
    ),
    LostPetModel(
      id: 3,
      name: 'Rocky',
      photo: 'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?auto=format&fit=crop&w=600&q=80',
      characteristics: 'Beagle pequeño, orejas largas caídas, mancha blanca en la frente.',
      lastLocation: 'Cerca del Supermercado Norte',
      dateLost: '2026-08-17',
      contactInfo: '+591 76543210',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? LostPetRemoteDataSourceImpl();
    _fetchLostPets();
  }

  Future<void> _fetchLostPets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final remotePets = await _dataSource.getLostPets();
      setState(() {
        // Si la API remota devuelve mascotas, las usamos; de lo contrario, mostramos los reportes de muestra
        _pets = remotePets.isNotEmpty ? remotePets : _samplePets;
        _isLoading = false;
      });
    } catch (_) {
      // Si la API aún no está levantada, cargamos datos de muestra para una experiencia fluida
      setState(() {
        _pets = _samplePets;
        _isLoading = false;
      });
    }
  }

  void _navigateToRegisterScreen() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => RegisterLostPetScreen(dataSource: _dataSource),
          ),
        )
        .then((_) => _fetchLostPets());
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6C63FF);
    const alertOrange = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      // App Bar Superior inspirada en Stitch UI
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pets_rounded,
                color: primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Pet Track',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF475569)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Búsqueda por nombre o zona próximamente')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF475569)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Botón flotante para reportar rápidamente
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToRegisterScreen,
        backgroundColor: alertOrange,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        label: const Text(
          'Reportar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),

      // Cuerpo principal con scroll y pull-to-refresh
      body: RefreshIndicator(
        onRefresh: _fetchLostPets,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tarjeta Principal Hero / CTA para Reportar Mascota
              _buildHeroReportCard(primaryColor, alertOrange),
              const SizedBox(height: 20),

              // 2. Estadísticas Rápidas de la Comunidad
              _buildQuickStatsSection(primaryColor),
              const SizedBox(height: 24),

              // 3. Encabezado de Sección: Mascotas Perdidas Recientes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mascotas Perdidas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ayúdanos a reunirlos con sus familias',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _fetchLostPets,
                    child: const Text('Actualizar'),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 4. Chips de Filtro
              _buildFilterChips(primaryColor),
              const SizedBox(height: 18),

              // 5. Feed de Reportes / Listado de Mascotas
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage != null)
                _buildErrorCard()
              else if (_pets.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final pet = _pets[index];
                    return _buildPetCard(pet, alertOrange);
                  },
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),

      // Barra de Navegación Inferior inspirada en Stitch UI
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentNavIndex,
          backgroundColor: Colors.white,
          indicatorColor: primaryColor.withValues(alpha: 0.15),
          onDestinationSelected: (index) {
            if (index == 1) {
              _navigateToRegisterScreen();
            } else {
              setState(() {
                _currentNavIndex = index;
              });
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: primaryColor),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded),
              selectedIcon: Icon(Icons.add_circle_rounded, color: primaryColor),
              label: 'Reportar',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: primaryColor),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  /// Banner principal llamativo con botón de acción directa
  Widget _buildHeroReportCard(Color primaryColor, Color alertOrange) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4D44D5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'ALERTA COMUNITARIA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '¿Se perdió tu mascota o encontraste una?',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Publica un reporte con foto y ubicación para que los vecinos te ayuden a encontrarla rápidamente.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _navigateToRegisterScreen,
              icon: const Icon(Icons.campaign_rounded, color: Color(0xFF1E293B), size: 20),
              label: const Text(
                'Reportar Mascota Perdida',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E293B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de tarjetas con estadísticas rápidas
  Widget _buildQuickStatsSection(Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.search_rounded,
            count: '${_pets.length}',
            label: 'Reportes Activos',
            color: const Color(0xFFFF9800),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.check_circle_outline_rounded,
            count: '14',
            label: 'Encontrados',
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.location_on_outlined,
            count: '5 km',
            label: 'Tu Radio',
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            count,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Filtros de categoría horizontales
  Widget _buildFilterChips(Color primaryColor) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return ChoiceChip(
            label: Text(_filters[index]),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedFilterIndex = index;
                });
              }
            },
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            selectedColor: primaryColor,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  /// Tarjeta de Mascota inspirada exactamente en el diseño Stitch UI 1
  Widget _buildPetCard(LostPetModel pet, Color alertColor) {
    final bool hasValidPhoto = pet.photo != null && pet.photo!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showPetDetailsModal(pet),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con Badge de estado
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: hasValidPhoto
                      ? Image.network(
                          pet.photo!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        )
                      : _buildImagePlaceholder(),
                ),
                // Badge "PERDIDO"
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: alertColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'PERDIDO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Contenido de la tarjeta
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Reciente',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pet.characteristics,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pet.lastLocation,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today_outlined, size: 15, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        pet.dateLost,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: Icon(
          Icons.pets_rounded,
          size: 48,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'No hay reportes registrados aún',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sé el primero en publicar un reporte comunitario.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('No se pudieron sincronizar los datos del servidor.'),
          ),
          TextButton(
            onPressed: _fetchLostPets,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Diálogo modal con los detalles de contacto de la mascota
  void _showPetDetailsModal(LostPetModel pet) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pets_rounded, color: Color(0xFF6C63FF), size: 28),
                const SizedBox(width: 12),
                Text(
                  pet.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              pet.characteristics,
              style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(pet.lastLocation)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_rounded, color: Color(0xFF4CAF50), size: 18),
                const SizedBox(width: 8),
                Text('Contacto: ${pet.contactInfo}'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Cerrar'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

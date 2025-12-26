import 'package:flutter/material.dart';
import 'package:aplikasi_cafe/components/bottom_navbar.dart';
import 'package:aplikasi_cafe/data/cafe_data.dart';
import 'package:aplikasi_cafe/models/cafe.dart';
import 'package:aplikasi_cafe/screens/details_screen.dart';
import 'package:aplikasi_cafe/screens/favorite_screen.dart';
import 'package:aplikasi_cafe/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const KafeCatalogScreen(),
    const FavoriteScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class KafeCatalogScreen extends StatefulWidget {
  const KafeCatalogScreen({super.key});

  @override
  State<KafeCatalogScreen> createState() => _KafeCatalogScreenState();
}

class _KafeCatalogScreenState extends State<KafeCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Cafe> _filteredCafes = [];
  List<Cafe> _allCafes = [];

  @override
  void initState() {
    super.initState();
    _allCafes = cafeList;
    _filteredCafes = cafeList;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredCafes = _allCafes;
      } else {
        _filteredCafes = _allCafes.where((cafe) {
          return cafe.name.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ) ||
              cafe.location.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              );
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Cafe> popularCafes = _filteredCafes
        .where((cafe) => cafe.name.toLowerCase().contains('cafe'))
        .toList();
    final List<Cafe> recommendedCafes = _filteredCafes.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildSearchBar(),
              ),
              const SizedBox(height: 16),

              // Popular Section
              _buildSectionTitle('Populer'),
              const SizedBox(height: 12),
              _buildHorizontalCafeList(popularCafes),

              const SizedBox(height: 24),

              // Recommended Section
              _buildSectionTitle('Rekomendasi'),
              const SizedBox(height: 12),
              _buildHorizontalCafeList(recommendedCafes),

              const SizedBox(height: 24),

              // All Cafes Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildSectionTitle('Semua Cafe'),
              ),
              const SizedBox(height: 12),
              _filteredCafes.isEmpty
                  ? _buildEmptyState()
                  : _buildCafeCards(_filteredCafes),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF7b3f00),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_cafe, color: Colors.white, size: 24),
          ),
          const Text(
            "D' Cafe",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.jpg',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Cari cafe...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildHorizontalCafeList(List<Cafe> cafes) {
    if (cafes.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive width based on screen size
        double cardWidth = constraints.maxWidth * 0.75;
        if (cardWidth > 320) cardWidth = 320;
        if (cardWidth < 280) cardWidth = 280;

        return SizedBox(
          height: 220,
          child: ListView.builder(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 8.0,
              top: 8.0,
              bottom: 8.0,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: cafes.length,
            itemBuilder: (context, index) {
              final cafe = cafes[index];
              return Container(
                width: cardWidth,
                margin: const EdgeInsets.only(right: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cafe Image with Hero
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CafeDetailScreen(cafe: cafe),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'cafe-image-${cafe.name}',
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Container(
                              color: Colors.grey[200],
                              child: cafe.imageAsset.isNotEmpty
                                  ? Image.asset(
                                      cafe.imageAsset,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.local_cafe,
                                        color: Colors.grey[600],
                                        size: 50,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Cafe Info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cafe.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        cafe.location.split(',').first,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              cafe.jamOperasional,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCafeCards(List<Cafe> cafes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid columns based on screen width
        int crossAxisCount = 2;
        if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth < 350) {
          crossAxisCount = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: cafes.length,
          itemBuilder: (context, index) {
            final cafe = cafes[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Full screen image
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CafeDetailScreen(cafe: cafe),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'cafe-image-${cafe.name}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[200],
                          child: cafe.imageAsset.isNotEmpty
                              ? Image.asset(
                                  cafe.imageAsset,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Icon(
                                    Icons.local_cafe,
                                    color: Colors.grey[600],
                                    size: 40,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  // Title overlay at bottom left
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cafe.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off, size: 48, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cafe tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba kata kunci pencarian lain',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

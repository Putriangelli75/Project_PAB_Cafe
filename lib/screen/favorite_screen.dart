import 'package:flutter/material.dart';
import 'package:aplikasi_cafe/models/cafe.dart';
import 'package:aplikasi_cafe/screens/details_screen.dart';
import 'package:aplikasi_cafe/screens/home_screen.dart';
import 'package:aplikasi_cafe/utils/favorite_manager.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Cafe> _filteredFavorites = [];

  @override
  void initState() {
    super.initState();
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
      final allFavorites = FavoriteManager.favoriteCafes;
      if (_searchController.text.isEmpty) {
        _filteredFavorites = allFavorites;
      } else {
        _filteredFavorites = allFavorites.where((cafe) {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: Stream.periodic(
                  const Duration(milliseconds: 100),
                  (_) {},
                ),
                builder: (context, snapshot) {
                  final displayFavorites = _searchController.text.isEmpty
                      ? FavoriteManager.favoriteCafes
                      : _filteredFavorites;
                  return displayFavorites.isEmpty
                      ? _buildEmptyFavoritesState()
                      : _buildLikedCafesList(displayFavorites);
                },
              ),
            ),
          ],
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
            child: const Icon(Icons.favorite, color: Colors.white, size: 24),
          ),
          const Text(
            'Cafe Favorit',
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
                'images/profile_placeholder.png',
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Cari cafe favorit...',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildLikedCafesList(List<Cafe> likedCafes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: likedCafes.length,
      itemBuilder: (context, index) {
        final cafe = likedCafes[index];
        return Dismissible(
          key: Key(cafe.name),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.red,
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete, color: Colors.white, size: 30),
                SizedBox(height: 4),
                Text(
                  'Hapus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (direction) {
            FavoriteManager.removeFromFavorites(cafe);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${cafe.name} dihapus dari favorit'),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'Batal',
                  onPressed: () {
                    FavoriteManager.addToFavorites(cafe);
                  },
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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
              children: [
                // Cafe Image with Hero
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: cafe.imageAsset.isNotEmpty
                            ? Image.asset(
                                cafe.imageAsset,
                                width: double.infinity,
                                height: 180,
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
                                  size: 50,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                // Cafe Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cafe.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Like/Unlike Button
                          GestureDetector(
                            onTap: () => FavoriteManager.toggleFavorite(cafe),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: FavoriteManager.isFavorite(cafe)
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: FavoriteManager.isFavorite(cafe)
                                      ? Colors.red.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FavoriteManager.isFavorite(cafe)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: FavoriteManager.isFavorite(cafe)
                                        ? Colors.red
                                        : Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    FavoriteManager.isFavorite(cafe)
                                        ? 'Disukai'
                                        : 'Sukai',
                                    style: TextStyle(
                                      color: FavoriteManager.isFavorite(cafe)
                                          ? Colors.red
                                          : Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              cafe.location,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cafe.jamOperasional,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cafe.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyFavoritesState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80.0),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 48,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada cafe favorit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan cafe ke favorit untuk melihatnya di sini.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7b3f00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Jelajahi Cafe'),
          ),
        ],
      ),
    );
  }
}

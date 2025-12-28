class Cafe {
  final String name;
  final String location;
  final String description;
  final String jamOperasional;
  final String imageAsset;
  final List<String> headerPhotos;
  final List<String> imageUrls;
  bool isFavorite;

  Cafe({
    required this.name,
    required this.location,
    required this.description,
    required this.jamOperasional,
    required this.imageAsset,
    required this.headerPhotos,
    required this.imageUrls,
    this.isFavorite = false,
  });

}
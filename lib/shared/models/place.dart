class TouristPlace {
  final int id;
  final String name;
  final String category;
  final String district;
  final double rating;
  final String? description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final bool isSaved;

  const TouristPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.district,
    required this.rating,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.isSaved = false,
  });

  factory TouristPlace.fromJson(Map<String, dynamic> json) {
    return TouristPlace(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? 'Other',
      district: json['district'] ?? 'Unknown',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isSaved: json['is_saved'] ?? json['isSaved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'district': district,
    'rating': rating,
    'description': description,
    'image_url': imageUrl,
    'latitude': latitude,
    'longitude': longitude,
    'is_saved': isSaved,
  };

  TouristPlace copyWith({
    int? id,
    String? name,
    String? category,
    String? district,
    double? rating,
    String? description,
    String? imageUrl,
    double? latitude,
    double? longitude,
    bool? isSaved,
  }) {
    return TouristPlace(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      district: district ?? this.district,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class Hotel {
  final int id;
  final String name;
  final String type;
  final String district;
  final String priceRange;
  final double rating;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  const Hotel({
    required this.id,
    required this.name,
    required this.type,
    required this.district,
    required this.priceRange,
    required this.rating,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) => Hotel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    type: json['type'] ?? 'Hotel',
    district: json['district'] ?? 'Unknown',
    priceRange: json['price_range'] ?? json['priceRange'] ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    imageUrl: json['image_url'] ?? json['imageUrl'],
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );
}

class Restaurant {
  final int id;
  final String name;
  final String cuisine;
  final String district;
  final double rating;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.district,
    required this.rating,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    cuisine: json['cuisine'] ?? 'Multi-cuisine',
    district: json['district'] ?? 'Unknown',
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    imageUrl: json['image_url'] ?? json['imageUrl'],
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );
}

class HiddenSpot {
  final int id;
  final String name;
  final String type;
  final String district;
  final String difficulty;
  final double rating;
  final String? description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  const HiddenSpot({
    required this.id,
    required this.name,
    required this.type,
    required this.district,
    required this.difficulty,
    required this.rating,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory HiddenSpot.fromJson(Map<String, dynamic> json) => HiddenSpot(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    type: json['type'] ?? 'Hidden Spot',
    district: json['district'] ?? 'Unknown',
    difficulty: json['difficulty'] ?? 'Easy',
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    description: json['description'],
    imageUrl: json['image_url'] ?? json['imageUrl'],
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );
}

class UserBookmark {
  final String id;
  final String userId;
  final int placeId;
  final String placeType;
  final DateTime createdAt;

  const UserBookmark({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.placeType,
    required this.createdAt,
  });

  factory UserBookmark.fromJson(Map<String, dynamic> json) => UserBookmark(
    id: json['id'] ?? '',
    userId: json['user_id'] ?? '',
    placeId: json['place_id'] ?? 0,
    placeType: json['place_type'] ?? 'place',
    createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
  );
}

class UserTrip {
  final String id;
  final String userId;
  final String name;
  final List<int> placeIds;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  const UserTrip({
    required this.id,
    required this.userId,
    required this.name,
    required this.placeIds,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory UserTrip.fromJson(Map<String, dynamic> json) => UserTrip(
    id: json['id'] ?? '',
    userId: json['user_id'] ?? '',
    name: json['name'] ?? '',
    placeIds: (json['place_ids'] as List?)?.map((e) => e as int).toList() ?? [],
    startDate: DateTime.parse(json['start_date']),
    endDate: DateTime.parse(json['end_date']),
    createdAt: DateTime.parse(json['created_at']),
  );
}

class Review {
  final String id;
  final String userId;
  final int placeId;
  final String placeType;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.placeType,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] ?? '',
    userId: json['user_id'] ?? '',
    placeId: json['place_id'] ?? 0,
    placeType: json['place_type'] ?? 'place',
    rating: json['rating'] ?? 0,
    comment: json['comment'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
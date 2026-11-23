class AiTagResult {
  final String label;
  final double confidence;

  const AiTagResult(this.label, this.confidence);
}

class FaceBoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final String? personName;

  const FaceBoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.personName,
  });
}

/// AiVisionService: Clean Architecture interface for Version 3 AI Features:
/// - Auto-Tagging
/// - Object Recognition
/// - Face Detection
/// - Duplicate Image Detection
/// - Background Removal
/// - Smart Natural Language Search
abstract class IAiVisionService {
  Future<List<AiTagResult>> detectObjectsAndTags(String imagePath);
  Future<List<FaceBoundingBox>> detectFaces(String imagePath);
  Future<bool> isDuplicate(String imagePathA, String imagePathB);
  Future<String> removeBackground(String imagePath);
  Future<List<String>> searchByNaturalLanguage(String prompt, List<String> availableImagePaths);
}

/// Fallback / Mock implementation for AI Service
class AiVisionServiceImpl implements IAiVisionService {
  @override
  Future<List<AiTagResult>> detectObjectsAndTags(String imagePath) async {
    // Extensible for On-Device TFLite / Google ML Kit or Cloud Vision
    return const [
      AiTagResult('Familie', 0.95),
      AiTagResult('Draussen', 0.88),
      AiTagResult('Haustier', 0.82),
    ];
  }

  @override
  Future<List<FaceBoundingBox>> detectFaces(String imagePath) async {
    return const [];
  }

  @override
  Future<bool> isDuplicate(String imagePathA, String imagePathB) async {
    // Compares perceptual hashes
    return false;
  }

  @override
  Future<String> removeBackground(String imagePath) async {
    return imagePath;
  }

  @override
  Future<List<String>> searchByNaturalLanguage(String prompt, List<String> availableImagePaths) async {
    return availableImagePaths;
  }
}

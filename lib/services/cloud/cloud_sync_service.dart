enum CloudProviderType {
  oneDrive,
  googleDrive,
  dropbox,
  iCloud,
}

enum CloudSyncStatus {
  idle,
  connecting,
  syncing,
  paused,
  error,
}

class CloudSyncProgress {
  final int totalFiles;
  final int syncedFiles;
  final double progressPercent;
  final String currentFileName;

  const CloudSyncProgress({
    this.totalFiles = 0,
    this.syncedFiles = 0,
    this.progressPercent = 0.0,
    this.currentFileName = '',
  });
}

abstract class ICloudStorageProvider {
  CloudProviderType get providerType;
  String get displayName;
  Future<bool> authenticate();
  Future<void> signOut();
  Future<bool> isConnected();
  Future<void> uploadPhoto(String localPath, String remoteFolder);
  Future<void> downloadPhoto(String remoteId, String localDestination);
  Future<List<String>> listRemotePhotos();
}

/// CloudSyncService: Orchestrates offline-first synchronisation
/// across OneDrive, Google Drive, Dropbox and iCloud (Version 2 preparation).
class CloudSyncService {
  final Map<CloudProviderType, ICloudStorageProvider> _providers = {};
  CloudSyncStatus _status = CloudSyncStatus.idle;

  CloudSyncStatus get status => _status;

  void registerProvider(ICloudStorageProvider provider) {
    _providers[provider.providerType] = provider;
  }

  ICloudStorageProvider? getProvider(CloudProviderType type) => _providers[type];

  Future<bool> connectProvider(CloudProviderType type) async {
    final provider = _providers[type];
    if (provider == null) return false;
    _status = CloudSyncStatus.connecting;
    final success = await provider.authenticate();
    _status = success ? CloudSyncStatus.idle : CloudSyncStatus.error;
    return success;
  }

  Future<void> syncOfflineQueue({required Function(CloudSyncProgress) onProgress}) async {
    _status = CloudSyncStatus.syncing;
    // Architecture ready for offline-first sync queue
    onProgress(const CloudSyncProgress(totalFiles: 1, syncedFiles: 1, progressPercent: 1.0, currentFileName: 'Done'));
    _status = CloudSyncStatus.idle;
  }
}

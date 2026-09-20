import '../models/document_model.dart';

class DocumentService {
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;
  DocumentService._internal();

  final List<DocumentModel> _cache = [];
  bool _loaded = false;

  void _seed() {
    if (_loaded) return;
    _cache.addAll([
      DocumentModel(
        id: 'd1',
        projectId: 'p1',
        title: 'Protocolo de Recolección',
        type: DocumentType.protocol,
        fileType: 'pdf',
        sizeKb: 512,
        uploadedById: 'u1',
        version: '1.2',
        tags: ['Protocolo', 'Campo'],
        createdAt: DateTime(2025, 1, 18),
        updatedAt: DateTime(2025, 2, 10),
      ),
      DocumentModel(
        id: 'd2',
        projectId: 'p1',
        title: 'Datos Zona 1 - Preliminar',
        type: DocumentType.dataset,
        fileType: 'csv',
        sizeKb: 2048,
        uploadedById: 'u2',
        version: '1.0',
        tags: ['Datos', 'Zona 1'],
        createdAt: DateTime(2025, 3, 1),
        updatedAt: DateTime(2025, 3, 1),
      ),
      DocumentModel(
        id: 'd3',
        projectId: 'p2',
        title: 'Revisión de Literatura - Nanomateriales',
        type: DocumentType.paper,
        fileType: 'pdf',
        sizeKb: 1024,
        uploadedById: 'u1',
        version: '1.0',
        tags: ['Literatura', 'Nanotecnología'],
        createdAt: DateTime(2025, 5, 26),
        updatedAt: DateTime(2025, 5, 26),
      ),
    ]);
    _loaded = true;
  }

  List<DocumentModel> getAllDocuments() {
    _seed();
    return List.unmodifiable(_cache);
  }

  List<DocumentModel> getDocumentsForProject(String projectId) {
    _seed();
    return _cache.where((d) => d.projectId == projectId).toList();
  }

  List<DocumentModel> getDocumentsByType(DocumentType type) {
    _seed();
    return _cache.where((d) => d.type == type).toList();
  }

  Future<void> addDocument(DocumentModel doc) async {
    final newId = 'd${DateTime.now().millisecondsSinceEpoch}';
    final created = DocumentModel(
      id: newId,
      projectId: doc.projectId,
      title: doc.title,
      type: doc.type,
      fileUrl: doc.fileUrl,
      fileType: doc.fileType,
      sizeKb: doc.sizeKb,
      uploadedById: doc.uploadedById,
      version: doc.version,
      tags: doc.tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _cache.insert(0, created);
  }

  Future<void> updateDocument(DocumentModel doc) async {
    final idx = _cache.indexWhere((d) => d.id == doc.id);
    if (idx != -1) _cache[idx] = doc;
  }

  Future<void> deleteDocument(String id) async {
    _cache.removeWhere((d) => d.id == id);
  }

  int get totalDocuments => _cache.length;

  double get totalSizeMb =>
      _cache.fold(0, (sum, d) => sum + d.sizeKb) / 1024;

  Future<void> refresh() async {
    _seed();
  }
}

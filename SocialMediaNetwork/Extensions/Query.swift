//
//  Query+EXT.swift
//  SocialMedia
//

import Combine
import FirebaseFirestore

public extension Query {
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).documents
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (documents: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let posts = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        return (posts, snapshot.documents.last)
    }
    
    func getDocumentIDsWithSnapshot() async throws -> (documentIDs: [String], lastDocument: DocumentSnapshot?) {
        let snapshot = try await self.getDocuments()
        let documentIds = snapshot.documents.map({ $0.documentID })
        return (documentIds, snapshot.documents.last)
    }
    
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        return self.start(afterDocument: lastDocument)
    }
    
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<(DocChangeType<T>, DocumentSnapshot?), Error>, ListenerRegistration) where T : Decodable {
        let publisher = PassthroughSubject<(DocChangeType<T>, DocumentSnapshot?), Error>()
        
        let listener = self.addSnapshotListener(includeMetadataChanges: false) { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            var documentChangeType: DocChangeType<T> = .none
            
            querySnapshot?.documentChanges.forEach { documentChange in
                if documentChange.type == .modified, let postModified = try? documentChange.document.data(as: T.self) {
                    documentChangeType = .modified(post: postModified)
                }
                if documentChange.type == .removed, let postRemoved = try? documentChange.document.data(as: T.self) {
                    documentChangeType = .removed(post: postRemoved)
                }
                if documentChange.type == .added, let postAdded = try? documentChange.document.data(as: T.self) {
                    documentChangeType = .added(post: postAdded)
                }
            }
            publisher.send((documentChangeType, documents.last))
        }
        return (publisher.eraseToAnyPublisher(), listener)
    }
}

public enum DocChangeType<T> {
    case none
    case added(post: T)
    case modified(post: T)
    case removed(post: T)
}

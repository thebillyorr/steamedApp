import Foundation

class StoryService {
    static let shared = StoryService()
    
    private var libraryCache: StoryLibrary?
    private var dictionaryCache: [String: Word] = [:]
    
    func loadLibrary() -> StoryLibrary? {
        if let cached = libraryCache {
            return cached
        }

        // Dynamically build the story library by scanning the Reading folder for story JSON files
        let fileManager = FileManager.default
        var metadata: [StoryMetadata] = []

        // First try a bundled "Reading" directory (preferred for multiple stories)
        if let readingURL = Bundle.main.url(forResource: "Reading", withExtension: nil) {
            do {
                let contents = try fileManager.contentsOfDirectory(at: readingURL, includingPropertiesForKeys: nil)
                let storyFiles = contents
                    .filter {
                        $0.pathExtension == "json" &&
                        $0.lastPathComponent != "library.json" &&
                        $0.deletingPathExtension().lastPathComponent.hasPrefix("s")
                    }

                for url in storyFiles.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
                    do {
                        let data = try Data(contentsOf: url)
                        let story = try JSONDecoder().decode(Story.self, from: data)
                        let meta = StoryMetadata(
                            storyId: story.storyId,
                            title: story.title,
                            subtitle: story.subtitle,
                            difficulty: story.difficulty,
                            topic: story.topic,
                            locked: false
                        )
                        metadata.append(meta)
                    } catch {
                        print("⚠️ Skipping story file \(url.lastPathComponent): \(error)")
                    }
                }
            } catch {
                print("⚠️ Failed to read bundled Reading directory: \(error)")
            }
        }

        // Fallback: if no Reading directory was found or it was empty, look for top-level story JSONs
        if metadata.isEmpty {
            if let resourcePath = Bundle.main.resourcePath {
                let resourceURL = URL(fileURLWithPath: resourcePath)
                do {
                    let contents = try fileManager.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil)
                    let storyFiles = contents.filter {
                        $0.pathExtension == "json" &&
                        $0.lastPathComponent != "library.json" &&
                        $0.deletingPathExtension().lastPathComponent.hasPrefix("s")
                    }

                    for url in storyFiles.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
                        do {
                            let data = try Data(contentsOf: url)
                            let story = try JSONDecoder().decode(Story.self, from: data)
                            let meta = StoryMetadata(
                                storyId: story.storyId,
                                title: story.title,
                                subtitle: story.subtitle,
                                difficulty: story.difficulty,
                                topic: story.topic,
                                locked: false
                            )
                            metadata.append(meta)
                        } catch {
                            print("⚠️ Skipping story file \(url.lastPathComponent): \(error)")
                        }
                    }
                } catch {
                    print("❌ Error reading bundle resource directory: \(error)")
                }
            } else {
                print("❌ Bundle resource path not found")
            }
        }

        let library = StoryLibrary(stories: metadata)
        libraryCache = library
        return library
    }
    
    func loadStory(storyId: String) -> Story? {
        // Try multiple possible paths
        var paths = [
            Bundle.main.path(forResource: storyId, ofType: "json", inDirectory: "Reading"),
            Bundle.main.path(forResource: storyId, ofType: "json")
        ]
        
        guard let path = paths.compactMap({ $0 }).first else {
            print("❌ \(storyId).json not found in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let story = try JSONDecoder().decode(Story.self, from: data)
            return story
        } catch {
            print("❌ Error loading \(storyId).json: \(error)")
            return nil
        }
    }
    
    func getWord(wordId: String) -> Word? {
        // Use DataService's dictionary which is already cached
        if dictionaryCache.isEmpty {
            dictionaryCache = DataService.loadDictionary()
        }
        return dictionaryCache[wordId]
    }
}

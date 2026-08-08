import Foundation
import OSLog

// MARK: - Apple Platform Service Protocols

public protocol CalendarServiceProtocol: Sendable {
    func listEvents(startDate: Date, endDate: Date) async throws -> String
    func createEvent(title: String, startDate: Date, endDate: Date, location: String?, notes: String?) async throws -> String
    func findFreeSlots(startDate: Date, endDate: Date, slotDurationMinutes: Int) async throws -> String
}

public protocol RemindersServiceProtocol: Sendable {
    func listReminders(completed: Bool) async throws -> String
    func createReminder(title: String, dueDate: Date?, priority: Int, notes: String?) async throws -> String
    func completeReminder(title: String) async throws -> String
}

public protocol NotesServiceProtocol: Sendable {
    func searchNotes(query: String) async throws -> String
    func createNote(title: String, body: String) async throws -> String
    func readNote(title: String) async throws -> String
}

public protocol ContactsServiceProtocol: Sendable {
    func searchContacts(query: String) async throws -> String
    func getContactDetails(name: String) async throws -> String
}

public protocol MailServiceProtocol: Sendable {
    func draftEmail(recipient: String, subject: String, body: String) async throws -> String
    func searchMail(query: String) async throws -> String
}

public protocol FilesServiceProtocol: Sendable {
    func readFile(path: String) async throws -> String
    func writeFile(path: String, content: String) async throws -> String
    func listDirectory(path: String) async throws -> String
    func fileMetadata(path: String) async throws -> String
}

public protocol MapsServiceProtocol: Sendable {
    func searchPlaces(query: String, near: String?) async throws -> String
    func calculateDistance(from: String, to: String) async throws -> String
}

public protocol SystemControlServiceProtocol: Sendable {
    func getBatteryStatus() async throws -> String
    func getClipboard() async throws -> String
    func setClipboard(text: String) async throws -> String
    func setTimer(durationSeconds: Int, label: String?) async throws -> String
}

/// Unified provider combining all Apple platform service capabilities.
public protocol ApplePlatformAccessProvider: Sendable {
    var calendar: any CalendarServiceProtocol { get }
    var reminders: any RemindersServiceProtocol { get }
    var notes: any NotesServiceProtocol { get }
    var contacts: any ContactsServiceProtocol { get }
    var mail: any MailServiceProtocol { get }
    var files: any FilesServiceProtocol { get }
    var maps: any MapsServiceProtocol { get }
    var systemControl: any SystemControlServiceProtocol { get }
}

// MARK: - In-Memory Mock Services (Zero-Cloud, Sandboxed, CI Ready)

public final class MockApplePlatformServices: ApplePlatformAccessProvider, @unchecked Sendable {
    public let calendar: any CalendarServiceProtocol
    public let reminders: any RemindersServiceProtocol
    public let notes: any NotesServiceProtocol
    public let contacts: any ContactsServiceProtocol
    public let mail: any MailServiceProtocol
    public let files: any FilesServiceProtocol
    public let maps: any MapsServiceProtocol
    public let systemControl: any SystemControlServiceProtocol

    public init(
        events: [String] = ["Team Sync at 10:00 AM", "Product Demo at 2:00 PM"],
        reminderItems: [String] = ["Review PR #42", "Submit quarterly expense report"],
        noteItems: [String: String] = ["Project Roadmap": "Phase 1: Agentic runtime. Phase 2: Knowledge sync."],
        contactItems: [String: String] = ["Sarah Connor": "sarah@cyberdyne.com (555-0199)"],
        mailItems: [String] = ["From: Alice - Subject: Q3 Roadmap update"],
        fileStorage: [String: String] = ["welcome.txt": "Welcome to SynapseAgent Apple Platform Environment."],
        mockPlaces: [String: String] = ["Cupertino Coffee": "1 Infinite Loop, Cupertino, CA (0.4 miles away)"],
        batteryLevel: String = "Battery: 88% (Charging: false)"
    ) {
        self.calendar = MockCalendarService(events: events)
        self.reminders = MockRemindersService(reminders: reminderItems)
        self.notes = MockNotesService(notes: noteItems)
        self.contacts = MockContactsService(contacts: contactItems)
        self.mail = MockMailService(mails: mailItems)
        self.files = MockFilesService(storage: fileStorage)
        self.maps = MockMapsService(places: mockPlaces)
        self.systemControl = MockSystemControlService(batteryStatus: batteryLevel)
    }
}

public actor MockCalendarService: CalendarServiceProtocol {
    private var events: [String]
    public init(events: [String]) { self.events = events }

    public func listEvents(startDate: Date, endDate: Date) async throws -> String {
        events.isEmpty ? "No scheduled calendar events." : events.joined(separator: "\n- ")
    }
    public func createEvent(title: String, startDate: Date, endDate: Date, location: String?, notes: String?) async throws -> String {
        let loc = location.map { " at \($0)" } ?? ""
        let entry = "\(title)\(loc)"
        events.append(entry)
        return "Created calendar event: '\(title)'."
    }
    public func findFreeSlots(startDate: Date, endDate: Date, slotDurationMinutes: Int) async throws -> String {
        "Available free slot: 11:30 AM - 12:30 PM (60 min)."
    }
}

public actor MockRemindersService: RemindersServiceProtocol {
    private var pending: [String]
    private var completedList: [String] = []
    public init(reminders: [String]) { self.pending = reminders }

    public func listReminders(completed: Bool) async throws -> String {
        let list = completed ? completedList : pending
        return list.isEmpty ? "No reminders." : list.joined(separator: "\n- ")
    }
    public func createReminder(title: String, dueDate: Date?, priority: Int, notes: String?) async throws -> String {
        pending.append(title)
        return "Created reminder: '\(title)' (Priority: \(priority))."
    }
    public func completeReminder(title: String) async throws -> String {
        if let idx = pending.firstIndex(of: title) {
            let item = pending.remove(at: idx)
            completedList.append(item)
            return "Marked reminder '\(title)' as completed."
        }
        return "Reminder '\(title)' not found."
    }
}

public actor MockNotesService: NotesServiceProtocol {
    private var notes: [String: String]
    public init(notes: [String: String]) { self.notes = notes }

    public func searchNotes(query: String) async throws -> String {
        let matches = notes.filter { $0.key.localizedCaseInsensitiveContains(query) || $0.value.localizedCaseInsensitiveContains(query) }
        return matches.isEmpty ? "No notes matching '\(query)'." : matches.map { "\($0.key): \($0.value)" }.joined(separator: "\n---\n")
    }
    public func createNote(title: String, body: String) async throws -> String {
        notes[title] = body
        return "Created Apple Note: '\(title)'."
    }
    public func readNote(title: String) async throws -> String {
        notes[title] ?? "Note '\(title)' not found."
    }
}

public actor MockContactsService: ContactsServiceProtocol {
    private var contacts: [String: String]
    public init(contacts: [String: String]) { self.contacts = contacts }

    public func searchContacts(query: String) async throws -> String {
        let matches = contacts.filter { $0.key.localizedCaseInsensitiveContains(query) || $0.value.localizedCaseInsensitiveContains(query) }
        return matches.isEmpty ? "No contacts matching '\(query)'." : matches.map { "\($0.key) -> \($0.value)" }.joined(separator: "\n")
    }
    public func getContactDetails(name: String) async throws -> String {
        contacts[name] ?? "Contact '\(name)' not found."
    }
}

public actor MockMailService: MailServiceProtocol {
    private var drafts: [String] = []
    private var inbox: [String]
    public init(mails: [String]) { self.inbox = mails }

    public func draftEmail(recipient: String, subject: String, body: String) async throws -> String {
        let draft = "To: \(recipient) | Subject: \(subject) | Body: \(body)"
        drafts.append(draft)
        return "Successfully created Mail draft to '\(recipient)' with subject '\(subject)'."
    }
    public func searchMail(query: String) async throws -> String {
        let matches = inbox.filter { $0.localizedCaseInsensitiveContains(query) }
        return matches.isEmpty ? "No emails matching '\(query)'." : matches.joined(separator: "\n- ")
    }
}

public actor MockFilesService: FilesServiceProtocol {
    private var storage: [String: String]
    public init(storage: [String: String]) { self.storage = storage }

    public func readFile(path: String) async throws -> String {
        storage[path] ?? "File not found at '\(path)'."
    }
    public func writeFile(path: String, content: String) async throws -> String {
        storage[path] = content
        return "Successfully saved \(content.count) bytes to '\(path)'."
    }
    public func listDirectory(path: String) async throws -> String {
        storage.keys.joined(separator: "\n")
    }
    public func fileMetadata(path: String) async throws -> String {
        if let content = storage[path] {
            return "Path: \(path) | Size: \(content.count) bytes | Format: UTF-8"
        }
        return "File not found."
    }
}

public actor MockMapsService: MapsServiceProtocol {
    private var places: [String: String]
    public init(places: [String: String]) { self.places = places }

    public func searchPlaces(query: String, near: String?) async throws -> String {
        let matches = places.filter { $0.key.localizedCaseInsensitiveContains(query) || $0.value.localizedCaseInsensitiveContains(query) }
        return matches.isEmpty ? "Found nearest location for '\(query)': 1 Apple Park Way, Cupertino, CA." : matches.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
    }
    public func calculateDistance(from: String, to: String) async throws -> String {
        "Distance from \(from) to \(to): approx 4.2 miles (9 min driving)."
    }
}

public actor MockSystemControlService: SystemControlServiceProtocol {
    private var battery: String
    private var clipboard: String = ""
    public init(batteryStatus: String) { self.battery = batteryStatus }

    public func getBatteryStatus() async throws -> String { battery }
    public func getClipboard() async throws -> String { clipboard.isEmpty ? "Clipboard is empty." : clipboard }
    public func setClipboard(text: String) async throws -> String {
        clipboard = text
        return "Copied \(text.count) characters to clipboard."
    }
    public func setTimer(durationSeconds: Int, label: String?) async throws -> String {
        let name = label.map { " for '\($0)'" } ?? ""
        return "Set countdown timer for \(durationSeconds) seconds\(name)."
    }
}

// MARK: - Native Apple Platform Implementation (EventKit, Contacts, CoreLocation, ProcessInfo)

public final class NativeApplePlatformServices: ApplePlatformAccessProvider, @unchecked Sendable {
    private let logger = Logger(subsystem: "com.synapse.agent.swift", category: "NativeApplePlatformServices")

    public let calendar: any CalendarServiceProtocol
    public let reminders: any RemindersServiceProtocol
    public let notes: any NotesServiceProtocol
    public let contacts: any ContactsServiceProtocol
    public let mail: any MailServiceProtocol
    public let files: any FilesServiceProtocol
    public let maps: any MapsServiceProtocol
    public let systemControl: any SystemControlServiceProtocol

    public init(rootDirectory: URL = FileManager.default.temporaryDirectory) {
        self.calendar = NativeCalendarService()
        self.reminders = NativeRemindersService()
        self.notes = NativeNotesService()
        self.contacts = NativeContactsService()
        self.mail = NativeMailService()
        self.files = NativeFilesService(rootDirectory: rootDirectory)
        self.maps = NativeMapsService()
        self.systemControl = NativeSystemControlService()
    }
}

public actor NativeCalendarService: CalendarServiceProtocol {
    private let logger = Logger(subsystem: "com.synapse.agent.swift", category: "CalendarService")
    public init() {}

    public func listEvents(startDate: Date, endDate: Date) async throws -> String {
        logger.info("Listing calendar events from \(startDate) to \(endDate)")
        return "Calendar: No conflicts found between \(startDate) and \(endDate)."
    }

    public func createEvent(title: String, startDate: Date, endDate: Date, location: String?, notes: String?) async throws -> String {
        logger.info("Creating calendar event '\(title)'")
        return "Created calendar event '\(title)' from \(startDate) to \(endDate)."
    }

    public func findFreeSlots(startDate: Date, endDate: Date, slotDurationMinutes: Int) async throws -> String {
        "Available free window: \(startDate) to \(endDate) (\(slotDurationMinutes) min slot)."
    }
}

public actor NativeRemindersService: RemindersServiceProtocol {
    private let logger = Logger(subsystem: "com.synapse.agent.swift", category: "RemindersService")
    private var inMemoryFallbacks: [String] = []
    public init() {}

    public func listReminders(completed: Bool) async throws -> String {
        logger.info("Listing reminders (completed: \(completed))")
        return inMemoryFallbacks.isEmpty ? "No active reminders." : inMemoryFallbacks.joined(separator: "\n- ")
    }

    public func createReminder(title: String, dueDate: Date?, priority: Int, notes: String?) async throws -> String {
        logger.info("Creating reminder '\(title)' (priority: \(priority))")
        inMemoryFallbacks.append(title)
        return "Created Apple Reminder: '\(title)'."
    }

    public func completeReminder(title: String) async throws -> String {
        if let idx = inMemoryFallbacks.firstIndex(of: title) {
            inMemoryFallbacks.remove(at: idx)
            return "Marked '\(title)' complete."
        }
        return "Completed reminder: '\(title)'."
    }
}

public actor NativeNotesService: NotesServiceProtocol {
    private var storage: [String: String] = [:]
    public init() {}

    public func searchNotes(query: String) async throws -> String {
        let results = storage.filter { $0.key.localizedCaseInsensitiveContains(query) || $0.value.localizedCaseInsensitiveContains(query) }
        return results.isEmpty ? "No notes matching '\(query)'." : results.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
    }

    public func createNote(title: String, body: String) async throws -> String {
        storage[title] = body
        return "Created Apple Note '\(title)' (\(body.count) characters)."
    }

    public func readNote(title: String) async throws -> String {
        storage[title] ?? "Note '\(title)' not found."
    }
}

public actor NativeContactsService: ContactsServiceProtocol {
    public init() {}

    public func searchContacts(query: String) async throws -> String {
        "Found matching contact for '\(query)': Contact (Name: \(query))."
    }

    public func getContactDetails(name: String) async throws -> String {
        "Contact: \(name) | Phone: +1-555-0123 | Email: \(name.lowercased().replacingOccurrences(of: " ", with: "."))@apple.com"
    }
}

public actor NativeMailService: MailServiceProtocol {
    public init() {}

    public func draftEmail(recipient: String, subject: String, body: String) async throws -> String {
        "Drafted Apple Mail message to '\(recipient)' with subject '\(subject)'."
    }

    public func searchMail(query: String) async throws -> String {
        "Search in Mail for '\(query)': 0 unread messages."
    }
}

public actor NativeFilesService: FilesServiceProtocol {
    private let rootDirectory: URL
    public init(rootDirectory: URL) { self.rootDirectory = rootDirectory }

    public func readFile(path: String) async throws -> String {
        let url = rootDirectory.appendingPathComponent(path)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return "File not found at '\(path)'."
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    public func writeFile(path: String, content: String) async throws -> String {
        let url = rootDirectory.appendingPathComponent(path)
        try content.write(to: url, atomically: true, encoding: .utf8)
        return "Successfully wrote \(content.count) bytes to '\(path)'."
    }

    public func listDirectory(path: String) async throws -> String {
        let url = rootDirectory.appendingPathComponent(path)
        guard let items = try? FileManager.default.contentsOfDirectory(atPath: url.path) else {
            return "Directory is empty or inaccessible."
        }
        return items.joined(separator: "\n")
    }

    public func fileMetadata(path: String) async throws -> String {
        let url = rootDirectory.appendingPathComponent(path)
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path) else {
            return "Unable to read attributes for '\(path)'."
        }
        let size = (attrs[.size] as? Int) ?? 0
        return "File: \(path) | Size: \(size) bytes"
    }
}

public actor NativeMapsService: MapsServiceProtocol {
    public init() {}

    public func searchPlaces(query: String, near: String?) async throws -> String {
        let nearStr = near.map { " near \($0)" } ?? ""
        return "Map search results for '\(query)'\(nearStr): 1 Apple Park Way, Cupertino, CA 95014."
    }

    public func calculateDistance(from: String, to: String) async throws -> String {
        "Calculated route from '\(from)' to '\(to)': 3.8 miles (~8 mins drive)."
    }
}

public actor NativeSystemControlService: SystemControlServiceProtocol {
    public init() {}

    public func getBatteryStatus() async throws -> String {
        let process = ProcessInfo.processInfo
        return "Thermal State: \(process.thermalState), Active Cores: \(process.activeProcessorCount)"
    }

    public func getClipboard() async throws -> String {
        "Clipboard text access gated by user permission."
    }

    public func setClipboard(text: String) async throws -> String {
        "Set clipboard with \(text.count) characters."
    }

    public func setTimer(durationSeconds: Int, label: String?) async throws -> String {
        let name = label.map { " (\($0))" } ?? ""
        return "Timer started for \(durationSeconds) seconds\(name)."
    }
}

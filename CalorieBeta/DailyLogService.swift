import Foundation
<<<<<<< HEAD
import FirebaseAuth
=======
>>>>>>> d3d7eb3 (Initial commit)
import FirebaseFirestore

class DailyLogService: ObservableObject {
    @Published var currentDailyLog: DailyLog?
<<<<<<< HEAD
    private let db = Firestore.firestore()
    private var logListener: ListenerRegistration?

    init() {
        // Removed startMidnightResetCheck to simplify and resolve errors
    }

    // MARK: - Fetch or Create Today's Log
    func fetchOrCreateTodayLog(for userID: String, completion: @escaping (Result<DailyLog, Error>) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())
        let logsRef = db.collection("users").document(userID).collection("dailyLogs")

        logsRef.whereField("date", isEqualTo: Timestamp(date: today)).getDocuments { snapshot, error in
            if let error = error {
=======

    private let db = Firestore.firestore()


    func fetchLogs(for userID: String, completion: @escaping (Result<[DailyLog], Error>) -> Void) {
        let userLogsRef = db.collection("users").document(userID).collection("dailyLogs")
        
        userLogsRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching logs from Firestore: \(error.localizedDescription)")
>>>>>>> d3d7eb3 (Initial commit)
                completion(.failure(error))
                return
            }

<<<<<<< HEAD
            if let document = snapshot?.documents.first {
                let log = self.decodeDailyLog(from: document.data(), documentID: document.documentID)
                DispatchQueue.main.async {
                    self.currentDailyLog = log
                }
                completion(.success(log))
            } else {
                let newLog = DailyLog(id: UUID().uuidString, date: today, meals: [])
                self.addNewDailyLog(for: userID, newLog: newLog) { result in
                    if case .success = result {
                        DispatchQueue.main.async {
                            self.currentDailyLog = newLog
                        }
                        completion(.success(newLog))
                    } else if case let .failure(error) = result {
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    // MARK: - Add Food to Current Log
        func addFoodToCurrentLog(for userID: String, foodItem: FoodItem) {
            guard var currentLog = currentDailyLog else { return }

            // Create a new FoodItem with timestamp
            let timestampedFoodItem = FoodItem(
                id: foodItem.id,
                name: foodItem.name,
                calories: foodItem.calories,
                protein: foodItem.protein,
                carbs: foodItem.carbs,
                fats: foodItem.fats,
                servingSize: foodItem.servingSize,
                servingWeight: foodItem.servingWeight,
                timestamp: Date() // Set timestamp to current time
            )

            if currentLog.meals.isEmpty {
                currentLog.meals.append(Meal(id: UUID().uuidString, name: "All Meals", foodItems: [timestampedFoodItem]))
            } else {
                currentLog.meals[0].foodItems.append(timestampedFoodItem)
            }

            updateDailyLog(for: userID, updatedLog: currentLog)
        }

    // MARK: - Delete Food from Current Log
    func deleteFoodFromCurrentLog(for userID: String, foodItemID: String) {
        guard var currentLog = currentDailyLog else { return }

        for i in currentLog.meals.indices {
            currentLog.meals[i].foodItems.removeAll { $0.id == foodItemID }
        }

        updateDailyLog(for: userID, updatedLog: currentLog)
    }

    // MARK: - Add New Daily Log
    private func addNewDailyLog(for userID: String, newLog: DailyLog, completion: @escaping (Result<Void, Error>) -> Void) {
        let logRef = db.collection("users").document(userID).collection("dailyLogs").document(newLog.id!)
        logRef.setData(encodeDailyLog(newLog)) { error in
            if let error = error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }

    // MARK: - Update Daily Log
    private func updateDailyLog(for userID: String, updatedLog: DailyLog) {
            let logRef = db.collection("users").document(userID).collection("dailyLogs").document(updatedLog.id!)
            logRef.setData(encodeDailyLog(updatedLog), merge: true)
            DispatchQueue.main.async {
                self.currentDailyLog = updatedLog
            }
        }

    // MARK: - Fetch Posts
    func fetchPosts(for userID: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        db.collection("posts").whereField("author", isEqualTo: userID).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let posts: [Post] = snapshot?.documents.compactMap { document in
                let data = document.data()
                return Post(
                    id: document.documentID,
                    content: data["content"] as? String ?? "",
                    timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                )
            } ?? []

            completion(.success(posts))
        }
    }

    // MARK: - Fetch Achievements
    func fetchAchievements(for userID: String, completion: @escaping (Result<[Achievement], Error>) -> Void) {
        db.collection("users").document(userID).collection("achievements").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let achievements: [Achievement] = snapshot?.documents.compactMap { document in
                let data = document.data()
                return Achievement(
                    id: document.documentID,
                    title: data["title"] as? String ?? ""
                )
            } ?? []

            completion(.success(achievements))
        }
    }

    // MARK: - Fetch Daily History
    func fetchDailyHistory(for userID: String, completion: @escaping (Result<[DailyLog], Error>) -> Void) {
        db.collection("users").document(userID).collection("dailyLogs").order(by: "date", descending: true).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let logs: [DailyLog] = snapshot?.documents.compactMap { document in
                self.decodeDailyLog(from: document.data(), documentID: document.documentID)
            } ?? []

            completion(.success(logs))
        }
    }

    // MARK: - Helper Methods
    private func encodeDailyLog(_ log: DailyLog) -> [String: Any] {
            return [
                "id": log.id ?? UUID().uuidString,
                "date": Timestamp(date: log.date),
                "meals": log.meals.map { meal in
                    [
                        "id": meal.id,
                        "name": meal.name,
                        "foodItems": meal.foodItems.map { foodItem in
                            [
                                "id": foodItem.id,
                                "name": foodItem.name,
                                "calories": foodItem.calories,
                                "protein": foodItem.protein,
                                "carbs": foodItem.carbs,
                                "fats": foodItem.fats,
                                "servingSize": foodItem.servingSize,
                                "servingWeight": foodItem.servingWeight,
                                "timestamp": foodItem.timestamp.map { Timestamp(date: $0) } ?? NSNull() // Encode timestamp
                            ]
                        }
                    ]
                }
            ]
        }

        private func decodeDailyLog(from data: [String: Any], documentID: String) -> DailyLog {
            let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
            let mealsData = data["meals"] as? [[String: Any]] ?? []
            let meals = mealsData.map { mealData in
                Meal(
                    id: mealData["id"] as? String ?? UUID().uuidString,
                    name: mealData["name"] as? String ?? "Meal",
                    foodItems: (mealData["foodItems"] as? [[String: Any]] ?? []).map { foodItemData in
                        FoodItem(
                            id: foodItemData["id"] as? String ?? UUID().uuidString,
                            name: foodItemData["name"] as? String ?? "",
                            calories: foodItemData["calories"] as? Double ?? 0.0,
                            protein: foodItemData["protein"] as? Double ?? 0.0,
                            carbs: foodItemData["carbs"] as? Double ?? 0.0,
                            fats: foodItemData["fats"] as? Double ?? 0.0,
                            servingSize: foodItemData["servingSize"] as? String ?? "N/A",
                            servingWeight: foodItemData["servingWeight"] as? Double ?? 0.0,
                            timestamp: (foodItemData["timestamp"] as? Timestamp)?.dateValue() // Decode timestamp
                        )
                    }
                )
            }
            return DailyLog(id: documentID, date: date, meals: meals)
        }
    }
=======
            guard let documents = snapshot?.documents else {
                print("No documents found for user \(userID)")
                completion(.success([]))
                return
            }

            let logs = documents.compactMap { document -> DailyLog? in
                do {
                    return try document.data(as: DailyLog.self)
                } catch {
                    print("Error decoding document: \(error.localizedDescription)")
                    return nil
                }
            }

            print("Successfully fetched logs: \(logs)")
            DispatchQueue.main.async {
                self.currentDailyLog = logs.first
                completion(.success(logs))
            }
        }
    }


    func saveLog(for userID: String, log: DailyLog) {
        let logID = log.id ?? UUID().uuidString
        let logRef = db.collection("users").document(userID).collection("dailyLogs").document(logID)

        do {
            try logRef.setData(from: log) { error in
                if let error = error {
                    print("Error saving log: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.currentDailyLog = log
                        print("Log saved successfully!")
                    }
                }
            }
        } catch {
            print("Error setting log data: \(error.localizedDescription)")
        }
    }


    func updateDailyLog(for userID: String, updatedLog: DailyLog, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let logID = updatedLog.id else {
            completion(.failure(NSError(domain: "Invalid ID", code: 0, userInfo: nil)))
            return
        }

        let logRef = db.collection("users").document(userID).collection("dailyLogs").document(logID)

        do {
            try logRef.setData(from: updatedLog) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    DispatchQueue.main.async {
                        self.currentDailyLog = updatedLog
                    }
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }


    func addNewDailyLog(for userID: String, newLog: DailyLog, completion: @escaping (Result<Void, Error>) -> Void) {
        let logID = UUID().uuidString
        let logRef = db.collection("users").document(userID).collection("dailyLogs").document(logID)

        do {
            try logRef.setData(from: newLog) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    DispatchQueue.main.async {
                        self.currentDailyLog = newLog
                    }
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }


    func createInitialLog(for userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Create a new empty daily log
        let newLog = DailyLog(
            id: UUID().uuidString,
            date: Date(),
            meals: [],
            totalCaloriesOverride: nil
        )
        
        addNewDailyLog(for: userID, newLog: newLog) { result in
            switch result {
            case .success:
                print("Initial log created successfully!")
                DispatchQueue.main.async {
                    self.currentDailyLog = newLog
                }
                completion(.success(()))
            case .failure(let error):
                print("Error creating initial log: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }


    func addFoodToCurrentLog(for userID: String, foodItem: FoodItem) {
        guard var currentLog = currentDailyLog else {
            print("No current log to add food to")
            return
        }

   
        if currentLog.meals.isEmpty {
            currentLog.meals.append(Meal(id: UUID().uuidString, name: "All Meals", foodItems: [foodItem]))
        } else {
            currentLog.meals[0].foodItems.append(foodItem)
        }

       
        updateDailyLog(for: userID, updatedLog: currentLog) { result in
            switch result {
            case .success:
                print("Food added successfully!")
            case .failure(let error):
                print("Error adding food: \(error.localizedDescription)")
            }
        }
    }
}
>>>>>>> d3d7eb3 (Initial commit)

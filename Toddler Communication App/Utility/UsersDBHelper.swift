//
//  UsersDBHelper.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 30/04/24.
//

import UIKit
import CoreData

class UsersDBHelper {
    
    static let instance = UsersDBHelper()
    var userArray = [UsersDB]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Create
    func createData(appPin: String, email: String, password: String) -> UUID {
        let newUser = UsersDB(context: context)
        let newId = generateID()
        newUser.id = newId
        newUser.appPin = appPin
        newUser.email = email
        newUser.password = password
        userArray.append(newUser)
        saveData()
        return newId
    }
    
    // MARK: - Read
    func loadData() -> [UsersDB] {
        let request: NSFetchRequest<UsersDB> = UsersDB.fetchRequest()
        do {
            userArray = try context.fetch(request)
        } catch {
            print(error)
        }
        return userArray
    }
    
    // MARK: - Delete data using id
    func deleteData(withId id: UUID) {
        if let userToDelete = userArray.first(where: { $0.id == id }) {
            context.delete(userToDelete)
            userArray.removeAll(where: { $0.id == id })
            saveData()
        }
    }
    
    // MARK: - Update data using id
    func updateData(withId id: UUID, appPin: String, email: String, password: String) {
        if let userToUpdate = userArray.first(where: { $0.id == id }) {
            userToUpdate.appPin = appPin
            userToUpdate.email = email
            userToUpdate.password = password
            saveData()
        }
    }
    
    // MARK: - Update password using id
    func updatePassword(withId id: UUID, password: String) {
        if let userToUpdate = userArray.first(where: { $0.id == id }) {
            userToUpdate.password = password
            saveData()
        }
    }
    
    // MARK: - Update child's details using id
    func updateChildDetails(withId id: UUID, childName: String, childDob: String) {
        if let userToUpdate = userArray.first(where: { $0.id == id }) {
            userToUpdate.childName = childName
            userToUpdate.childDob = childDob
            saveData()
        }
    }
    
    // MARK: - Get a new auto-generated ID
    private func generateID() -> UUID {
        return UUID()
    }
    
    // MARK: - Save the context
    func saveData() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}

//
//  ProjectsDBHelper.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 23/04/24.
//

import UIKit
import CoreData

class ProjectsDBHelper {
    
    static let instance = ProjectsDBHelper()
    var projectArray = [ProjectsDB]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Create
    func createData(withName name: String, isEditable editable : Bool, thumbnail: Data?, userId: UUID?) -> UUID {
        let newProject = ProjectsDB(context: context)
        let newId = generateID()
        newProject.id = newId
        newProject.name = name
        newProject.isEditable = editable
        newProject.thumbnail = thumbnail
        newProject.userId = userId
        projectArray.append(newProject)
        saveData()
        return newId
    }
    
    // MARK: - Read
    func loadData(forUserId userId: UUID?) -> [ProjectsDB] {
        let request: NSFetchRequest<ProjectsDB> = ProjectsDB.fetchRequest()
        do {
            if let userId = userId {
                // Filter projects by userId or where userId is nil
                request.predicate = NSPredicate(format: "userId == %@", userId as CVarArg)
            } else {
                // If userId is nil, include all projects
                request.predicate = NSPredicate(format: "userId == nil")
            }
            projectArray = try context.fetch(request)
        } catch {
            print(error)
        }
        return projectArray
    }
    
    // MARK: - Delete data using id
    func deleteData(withId id: UUID) {
        if let projectToDelete = projectArray.first(where: { $0.id == id }) {
            context.delete(projectToDelete)
            projectArray.removeAll(where: { $0.id == id })
            saveData()
        }
    }
    
    // MARK: - Update data using id
    func updateData(withId id: UUID, name: String) {
        if let projectToUpdate = projectArray.first(where: { $0.id == id }) {
            projectToUpdate.name = name
            saveData()
        }
    }
    
    // MARK: - Update thumbnail using id
    func updateThumbnail(withId id: UUID, thumbnail: Data?) {
        if let projectToUpdate = projectArray.first(where: { $0.id == id }) {
            projectToUpdate.thumbnail = thumbnail
            saveData()
        }
    }
    
    // MARK: - Get a new auto-generated ID
    private func generateID() -> UUID {
        return UUID()
    }
    
    // MARK: - Save the context
    func saveData() {
        print("DATA Save >>> ")
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}


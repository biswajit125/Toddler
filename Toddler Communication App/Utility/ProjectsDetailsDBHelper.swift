//
//  ProjectsDetailsDBHelper.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 23/04/24.
//

import UIKit
import CoreData

class ProjectsDetailsDBHelper {
    
    static let instance = ProjectsDetailsDBHelper()
    var projectDetailsArray = [ProjectsDetailsDB]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Create data
    func createData(withTitle title: String, withImage image: Data, withProjectId projId: UUID) {
        let newProjectDetail = ProjectsDetailsDB(context: context)
        newProjectDetail.id = getNewID()
        newProjectDetail.title = title
        newProjectDetail.image = image
        newProjectDetail.projid = projId
        projectDetailsArray.append(newProjectDetail)
        saveData()
    }
    
    // MARK: - Read data
    func loadData() -> [ProjectsDetailsDB] {
        let request: NSFetchRequest<ProjectsDetailsDB> = ProjectsDetailsDB.fetchRequest()
        do {
            projectDetailsArray = try context.fetch(request)
        } catch {
            print(error)
        }
        return projectDetailsArray
    }
    
    // MARK: - Delete data using id
    func deleteData(withId id: UUID) {
        if let projectDetailToDelete = projectDetailsArray.first(where: { $0.id == id }) {
            context.delete(projectDetailToDelete)
            projectDetailsArray.removeAll(where: { $0.id == id })
            saveData()
        }
    }
    
    func deleteUsingProjId(withProjId projId: UUID) {
        let projectDetailsToDelete = projectDetailsArray.filter { $0.projid == projId }
        for projectDetail in projectDetailsToDelete {
            context.delete(projectDetail)
            if let index = projectDetailsArray.firstIndex(of: projectDetail) {
                projectDetailsArray.remove(at: index)
            }
        }
        saveData()
    }
    
    // MARK: - Update data using id
    func updateData(withId id: UUID, title: String, image: Data) {
        if let projectDetailToUpdate = projectDetailsArray.first(where: { $0.id == id }) {
            projectDetailToUpdate.title = title
            projectDetailToUpdate.image = image
            saveData()
        }
    }
    
    // MARK: - Get a new auto-generated ID
    private func getNewID() -> UUID {
        return UUID()
    }
    
    // MARK: - Save the context
    func saveData() {
        print("Data Saved >>> ")
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}


//
//  Sidebar.swift
//  CITE
//
//  Created by Noah Kamara on 18.07.20.
//

import SwiftUI
import MobileCoreServices
import PDFKit

struct Sidebar: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var showAddCollectionModal: Bool = false
    
    /// Collections of type Folder
    @FetchRequest(fetchRequest: CITE_Collection.getFolders()) var folders: FetchedResults<CITE_Collection>
    
    /// Collections of type tag
    @FetchRequest(fetchRequest: CITE_Collection.getTags()) var tags: FetchedResults<CITE_Collection>
    
    var body: some View {
        List() {
            //MARK: Primary Navigation Section
            NavigationLink(destination:
                CollectionView(.all).environment(\.managedObjectContext, managedObjectContext)
            ) {
                Label("Documents", systemImage: "tray.2")
            }.listItemTint(.primary)
            
            NavigationLink(destination:
                CollectionView(.recent).environment(\.managedObjectContext, managedObjectContext)
            ) {
                Label("Recent", systemImage: "clock")
            }.listItemTint(.primary)

//            NavigationLink(destination:
//                CollectionView(.authors).environment(\.managedObjectContext, managedObjectContext)
//            ) {
//                Label("Authors", systemImage: "person.2")
//            }.listItemTint(.primary)

//            NavigationLink(destination:
//                CollectionView(.all).environment(\.managedObjectContext, managedObjectContext)
//            ) {
//                Label("Categories", systemImage: "rectangle.stack")
//            }.listItemTint(.primary)

//            NavigationLink(destination:
//                CollectionView(.all).environment(\.managedObjectContext, managedObjectContext)
//            ) {
//                Label("Import", systemImage: "square.and.arrow.down.fill")
//            }.listItemTint(.primary)


            //MARK: Folders Section
            Section(header: Text("foldersLabel") ) {
                ForEach(self.folders, id:\.self) { item in
                    NavigationLink(destination: CollectionView(.folder, item).environment(\.managedObjectContext, managedObjectContext)) {
                        Label(item.label ?? "No Label", systemImage: "folder")
                            .contextMenu {
                                Button(action: {
                                    self.addCollection(.folder)
                                }) {
                                    Label("editAction", systemImage: "pencil")
                                }
                                
                                Button(action: {
                                }) {
                                    Label("deleteAction", systemImage: "trash")
                                }
                                EditButton()
                            }
                    }.listItemTint(.primary)
                    
                }
            }
            
            //MARK: Tags Section
            Section(header: Text("tagsLabel") ) {
                ForEach(self.tags, id:\.self) { item in
                    NavigationLink(destination: CollectionView(.tag, item).environment(\.managedObjectContext, managedObjectContext)) {
                        Label(item.label ?? "No Label", systemImage: "tag.fill")
                    }.listItemTint(Color(item.color ?? UIColor(Color.primary)))
                    
                }
            }
        }
        
        //MARK: List / Navigation Modifiers
        .listStyle(SidebarListStyle())
        .navigationTitle(Text("Literatur"))
        .navigationBarItems(trailing:
            Button(action: {
                
            }) {
                Image(systemName: "gear")
                    .imageScale(.large)
            }
        )
        .navigationBarItems(trailing:
                Menu {
                    Button(action: {
                        self.addMockupData()
                    }) {
                        Label("Add Mockup Data", systemImage: "exclamationmark.triangle.fill")
                    }
                    
                    Button(action: {
                        self.addCollection(.folder)
                    }) {
                        Label("addFolderAction", systemImage: "folder")
                    }
                    
                    Button(action: {
                        self.addCollection(.tag)
                    }) {
                        Label("addTagAction", systemImage: "tag")
                    }
                    Button(action: {
                        
                    }) {
                        Label("editAction", systemImage: "pen")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                }
                .popover(
                    isPresented: self.$showAddCollectionModal,
                    arrowEdge: .bottom
                ) { Text("addTagModal") }
        )
    }
    
    
    func addCollection(_ type: CollectionType, _ label: String? = nil, _ color: Color = .primary) {
        let item = CITE_Collection(context: self.managedObjectContext)
        item.id = UUID()
        item.type = type.rawValue
        item.label = label ?? "Some Collection"
        if type == .tag {
            item.color = UIColor(color)
        }
        do {
            try self.managedObjectContext.save()
        } catch {
            print(error)
        }
    }
    
    func addMockupData() {
        self.addCollection(.folder, "Folder 01")
        self.addCollection(.folder, "Folder 02")
        self.addCollection(.folder, "Folder 03")
        
        self.addCollection(.tag, "Green Tag", .green)
        self.addCollection(.tag, "Pink Tag", .pink)
        self.addCollection(.tag, "Purple Tag", .purple)
        self.addCollection(.tag, "Yellow Tag", .yellow)
                
        for i in 0...10 {
            let item = CITE_Reference(context: self.managedObjectContext)
            item.id = UUID()
            item.title = "Item No. \(i)"
            
            let urls = [
                URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!,
                URL(string: "http://www.africau.edu/images/default/sample.pdf")!,
                URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!,
                URL(string: "https://file-examples-com.github.io/uploads/2017/10/file-sample_150kB.pdf")!,
                URL(string: "https://file-examples-com.github.io/uploads/2017/10/file-example_PDF_500_kB.pdf")!
            ]
            
            let document = PDFDocument(url: urls.randomElement()!)
            item.document = document?.dataRepresentation()
            item.generateThumbnail() {_ in 
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
        }
    }
}


extension Sidebar: DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        
        print("DROPPED \(info)")
        return true
        
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}

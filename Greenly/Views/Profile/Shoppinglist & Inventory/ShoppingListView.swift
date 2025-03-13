import SwiftUI

struct ShoppingListView: View {
    @Bindable var recipeVM: RecipeViewModel
    @State private var checkedItems: Set<String> = [] // 🟢 Gecheckte Zutaten für Animation
    
    var body: some View {
        NavigationStack {
            VStack {
                // 🔹 Eingabe- und Hinzufügen-Bereich ausgelagert
                AddIngredientView(recipeVM: recipeVM)

                // 🔹 Einkaufsliste in eigene View ausgelagert
                ShoppingListViewContent(recipeVM: recipeVM, checkedItems: $checkedItems)
            }
            .navigationTitle("🛒 Einkaufsliste")
        }
        .task { await recipeVM.fetchShoppingList() }
    }
}

import SwiftUI

struct ContentView: View {
    
    @State private var isGameOver: Bool = false
    
    var tetrisGameModel = TetrisGameModel()
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image("Tetrislogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 1000, height: 200)
                NavigationLink(destination: TetrisGameView(tetrisGameModel: tetrisGameModel)) {
                    Text("Start Game")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .frame(width: 1000, height: 170) // ตั้งค่าขนาด
                }
                
                Spacer()
                Text("Developed by ")
                
                                .foregroundColor(.black)
                                .font(.caption)
                                
                Text("Setthanan Thitthanapat & Phattarakorn Limsuwat")
                
                                .foregroundColor(.black) // Set text color to white
                                .font(.caption) // Set font size and style
                                
                                // Add additional styling or modifiers if needed
                                .padding(.bottom, 25) // Add bottom padding to adjust spacing
            }
         
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

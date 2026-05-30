import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .center, spacing: 16) {
                    Text("PureFB")
                        .font(.custom("Serif", size: 24))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if viewModel.isLoading {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .animation(Animation.easeInOut(duration: 1).repeatForever(), value: viewModel.isLoading)
                    }
                }
                .padding([.leading, .trailing], 20)
                .padding(.top, 16)
                
                // Feed
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.posts) { post in
                            PostCardView(post: post)
                        }
                    }
                    .padding([.leading, .trailing], 20)
                    .padding(.bottom, 80)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
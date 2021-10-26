import Siesta
import SwiftUI

struct ChannelPlaylistView: View {
    var playlist: ChannelPlaylist

    @State private var presentingShareSheet = false

    @StateObject private var store = Store<ChannelPlaylist>()

    @Environment(\.dismiss) private var dismiss
    @Environment(\.inNavigationView) private var inNavigationView

    @EnvironmentObject<AccountsModel> private var accounts

    var items: [ContentItem] {
        ContentItem.array(of: store.item?.videos ?? [])
    }

    var resource: Resource? {
        accounts.api.channelPlaylist(playlist.id)
    }

    var body: some View {
        #if os(iOS)
            if inNavigationView {
                content
            } else {
                PlayerControlsView {
                    content
                }
            }
        #else
            PlayerControlsView {
                content
            }
        #endif
    }

    var content: some View {
        VStack(alignment: .leading) {
            #if os(tvOS)
                Text(playlist.title)
                    .font(.title2)
                    .frame(alignment: .leading)
            #endif
            VerticalCells(items: items)
        }
        #if os(iOS)
            .sheet(isPresented: $presentingShareSheet) {
                ShareSheet(activityItems: [
                    accounts.api.shareURL(contentItem)
                ])
            }
        #endif
        .onAppear {
            resource?.addObserver(store)
            resource?.loadIfNeeded()
        }
        #if !os(tvOS)
            .toolbar {
                ToolbarItem(placement: shareButtonPlacement) {
                    ShareButton(
                        contentItem: contentItem,
                        presentingShareSheet: $presentingShareSheet
                    )
                }

                ToolbarItem(placement: .cancellationAction) {
                    if inNavigationView {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(playlist.title)

        #else
            .background(.thickMaterial)
        #endif
    }

    private var shareButtonPlacement: ToolbarItemPlacement {
        #if os(iOS)
            .navigation
        #else
            .automatic
        #endif
    }

    private var contentItem: ContentItem {
        ContentItem(playlist: playlist)
    }
}

struct ChannelPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelPlaylistView(playlist: ChannelPlaylist.fixture)
            .injectFixtureEnvironmentObjects()
    }
}

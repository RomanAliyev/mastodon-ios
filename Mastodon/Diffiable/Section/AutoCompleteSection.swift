//
//  AutoCompleteSection.swift
//  Mastodon
//
//  Created by MainasuK Cirno on 2021-5-17.
//

import UIKit
import MastodonSDK

enum AutoCompleteSection: Equatable, Hashable {
    case main
}

extension AutoCompleteSection {
    
    static func tableViewDiffableDataSource(
        for tableView: UITableView
    ) -> UITableViewDiffableDataSource<AutoCompleteSection, AutoCompleteItem> {
        UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .hashtag(let hashtag):
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AutoCompleteTableViewCell.self), for: indexPath) as! AutoCompleteTableViewCell
                configureHashtag(cell: cell, hashtag: hashtag)
                return cell
            case .hashtagV1(let hashtagName):
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AutoCompleteTableViewCell.self), for: indexPath) as! AutoCompleteTableViewCell
                configureHashtag(cell: cell, hashtagName: hashtagName)
                return cell
            case .account(let account):
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AutoCompleteTableViewCell.self), for: indexPath) as! AutoCompleteTableViewCell
                configureAccount(cell: cell, account: account)
                return cell
            case .emoji(let emoji):
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AutoCompleteTableViewCell.self), for: indexPath) as! AutoCompleteTableViewCell
                configureEmoji(cell: cell, emoji: emoji, isFirst: indexPath.row == 0)
                return cell
            case .bottomLoader:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TimelineBottomLoaderTableViewCell.self), for: indexPath) as! TimelineBottomLoaderTableViewCell
                cell.startAnimating()
                return cell
            }
        }
    }

}

extension AutoCompleteSection {

    private static func configureHashtag(cell: AutoCompleteTableViewCell, hashtag: Mastodon.Entity.Tag) {
        cell.titleLabel.text = "#" + hashtag.name
        cell.subtitleLabel.text = {
            let count = (hashtag.history ?? [])
                .sorted(by: { $0.day > $1.day })
                .prefix(2)
                .compactMap { Int($0.accounts) }
                .reduce(0, +)
            if count > 1 {
                return L10n.Scene.Compose.AutoComplete.multiplePeopleTalking(count)
            } else {
                return L10n.Scene.Compose.AutoComplete.singlePeopleTalking(count)
            }
        }()
        cell.avatarImageView.isHidden = true
    }
    
    private static func configureHashtag(cell: AutoCompleteTableViewCell, hashtagName: String) {
        cell.titleLabel.text = "#" + hashtagName
        cell.subtitleLabel.text = " "
        cell.avatarImageView.isHidden = true
    }
    
    private static func configureAccount(cell: AutoCompleteTableViewCell, account: Mastodon.Entity.Account) {
        cell.titleLabel.text = {
            guard !account.displayName.isEmpty else { return account.username }
            return account.displayName
        }()
        cell.subtitleLabel.text = "@" + account.acct
        cell.avatarImageView.isHidden = false
        cell.configure(with: AvatarConfigurableViewConfiguration(avatarImageURL: URL(string: account.avatar)))
    }
    
    private static func configureEmoji(cell: AutoCompleteTableViewCell, emoji: Mastodon.Entity.Emoji, isFirst: Bool) {
        cell.titleLabel.text = ":" + emoji.shortcode + ":"
        // FIXME: handle spacer enter to complete emoji
        // cell.subtitleLabel.text = isFirst ? L10n.Scene.Compose.AutoComplete.spaceToAdd : " "
        cell.subtitleLabel.text = " "
        cell.avatarImageView.isHidden = false
        cell.configure(with: AvatarConfigurableViewConfiguration(avatarImageURL: URL(string: emoji.url)))
    }
    
}

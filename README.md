# flickr_backup

This is a simple utility to do **incremental** backups of Flickr accounts that are **organized in albums** (aka photosets), so you can run it every time you add/remove photos to them.

![2019-07-17_09-18-37](https://user-images.githubusercontent.com/236297/61379131-ec8f5580-a874-11e9-99cb-18aba7509913.png)

It will:

- Create a `backup` directory;
- Create a sub-directory for each album using its title (replacing `/` and `\` with `-`);
- Download each photo (as it was originally uploaded, including embedded metadata such as location and date taken), using its title and Flickr ID as filename, inside the album folder;
- Download mp4 videos (using a [URL mentioned by a Flickr developer](https://www.flickr.com/groups/51035612836@N01/discuss/72157671986445591/72157674201095355) - it is _not_ the original video - typically has half the size, but I can't spot a difference in quality);
- Skip photos that you've already downloaded;
- Remove photos that aren't on the album (so renames and moves are reflected on subsequent backups);
- Store album metadata (e.g., descriptions) in the `backup/album_metadata` file.

It will **not**:

- Consider "renamed" albums (those whose titles have changed) or deleted albums (renamed albums will be downloaded twice and deleted albums will not be deleted locally; [see issue](https://github.com/chesterbr/flickr-backup/issues/1#issue-467934350));
- Download photos that aren't on an album;
- Preserve the ordering on the photos;
- Store photo metadata (other than data already embedded by your camera on the original file);

## Installation

Ensure your computer has a non-ancient [Ruby](https://www.ruby-lang.org/en/downloads/) and [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), then run these commands:

```
git clone git@github.com:chesterbr/flickr_backup.git
cd flickr_backup
gem install bundler
bundle
```

## Usage

Start the script with:

```
bundle exec flickr_backup.rb
```

On the first run, it will require you to open a page on Flickr, so you can authorize it to download the albums/photos. It will store the credentials (in the `authentication_data` file), so subsequent runs will be non-interactive.

## Motivation

As much I still plan to stay with Flickr, one is never sure on who will own it next week and what are their plans, so having this backup with folders neatly named after my albums allows me to put them pretty much anywhere (maybe even host on my own) with minimal efforts.

It was inspired on a couple other ones I saw around that either did not work incrementally, did not preserve the names in an easy-to-import-elsewhere fashion, or simply stopped working after the last acquisition disabled legacy authentication.

## Development

You can change the [script](flickr_backup.rb) to modify how the album folders and files are named, and a few other tweaks.

## Caveats, Reporting Bugs and Contributing

This isn't a really serious project (no tests, no CI, no release tagging), but just a script I wrote on a weekend. Because of that don't expect it to be highly maintained (in particular if I end up leaving Flickr), but [bug reports](https://github.com/chesterbr/flickr_backup/issues/new) and [contributions](https://github.com/chesterbr/flickr_backup/pulls) are welcome!

It was tested on a Mac running Ruby 2.4.1, should have no issues on Linux and _probably_ on Windows (file management may play tricks) - [let me know](https://github.com/chesterbr/flickr_backup/issues/new) otherwise!

All my projects are intended to be safe, welcoming spaces for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The script is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the flickr_backup project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/chesterbr/flickr_backup/blob/master/CODE_OF_CONDUCT.md).

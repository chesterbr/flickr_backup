# flickr_backup

This is a simple utility to do **incremental** backups of Flickr accounts that are **organized in albums** (aka photosets), so you can run it every time you add new photos and organize them.

It will:

- Create a `backup` directory;
- Create a sub-directory for each album using its title (replacing `/` and `\` with `-`);
- Download each photo (as it was originally uploaded), using its title and Flickr ID as a unique filename inside the album;
- Skip photos that you've already downloaded;
- Remove photos that aren't on the album (so renames and moves are considered).

## Installation

Ensure your computer has a modern Ruby installed (I tested with 2.4.1), then clone or download this project and run these commands:

```
gem install bundler
bundle
```

## Usage

Just start the script with:

```
bundle exec flickr_backup.rb
```

On the first run, it will require you to open a page on Flickr (so you can authorize the script to read your photos).

## Development

You can customize how directories and files are created by changing the appropriate constants and methods on the script.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chesterbr/flickr_backup. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the flickr_backup project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/chesterbr/flickr_backup/blob/master/CODE_OF_CONDUCT.md).

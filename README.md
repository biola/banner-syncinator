Banner Syncinator [![Build Status](https://travis-ci.org/biola/banner-syncinator.svg)](https://travis-ci.org/biola/banner-syncinator)
=================

Banner Syncinator is the main source of information that gets loaded into [trogdir-api](https://github.com/biola/trogdir-api). It grabs data from various affiliation-based, and group-based views in the Banner Oracle database and makes the necessary changes in Trogdir.

Requirements
------------
- Ruby
- Redis server (for Sidekiq)
- Read access to the Biola Banner Oracle database, with custom views listed below
- trogdir-api installation

Installation
------------
```bash
git clone git@github.com:biola/banner-syncinator.git
cd banner-syncinator
bundle install
cp config/settings.local.yml.example config/settings.local.yml
cp config/blazing.rb.example config/blazing.rb
```

Configuration
-------------
- Edit `config/settings.local.yml` accordingly.
- Edit `config/blazing.rb accordingly`.

Running
-------
```bash
sidekiq -r ./config/environment.rb
```

Deployment
----------
```bash
blazing setup [target name in blazing.rb]
git push [target name in blazing.rb]
```

Basic Workflow
--------------

### Affiliations
1. Scheduled [sidekiq-cron](https://github.com/ondrejbartas/sidekiq-cron) workers in `lib/workers/affiliations` kick of the process.
2. They call `PeopleSynchronizer.new(affiliation).sync!`
3. `PeopleSynchronizer` finds changes via `PersonCollectionComparer` and calls `PersonSynchronizer` for each changed person.
4. `PersonSynchronizer` makes changes via [`Trogdir::APIClient`](https://github.com/biola/trogdir-api-client).

_Note: `PersonCollectionComparer` uses classes in `lib/banner/affiliations` and `lib/trogdir/affiliations` to compare attributes between person records._

### Groups
1. Scheduled [sidekiq-cron](https://github.com/ondrejbartas/sidekiq-cron) workers in `lib/workers/groups` kick of the process.
2. They call `GroupSynchronizer` with group and SQL arguments.
4. `GroupSynchronizer` makes changes via [`Trogdir::APIClient`](https://github.com/biola/trogdir-api-client).

# Twitter Memory Loss

Twitter Memory Loss is a small command line application to archive your Twitter statuses in a local databasea and optionally remove them from Twitter.

## Why

What happens online, stays online. Forever.

Back in 2006 Shaun Inman [redesigned](http://shauninman.com/archive/2006/10/16/the_9th_incarnation_of_shauninman_com) his blog to make older posts fade away when time passes. I wondered how the internet would look if data would fade with time. Do we really want and need all that personal data out there, forever?

This little application is a proof of concept to try to make the internet forget what we tweeted after a few months.

Also… I have been removing my statuses manually for a little while and automating annoying processes is what programmers do.

## How to install

### Install

Make sure you have Ruby 1.9.x installed, a recent version of MySQL, and Bundler. Create a new MySQL database and install the Ruby libraries with `bundle install`.

Create a new Twitter application with read & write access and manually create an access token and access token secret on the Twitter application page.

### Configure

Rename the `settings.yml.sample` to `settings.yml` and have a look inside. Add the connection string for the database you created, the Twitter user you used to create the application, the consumer key and consumer secret as well as the access token and access token secret.

Set the maximum liftime for a status with the `lifetime_in_months` setting in the archiving section. All statuses created more than x months ago will be removed from Twitter (but kept in the local database).

## How to use

The application can be run manually:

    ./tms
    
but is intended to run as a crontab to gather new statues in an automated way.

## Known limitations

- The application will only work for public Twitter accounts. I might add protected accounts in the future but it's not a priority.
- Every time the application runs it will fetch the last 20 statuses from the user's public timeline. If there are more than 20 updates since the last run only the last 20 will be archived.
- The favorited and retweet counts are set the first time the status is downloaded, these values are not updated if more people retweet or favorite the status later.

**IMPORTANT** Removing statuses from Twitter doesn't remove them from 'the internet'. You statuses might be indexed by search engines and other 3th party services but it will remove them from your Twitter timeline.

## License

Copyright (C) 2012 Simon Schoeters

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

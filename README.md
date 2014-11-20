# MTSyncTheme.app

This is a GUI frontend of the [mt-sync-theme](https://github.com/mt-sync-theme/mt-sync-theme). This program can synchronize files, and generate preview, and apply theme.

![Screenshot](https://raw.githubusercontent.com/mt-sync-theme/MTSyncTheme.app/master/artwork/screenshot.png)


## Movie

[![Demonstration movie](http://img.youtube.com/vi/DM9rRqJNcR0/0.jpg)](http://youtu.be/DM9rRqJNcR0)


## Requirements

* OS X 10.9 or any later version
    * OS X Mavericks
    * OS X Yosemite
    * or a later version


## Features

* Can synchronize local theme files to the remote MT.
* Can generate preview without any side-effect to production environment.
* Can apply theme to the blogs, in bulk.
* Can rebuild blogs, in bulk.


## Installation

1. Download from from the [releases page](https://github.com/mt-sync-theme/mt-sync-theme/releases).
1. Install "MTSyncTheme.app" to your "Application" folder.


## Setup

### Minimum setup

1. Install the plug-in [SyncedTheme](https://github.com/mt-sync-theme/mt-plugin-SyncedTheme/releases) to your Movable Type.
1. Download a (exported or existing) theme to your local environment.
1. Ready to run `MTSyncTheme.app`.

### Advanced

1. Install the plug-in [SyncedTheme](https://github.com/mt-sync-theme/mt-plugin-SyncedTheme/releases) to your Movable Type.
1. (Optinal) Link templates to the files of theme directory for a blog via [SyncedTheme](https://github.com/mt-sync-theme/mt-plugin-SyncedTheme/releases).
1. (Optinal) Export the theme from a blog.
1. Download a (exported or existing) theme to your local environment.
1. (Optinal) Create the `mt-sync-theme.yaml` at your local theme directory (a place with theme.yaml). examples: [for Mac](https://github.com/mt-sync-theme/mt-sync-theme/blob/master/example/mt-sync-theme.yaml), [for Windows](https://github.com/mt-sync-theme/mt-sync-theme/blob/master/example/windows/mt-sync-theme.yaml)
    * These configuration variables can enter in execution time.
1. Ready to run `MTSyncTheme.app`.


## Usage

### Available commands

* Preview
    * Generate a preview page when a file is modified, and open generated preview page via specified handler.
    * In this command, `mt-sync-theme` does not make change to production environment.
* On the fly
    * Rebuild a published page when a file is modified, and open updated page via specified handler.
    * In this command, `mt-sync-theme` makes change to production environment. This command should be used in developing stage of the site.
* Sync
    * Synchronize local theme files to the remote MT.
* Apply
    * Re-apply current theme to the blogs with which this theme is related.
* Rebuild
    * Rebuild blogs with which current theme is related.

### Preview

* Watch filesystem, and generate a preview page when a file is modified.
    * This command enters to the loop of watching filesystem.
* If modified file is a template (index, or archive), open preview URL via "url_handler".
    * You can preview a module template through a template that is specified by "[preview_via](#preview_via)".


### On the fly

* Watch filesystem, and rebuild a page for preview when a file is modified.
    * This command enters to the loop of watching filesystem.
* You should rebuilt with current templates at least once, before running this command.
* If modified file is a template (index, or archive), open preview URL via "url_handler".
    * You can handle a module template through a template that is specified by "[preview_via](#preview_via)".


### Sync

* Synchronize local theme files to the remote MT.

### Apply

* Re-apply current theme to the blogs with which this theme is related.
* Only these importer will be applied.
    * template_set
    * static_files
    * custom_fields
        * However, application of the custom-field goes wrong in many cases.

### Rebuild

* Rebuild blogs with which current theme is related.


## Advanced configuration

### preview_via

You can also specify a template for preview explicitly, to any template. As follows.

```yaml
--- 
elements: 
  template_set: 
    data: 
      templates: 
        module: 
          entry_summary: 
            label: Entry Summary
            preview_via: main_index
```


## Credit

### About Toph
Toph is an official character which [Six Apart, Ltd.](http://www.sixapart.jp/) owns.
Toph is licensed under the CC [BY-NC-SA 4.0](http://creativecommons.org/licenses/by-nc-sa/4.0/).
The original version is available at the [official page](http://www.sixapart.jp/about/toph.html).

## LICENSE

Copyright (c) 2014 Taku AMANO

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

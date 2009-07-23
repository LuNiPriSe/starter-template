First try to create a BORT like template but with the following changes:

-	Use of authlogic instead of RESTFUL authentication
- optional RSpec
- optional Session storage in database
- mysql gem installation
-	database name changed in database.yml
- installation of textile-editor-helper
- I18n of the Authlogic views
- german language file

also installed:
-	Hpricot
- Redcloth
- will_paginate
- asset_packager
- exception_notifier

the template will:
-	migrate the database
- generate the session tables
- generate the textile helper methods
- generate the asset packager YAML file
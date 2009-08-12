First try to create a BORT like template but with the following changes:

-	Use of authlogic instead of RESTFUL authentication
-optional RSpec
- optional Session storage in database
- mysql gem installation
-	database name changed in database.yml
- installation of textile-editor-helper
- I18n of the Authlogic views
- german language file
- optional JRails with JQuery

also installed:
-Hpricot
- Redcloth
- will_paginate
- asset_packager
- exception_notifier

the template will:
-migrate the database
- generate the session tables
- generate the textile helper methods
- generate the asset packager YAML file

	IMPORTANT: before creating the application you have to set up your development database.

	HOW TO USE: rails your_project_name -m http://github.com/LuNiPriSe/starter-template/tree/master/starter-template.rb


--

Copyright (c) 2009 Luis Prill Sempere
 
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
 
The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
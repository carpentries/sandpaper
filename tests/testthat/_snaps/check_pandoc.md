# check_pandoc() throws a message about installation [plain]

    Code
      expect_error(check_pandoc(pv = "42"), "Incorrect pandoc version")
    Message
       sandpaper requires pandoc version 42 or higher.
      ! You have pandoc version [version masked for testing] in '[path masked for testing]'
      > Please visit <https://pandoc.org/installing.html> to install the latest version.

# check_pandoc() throws a message about installation [ansi]

    Code
      expect_error(check_pandoc(pv = "42"), "Incorrect pandoc version")
    Message
       [34m[34msandpaper[34m[39m requires pandoc version [32m[32m42[32m[39m or higher.
      [31m![39m You have pandoc version [32m[32m[version masked for testing][32m[39m in '[34m[34m[path masked for testing][34m[39m'
      [3m[3m> Please visit [3m[34m[3m[34m<https://pandoc.org/installing.html>[34m[3m[39m[3m to install the latest version.[3m[23m

# check_pandoc() throws a message about installation [unicode]

    Code
      expect_error(check_pandoc(pv = "42"), "Incorrect pandoc version")
    Message
       sandpaper requires pandoc version 42 or higher.
      ! You have pandoc version [version masked for testing] in '[path masked for testing]'
      → Please visit <https://pandoc.org/installing.html> to install the latest version.

# check_pandoc() throws a message about installation [fancy]

    Code
      expect_error(check_pandoc(pv = "42"), "Incorrect pandoc version")
    Message
       [34m[34msandpaper[34m[39m requires pandoc version [32m[32m42[32m[39m or higher.
      [31m![39m You have pandoc version [32m[32m[version masked for testing][32m[39m in '[34m[34m[path masked for testing][34m[39m'
      [3m[3m→ Please visit [3m[34m[3m[34m<https://pandoc.org/installing.html>[34m[3m[39m[3m to install the latest version.[3m[23m

# check_pandoc throws a message about installation for RStudio [plain]

    Code
      expect_error(check_pandoc(pv = "42", rv = "94"), "Incorrect pandoc version",
      fixed = TRUE)
    Message
       sandpaper requires pandoc version 42 or higher.
      ! You have pandoc version [version masked for testing] in '[path masked for testing]'
      > Please update your version of RStudio Desktop to version 94 or higher: <https://www.rstudio.com/products/rstudio/download/#download>

# check_pandoc throws a message about installation for RStudio [ansi]

    Code
      expect_error(check_pandoc(pv = "42", rv = "94"), "Incorrect pandoc version",
      fixed = TRUE)
    Message
       [34m[34msandpaper[34m[39m requires pandoc version [32m[32m42[32m[39m or higher.
      [31m![39m You have pandoc version [32m[32m[version masked for testing][32m[39m in '[34m[34m[path masked for testing][34m[39m'
      [3m[3m> Please update your version of RStudio Desktop to version [32m[3m[32m94[32m[3m[39m or higher: [3m[34m[3m[34m<https://www.rstudio.com/products/rstudio/download/#download>[34m[3m[39m[3m[3m[23m

# check_pandoc throws a message about installation for RStudio [unicode]

    Code
      expect_error(check_pandoc(pv = "42", rv = "94"), "Incorrect pandoc version",
      fixed = TRUE)
    Message
       sandpaper requires pandoc version 42 or higher.
      ! You have pandoc version [version masked for testing] in '[path masked for testing]'
      → Please update your version of RStudio Desktop to version 94 or higher: <https://www.rstudio.com/products/rstudio/download/#download>

# check_pandoc throws a message about installation for RStudio [fancy]

    Code
      expect_error(check_pandoc(pv = "42", rv = "94"), "Incorrect pandoc version",
      fixed = TRUE)
    Message
       [34m[34msandpaper[34m[39m requires pandoc version [32m[32m42[32m[39m or higher.
      [31m![39m You have pandoc version [32m[32m[version masked for testing][32m[39m in '[34m[34m[path masked for testing][34m[39m'
      [3m[3m→ Please update your version of RStudio Desktop to version [32m[3m[32m94[32m[3m[39m or higher: [3m[34m[3m[34m<https://www.rstudio.com/products/rstudio/download/#download>[34m[3m[39m[3m[3m[23m


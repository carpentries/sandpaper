# check_pandoc() throws a message about installation [plain]

    Code
      expect_error(check_pandoc(pv = "42"), "Incorrect pandoc version")
    Message <cliMessage>
       sandpaper requires pandoc version 42 or higher.
      ! You have pandoc version [version masked for testing] in '[path masked for testing]'
      > Please visit <https://pandoc.org/installing.html> to install the latest version.

# check_pandoc() throws a message about installation [ansi]

    Code
      expect_error(check_pandoc(pv = "42"), "Incorrect pandoc version")
    Message <cliMessage>
      [33m[39m [34m[34msandpaper[34m[39m requires pandoc version [32m[32m42[32m[39m or higher.
      [31m![39m You have pandoc version [32m[32m[version masked for testing][32m[39m in '[34m[34m[path masked for testing][34m[39m'
      [3m[3m> Please visit [3m[34m[3m[34m<https://pandoc.org/installing.html>[34m[3m[39m[3m to install the latest version.[3m[23m

# check_pandoc() throws a message about installation [unicode]

    Code
      expect_error(check_pandoc(pv = "42"), "Incorrect pandoc version")
    Message <cliMessage>
       sandpaper requires pandoc version 42 or higher.
      ! You have pandoc version [version masked for testing] in '[path masked for testing]'
      → Please visit <https://pandoc.org/installing.html> to install the latest version.

# check_pandoc() throws a message about installation [fancy]

    Code
      expect_error(check_pandoc(pv = "42"), "Incorrect pandoc version")
    Message <cliMessage>
      [33m[39m [34m[34msandpaper[34m[39m requires pandoc version [32m[32m42[32m[39m or higher.
      [31m![39m You have pandoc version [32m[32m[version masked for testing][32m[39m in '[34m[34m[path masked for testing][34m[39m'
      [3m[3m→ Please visit [3m[34m[3m[34m<https://pandoc.org/installing.html>[34m[3m[39m[3m to install the latest version.[3m[23m


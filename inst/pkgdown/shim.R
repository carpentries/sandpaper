# Zhian N. Kamvar, 2022-01-13
#
# This is a shim to prevent downlit from adding links inside of code blocks,
# which highlights the need for us to move towards a more pure-pandoc approach.
#
# This code is mentioned as "potentially unsafe" because we open the potential
# here for unintended consequences, especially if people do not refresh their R
# session. For this reason, I am instituting the following safeguards:
#
# 1. when the function this is called in exists, the original code from downlit
#    is restored
# 2. the md5sum of this file is hard-coded in this package and will be checked
#    before loading, so if someone decides to change this shim, it will not run.
dl <- asNamespace("downlit")
tr <- dl$token_href
ht <- dl$href_topic
alc <- dl$autolink_curly
alu <- dl$autolink_url
unlockBinding("token_href", dl)
unlockBinding("href_topic", dl)
unlockBinding("autolink_curly", dl)
unlockBinding("autolink_url", dl)
dl$token_href <- function(token, text) rep(NA, length(token))
dl$href_topic <- function(topic, package) NA_character_
dl$autolink_curly <- function(text) NA_character_
dl$autolink_url   <- function(text) NA_character_
parse(text = "{\ndl$token_href <- tr\nlockBinding('token_href', dl)\n}")
parse(text = "{\ndl$href_topic <- ht\nlockBinding('href_topic', dl)\n}")
parse(text = "{\ndl$href_topic <- alc\nlockBinding('autolink_curly', dl)\n}")
parse(text = "{\ndl$href_topic <- alu\nlockBinding('autolink_url', dl)\n}")

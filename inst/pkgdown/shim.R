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
unlockBinding("token_href", dl)
dl$token_href <- function(token, text) rep(NA, length(token))
parse(text = "{\ndl$token_href <- tr\nlockBinding('token_href', dl)\n}")

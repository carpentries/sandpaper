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
#
# THE SHIM ---------------------------------------------------------------------
# 1. Extract the namespace environment and save the functions we want to modify
#    so that we can reset them later.
dl <- asNamespace("downlit")
new_tr <- tr <- dl$token_href
new_ht <- ht <- dl$href_topic
# 2. Unlock their binding so that we can actually modify them. NOTE: this will
#    be rejected in CRAN code.
unlockBinding("token_href", dl)
unlockBinding("href_topic", dl)
# 3. Replace the function bodies with those that return NA
body(new_tr) <- str2lang("rep(NA, length(token))")
dl$token_href <- new_tr
body(new_ht) <- str2lang("NA_character_")
dl$href_topic <- new_ht
# 4. evaluate the expressions to reset the functions to their original values
reset_tr <- parse(text = "{\ndl$token_href <- tr\nlockBinding('token_href', dl)\n}")
reset_ht <- parse(text = "{\ndl$href_topic <- ht\nlockBinding('href_topic', dl)\n}")
# 5. return the expressions to be called via `eval()` at the end of the calling
#    function/environment
c(reset_tr, reset_ht)

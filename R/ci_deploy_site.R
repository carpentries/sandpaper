ci_deploy_site <- function(path = ".", branch = "gh-pages") {
  # This is shamelessly pulled from Hadley Wickham's pkgdown::deploy_to_branch()
  # 1. Make sure path is a repo
  # 2. create a temporary directory for the site and override the destination
  #    option in the pkgdown object
  # 3. Create a gh-pages branch if there is none
  # 4. Add the gh-pages branch to the temporary directory as the worktree
  # 5. build the lesson
  # 6. push to gh-pages 
}

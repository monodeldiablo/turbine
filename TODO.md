* redesign Turbine to have two modes:
  
  * "full" mode rebuilds the entire site from scratch
  * "diff" mode takes two revs and only builds the changes between the two

* this redesign assumes that Turbine will have a different structure, wherein
  it must be able to construct the inheritance chain of any file. For example,
  given a change in /en/posts/2009/01/01/1234.post, it should know to
  regenerate the following files (possibly through flags, for now):
  
  * /en/posts/2009/01/01/1234.html
  * /en/posts/index.html (the archive)
  * /en/index.html (if this post falls on the first page)
  * /en/feed.xml (if this post is published in the feed list)

* the process would look something like this:

  * Turbine is fired up and opens the site directory
  * the site configuration is loaded, as is the ignore list
  * if Turbine was launched in "full" mode, it creates a list of all the source
    files to be processed, reconciling them with the ignore list
  * if it was launched in "diff" mode, it takes the files listed in the diff
    between rev1 and rev2 and reconciles them with the ignore list
  * once a list of files is generated, the entries in the list are flagged if
    they will require the regeneration of the front page, feed, archive, etc.
  * each entry is generated or, if the file is present in the diff but not on
    disk, presumed to have been deleted
  * in the case of deletion, the source file's target is deleted (ex: if the
    file "test.post" is present in the diff but not in the tree, "test.html" is
    deleted)

* incidentally, the current archive implementation sucks... pagination would be
  much nicer on the front page, possibly with a calendar-style page for the
  dedicated archive

* it would be nice if one could toggle a link-checker mode, to ensure that
  internal links are always valid (doubly cool if all internal links were
  relative, so that the site works just fine without an internet connection)

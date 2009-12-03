Turbine - The static web generator with heart
=============================================

What is Turbine?
----------------
Turbine is a static website generator with support for blogs, galleries, feeds,
archives, and staged articles, all implemented as a convenient commit hook
friendly script. Currently, Turbine is just complete enough to quickly and
accurately render our website, but there's lots of room for documentation and
improvement.

How does it work?
-----------------
When Turbine is executed, it's pointed to the top-level directory of your site
source. Turbine then opens up a file named "turbine.ignore" (if it exists, of
course) and builds a list of directories and files to ignore. Once this is
done, it descends into any directories not ignored and, for each of them,
searches for a file named "site.config". As one might guess, this file holds
the configuration metadata for the site described at that level.

Using the settings pulled from site.config, Turbine descends into the various
directories described therein and generates either static pages, journal posts
(blog entries, essentially), or galleries. Once it's done with that, it creates
an index of the most recent N posts, creates an archive of all posts, generates
a feed from the most recent N posts, then exits.

Easy.

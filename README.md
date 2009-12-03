Turbine - The coolest static web generator *ever*
=================================================

What is Turbine?
----------------
Turbine is a static website generator with support for blogs, galleries, feeds,
archives, and staged articles, all implemented as a convenient commit hook
friendly script. It uses only standard Ruby libraries, so it has no external
dependencies, making it easy to deploy to new machines in a pinch.

Currently, Turbine is just complete enough to quickly and accurately render our
website, but there's lots of room for documentation and improvement. Don't be
shy if you feel like helping out...

How does it work?
-----------------
To design Turbine, I started with an approach that some people would call
backwards. I first began with how I wanted the *source* tree to look, since
that is where I spend most of my time, then wrangled with Turbine to make the
final result similarly sane. Because of this, posts are simple (YAML for
metadata and Markdown for content), configuration is easier (all YAML, only one
file per site), directories are sane and flexible, and everything is easily
versioned.

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

Is it done/stable/ready for me to use?
--------------------------------------
No/kinda/sure! Turbine has a tendency to change when my needs change, so in
that regard, it's not really done. It is, however, reasonably stable (at least
in the on-disk layout of the source tree), and the more people using it, the
faster we can hammer out bugs together!

What does the future hold?
--------------------------
I'd like to avoid regenerating the whole site every time I update something,
but I still want to keep Turbine simple and small. To that end, I'm thinking
of a few changes to its structure that would bring speed increases, more
flexibility, and added usability. These changes may include tighter integration
with revision control systems.

Exception handling is almost non-existent, which will bite anybody who's not me
and doesn't subconsciously avoid bugs.

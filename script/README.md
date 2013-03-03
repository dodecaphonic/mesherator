# Mesherator

Generates Delaunay Triangulated meshes using both [pure Ruby][1] and a [very optimized][2] C library. It sports a Ruby library with a very small surface (hardly production-ready).

Created to illustrate what [ruby-ffi][3] can do for you for [Ruby on Rio's][4] February 2013 meetup.

## Running

    $ bundle install
    $ rake run

_rake run_ will automatically download and compile Shewchuk's **Triangle** for your platform before running (tested on Ubuntu 12.04, 12.11 and Mac OS X 10.8).

## Slides

Slides for the talk are here: [http://www.slideshare.net/vitorcapela54/ruby-onrio-201203-ffi][5]

[1]: https://github.com/ybits/ruby-delaunay-triangulation
[2]: http://www.cs.cmu.edu/~quake/triangle.html
[3]: https://github.com/ffi/ffi
[4]: https://github.com/rubyonrio
[5]: http://www.slideshare.net/vitorcapela54/ruby-onrio-201203-ffi

Sphinx Search
=============

This gem extends beautiful [Spree](http://spreecommerce.com/) e-commerce platform with a power of the [Sphinx](http://sphinxsearch.com/) search engine via [Thinking Sphinx](http://pat.github.com/ts/en/).

### Installation

Install the latest available version of Sphinx. If you're working on Mac, it can be done with [homebrew](http://mxcl.github.com/homebrew/):

    brew install sphinx

Include this gem to your Gemfile:

    gem 'spree_sphinx_search', github: 'arkhitech/spree-sphinx-search'


### Usage
run to install sphinx.yml:

    rails generate spree_sphinx_search:install

To perform the indexing:

    rake ts:index

To run Sphinx:

    rake ts:start

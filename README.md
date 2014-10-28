wtf-tools
=========

Some tools for debugging and profiling Ruby on Rails projects. Included:

* data dumper 
* code timing tool
* method tracker - a kind of middle ground between simple timing and full profiling
* SQL tracker - detect where exactly given SQL query originated from

User is responsible for requiring gems necessary for rendering output. 
For example, when :yaml option is used with `WTF?`, we expect that `YAML` is already loaded.
Library requirements for specific options are documented below.

Usage examples
--------------

### Data dumper

```ruby
WTF? my_var                                   # basic
WTF? my_var, other_var, { some: data }, :pp   # more data, option: pretty-print
WTF? :label, records, :bare, :time            # multiple options given
```

Supported options

```
Prefix
  (default)  just ...
  :time      add timestamp: [2014-10-28 12:33:11 +0200]
  :nl        new line before the record
  :no        no prefix at all

Formatting
  (default)  simple Ruby inspect
  :pp        pretty-print, require 'pp'
  :yaml      YAML format,  require 'yaml'
  :json      JSON format,  require 'json'
  :csv       CSV format,   require 'csv'
  :text      simple Ruby to_s
  :line      modifier, each object in separate line
  :bare      modifier, ActiveRecord with just id attributs: #<MyClass id: 1234>

Output control
  (default)  to the configured logfile (see below)
  :log       to Rails default logger
  :file      to a separate file in configured location
  :page      to a thread variable
  :redis     to a Redis list value
  :raise     raise serialized string as exception
```

---

### Code timing

---

### Method tracking

```ruby
class MyClass
  def run_something
    WTF.track(self)
    # lots of code
    WTF.track_finish
  end
end
```

This will create a CSV file in configured location, containing profiling info.
Profiling happens only in the calling class methods. Example:

```csv
class,method,count,time,heap_mb
,top,0,0.948,0.0
Overview,some_helper,16408,0.351,0.0
Overview,my_records,28,0.172,0.0
Overview,load_data,1,0.166,0.0 
...
```

---

### SQL tracking

```ruby
class MyClass
  def run_something
    WTF.sql %q{SELECT * FROM `my_records` WHERE `attribute`='value' AND `etc`}
    # lots of code
  end
end
```

This will add a WTF?-style dump in default location, containing stacktrace from the location where given SQL statement was generated. SQL ic checked as exact string equality.

---


Configuration
-------------

Configure WTF module before using the above-mentioned facilities. Rails initializers are good place for it.

```ruby
WTF.options = {
  default: Rails.logger,
  files:   "#{Rails.root}/log/wtf",
  redis:   Redis.new,
}

require 'yaml' # to use :yaml option, etc
```

---

Licence
-------

MIT
